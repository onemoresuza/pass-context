# pass-context

An easy way to change [Pass'](https://www.passwordstore.org/) contexts.

[![Build Status](https://app.travis-ci.com/onemoresuza/pass-context.svg?branch=main)](https://app.travis-ci.com/onemoresuza/pass-context)

# Rationale
To change contexts, one must use environment variables, at least
`PASSWORD_STORE_DIR`. However, there cases in which they are not available, for
example applications that can launch others, but without a shell (*e. g.*,
[Borgmatic](https://torsion.org/borgmatic/)).

Albeit the main reason, this extension came also to be to facilitate the use of
different contexts, since today they are usually managed by [shell
aliases](https://wiki.archlinux.org/title/Pass#Advanced_usage).

# Dependencies
* Pass

## Optional Dependencies (xmenu support)
1. [Dmenu](https://tools.suckless.org/dmenu/); or
2. [Rofi](https://github.com/davatorium/rofi).

## Testing Dependencies
1. [Shunit2](https://github.com/kward/shunit2);
2. [Shellcheck](https://github.com/koalaman/shellcheck); and
3. [Shfmt](https://github.com/mvdan/sh).

# Install
After downloading the repo, cd into it and run, for the global install:
```
# make install
```

Or, for the local one:
```
$ make PREFIX= EXTENSION_DIR="${PASSWORD_STORE_EXTENSIONS_DIR}"
```
