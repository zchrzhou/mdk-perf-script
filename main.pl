#!/usr/bin/env perl

use strict;
use Cwd;
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/lib";

use config;
use sample;
use tools;
use cpu_mem;
use gpu;


#$ENV{LIBVA_DRIVERS_PATH} = "/opt/intel/mediasdk/lib64";
#$ENV{LIBVA_DRIVER_NAME}  = "iHD";

my $verbose_flag    = $config::conf{"verbose_flag"};
my $debug_flag      = $config::conf{"debug_flag"};
my $sample_bin_path = $config::conf{'sample_bin_path'};

my $steam_dir     = $config::conf{'steam_dir'};
my $input_dir     = $config::conf{"input_dir"};
my $output_dir    = $config::conf{"output_dir"};
my $input_cp_flag = $config::conf{"input_cp_flag"};
my $output_flag   = $config::conf{"output_flag"};

my $cpu_cal_flag  = $config::conf{"cpu_cal_flag"};
my $gpu_cal_flag  = $config::conf{"gpu_cal_flag"};
my $fps_cal_flag  = $config::conf{"fps_cal_flag"};
my $par_use_flag  = $config::conf{"par_use_flag"};

my $opts;
my @opts_test = ();

sub parse_opts
{
    my $result = GetOptions(
        "loop=i"       => \$opts->{'loop'},
        "all!"         => \$opts->{'all'},
        "start=i"      => \$opts->{'start'},
        "end=i"        => \$opts->{'end'},
        "test=s@"      => \@opts_test,

        "input-dir=s"  => \$input_dir,
        "output-dir=s" => \$output_dir,
        "sample-dir=s" => \$sample_bin_path,

        "with-output!"  => \$output_flag,
        "with-par!"     => \$par_use_flag,
        "with-gpu!"     => \$gpu_cal_flag,
        "with-cpu-mem!" => \$cpu_cal_flag,
        "with-fps!"     => \$fps_cal_flag,
    );

    return $result;
}

sub usage
{
    my $script_name = `basename $0`;
    chomp $script_name;

    print STDOUT << "EOF";
Performance test with Intel MSDK sample
Use example:
    $script_name [--test <item-1> --test <item-n>] [--all] [--loop n] [--start n1 --end n2]
    $script_name [--test A01 --test B1 --test C1] [--loop 2]
    $script_name [--start 1 --end 10] [--loop 2]
    $script_name [--test A01] [--loop -1]

    --loop:           loop run (-1 will run forever)
    --start|--end:    run with the range from --start to --end
                      refer to lib/config.pl -> %conf{"range_template"}
    --all:            for all test items in lib/config.pl -> %test_map
    --test:           test item, refter to lib/config.pl -> %test_map

    --input-dir:      set input file folder
    --output-dir:     set output file folder
    --sample-dir:     set sample binary folder

    --with-output:    save output file
    --with-par:       only for transcode test
    --with-gpu:       only for linux
    --with-cpu-mem:   only for linux
    --with-fps:       fps calculate
EOF
    exit 1;
}

sub pre_exec
{
    my $item = shift;
    my $num  = $config::test_map{$item}->[0];
    my $clip = $config::test_map{$item}->[3];

    my @cmds = (
        "mkdir -p $input_dir",
        "mkdir -p $output_dir/$item",
        "rm -rf   $output_dir/$item/*",
    );

    if ($input_cp_flag)
    {
        print "Input copy need ...\n";
        for my $i (1 .. $num)
        {
            my $file_clip = "$input_dir/$i-$clip";
            if (! -e $file_clip)
            {
                push  @cmds, "cp -f $steam_dir/$clip $file_clip";
            }
        }
    }
    else
    {
        my $file_clip = "$input_dir/$clip";
        if (-e $file_clip)
        {
            push  @cmds, "rm -f $file_clip";
        }
        push  @cmds, "cp -f $steam_dir/$clip $file_clip";
    }

    run_cmds(@cmds);
}

sub execute
{
    my $item = shift;

    my $num       = $config::test_map{$item}->[0];
    my $test_type = $config::test_map{$item}->[1];

    ## start CPU & MEM
    if ($cpu_cal_flag)
    {
        cpu_mem_start($test_type);
    }

    ## start GPU
    if ($gpu_cal_flag)
    {
        gpu_start();
    }

    ## msdk sample run
    run_msdk_sample($item,
                    $par_use_flag,
                    $input_dir,
                    $output_dir,
                    $input_cp_flag,
                    $output_flag,
                    $sample_bin_path);

    if ($cpu_cal_flag)
    {
        cpu_mem_end();
    }

    if ($gpu_cal_flag)
    {
        gpu_end();
    }
}

sub post_exec
{
    my $item      = shift;
    my $num       = $config::test_map{$item}->[0];
    my $test_type = $config::test_map{$item}->[1];

    my @output_list = ();

    push @output_list, "[$item:$num]";

    if ($fps_cal_flag)
    {
        if ($test_type eq "transcode")
        {
            my $avg_fps = transcode_calc($par_use_flag, $output_dir, $item, $num);

            print "AVG FPS: $avg_fps\n";
            print "Num Stream: $num\n";
            push @output_list, $avg_fps;
        }
        elsif ($test_type eq "encode")
        {
            my $avg_fps = encode_calc($output_dir, $item, $num);

            print "AVG FPS: $avg_fps\n";
            print "Num Stream: $num\n";
            push @output_list, $avg_fps;
        }
        elsif ($test_type eq "decode")
        {
            my $avg_fps = decode_calc($output_dir, $item, $num);
            print "AVG FPS: $avg_fps\n";
            print "Num Stream: $num\n";
            push @output_list, $avg_fps;
        }
        elsif ($test_type eq "vpp")
        {
            my $avg_fps = vpp_calc($output_dir, $item, $num);
            print "AVG FPS: $avg_fps\n";
            print "Num Stream: $num\n";
            push @output_list, $avg_fps;
        }
        else
        {
            print "Collect result for $test_type is not support yet\n";
        }
    }

    if ($cpu_cal_flag)
    {
        my ($cpu_usage, $mem_usage) =  cpu_mem_calc($num);

        print "CPU: $cpu_usage %\n";
        print "MEM: $mem_usage MB\n";

        push @output_list, "$cpu_usage%";
        push @output_list, "$mem_usage(MB)";
    }

    if ($gpu_cal_flag)
    {
        ## calu GPU
        my @gpu_usage = gpu_calc();

        print "GPU: @gpu_usage\n";
        push @output_list, "@gpu_usage";
    }


    ## write to result file
    my $file_out_name = "$output_dir/$item-result.log";
    open (my $file_out, ">", $file_out_name) or die "can not open input file: $file_out_name";

    print $file_out commify_series(@output_list) . "\n";

    close($file_out);

    ## saving cpu-mem result
    if ($cpu_cal_flag)
    {
        cpu_mem_save("$output_dir/$item");
    }

    ## saving gpu result
    if ($gpu_cal_flag)
    {
        gpu_save("$output_dir/$item");
    }
}

sub create_range_map
{
    my $test_start = shift;
    my $test_end   = shift;

    # clear test map
    undef %config::test_map;

    for my $test_i ($test_start .. $test_end)
    {
        my $item = sprintf($config::conf{"range_template"}->[0], $test_i);

        $config::test_map{$item} = [];
        $config::test_map{$item}->[0] = $test_i;

        for my $temp_i (1 .. @{$config::conf{"range_template"}})
        {
            $config::test_map{$item}->[$temp_i] = $config::conf{"range_template"}->[$temp_i];
        }
    }
}

sub main
{
    print "Welcome to Intel MediaSDK sample multiable process test tool.\n";
    print "Enjoy and good luck.\n";

    usage() if (@ARGV == 0 || !parse_opts());

    my @test_list = ();
    if ($opts->{'all'})
    {
         @test_list = sort keys %config::test_map;
    }
    elsif ($opts->{'start'} && $opts->{'end'})
    {
        # create range map
        print "Run under range mode\n";
        create_range_map($opts->{'start'}, $opts->{'end'});
        @test_list = sort keys %config::test_map;
    }
    else
    {
        @test_list = @opts_test;
    }

    unless (scalar(@test_list))
    {
        print "Please use [--all][--start,--end][--test]\n";
        exit 1;
    }

    my $test_loop_flag = 0;
    if (!defined($opts->{'loop'}))
    {
        $opts->{'loop'} = 1;
    }
    else
    {
        if ($opts->{'loop'} == -1)
        {
            $test_loop_flag = 1;
            print "Loop = forever\n";
        }
        else
        {
            print "Loop = $opts->{'loop'}\n";
        }
    }

    for (my $idx = 0; $test_loop_flag || $idx < $opts->{'loop'}; $idx++)
    {
        foreach my $test_item (@test_list)
        {
            if (exists($config::test_map{$test_item}))
            {
                # Create test files
                pre_exec($test_item);
                # Execute
                execute($test_item);
                # Post execute
                post_exec($test_item);
                print "Wait 2s ...\n";
                sleep 2;
            }
            else
            {
                print "Can`t run test for $test_item\n";
            }
        }
    }
}

main
