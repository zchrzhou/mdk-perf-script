package cpu_mem;

require Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw |
                          &cpu_mem_init
                          &cpu_mem_start
                          &cpu_mem_end
                          &cpu_mem_calc
                          &cpu_mem_save
                      |;

use warnings;
use strict;
use Cwd;

use config;
use sample;

$| = 1;

my $debug_flag      = $config::conf{"debug_flag"};
my $cpumem_root     = "$config::conf{'tools_dir'}/cpu_mem";

sub cpu_mem_init
{

}

sub cpu_mem_start
{
    my $test_type   = shift;

    my $sample_name   = $config::msdk_sample_map{$test_type}->[0];
    my $sample_filter = substr($sample_name, 0, 8);

    # start cpu process
    if (!defined(my $top_pid = fork()))
    {
        # fork returned undef, so unsuccessful
        die "Cannot fork a child: $!";
    }
    elsif ($top_pid == 0)
    {
        print "Start top by child process\n";
        my $cpu_mem_cmd = "$cpumem_root/top.sh 1 $sample_filter";
        print "CPU&MEM cmd: $cpu_mem_cmd\n" if ($debug_flag);
        exec("$cpu_mem_cmd") || die "can't exec $cpu_mem_cmd: $!";
    }
    else
    {
        # fork returned 0 nor undef
        # so this branch is parent
    }
}

sub cpu_mem_end
{
    # kill top process
    my @top_list = `ps -ef | grep $cpumem_root/top.sh | grep -v grep`;
    print "top process num: @top_list\n";
    foreach my $top_item  (@top_list)
    {
        my @item_list = split ' ', $top_item;
        print "kill top :  $item_list[1]\n" if ($debug_flag);
        my $kill_item_info = `kill -9 $item_list[1]`;
    }
}


sub cpu_mem_calc
{
    my $num = shift;

    ## calu CPU&&MEM
    my @cpu_mem = `$cpumem_root/calc.sh $num`;
    chomp $cpu_mem[0];
    chomp $cpu_mem[1];

    my $mem_use = sprintf "%0.2f", $cpu_mem[1] * get_total_mem() / 100.0;

    return ($cpu_mem[0], $mem_use);
}

sub cpu_mem_save
{
    my $target_dir = shift;

    my @cmds = (
        "mv $cpumem_root/cpu_mem.txt $target_dir",
    );

    run_cmds(@cmds);
}


1;
