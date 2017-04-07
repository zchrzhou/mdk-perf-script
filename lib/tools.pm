package tools;

require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw |
                          &run_msdk_sample
                          &transcode_calc
                          &encode_calc
                          &decode_calc
                          &vpp_calc
                      |;

use warnings;
use strict;
use Cwd;

use config;
use sample;

$| = 1;

my $verbose_flag    = $config::conf{"verbose_flag"};
my $debug_flag      = $config::conf{"debug_flag"};
my $latency_root    = $config::conf{'tools_dir'};

sub run_msdk_sample
{
    my $item            = shift;
    my $par_use_flag    = shift;
    my $input_dir       = shift;
    my $output_dir      = shift;
    my $input_cp_flag   = shift;
    my $output_flag     = shift;
    my $sample_bin_path = shift;


    my $num        = $config::test_map{$item}->[0];
    my $test_type  = $config::test_map{$item}->[1];
    my $in_fmt     = $config::test_map{$item}->[2];
    my $clip       = $config::test_map{$item}->[3];
    my $out_fmt    = $config::test_map{$item}->[4];
    my $out_ext    = $config::test_map{$item}->[5];
    my $head_args  = $config::test_map{$item}->[6];
    my $tail_args  = $config::test_map{$item}->[7];

    my @procs = ();

    if ($par_use_flag && ($test_type eq "transcode"))
    {
        print "Test --with-par is used\n";
        my $par_file_name = "multi-channel.par";
        my $par_file_path = "$output_dir/$item/$par_file_name";
        open (my $file, ">", $par_file_path) or die "can't open file $par_file_name\n";

        foreach my $i (1 .. $num)
        {
            # for windows
            my $input_file  = "$input_dir/$clip";
            my $output_file = "$output_dir/$item/$i-out.$out_ext";
            if ($input_cp_flag)
            {
                $input_file = "$input_dir/$i-$clip";
            }

            if ($output_flag == 0)
            {
                if ("$^O" eq "linux" || "$^O" eq "msys")
                {
                    $output_file = "/dev/null";
                }
            }

            my $item_cmd = sprintf("%s %s %s %s %s",
                                     $in_fmt,
                                     $input_file,
                                     $out_fmt,
                                     $output_file,
                                     $tail_args,
                                     );
            print $file  "$item_cmd\n";
        }

        close ($file);

        my $sample_path = get_sample_path($sample_bin_path, $test_type);
        my $sample_cmd = sprintf("$sample_path %s -par %s > %s",
                                 $head_args,
                                 $par_file_path,
                                 "$output_dir/$item/${item}-with-par.log");
        print "$sample_cmd\n" if ($debug_flag);
        my @cmds = (
            "$sample_cmd",
        );

        run_cmds(@cmds);

    }
    else
    {
        # start procesess for test
        foreach my $i (1 .. $num)
        {
            # start  process
            if (!defined(my $pid = fork()))
            {
                # fork returned undef, so unsuccessful
                die "Cannot fork a child: $!";
            }
            elsif ($pid == 0)
            {
                print "Start $i by child process\n";
                # for windows
                my $sample_path = get_sample_path($sample_bin_path, $test_type);
                my $input_file  = "$input_dir/$clip";
                my $output_file = "$output_dir/$item/$i-out.$out_ext";
                if ($input_cp_flag)
                {
                    $input_file = "$input_dir/$i-$clip";
                }

                if ($output_flag == 0)
                {
                    if ("$^O" eq "linux" || "$^O" eq "msys")
                    {
                        $output_file = "/dev/null";
                    }
                }

                ## For decode parameter
                if ($test_type eq "decode")
                {
                    if ($out_fmt eq "" || $out_fmt eq "-r")
                    {
                        $output_file = "";
                    }
                }

                my $sample_cmd = sprintf("$sample_path %s %s %s %s %s %s > %s",
                                         $head_args,
                                         $in_fmt,
                                         $input_file,
                                         $out_fmt,
                                         $output_file,
                                         $tail_args,
                                         "$output_dir/$item/$i-$item.log");
                ## For encode parameter
                if ($test_type eq "encode" || $test_type eq "decode" || $test_type eq "vpp")
                {
                    my $time_log = "$output_dir/$item/$i-time.log";
                    $sample_cmd = "perl $latency_root/latency.pl > $time_log ; $sample_cmd; perl $latency_root/latency.pl >> $time_log";
                }

                print "$sample_cmd\n";
                exec("$sample_cmd") || die "can't exec $sample_cmd: $!";
            }
            else
            {
                # fork returned 0 nor undef
                # so this branch is parent
                push @procs, $pid;
            }
        }

        # wait transcode finished
        print "Wait all channel play finished ...\n";
        foreach my $proc (@procs)
        {
            my $ret = waitpid($proc, 0);
            print "Completed process pid: $ret\n";
        }

    }


}


sub transcode_calc
{
    my $par_use_flag  = shift;
    my $output_dir    = shift;
    my $item          = shift;
    my $num           = shift;

    my $total_fps = 0.0;

    ## write to fps result file
    my $fps_out_name = "$output_dir/$item-fps.log";
    open (my $file_out, ">", $fps_out_name) or die "can not open input file: $fps_out_name";

    if ($par_use_flag)
    {
        my $item_log_name="$output_dir/$item/${item}-with-par.log";
        if (`ls $item_log_name`)
        {
            foreach my $i (0 .. $num - 1)
            {
                # grep processing time
                my $result_str = "*** session $i PASSED (MFX_ERR_NONE)";
                my @proc_time = `grep \"$result_str\"  $item_log_name`;

                print "@proc_time\n" if ($debug_flag);

                my $time = $proc_time[0];
                $time =~ s/.*\)//;
                $time =~ s/sec.*//;
                $time =~ s/\s+//;
                printf "$i-time: %.2f sec\n", $time if ($verbose_flag);

                # grep process frames
                my @proc_frames = `grep \"$result_str\" $item_log_name`;
                print "@proc_frames\n" if ($debug_flag);

                my $frames = $proc_frames[0];

                $frames =~ s/.*,//;
                $frames =~ s/\s+frames//;
                $frames =~ s/\s+//;
                printf "$i-frames: %d\n", $frames if ($verbose_flag);

                my $fps = $frames / $time if ($time);
                printf "$i-fps: %.2f\n", $fps if ($verbose_flag);
                printf $file_out "$item $i-fps: %.2f\n", $fps;

                $total_fps += $fps;
            }
        }
    }
    else
    {
        foreach my $i (1 .. $num)
        {
            my $item_log_name="$output_dir/$item/$i-$item.log";
            if (`ls $item_log_name`)
            {
                # grep processing time
                my $result_str = "*** session 0 PASSED (MFX_ERR_NONE)";
                my @proc_time = `grep \"$result_str\"  $item_log_name`;

                print "@proc_time\n" if ($debug_flag);

                my $time = $proc_time[0];
                $time =~ s/.*\)//;
                $time =~ s/sec.*//;
                $time =~ s/\s+//;
                printf "$i-time: %.2f sec\n", $time if ($verbose_flag);

                # grep process frames
                my @proc_frames = `grep \"$result_str\" $item_log_name`;
                print "@proc_frames\n" if ($debug_flag);

                my $frames = $proc_frames[0];

                $frames =~ s/.*,//;
                $frames =~ s/\s+frames//;
                $frames =~ s/\s+//;
                printf "$i-frames: %d\n", $frames if ($verbose_flag);

                my $fps = $frames / $time if ($time);
                printf "$i-fps: %.2f\n", $fps if ($verbose_flag);
                printf $file_out "$item $i-fps: %.2f\n", $fps;

                $total_fps += $fps;
            }
        }
    }

    close($file_out);

    my $avg_fps = sprintf "%0.2f", $total_fps / $num;

    return $avg_fps;

}

sub encode_calc
{
    my $output_dir    = shift;
    my $item          = shift;
    my $num           = shift;

    my $total_fps = 0.0;

    ## write to fps result file
    my $fps_out_name = "$output_dir/$item-fps.log";
    open (my $file_out, ">", $fps_out_name) or die "can not open input file: $fps_out_name";

    foreach my $i (1 .. $num)
    {
        my $item_log_name = "$output_dir/$item/$i-$item.log";
        my $time_log_name = "$output_dir/$item/$i-time.log";
        if (`ls $item_log_name`)
        {

            my $start_time = `cat $time_log_name | head -1`;
            my $end_time = `cat $time_log_name | tail -1`;

            my $time = $end_time - $start_time;
            printf "$i-time: %.2f sec\n", $time if ($verbose_flag);

            # grep process frames
            my @proc_frames = `grep "Frame number:" $item_log_name`;
            print "@proc_frames\n" if ($debug_flag);

            my $frames = $proc_frames[0];

            $frames =~ s/.*Frame number://;
            $frames =~ s/\s+//;
            printf "$i-frames: %d\n", $frames if ($verbose_flag);

            my $fps = $frames / $time if ($time);

            printf "$i-fps: %.2f\n", $fps if ($verbose_flag);
            printf $file_out "$item $i-fps: %.2f\n", $fps;

            $total_fps += $fps;
        }
    }

    close($file_out);

    my $avg_fps = sprintf "%0.2f", $total_fps / $num;

    return $avg_fps;

}

sub decode_calc
{
    my $output_dir    = shift;
    my $item          = shift;
    my $num           = shift;

    my $total_fps = 0.0;

    ## write to fps result file
    my $fps_out_name = "$output_dir/$item-fps.log";
    open (my $file_out, ">", $fps_out_name) or die "can not open input file: $fps_out_name";

    foreach my $i (1 .. $num)
    {
        my $item_log_name = "$output_dir/$item/$i-$item.log";
        my $time_log_name = "$output_dir/$item/$i-time.log";
        if (`ls $item_log_name`)
        {
            my @fps_lines = `grep "Frame number:" $item_log_name`;
            my @fps_info = split(/\r\s*/, $fps_lines[0]);
            my $last_fps_item = pop @fps_info;
            $last_fps_item =~ s/.*Frame\s+number:s*/Frame number:/;
            print "last fps item: $last_fps_item\n" if ($debug_flag);

            my @fps_items = split(/,\s*/, $last_fps_item);
            my $frames = $fps_items[0];

            $frames =~ s/\s*Frame\s+number:s*//;

            print "$i-frames: $frames\n" if ($verbose_flag);

            my $start_time = `cat $time_log_name | head -1`;
            my $end_time = `cat $time_log_name | tail -1`;

            my $time = $end_time - $start_time;
            printf "$i-time: %.2f sec\n", $time if ($verbose_flag);

            my $fps = $frames / $time if ($time);

            printf "$i-fps: %.2f\n", $fps if ($verbose_flag);
            printf $file_out "$item $i-fps: %.2f\n", $fps;

            $total_fps += $fps;
        }
    }

    close($file_out);

    my $avg_fps = sprintf "%0.2f", $total_fps / $num;

    return $avg_fps;
}

sub vpp_calc
{
    my $output_dir    = shift;
    my $item          = shift;
    my $num           = shift;

    my $total_fps = 0.0;

    ## write to fps result file
    my $fps_out_name = "$output_dir/$item-fps.log";
    open (my $file_out, ">", $fps_out_name) or die "can not open input file: $fps_out_name";

    foreach my $i (1 .. $num)
    {
        my $item_log_name = "$output_dir/$item/$i-$item.log";
        my $time_log_name = "$output_dir/$item/$i-time.log";
        if (`ls $item_log_name`)
        {
            my @fps_lines = `grep "Frame number:" $item_log_name`;
            my @fps_info = split(/\r\s*/, $fps_lines[0]);
            my $last_fps_item = pop @fps_info;
            print "last fps item: $last_fps_item\n" if ($debug_flag);

            my $frames = $last_fps_item;

            $frames =~ s/.*://;
            chomp $frames;

            print "$i-frames: $frames\n" if ($verbose_flag);

            my $start_time = `cat $time_log_name | head -1`;
            my $end_time = `cat $time_log_name | tail -1`;

            my $time = $end_time - $start_time;
            printf "$i-time: %.2f sec\n", $time if ($verbose_flag);

            my $fps = $frames / $time if ($time);

            printf "$i-fps: %.2f\n", $fps if ($verbose_flag);
            printf $file_out "$item $i-fps: %.2f\n", $fps;

            $total_fps += $fps;
        }
    }

    close($file_out);

    my $avg_fps = sprintf "%0.2f", $total_fps / $num;

    return $avg_fps;
}

1;
