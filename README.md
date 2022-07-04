# pass-context

An easy way to change [Pass's](https://www.passwordstore.org/) contexts.

# Rationale
To change contexts, one must use environment variables, at least
`PASSWORD_STORE_DIR`. However, there cases in which they are not available, for
example applications that can launch others, but without a shell (*e. g.*,
[Borgmatic](https://torsion.org/borgmatic/)).

Albeit the main reason, this extension came also to be to facilitate the use of
different contexts, since today they are usually managed by [shell
aliases](https://wiki.archlinux.org/title/Pass#Advanced_usage).
