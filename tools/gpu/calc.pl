#!/usr/bin/env perl

use warnings;
use strict;
use Getopt::Std;
use Cwd;

sub help {
    print "welcome performance test tools\n";
    print "using like this: $0 <gpu.log>\n";
    print "have fun && good luck\n";
}

sub main {

    if (scalar(@ARGV) != 1) {
        help();
        exit 0;
    }

    my $gpu_file_name = $ARGV[0];
    open (my $file, "<", $gpu_file_name) or die "can't open file $gpu_file_name\n";

    my @contents = <$file>;

    my @render_list = ();
    my @video_list = ();
    my @video_e_list = ();
    my @video2_list = ();

    my $max_render  = 0.0;
    my $max_video   = 0.0;
    my $max_video_e = 0.0;
    my $max_video2  = 0.0;
    my $video2_flag = 0;

    foreach my $item (@contents)
    {
        #print "item: $item\n";
        my ($render, $video, $video_e) = split(/,\s*/, $item);
        #print "render : $render\n";
        #print "video  : $video\n";
        #print "video_e: $video_e\n";

        $render =~ s/\s*RENDER\s+usage:\s*//;
        $video =~ s/\s*VIDEO\s+usage:\s*//;
        $video_e =~ s/\s*VIDEO_E\s+usage:\s*//;

        if ($render =~ /[0-9]+\.[0-9]+/)
        {
            push @render_list, $render;
            $max_render += $render;
        }

        if ($video_e =~ /[0-9]+\.[0-9]+/)
        {
            push @video_list, $video;
            $max_video += $video;
        }


        if ($video_e =~ /VIDEO2/)
        {
            $video2_flag = 1;

            my $video2 = $video_e;
            $video2 =~ s/.*VIDEO2 usage:\s*//;
            #print "video2-1: $video2\n";
            if ($video2 =~ /[0-9]+\.[0-9]+/)
            {
                push @video2_list, $video2;
                $max_video2 += $video2;
            }


            $video_e =~ s/\s*VIDEO2.*//;
            #print "video_e-1: $video_e\n";
            if ($video_e =~ /[0-9]+\.[0-9]+/)
            {
                push @video_e_list, $video_e;
                $max_video_e += $video_e;
            }
        }
        else
        {
            if ($video_e =~ /[0-9]+\.[0-9]+/)
            {
                push @video_e_list, $video_e;
                $max_video_e += $video_e;
            }
        }
    }

    my $out_render = sprintf "%0.2f", $max_render / scalar(@render_list);
    my $out_video = sprintf "%0.2f", $max_video / scalar(@video_list);
    my $out_video_e = sprintf "%0.2f", $max_video_e / scalar(@video_e_list);

    print "$out_render%\n";
    print "$out_video%\n";
    print "$out_video_e%\n";

    if ($video2_flag)
    {
        my $out_video2 = sprintf "%0.2f", $max_video2 / scalar(@video2_list);
        print "$out_video2%\n";
    }

    close($file);
}

main();
