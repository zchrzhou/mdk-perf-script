package gpu;

require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw |
                          &gpu_init
                          &gpu_start
                          &gpu_end
                          &gpu_calc
                          &gpu_save
                      |;

use warnings;
use strict;
use Cwd;

use config;
use sample;

$| = 1;

my $debug_flag      = $config::conf{"debug_flag"};
my $gpu_log_name    = $config::conf{"gpu_log_name"};
my $gpu_root        = "$config::conf{'tools_dir'}/gpu";

sub gpu_pre_exec
{

}

sub gpu_start
{
    # start cpu process
    if (!defined(my $gpu_pid = fork()))
    {
        # fork returned undef, so unsuccessful
        die "Cannot fork a child: $!";
    }
    elsif ($gpu_pid == 0)
    {
        print "Start top by child process\n";
        my $gpu_cmd = "$gpu_root/metrics_monitor.sh";
        exec("$gpu_cmd") || die "can't exec $gpu_cmd: $!";
    }
    else
    {
        # fork returned 0 nor undef
        # so this branch is parent
    }
}

sub gpu_end
{
    # kill gop process
    my @gpu_list = `ps -ef | grep $gpu_root/metrics_monitor.sh | grep -v grep`;
    print "gpu process num: @gpu_list\n";
    foreach my $gpu_item  (@gpu_list)
    {
        my @item_list = split ' ', $gpu_item;
        print "kill metrics_monitor.sh :  $item_list[1]\n" if ($debug_flag);
        my $kill_item_info = `kill -9 $item_list[1]`;
    }

    my $kill_item_info = `$gpu_root/kill.sh`;

}

sub gpu_calc
{
    ## calu GPU
    my @gpu_usage = `$gpu_root/calc.pl $gpu_root/$gpu_log_name`;
    chomp @gpu_usage;

    return @gpu_usage;
}

sub gpu_save
{
    my $target_dir = shift;

    my @cmds = (
        "mv $gpu_root/$gpu_log_name $target_dir",
    );

    run_cmds(@cmds);
}

1;
