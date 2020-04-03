# notes

```
             _
 _ __   ___ | |_ ___  ___
| '_ \ / _ \| __/ _ \/ __|
| | | | (_) | ||  __/\__ \
|_| |_|\___/ \__\___||___/
```

`notes` is a command line note-taking and document management tool with
encryption, advanced search, [Git](https://git-scm.com/)-backed
versioning and syncing, [Pandoc](http://pandoc.org/)-backed conversion, and
more in a single portable script. `notes` creates notes in text-based formats
like [Markdown](https://daringfireball.net/projects/markdown/) and
[Emacs Org mode](https://orgmode.org/), can organize and
work with files in any format, and can export notes to many document formats.
`notes` can also create private, password-protected encrypted notes to protect
sensitive information.

With `notes`, you can add and edit notes using Vim, Emacs, VS Code, Sublime
Text, and any other text editor you prefer. `notes` works great in any
[Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) environment.
[Optional dependencies](#optional) can be installed to enhance functionality,
but `notes` still works great without them.

`notes` uses [Git](https://git-scm.com/) in the background to automatically
record changes and sync with a remote repository, if one has been configured.
`notes` can also be configured to save notes in a location used by a general
purpose syncing utility like Dropbox so notes can be edited in other apps on
any device.

#### Dependencies

##### Required

- [Bash](https://www.gnu.org/software/bash/)
- [Git](https://git-scm.com/)
- A text editor with command line support, such as:
  - [Vim](https://en.wikipedia.org/wiki/Vim_\(text_editor\)),
  - [Emacs](https://en.wikipedia.org/wiki/Emacs),
  - [Visual Studio Code](https://code.visualstudio.com/),
  - [Sublime Text](https://www.sublimetext.com/),
  - [Atom](https://atom.io/),
  - [TextMate](https://macromates.com/),
  - [MacDown](https://macdown.uranusjr.com/),
  - [nano](https://en.wikipedia.org/wiki/GNU_nano),
  - [or many of these.](https://en.wikipedia.org/wiki/List_of_text_editors)

##### Optional

`notes` leverages standard command line tools and works in any Bash
environment. `notes` also checks the environment for some additional optional
tools and uses them to enhance the experience whenever they are available.

- [Ack](http://beyondgrep.com/)
- [Ag - The Silver Searcher](https://github.com/ggreer/the_silver_searcher)
- [Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser))
- [Pandoc](http://pandoc.org/)
- [Pygments](http://pygments.org/)
- [rg - ripgrep](https://github.com/BurntSushi/ripgrep)
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
# create a new note in your text editor
notes add

# create a new note with the filename 'example.md'
notes add example.md

# create a new note containing "This is a note."
notes add "This is a note."

# creare a new password-protected, encrypted note
notes add "# Secret Document" --encrypt
```

`notes add` with no arguments will open the new, blank note in your
environment's preferred text editor. You can change your editor using the
[`$EDITOR`](https://askubuntu.com/questions/432524) variable in your
environment or [`notes settings`](#configuration).

`notes` files are [Markdown](https://daringfireball.net/projects/markdown/)
files by default. To change the file type, see `notes help add`

To list your notes and notebooks, run `notes` with no arguments:

```bash
notes
# home
# ---------------------
# [3] 20200101000002.md
# [2] 20200101000001.md
# [1] 20200101000000.md
```

Notebooks are listed above the line, with the current notebook highlighted.

Notes from the current notebook are listed with each id and filename. When the
note has a Markdown title on the first line (e.g., `# Example Title`), the
title will be displayed instead of the filename:

```bash
notes
# home
# ---------------------
# [3] Todos
# [2] Links
# [1] Example Title
```

Pass an id, filename, or markdown title to view the listing for that note:

```bash
notes Todos
# [3] Todos

notes 1
# [1] Example Title
```

To view excerpts of notes, use the `--excerpt` or `-e` option:

```bash
notes 1 --excerpt
# [1] Example Title
# -----------------
# # Example Title
#
# This is an example excerpt.
```

`notes` is a shortcut for `notes ls`, and both commands respond to the same
arguments as `notes list`. For more information about options for listing
notes, run `notes help list`.

You can edit a note using its id, filename, or markdown title:

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
# show note 5 in example-notebook
notes example-notebook:show 5
```

You can similarly set the notebook name as a modifier to the id, filename, or
title:

```bash
# edit note 12 in example-notebook
notes edit example-notebook:12
```

Notes can also be moved between notebooks:

```bash
# move note 3 from the current notebook to example-notebook
notes move 3 example-notebook
```

When you have an existing `notes` notebook in a git repository, simply
pass the URL to `notes notebooks add` and `notes` will clone your
existing notebook and start syncing changes automatically:

```bash
notes notebooks add Example https://github.com/example/example.git
```

For more information about working with notebooks, run `notes help notebooks`

Whenever a note is added, changed, or removed, `notes` automatically commits
the change to git transparently in the background. You can view the history of
the notebook or an individual note with:

```bash
# show history for current notebook
notes history

# show history for note 4
notes history 4
```

Use `notes search` to search your notes, with support for regular
expressions:

```bash
# search current notebook for 'example query'
notes search 'example query'

# search all notebooks for 'example query'
notes search 'example query' --all

# search notes for "Example" OR "Sample"
notes search 'Example|Sample'

# search with a regular expression for Markdown notes titled "Example"
notes search '^# Example'
```

You can also import and export notes. If you have Pandoc installed, notes can
be exported to any of the
[formats supported by Pandoc](https://pandoc.org/MANUAL.html#option--to).
The formats are determined by the file extensions:

```bash
# Export a Markdown note to a .docx Microsoft Office Word document
notes export example.md /path/to/example.docx

# Export a note titled 'Movies' to an HTML web page.
notes export Movies /path/to/example.html
```

For more commands and options, run `notes help`.

### Help

```text
Usage:
  notes [<id> | <filename> | <path> | <title>] [<list options>]
  notes add [<filename> | <content>] [-c <content> | --content <content>]
            [-e | --encrypt] [-f <filename> | --filename <filename>]
            [-t <title> | --title <title>] [--type <type>]
  notes count
  notes delete (<id> | <filename> | <path> | <title>) [--force]
  notes edit (<id> | <filename> | <path> | <title>)
  notes export (<id> | <filename> | <path> | <title>) <path> [--force]
               [<pandoc options>...]
  notes git <git options>...
  notes history [<selection>]
  notes import [copy | download | move] (<path> | <url>) [--convert]
  notes init [<remote-url>]
  notes list [-e [<length>] | --excerpt [<length>]] [--no-id] [-n <limit>]
             [-s | --sort] [-r | --reverse] [--titles]
             [<id> | <filename> | <path> | <title>]
  notes ls [<list options>...]
  notes move (<id> | <filename> | <path> | <title>) [--force] <notebook>
  notes notebook
  notes notebooks [<name>] [--names] [--no-color]
  notes notebooks add <name> [<remote-url>]
  notes notebooks current
  notes notebooks rename <old-name> <new-name>
  notes notebooks use <name>
  notes open
  notes remote [remove | set <url> [--force]]
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset)
  notes search <query> [-a | --all] [--path]
  notes settings
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]
  notes sync [-a | --all]
  notes use <notebook>
  notes -h | --help | help [<subcommand>]
  notes --version | version

Help:
  notes help [<subcommand>]

Subcommands:
  (default)  List notes and notebooks. This is an alias for `notes ls`.
  add        Add a new note.
  count      Print the number of notes.
  delete     Delete a note.
  edit       Edit a note.
  env        Print program environment variables.
  export     Export a note to a variety of different formats.
  git        Alias for `git` within the current notebook.
  help       Display this help information.
  history    Display git history for the current notebook or a note.
  import     Import a file into the current notebook.
  init       Initialize the first notebook.
  list       List notes in the current notebook.
  ls         List notebooks and notes in the current notebook.
  move       Move a note to a different notebook.
  notebook   Print current notebook name.
  notebooks  Manage notebooks.
  open       Open the notebook directory in your file browser or explorer.
  remote     Get, set, and remove the remote URL for the notebook.
  rename     Rename a note.
  search     Search notes.
  settings   Edit configuration settings.
  show       Show a note.
  status     Run `git status` in the current notebook.
  sync       Sync local notebook with the remote repository.
  use        Switch to a notebook.
  version    Display version information.

Program Options:
  -h --help              Display this help information.
  --version              Display version information.
```

### Subcommands

#### `add`

```text
Usage:
  notes add [<filename> | <content>] [-c <content> | --content <content>]
            [-e | --encrypt] [-f <filename> | --filename <filename>]
            [-t <title> | --title <title>] [--type <type>]

Options:
  -c --content   <content>    The content for the new note.
  -e --encrypt                Encrypt the note with a password.
  -f --filename  <filename>   The filename for the new note.
  -t --title     <title>      The title for a new note. If `--title` is
                              present, the filename will be derived from the
                              title, unless `--filename` is specified.
  --type         <type>       The file type for the new note, as a file
                              extension.

Description:
  Create a new note.

  If no arguments are passed, a new blank note file is opened with
  `$EDITOR`. If a non-option argument is passed, `notes` will treat it
  as a <filename≥ if a file extension is found. If no file extension is
  found, `notes` will treat the string as <content> and will create a
  new note without opening the editor. `notes add` can also create a new
  note with piped content.

  `notes` creates Markdown files by default. To create a note with a
  different file type, use the extension in the filename or use the `--type`
  option. To change the default file type, use `notes settings`.

  When the `--encrypt` option is specified, `notes` will encrypt the
  note with AES-256.

Examples:
  notes add
  nores add example.md
  notes add "Note content."
  notes add example.md --title "Example Title" --content "Example content."
  echo "Note content." | notes add
  notes add -t "Secret Document" --encrypt

Alias: `a`
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

Alias: `d`
```

#### `edit`

```text
Usage:
  notes edit (<id> | <filename> | <path> | <title>)

Description:
  Open the specified note in `$EDITOR`. Any data piped to `notes edit` will be
  appended to the file.

  Non-text files will be opened in your system's preferred app or program for
  that file type.

Example:
  notes edit 1
  echo "Content to append." | noted edit 1

Alias: `e`
```

#### `env`

```text
Usage:
  notes env

Description:
  Print program environment variables.
```

#### `export`

```text
Usage:
  notes export (<id> | <filename> | <path> | <title>) <path> [--force]
               [<pandoc options>...]
  notes export pandoc (<id> | <filename> | <path> | <title>)
               [<pandoc options>...]

Options:
  --force    Skip the confirmation prompt when overwriting an existing file.

Subcommands:
  (default)  Export a file to <path>. If <path> has a different extension from
             the source note, convert the note using `pandoc`.
  pandoc     Export the file to standard output or a file using `pandoc`.
             `export pandoc` prints to standard output by default.

Description:
  Export a file from the notebook.

  If Pandoc [1] is available, convert the note from its current format
  to the format of the output file as indicated by the file extension
  in <path>. Any additional arguments are passed directly to Pandoc.
  See the Pandoc help information for available options.

    1. http://pandoc.org/

Examples:
  # Export an Emacs Org mode note
  notes export example.org /path/to/example.org

  # Export a Markdown note to HTML and print to standard output
  notes export pandoc example.md --from=markdown_strict

  # Export a Markdown note to a .docx Microsoft Office Word document
  notes export example.md /path/to/example.doc
```

#### `git`

```text
Usage:
  notes git <git options>...

Description:
  Alias for `git` within the current notebook.
```

#### `help`

```text
Usage:
  notes help [<subcommand>]

Description:
  Print the program help information. When a subcommand name is passed, print
  the help information for the subcommand.
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

#### `import`

```text
Usage:
  notes import (<path> | <url>)
  notes import copy <path>
  notes import download <url> [--convert]
  notes import move <path>

Options:
  --convert    Convert HTML content to Markdown.

Subcommands:
  (default) Copy or download the file in <path> or <url>.
  copy      Copy the file at <path> into the current notebook.
  download  Download the file at <url> into the current notebook.
  move      Copy the file at <path> into the current notebook.

Description:
  Copy, move, or download a file into the current notebook.
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
  notes list [-e [<length>] | --excerpt [<length>]] [--no-id] [-n <limit>]
             [-s | --sort] [-r | --reverse] [--titles]
             [<id> | <filename> | <path> | <title>]

Options:
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --no-id                Don't print the id next to each note's filename.
  -n           <limit>   The maximum number of notes to list.
  -s --sort              Order notes by id.
  -r --reverse           Order notes by id descending.
  --titles               Show title instead of filename when present.

Description:
  List notes in the current notebook.

Examples:
  notes list
  notes list example.md -e 10
  notes list --excerpt --no-id
  notes list --titles --reverse
```

#### `ls`

```text
Usage:
  notes ls [<list options>...]

Description:
  List notebooks and notes in the current notebook. Options are passed through
  to `list`. For more information, see `notes help list`.
```

#### `move`

```text
Usage:
  notes move (<id> | <filename> | <path> | <title>) [--force] <notebook>

Description:
  Move the specified note to <notebook>.

Alias: `mv`
```

#### `notebook`

```text
Usage:
  notes notebook

Description:
  Print the current notebook name.
```

#### `notebooks`

```text
Usage:
  notes notebooks [<name>] [--names] [--no-color]
  notes notebooks add <name> [<remote-url>]
  notes notebooks current
  notes notebooks rename <old-name> <new-name>
  notes notebooks use <name>

Subcommands:
  (default)  List notebooks.
  add        Create a new notebook.
  current    Print the current notebook name.
  rename     Rename a notebook.
  use        Switch to a notebook.
```

#### `open`

```text
Usage:
  notes open

Description:
  Open the notebook directory in your file browser, explorer, or finder.
```

#### `remote`

```text
Usage:
  notes remote
  notes remote remove
  notes remote set <url> [--force]

Subcommands:
  (default)  Print the remote URL for the notebook.
  remove     Remove the remote URL from the notebook.
  set        Set the remote URL for the notebook.

Description:
  Get, set, and remove the remote repository URL for the current notebook.
```

#### `rename`

```text
Usage:
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset)

Options:
  --reset  Reset the filename to the timestamp at which it was last updated.

Description:
  Rename a note. Set the filename to <name> for the specified note file.
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
    1. `rg`    https://github.com/BurntSushi/ripgrep
    2. `ag`    https://github.com/ggreer/the_silver_searcher
    3. `ack`   http://beyondgrep.com/
    4. `grep`  https://en.wikipedia.org/wiki/Grep

Alias: `q`
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

Description:
  Show a note. Notes in text file formats can be rendered or dumped to
  standard output. Non-text files will be opened in your system's preferred
  app or program for that file type.

  If Pygments [4] is installed, notes are printed with syntax highlighting.

    1. http://pandoc.org/
    2. https://en.wikipedia.org/wiki/Lynx_(web_browser)
    3. https://en.wikipedia.org/wiki/W3m
    4. http://pygments.org/

Alias: `s`
```

#### `settings`

```text
Usage:
  notes settings

Description:
  Open the ~/.notesrc configuration file in `$EDITOR`.

  For more information about .notesrc, visit:
  https://github.com/xwmx/notes#configuration
```

#### `status`

```text
Usage:
  notes status

Description:
  Run `git status` the current notebook.
```

#### `sync`

```text
Usage:
  notes sync [-a | --all]

Options:
  -a --all  Sync all notebooks.

Description:
  Sync the current local notebook with the remote repository.
```

#### `use`

```text
Usage:
  notes use <notebook>

Description:
  Switch to the specified notebook. Shortcut for `notes notebooks use`.

Alias: `u`
```

#### `version`

```text
Usage:
  notes version

Description:
  Display version information.
```

## Configuration

`notes` is configured using environment variables set in the `.notesrc` file
in your home directory.

Open your `~/.notesrc` configuration file in your editor:

```bash
notes settings
```

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

The location of the directory that contains the notebooks.
For example, to store your notes in Dropbox, you could use:

```bash
export NOTES_DIR="~/Dropbox/Notes"
```

#### `$NOTES_DEFAULT_EXTENSION`

Default: `md`

The default extension to use for notes files. Change to `org` for Emacs Org
mode files, `rst` for reStructuredText, `txt` for plain text, or whatever you
prefer.

Example Values:
[`md`](https://en.wikipedia.org/wiki/Markdown),
[`org`](https://en.wikipedia.org/wiki/Org-mode),
[`txt`](https://en.wikipedia.org/wiki/Text_file),
[`rst`](https://en.wikipedia.org/wiki/ReStructuredText)

Example:
```bash
export NOTES_DEFAULT_EXTENSION="org"
```

#### `$EDITOR`

Default: inherits the global `$EDITOR` value.

Reassign `$EDITOR` to use a specific editor with `notes`, overriding the
global `$EDITOR` setting.

Example Values:
[`vim`](https://en.wikipedia.org/wiki/Vim_\(text_editor\)),
[`emacs`](https://en.wikipedia.org/wiki/Emacs),
[`code`](https://en.wikipedia.org/wiki/Visual_Studio_Code),
[`subl`](https://en.wikipedia.org/wiki/Sublime_Text),
[`atom`](https://en.wikipedia.org/wiki/Atom_\(text_editor\)),
[`macdown`](https://macdown.uranusjr.com/)

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
