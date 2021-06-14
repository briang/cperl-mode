# cperl-mode.el

This is a mirror of the single file cperl-mode.el from the official
GNU emacs repository at https://git.savannah.gnu.org/cgit/emacs.git

## Motivation

I wanted to include an up-to-date cperl-mode.el in my local ELPA. The
ELPA package building script uses the upstream version of cperl-mode,
but does it by cloning the entire emacs repository and that's
**really** slow. The update-cperl-mode.pl script in this repository
just copies the single file from upstream to the local repo.

## Contents of the repository

| File                 | Description                                     |
|----------------------|-------------------------------------------------|
| cperl-mode.el        | cperl-mode.el, mirrored from GNU emacs repo     |
| LICENSE              | GPL3                                            |
| update-cperl-mode.pl | Fetches cperl-mode.el from git.savannah.gnu.org |
|                      |                                                 |

### update-cperl-mode.pl

If cperl-mode.el is different to the upstream copy, the upstream
version replaces the file in this repository and is commited to
git. The commit is tagged with a version derived from the current UTC
date (yyyy.mm.dd).
