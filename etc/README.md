# Installation instructions

## Homebrew

Installing via Homebrew with `brew install xwmx/taps/notes` will also
install the completion scripts. The extra steps to install `notes`
completions below are not needed.

A one-time setup might be needed to [enable completion for all Homebrew
programs](https://docs.brew.sh/Shell-Completion).

## npm, bpkg, Make

When `notes` is installed with `npm`, `bpkg`, or Make, an install hook will
check the environment and attempt to install completions. If it's successful,
you should see a message similar to:

```bash
Completion installed: /usr/local/etc/bash_completion.d/notes-completion.bash
Completion installed: /usr/local/share/zsh/site-functions/_notes
```

If completion is working after installing through any of these methods, then
you don't need to do anything else.

## `scripts/notes-completion`

`notes` includes a script for installing and uninstalling `notes` completions
that is used in installation hooks:
[notes-completion](../scripts/notes-completion)

To run this script directly, navigate to this directory in your terminal, and
run:

```bash
./notes-completion
```

To install completions:

```bash
./notes-completion install
```

To uninstall:

```bash
./notes-completion uninstall
```

Use the `check` subcommand to determine if completion scripts are installed:

```bash
> ./notes-completion check
Exists: /usr/local/etc/bash_completion.d/notes-completion.bash
Exists: /usr/local/share/zsh/site-functions/_notes
```

This script will try to determine the completion installation
locations from your environment. If completion doesn't work, you might
need to try installing manually.

## Manual Installation

### bash

#### Linux

On a current Linux OS (in a non-minimal installation), bash completion should
be available.

Place the completion script in `/etc/bash_completion.d/`:

```bash
sudo curl -L https://raw.githubusercontent.com/xwmx/notes/master/notes-completion.bash -o /etc/bash_completion.d/notes
```

#### macOS

If you aren't installing with homebrew, source the completion script in
`.bash_profile`:

```sh
if [[ -f /path/to/notes-completion.bash ]]
then
  source /path/to/notes-completion.bash
fi
```

### zsh

Place the completion script in your `/path/to/zsh/completion` (typically
`~/.zsh/completion/`):

```bash
$ mkdir -p ~/.zsh/completion
$ curl -L https://raw.githubusercontent.com/xwmx/notes/master/notes-completion.zsh > ~/.zsh/completion/_notes
```
Include the directory in your `$fpath` by adding in `~/.zshrc`:

```bash
fpath=(~/.zsh/completion $fpath)
```

Make sure `compinit` is loaded or do it by adding in `~/.zshrc`:

```bash
autoload -Uz compinit && compinit -i
```

Then reload your shell:

```bash
exec $SHELL -l
```
