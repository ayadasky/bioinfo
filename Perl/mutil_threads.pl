#!/usr/bin/env perl
use strict;
use warnings;
use threads;
use threads::shared;
use Getopt::Long;
use FindBin qw($Bin $Script);
use Cwd qw(abs_path getcwd);
my @Times=localtime();my $Year=$Times[5]+1900;
my $Month=$Times[4]+1;my $Day=$Times[3];
my $version="1.0.0";
use vars qw/$thread_input $thread_output @thrs/;

#$ARGV[0] = 1 unless defined $ARGV[0];#任务投递数
my %opts;
GetOptions(\%opts,"c=s","m=s","h" );
if(!defined($opts{c}) || defined($opts{h}))
{
	my $usage = << "USAGE";

 ProgramName:	$Script
     Version:	$version
     Contact:	puroton
Program Date:	2018.12.18
Current Date:	$Year.$Month.$Day
      Modify:	
 Description:	This program is used to mutil_threads
       Usage:
		Options:
		-c           cmds <input shell file>             [forced]
		-m           mutil_threads                       [optional,default:3]
		-h           help
Example:perl $Script -c example_work.sh
        perl $Script -c example_work.sh -m 4

USAGE
	print $usage;
	exit;
}
my $maxproc = defined $opts{m} ? $opts{m} : 3;
my $shells = abs_path($opts{c});

start_threads(\@thrs, $maxproc);

open (IN,$shells) or die "Can't open $shells $!\n";
my @cmds;
while (<IN>) {
	chomp;
	push @cmds,$_;
}
close IN;

_perform(\@cmds);

end_threads(\@thrs);

#############################################################################
sub start_threads {
	my $thrs = shift;
	my $num_threads = shift;

	my @input :shared;
	my @output :shared;

	$thread_input = \@input;
	$thread_output = \@output;

	for (my $i=0; $i< $num_threads; $i++) {
		my $thr = threads->create(\&_postdocs, $i);
		push @$thrs, $thr;
	}
}

sub _postdocs {
	my $thread_num = shift;

	while (1) {
		my $cmd;

		if (defined $thread_input->[0]) {
			$cmd = shift @$thread_input;

			if ($cmd eq "you_are_fired") {
				push @$thread_output, 1;
				return;
			} else {
				system($cmd);
				push @$thread_output, 1;
			}
		} else {
			sleep 1;
		}
	}
}

sub end_threads {
	my $thrs = shift;

	my @cmds;
	for (my $i=0; $i<@$thrs; $i++) {
		push @cmds, "you_are_fired";
	}

	_perform(\@cmds);

	foreach my $thr (@$thrs) {	$thr->join(); }
}

sub _perform {
	my $cmds = shift;

	@$thread_output = ();
	@$thread_input = @$cmds;

	while (scalar @$thread_output != scalar @$cmds) {
		sleep 1;
	}

}
