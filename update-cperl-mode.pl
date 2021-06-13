#!/usr/bin/env perl

#:TAGS:

use 5.030;

use strict;  use warnings;  use autodie qw/:all/;
use experimental qw(signatures);

# use Capture::Tiny;
# use Data::Dump;
# use List::AllUtils;
# use Path::Tiny;
# use re q(/axms);
# use Time::Piece;
################################################################################
package GitRepo {
    use Classy qw( branch path repo );

    use LWP::Simple;
    use Try::Tiny;

    # use Data::Dump; # XXX

    use constant NO_DATE => '0000-00-00';

    sub newest_commit_date($self) {
        return "2021-05-06T10:33:40Z"
          if $self->branch eq 'master';
        return NO_DATE;

        # XXX

        try {
            my $url = join '',
              'https://api.github.com/repos/', $self->repo,
              '/commits?path=', $self->path, '&page=1&per_page=1';
            my $json = get($url) or die;
            $json = decode_json $json or die;
            return $json->[0]{commit}{committer}{date};
        }
        catch { return NO_DATE };
    }

    sub get_remote_file($self) {
        my $url = join '',
          'https://raw.githubusercontent.com/',
          $self->repo, '/', $self->branch, '/', $self->path;
        my $content = get($url) or die;
        return $content;
    }
};
################################################################################
use JSON;

# use Data::Dump; # XXX

# TERMINOLOGY
#
# primary_upstream = officialish emacs repo on GitHub
# secondary_upstream = mirror of cperl-mode on GitHub

my $upstream = GitRepo->new(
    branch => 'master',
    path   => 'lisp/progmodes/cperl-mode.el',
    repo   => 'emacs-mirror/emacs',
);

my $downstream = GitRepo->new(
    branch => 'main',
    path   => 'cperl-mode.el',
    repo   => 'briang/cperl-mode',
);

my $upstream_date   = $upstream  ->newest_commit_date();
my $downstream_date = $downstream->newest_commit_date();

if ($upstream_date gt $downstream_date) {
    my $new_version = $upstream_date =~ s/T.*//r =~ s/-/./gr;

    my $new_content = $upstream->get_remote_file();
    write_file($downstream->path, $new_content);

    my $path = $downstream->path;
    git(qq[add $path]); # XXX autodie
    git(qq[commit $path -m "update $path to $new_version"]); # XXX autodie
    git(qq[tag $new_version]); # XXX autodie
}
else { say "Already up to date" }

sub git($command) {
    say    qq(git $command);
#    system qq(git $command); # XXX autodie
}

sub write_file($file, $content) {
    open my $f, ">", $file; # XXX autodie
    print $f $content;
}
