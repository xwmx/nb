# `notes` Tab Completion

## Homebrew

Installing via Homebrew with `brew install xwmx/taps/notes` will also
install the completion scripts.

A one-time setup might be needed to [enable completion for all Homebrew
programs](https://docs.brew.sh/Shell-Completion).

## npm, bpkg, Make

When `notes` is installed with `npm`, `bpkg`, or Make, an install hook will
check the environment and attempt to install completions. If it's successful,
you should see a message similar to:

```bash
Completion script installed: /usr/local/etc/bash_completion.d/notes
Completion script installed: /usr/local/share/zsh/site-functions/_notes
```

If completion is working after installing through any of these methods, then
you don't need to do anything else.

## `notes completions`

The `notes completions` subcommand can be used for installing and uninstalling
completion scripts. Depending on your configuration, you might need to use
`sudo` to install completion scripts easily:

```bash
> sudo notes completions check
Completion scripts not found.

> sudo notes completions install
Completion script installed: /usr/local/etc/bash_completion.d/notes
Completion script installed: /usr/local/share/zsh/site-functions/_notes

> sudo notes completions check
Exists: /usr/local/etc/bash_completion.d/notes
Exists: /usr/local/share/zsh/site-functions/_notes

> sudo notes completions uninstall
Completion script removed: /usr/local/etc/bash_completion.d/notes
Completion script removed: /usr/local/share/zsh/site-functions/_notes
```

If you installed `notes` manually by downloading just the `notes` script,
the completion scripts won't be immediately available for
`notes completions install`. You can try installing the completions with
the `--download` flag, which will get the latest version from GitHub:

```bash
sudo notes completions install --download
```

`notes completions` will try to determine the completion script directories
from your environment. If `notes completions` isn't able to install
the completion scripts, you can try installing them manually.

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
