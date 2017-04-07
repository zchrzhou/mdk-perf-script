#!/usr/bin/env perl

use strict;
use Time::HiRes qw(gettimeofday usleep);

my ($start_sec, $start_usec) = gettimeofday;
printf("%s.%s\n",$start_sec, $start_usec);

exit 0;
