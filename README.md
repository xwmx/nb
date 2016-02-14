# notes

```
             _
 _ __   ___ | |_ ___  ___
| '_ \ / _ \| __/ _ \/ __|
| | | | (_) | ||  __/\__ \
|_| |_|\___/ \__\___||___/
```

A command line note-taking and syncing tool that stores data in Markdown files versioned with git.

With `notes`, you can add and edit notes using Vim, Emacs, or whatever editor you have set in the `$EDITOR` environment variable. `notes` uses git in the background to automatically record changes and sync with a remote repository, if one has been configured. Optional dependencies can be installed to enable enhanced rendering, display, and searching functionality, but everything still works great without them.

`notes` files are normal [Markdown](https://daringfireball.net/projects/markdown/) files that can be edited with any application. If the files are modified using a different program, `notes` will automatically commit all of the changes the next time it runs. As a result, `notes` can be configured to save the data files in a directory used by a general purpose syncing utility like Dropbox so they can be edited on any device with apps that support Dropbox and Markdown or plain text.

#### Dependencies

##### Required

- [Bash](https://www.gnu.org/software/bash/)
- [Git](https://git-scm.com/)

##### Optional

- [Ack](http://beyondgrep.com/)
- [Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser))
- [Pandoc](http://pandoc.org/)
- [Pygments](http://pygments.org/)
- [Pygments Markdown Lexer](https://github.com/jhermann/pygments-markdown-lexer)
- [tig](https://github.com/jonas/tig)
- [w3m](https://en.wikipedia.org/wiki/W3m)

## Usage

```
Usage:
  notes [<number>] [<list options>]
  notes add [<note>]
  notes count
  notes delete (<index> | <filename> | <path> | <title>)
  notes edit (<index> | <filename> | <path> | <title>)
  notes history [<selection>]
  notes init [<remote-url>]
  notes list [(-e | --excerpt) [<length>]] [--noindex]
  notes ls [<number>] [<list options>]
  notes search <query> [--path]
  notes show (<index> | <filename> | <path> | <title>)
  notes show <selection> ([--index] | [--path] | [---render]) [--dump]
  notes sync
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
  init       Initialize the local git repository.
  list       List all notes.
  ls         List with an excerpt. This is an alias for `notes list -e`.
  search     Search notes.
  show       Show a note.
  status     Run `git status` in `$NOTES_DATA_DIR`.
  sync       Sync notes with the remote repository.
  version    Display version information.

Program Options:
  -h --help              Display this help information.
  --version              Display version information.
```

### Subcommands

#### `add`

```
Usage:
  notes add [<note>]

Description:
  Create a new Markdown-formatted note. Any arguments passed to `add` are
  written to the note file. When no arguments are passed, a new note file is
  opened with `$EDITOR`.

Examples:
  notes add
  notes add "Note content."
  echo "Note content." | notes add
```

#### `count`

```
Usage:
  notes count

Description:
  Print the number of notes files in the current repository.
```

#### `delete`

```
Usage:
  notes delete <index>
  notes delete <filename>
  notes delete <path>
  notes delete <title>

Description:
  Delete a note.
```

#### `edit`

```
Usage:
  notes edit <index>
  notes edit <filename>
  notes edit <path>
  notes edit <title>

Description:
  Open the specified note in `$EDITOR`.
```

#### `env`

```
Usage:
  notes env

Description:
  Print program environment variables.
```

#### `git`

```
Usage:
  notes git <arguments>

Description:
  Alias for `git`, with commands run in `$NOTES_DATA_DIR`.
```

#### `help`

```
Usage:
  notes help [<subcommand>]

Description:
  Print the program help information. When a subcommand name is passed, the
  print the help information for the subcommand.
```

#### `history`

```
Usage:
  notes history [<selection>]

Description:
  Display git history using `tig` [1] (if available) or `git log`. When a
  <selection> is specified, the history for that note is displayed.

  1. https://github.com/jonas/tig
```

#### `init`

```
Usage:
  notes init [<remote-url>]

Description:
  Initialize the local git repository.
```

#### `list`

```
Usage:
  notes list [(-e | --excerpt) [<length>]] [--noindex] [-n [<limit>]]

Options:
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --noindex              Don't print an index next to each note's filename.
  -n <limit>             The maximum number of notes to list.

Description:
  List all notes.

  If Pygments [1] and the Markdown lexer [2] are installed, excerpts are
  printed with syntax highlighting.

  1. http://pygments.org/
  2. https://github.com/jhermann/pygments-markdown-lexer

Examples:
  notes list
  notes list -e 10
  notes list --excerpt --noindex
```

#### `ls`

```
Usage:
  notes ls [<number>] [<list options>]

Description:
  List with magic. By default, this is an alias for

    notes list --titles -n 15

  When <number> is present, output is truncated to <number> lines. Any
  additional options are passed through to `notes list`.
```

#### `search`

```
Usage:
  notes search <query> [--path]

Options:
  --path  Print the full path for each file with query matches.

Description:
  Search notes using `ack` [1] (if available) or `grep`.

  1. http://beyondgrep.com/
```

#### `show`

```
Usage:
  notes show (<index> | <filename> | <path> | <title>)
  notes show <selection> ([--index] | [--path] | [---render]) [--dump]

Options:
  --dump    Print to standard output.
  --index   Print the index number of the note file.
  --path    Print the full path of the note file.
  --render  Use `pandoc` [1] to render the file to HTML and display with
            `lynx` [2] (if available) or `w3m` [3]. If `pandoc` is not
            available, `--render` is ignored.

            1. http://pandoc.org/
            2. https://en.wikipedia.org/wiki/Lynx_(web_browser)
            3. https://en.wikipedia.org/wiki/W3m

Description:
  Show a note.

  If Pygments [1] and the Markdown lexer [2] are installed, the note file is
  displayed with syntax highlighting.

  1. http://pygments.org/
  2. https://github.com/jhermann/pygments-markdown-lexer
```

#### `status`

```
Usage:
  notes status

Description:
  Run `git status` in `$NOTES_DATA_DIR`.
```

#### `sync`

```
Usage:
  notes sync

Description:
  Sync local notes with the remote repository.
```

#### `version`

```
Usage:
  notes version

Description:
  Display version information.
```

## Configuration

`notes` is configured using environment variables, which can be set in `~/.notesrc`.

#### `$NOTES_AUTO_SYNC`

Default: `0`

When set to '1', operations that trigger a git commit like `add`, `edit`, and `delete` will automatically sync changes to the remote git repository in the background.

Example:

```bash
export NOTES_AUTO_SYNC=1
```

#### `$NOTES_DIR`

Default: `~/.notes`

The location of the notes directory that contains the data repository. For example, to store your notes in Dropbox, you could use:

```bash
export NOTES_DIR="~/Dropbox/Notes"
```

## Testing

To run the test suite, install [Bats](https://github.com/sstephenson/bats) and run `bats test` in the project root directory.
