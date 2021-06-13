#!/usr/bin/env perl

#:TAGS:

use 5.010;

use strict;  use warnings;  use autodie qw/:all/;

use Data::Dump; # XXX

use File::Compare ();
use File::Copy ();
use File::stat;
use LWP::Simple;
use Time::Piece;

my $CPERL_MODE = 'cperl-mode.el';
my $UPSTREAM =
  "https://git.savannah.gnu.org/cgit/emacs.git/plain/lisp/progmodes/$CPERL_MODE";

my $TEMP_FILE = "/tmp/$CPERL_MODE";

my $response = getstore($UPSTREAM, $TEMP_FILE);
die "Unexpected https response: $response" unless $response == 200;

if (-e $CPERL_MODE && File::Compare::compare($CPERL_MODE, $TEMP_FILE) == 0) {
    say "$CPERL_MODE is up-to-date";
}
else {
    File::Copy::move($TEMP_FILE, '.')
      or die "Error while moving $CPERL_MODE: $!\n";

    my $st = stat($CPERL_MODE)
      or die "Error stating $CPERL_MODE: $!";
    my $time = gmtime $st->mtime;
    my $version = sprintf "%4d.%02d.%02d", $time->year, $time->mon, $time->mday;

    git(qq[add $CPERL_MODE]); # XXX autodie
    git(qq[commit $CPERL_MODE -m "update $CPERL_MODE to $version"]); # XXX autodie
    git(qq[tag $version]); # XXX autodie
}

sub git {
    say my $command = "git " . shift;
    system $command; # XXX autodie
}
