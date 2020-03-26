# notes

```
             _
 _ __   ___ | |_ ___  ___
| '_ \ / _ \| __/ _ \/ __|
| | | | (_) | ||  __/\__ \
|_| |_|\___/ \__\___||___/
```

A command line note-taking and syncing tool that stores data as Markdown,
Emacs Org mode, and other text file formats versioned with git.

With `notes`, you can add and edit notes using Vim/GVim/MacVim, Emacs, VS Code,
or whatever editor you have set in the `$EDITOR` environment variable.
`notes` uses git in the background to automatically record changes and sync
with a remote repository, if one has been configured. Optional dependencies
can be installed to enable enhanced rendering, display, and searching
functionality, but everything still works great without them.

`notes` works with text files in any markup format. By default, `notes` files
are normal [Markdown](https://daringfireball.net/projects/markdown/) files that
can be edited with any text editor.

`notes` can be configured to save the data files in a directory used
by a general purpose syncing utility like Dropbox so they can be edited on
any device with apps that support Dropbox and Markdown, plain text, or
your preferred markup format.

#### Dependencies

##### Required

- [Bash 4.3+](https://www.gnu.org/software/bash/)
- [Git](https://git-scm.com/)
- A text editor with command line support, such as
  - [Vim](http://www.vim.org/),
  - [Emacs](https://www.gnu.org/software/emacs/),
  - [VS Code](https://code.visualstudio.com/),
  - [Sublime Text](https://www.sublimetext.com/),
  - [Atom](https://atom.io/),
  - [nano](https://en.wikipedia.org/wiki/GNU_nano),
  - [or many of these.](https://en.wikipedia.org/wiki/List_of_text_editors)

##### Optional

`notes` leverages standard command line tools and works great in any Bash
environment. `notes` also checks the environment for some additional optional
tools and uses them to enhance the experience whenever they are available.

- [Ack](http://beyondgrep.com/)
- [Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser))
- [Pandoc](http://pandoc.org/)
- [Pygments](http://pygments.org/)
- [tig](https://github.com/jonas/tig)
- [w3m](https://en.wikipedia.org/wiki/W3m)

### Installation

#### Homebrew

To install with [Homebrew](http://brew.sh/):

```bash
brew install xwmx/taps/notes
```

#### npm

To install with [npm](https://www.npmjs.com/package/notes.sh):

```bash
npm install --global notes.sh
```

#### Manual

To install manually, simply add the `notes` script to your `$PATH`. If
you already have a `~/bin` directory, you can use the following command:

```bash
curl -L https://raw.github.com/xwmx/notes/master/notes \
  -o ~/bin/notes && chmod +x ~/bin/notes
```

## Usage

To get started, simply run:

```bash
notes
```

This will set up your initial 'home' notebook where notes will be stored.

To add a note:

```bash
# create a new note in your terminal's text editor
notes add

# create a new note containing "This is a note."
notes add "This is a note."
```

To list your notes and notebooks:

```bash
notes ls
# home
# ---------------------
# [3] 20200101000002.md
# [2] 20200101000001.md
# [1] 20200101000000.md
```

Notes are listed with each id and filename. If the note file has a
Markdown title on the first line (e.g., `# Example Title`) , the
title will be displayed instead of the filename:

```bash
notes ls
# home
# ---------------------
# [3] Todos
# [2] Links
# [1] Example Title
```

Pass an id, filename, or markdown title to view the listing for that item:

```bash
notes ls Todos
# [3] Todos

notes ls 1
# [1] Example Title
```

To view excerpts of files, use the `--excerpt` or `-e` option:

```bash
notes ls 1 --excerpt
# [1]  Example Title
# ---------
# # Example Title
#
# This is an example excerpt.
```

For more information on the options for listing files and excerpts, run
`notes help ls` and `notes help list`.

You can edit a file using its id, filename, or markdown title, if the
note contains one:

```bash
# edit note by id
notes edit 3

# edit note by filename
notes edit example.md

# edit note by title
notes edit 'A Document Title'
```

Deleting notes works the same:

```bash
# delete note by id
notes delete 3
```

You can create additional notebooks, each of which has its own version history.

Create a new notebook:

```bash
# add a notebook named example-notebook
notes notebooks add example-notebook
```

Switch to a notebook:

```bash
# switch to example-notebook
notes use example-notebook
```

If you are in one notebook and you want to perform a command in a
different notebook without switching to it, add the notebook name with a
colon before the command name:

```bash
# edit note 5 in example-notebook
notes example-notebook:edit 5
```

Files can also be moved between notebooks:

```bash
# move note 3 from home to example-notebook
notes move 3 example-notebook
```

Whenever a file is added, changed, or removed, `notes` automatically commits
the change to git transparently in the background. You can view the history of
the notebook or an individual file with:

```bash
# show history for current notebook
notes history

# show history for note 4
notes history 4
```

Search your notes:

```bash
# search current notebook for 'a query'
notes search 'a query'

# search all notebooks for 'a query'
notes search -a 'a query'
```

For more commands and options, run `notes help`.

### Help

```text
Usage:
  notes [<id> | <filename> | <path> | <title>] [<list options>]
  notes add [<note>] [--type <type>]
  notes count
  notes delete (<id> | <filename> | <path> | <title>) [--force]
  notes edit (<id> | <filename> | <path> | <title>)
  notes history [<selection>]
  notes init [<remote-url>]
  notes list [(-e | --excerpt) [<length>]] [--no-id] [-n <limit>] [--titles]
             [-s | --sort] [-r | --reverse] [<selection>]
  notes ls [<list options>]
  notes move (<id> | <filename> | <path> | <title>) [--force] <notebook>
  notes notebook
  notes notebooks [<name>] [--names] [--no-color]
  notes notebooks add <name> [<remote-url>]
  notes notebooks current
  notes notebooks rename <old-name> <new-name>
  notes notebooks use <name>
  notes search <query> [-a | --all] [--path]
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]
  notes sync [-a|--all]
  notes -h | --help | help [<subcommand>]
  notes --version | version

Help:
  notes help [<subcommand>]

Subcommands:
  (default)  List notes. This is an alias for `notes ls`.
  add        Add a new note.
  count      Print the number of notes.
  delete     Delete a note.
  edit       Edit a note.
  env        Print program environment variables.
  help       Display this help information.
  history    Display git history for the current notebook or a note.
  init       Initialize the first notebook.
  list       List all notes.
  ls         Shortcut for `list --titles`.
  notebook   Print current notebook name.
  notebooks  Manage notebooks.
  search     Search notes.
  show       Show a note.
  status     Run `git status` in `$NOTES_DATA_DIR`.
  sync       Sync local notebook with the remote repository.
  version    Display version information.

Program Options:
  -h --help              Display this help information.
  --version              Display version information.
```

### Subcommands

#### `add`

```text
Usage:
  notes add [<note>] [--type <type>]

Options:
  --type  The file extension for the note file type [default: 'md'].

Description:
  Create a new note. Any arguments passed to `add` are written to the note
  file. When no arguments are passed, a new note file is opened with
  `$EDITOR`.

Examples:
  notes add
  notes add "Note content."
  echo "Note content." | notes add
```

#### `count`

```text
Usage:
  notes count

Description:
  Print the number of notes files in the current repository.
```

#### `delete`

```text
Usage:
  notes delete (<id> | <filename> | <path> | <title>) [--force]

Options:
  --force  Skip the confirmation prompt.

Description:
  Delete a note.
```

#### `edit`

```text
Usage:
  notes edit (<id> | <filename> | <path> | <title>)

Description:
  Open the specified note in `$EDITOR`.
```

#### `env`

```text
Usage:
  notes env

Description:
  Print program environment variables.
```

#### `git`

```text
Usage:
  notes git <arguments>

Description:
  Alias for `git`, with commands run in `$NOTES_DATA_DIR`.
```

#### `help`

```text
Usage:
  notes help [<subcommand>]

Description:
  Print the program help information. When a subcommand name is passed, the
  print the help information for the subcommand.
```

#### `history`

```text
Usage:
  notes history [<selection>]

Description:
  Display git history using `tig` [1] (if available) or `git log`. When a
  <selection> is specified, the history for that note is displayed.

  1. https://github.com/jonas/tig
```

#### `init`

```text
Usage:
  notes init [<remote-url>]

Description:
  Initialize the local git repository.
```

#### `list`

```text
Usage:
  notes list [(-e | --excerpt) [<length>]] [--no-id] [-n <limit>] [--titles]
             [-s | --sort] [-r | --reverse] [<selection>]

Options:
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --no-id                Don't print the id next to each note's filename.
  -n <limit>             The maximum number of notes to list.
  -s --sort              Order notes by id.
  -r --reverse           Order notes by id descending.
  --titles               Show title instead of filename when present.

Description:
  List all notes.

  If Pygments <http://pygments.org/> is installed, excerpts are printed with
  syntax highlighting.

Examples:
  notes list
  notes list -e 10
  notes list --excerpt --no-id
```

#### `ls`

```text
Usage:
  notes ls [<list options>]

Description:
  Shortcut for `list --titles`. Any options are passed through to `list`.
```

#### `search`

```text
Usage:
  notes search <query> [-a | --all] [--path]

Options:
  -a --all  Search all notebooks.
  --path    Print the full path for each file with query matches.

Description:
  Search notes. Uses the first available tool in the following list:
    1. `ag`    <https://github.com/ggreer/the_silver_searcher>
    2. `ack`   <http://beyondgrep.com/>
    3. `grep`  <https://en.wikipedia.org/wiki/Grep>
```

#### `move`

```text
Usage:
  notes move (<id> | <filename> | <path> | <title>) [--force] <notebook>

Description:
  Move the specified note to <notebook>.
```

#### `show`

```text
Usage:
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]

Options:
  --dump      Print to standard output.
  --id        Print the id number of the note file.
  --path      Print the full path of the note file.
  --no-color  When used with `--dump`, print the note without highlighting.
  --render    Use `pandoc` [1] to render the file to HTML and display with
              `lynx` [2] (if available) or `w3m` [3]. If `pandoc` is not
              available, `--render` is ignored.

            1. http://pandoc.org/
            2. https://en.wikipedia.org/wiki/Lynx_(web_browser)
            3. https://en.wikipedia.org/wiki/W3m

Description:
  Show a note.

  If Pygments <http://pygments.org/> is installed, excerpts are printed with
  syntax highlighting.
```

#### `status`

```text
Usage:
  notes status

Description:
  Run `git status` in `$NOTES_DATA_DIR`.
```

#### `sync`

```text
Usage:
  notes sync [-a|--all]

Options:
  -a --all  Sync all notebooks.

Description:
  Sync the current local notebook with the remote repository.
```

#### `version`

```text
Usage:
  notes version

Description:
  Display version information.
```

## Configuration

`notes` is configured using environment variables, which can be set in
`~/.notesrc`.

#### `$NOTES_AUTO_SYNC`

Default: `1`

By default, operations that trigger a git commit like `add`, `edit`,
and `delete` will also sync notebook changes to the remote repository, if
one is set.

To disable this behavior, set the value to '0'.

Example:

```bash
export NOTES_AUTO_SYNC=0
```

#### `$NOTES_DIR`

Default: `~/.notes`

The location of the notes directory that contains the data repository. For
example, to store your notes in Dropbox, you could use:

```bash
export NOTES_DIR="~/Dropbox/Notes"
```

#### `$NOTES_DEFAULT_EXTENSION`

Default: `md`

The default extension to use for notes files. Change to `org` for Emacs Org
mode files, `rst` for reStructuredText, `txt` for plain text, or whatever you
prefer.

Example Values: `md`, `org`, `txt`, `rst`

Example:
```bash
export NOTES_DEFAULT_EXTENSION="org"
```

#### `$EDITOR`

Default: inherits the global `$EDITOR` value.

Reassign `$EDITOR` to use a specific editor with `notes`, overriding the
global `$EDITOR` setting.

Example Values: `vim`, `emacs`, `subl`, `atom`, `code`, `macdown`

Examples:
```bash
# Set to emacsclient
export EDITOR="emacsclient -q --alternate-editor='' 2>/dev/null"

# Set to VS Code
export EDITOR="code"
```

## Testing

To run the test suite, install [Bats](https://github.com/sstephenson/bats) and
run `bats test` in the project root directory.
