package sample;

require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw |
                          &run_cmds
                          &get_total_mem
                          &commify_series
                          &check_os_flag
                          &get_sample_path
                      |;

use warnings;
use strict;
use Getopt::Std;
use Cwd;

use config;

$| = 1;

sub run_cmds {
    my @cmds = @_;
    foreach (@cmds) {
        print "$_\n" if $config::conf{"verbose_flag"};
        unless ("" eq $_) {
            (system("$_") == 0) || die "can't run $_ : $!";
        }
    }
}

sub get_total_mem {
    my @mem_info = `cat /proc/meminfo`;
    my $total_mem = $mem_info[0];

    chomp $total_mem;
    $total_mem =~ s/MemTotal:\s+//;
    $total_mem =~ s/\s*kB//;

    $total_mem / 1024;
}

sub commify_series {
    (@_ == 0) ? ''                                   :
    (@_ == 1) ? $_[0]                                :
    (@_ == 2) ? join("\t", @_)                       :
    join("\t", @_[0 .. ($#_-1)], "$_[-1]");
}

sub get_sample_path {
    my $sample_bin_path = shift;
    my $test_type = shift;

    if (exists($config::msdk_sample_map{$test_type}))
    {
        my $index = 0;
        if ($^O eq "linux") {
            $index = 0;
        } else {
            $index = 1;
        }
        return "$sample_bin_path/$config::msdk_sample_map{$test_type}->[$index]";
    }
    else
    {
        die "Can`t find for $test_type\n";
    }
}

1;
