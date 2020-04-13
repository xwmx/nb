# Installation instructions

## Homebrew

If you're using Homebrew, just run `brew install xwmx/taps/notes` and the
completion scripts will be installed automatically. The extra steps to install
`notes` completion scripts outlined below are *not needed*.

A one-time setup might be needed to [enable completion for all Homebrew
programs](https://docs.brew.sh/Shell-Completion).

## bash

### Linux

On a current Linux OS (in a non-minimal installation), bash completion should
be available.

Place the completion script in `/etc/bash_completion.d/`:

```bash
sudo curl -L https://raw.githubusercontent.com/xwmx/notes/master/notes-completion.bash -o /etc/bash_completion.d/notes
```

### macOS

If you aren't installing with homebrew, source the completion script in
`.bash_profile`:

```sh
if [[ -f /path/to/notes-completion.bash ]]
then
  source /path/to/notes-completion.bash
fi
```

## zsh

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
