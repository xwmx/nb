# notes

```
__                _
\ \   _ __   ___ | |_ ___  ___
 \ \ | '_ \ / _ \| __/ _ \/ __|
 / / | | | | (_) | ||  __/\__ \
/_/  |_| |_|\___/ \__\___||___/
```

`notes` is a command line note-taking, bookmarking, and document management
tool with encryption, advanced search, [Git](https://git-scm.com/)-backed
versioning and syncing, [Pandoc](http://pandoc.org/)-backed conversion,
tagging, an interactive shell, and more in a single portable script.
`notes` creates notes in text-based formats like
[Markdown](https://daringfireball.net/projects/markdown/) and
[Emacs Org mode](https://orgmode.org/), can organize and
work with files in any format, and can export notes to many document formats.
`notes` can also create private, password-protected encrypted notes and
bookmarks.

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

`notes` is designed to be lightweight and portable, with a focus on vendor and
tool independence, while providing a full-featured, intuitive experience. The
entire program is a single well-tested Bash script that can be copied anywhere
and should continue working as long as Bash, Git, and standard Linux / Unix
environments exist. Since `notes` files are normal markdown files, it's easy
to incorporate or switch to any other tool, or just manage your notes manually
in your shell or file browser.

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
- [GnuPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard)
- [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL)
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

This will set up your initial "home" notebook where notes will be stored.

### Working with Notes

#### Adding Notes

To add a note:

```bash
# create a new note in your text editor
notes add

# create a new note with the filename 'example.md'
notes add example.md

# create a new note containing "This is a note."
notes add "This is a note."

# create a new note with piped content
echo "Note content." | notes add

# create a new password-protected, encrypted note
notes add --title "Secret Document" --encrypt
```

`notes add` with no arguments or input will open the new, blank note in your
environment's preferred text editor. You can change your editor using the
[`$EDITOR`](https://askubuntu.com/questions/432524) variable in your
environment or [`notes settings`](#configuration).

`notes` files are [Markdown](https://daringfireball.net/projects/markdown/)
files by default. To change the file type, see `notes help add`.

Password-protected notes are encrypted with AES-256 using OpenSSL by
default. GPG is also supported and can be configured in `notes settings`.
Encrypted notes can be decrypted using the OpenSSL and GPG command line
tools directly, so you aren't dependent on `notes` to decrypt your
files.

#### Listing Notes

To list your notes and notebooks, run `notes ls`:

```bash
> notes ls
home
--------------
[3] example.md
[2] todos.md
[1] ideas.md
```

Notebooks are listed above the line, with the current notebook highlighted.
Notes from the current notebook are listed with each id and either the
filename or title, if one is present.

Titles can be defined within a note using
[either Markdown `h1` style](https://daringfireball.net/projects/markdown/syntax#header)
or [YAML front matter](https://jekyllrb.com/docs/front-matter/):

```markdown
# Example Title
```

```markdown
Todos
=====
```

```markdown
---
title: Ideas
---
```

Once defined, titles will be displayed in place of the filename in the output
of `notes ls`:

```text
home
-----------------
[3] Example Title
[2] Todos
[1] Ideas
```

Pass an id, filename, or title to view the listing for that note:

```bash
> notes ls Todos
[2] Todos
```

```bash
> notes ls 3
[3] Example Title
```

If there is no immediate match, `notes` will list items with titles and
filenames that fuzzy match the query:

```bash
> notes ls 'idea'
[1] Ideas
```

A case-insensitive regular expression can also be to filter filenames and
titles:

```bash
> notes ls '^example.*'
[3] Example Title
```

For full text search, see `notes help search`.

To view excerpts of notes, use the `--excerpt` or `-e` option:

```bash
> notes ls 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt.
```

Bookmarks and encrypted notes are indicated with `🔖` and `🔒`, making them
easily identifiable in lists:

```text
[4] Example Note
[3] 20200101000001.md.enc 🔒
[2] Example Bookmark (example.com) 🔖
[1] 20200101000000.bookmark.md.enc 🔖 🔒
```

`notes` with no subcommand is an alias for `notes ls`, so the examples above
can be run without the `ls`:

```bash
> notes
home
-----------------
[3] Example Title
[2] Todos
[1] Ideas

> notes '^example.*'
[3] Example Title

> notes 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt
```

`notes ls` is a combination of `notes notebooks` and
`notes list --titles` in one view and accepts the to the same arguments
as `notes list`, which can be used to list only notes.

For more information about options for listing notes, run `notes help ls` and
`notes help list`.

#### Editing Notes

You can edit a note in your editor using its id, filename, or title:

```bash
# edit note by id
notes edit 3

# edit note by filename
notes edit example.md

# edit note by title
notes edit 'A Document Title'
```

`notes edit` can also receive piped content, which it will append to the
specified note:

```bash
echo "Content to append." | notes edit 1
```

When a note is encrypted, `notes edit` will prompt you for the note password,
open the unencrypted content in your editor, and then automatically reencrypt
the note when you are done editing.

#### Deleting Notes

Deleting notes works the same:

```bash
# delete note by id
notes delete 3

# delete note by filename
notes delete example.md

# delete note by title
notes delete 'A Document Title'
```

#### Bookmarks

`notes bookmark` is used to create and view bookmarks. Bookmarks are
Markdown notes containing information about the bookmarked page. To create a
new bookmark:

```bash
notes bookmark https://example.com
```

`notes` automatically generates a bookmark using information from the page:

```markdown
# Example Domain (example.com)

<https://example.com>

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

`notes` embeds the page content in the bookmark, making it available for full
text search with `notes search`. When `pandoc` is installed, the HTML page
content will be converted to Markdown.

Bookmarks can be tagged using the `--tags` option. Tags are converted
into hashtags:

```bash
notes bookmark https://example.com --tags tag1,tag2
```
```markdown
# Example Domain (example.com)

<https://example.com>

## Tags

#tag1 #tag2

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

Bookmarks can also be encrypted:

```bash
# create a new password-protected, encrypted bookmark
notes bookmark https://example.com --encrypt
```

##### Opening Bookmarks

`notes bookmark` provides two ways to view bookmarked web pages.

`notes bookmark open` opens the bookmarked page in your system's primary web
browser:

```bash
# open bookmark by id
notes bookmark open 3
```

`notes bookmark peek` opens the bookmarked page in your terminal web
browser:

```bash
# peek bookmark by id
notes bookmark peek 12
```

`notes bookmark open` and `notes bookmark peek` also work seamlessly with
encrypted bookmarks. `notes` will simply prompt you for the bookmark's
password.

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimal valid bookmark file with `notes add`:

```bash
notes add example.bookmark.md --content "<https://example.com>"
```

### Search

Use `notes search` to search your notes, with support for regular
expressions and tags:

```bash
# search current notebook for 'example query'
notes search 'example query'

# search all notebooks for 'example query'
notes search 'example query' --all

# search notes for 'Example' OR 'Sample'
notes search 'Example|Sample'

# search for notes containing the hashtag '#example'
notes search '#example'

# search with a regular expression for notes containing phone numbers
notes search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'
```

`notes search` looks for [`rg`](https://github.com/BurntSushi/ripgrep),
[`ag`](https://github.com/ggreer/the_silver_searcher),
[`ack`](http://beyondgrep.com/), and
[`grep`](https://en.wikipedia.org/wiki/Grep), in that order, and
performs searches using the first tool it finds.

### Revision History

Whenever a note is added, modified, or deleted, `notes` automatically commits
the change to git transparently in the background. You can view the history of
the notebook or an individual note with:

```bash
# show history for current notebook
notes history

# show history for note 4
notes history 4
```

### Notebooks

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

For more information about working with notebooks, run `notes help notebooks`.

### Syncing with Remotes

Each notebook can be synced with a remote git repository by setting the
remote URL:

```bash
# set the current notebook's remote to a private GitHub repository
notes remote set https://github.com/example/example.git
```

When you have an existing `notes` notebook in a git repository, simply
pass the URL to `notes notebooks add` and `notes` will clone your
existing notebook and start syncing changes automatically:

```bash
# create a new notebook named Example cloned from a private GitLab repository
notes notebooks add Example https://gitlab.com/example/example.git
```

Any notebook with a remote URL will sync automatically every time a command is
run in that notebook. Turn off syncing for a notebook by simply removing the
remote:

```bash
# remove the current remote from the current notebook
notes remote remove
```

You can also turn off autosync in `notes settings` and sync manually with
`notes sync`.

### Import / Export

Files of any type can be imported into a notebook. `notes show` and
`notes edit` will open files in your system's default application for that
file type.

```bash
# import an image file
notes import ~/Pictures/example.png

# open image in your default image viewer
notes show example.png
```

`notes import` can also download and import files directly from the web:

```bash
notes import https://example.com/example.pdf
# Imported 'https://example.com/example.pdf' to 'example.pdf'
```

Notes can also be exported. If you have Pandoc installed, notes can
be converted to any of the
[formats supported by Pandoc](https://pandoc.org/MANUAL.html#option--to).
By default, the output format is determined by the file extension:

```bash
# Export a Markdown note to a .docx Microsoft Office Word document
notes export example.md /path/to/example.docx

# Export a note titled 'Movies' to an HTML web page.
notes export Movies /path/to/example.html
```

### Interactive Shell

`notes` has an interactive shell that can be started with `notes shell`,
`notes -i`, or `notes --interactive`:

```bash
$ notes -i
notes> ls example
[3] Example

notes> edit 3 --content "New content."
Updated [3] Example

notes> notebook
home

notes> exit
$
```

The `notes` shell recognizes all `notes` subcommands and options,
providing a streamlined, distraction-free approach for working with `notes`.

### Shortcut Aliases

Several core `notes` subcommands have single-character aliases to make
them faster to work with:

```bash
# `a` (add): add a new note named 'example.md'
notes a example.md

# `b` (bookmark): add a new bookmark for https://example.com
notes b https://example.com

# `b o` (bookmark open): open bookmark 12 in your web browser
notes b o 12

# `b p` (bookmark peek): open bookmark 6 in your terminal browser
notes b p 6

# `e` (edit): edit note 5
notes e 5

# `d` (delete): delete note 19
notes d 19

# `q` (search): search notes for 'example query'
notes q 'example query'

# `h` (help): display the help information for the `add` subcommand
notes h add

# `u` (use): switch to example-notebook
notes u example-notebook
```

If `n` is available on your system, you can add `alias n="notes"` to your
`~/.bashrc` or equivalent, which will enable you to:

```bash
# add a new note
n a

# add a new bookmark for example.com
n b https://example.com

# open bookmark 12 in your web browser
n b o 12

# edit note 5
n e 5

# search notes for the hashtag '#example'
n q '#example'
```

For more commands and options, run `notes help` or `notes help
<subcommand>`

### Help

```text
Usage:
  notes [<id> | <filename> | <path> | <title>] [<list options>]
  notes add [<filename> | <content>] [-c <content> | --content <content>]
            [-e | --encrypt] [-f <filename> | --filename <filename>]
            [-t <title> | --title <title>] [--type <type>]
  notes bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--skip-content] [--tags <tag1>,<tag2>...]
                 [--title <title>]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  notes count
  notes delete (<id> | <filename> | <path> | <title>) [-f | --force]
  notes edit (<id> | <filename> | <path> | <title>)
  notes export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
               [<pandoc options>...]
  notes git <git options>...
  notes history [<id> | <filename> | <path> | <title>]
  notes import [copy | download | move] (<path> | <url>) [--convert]
  notes init [<remote-url>]
  notes list [-e [<length>] | --excerpt [<length>]] [--no-id]
             [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
             [--titles] [<id> | <filename> | <path> | <title> | <query>]
  notes ls [<list options>...]
  notes move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>
  notes notebook [open]
  notes notebooks [<name>] [--names] [--no-color]
  notes notebooks add <name> [<remote-url>]
  notes notebooks current
  notes notebooks rename <old-name> <new-name>
  notes notebooks use <name>
  notes remote [remove | set <url> [-f | --force]]
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset)
  notes search <query> [-a | --all] [--path]
  notes settings
  notes shell [<subcommand> [<options>...] | --clear-history]
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]
  notes sync [-a | --all]
  notes use <notebook>
  notes -i | --interactive [<subcommand> [<options>...]]
  notes -h | --help | help [<subcommand>]
  notes --version | version

Help:
  notes help [<subcommand>]

Subcommands:
  (default)  List notes and notebooks. This is an alias for `notes ls`.
  add        Add a new note.
  bookmark   Add and open bookmarks.
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
  notebook   Manage the current notebook.
  notebooks  Manage notebooks.
  remote     Get, set, and remove the remote URL for the notebook.
  rename     Rename a note.
  search     Search notes.
  settings   Edit configuration settings.
  shell      Start the `notes` interactive shell.
  show       Show a note.
  status     Run `git status` in the current notebook.
  sync       Sync local notebook with the remote repository.
  use        Switch to a notebook.
  version    Display version information.

Program Options:
  -i --interactive  Start the `notes` interactive shell.
  -h --help         Display this help information.
  --version         Display version information.
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

  When the `-e` / `--encrypt` option is used, `notes` will encrypt the
  note with AES-256 using OpenSSL by default, or GPG, if configured in
  `notes settings`.

Examples:
  notes add
  notes add example.md
  notes add "Note content."
  notes add example.md --title "Example Title" --content "Example content."
  echo "Note content." | notes add
  notes add -t "Secret Document" --encrypt

Shortcut Alias: `a`
```

#### `bookmark`

```text
Usage:
  notes bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--skip-content] [--tags <tag1>,<tag2>...]
                 [--title <title>]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)

Options:
  -c --comment   <comment>      A comment or description for this bookmark.
  --edit                        Open the bookmark in your editor before saving.
  -e --encrypt                  Encrypt the bookmark with a password.
  --skip-content                Omit page content from the note.
  --tags         <tag1>,<tag2>  A comma-separated list of tags.
  --title        <title>        The bookmark title. When not specified,
                                `notes` will use the html <title> tag.

Subcommands:
  open    Open the bookmarked page in your system's primary web browser.
          Shortcut Alias: `o`
  peek    Open the bookmarked page in your terminal web browser.
          Shortcut Alias: `p`
  url     Print the URL for the specified bookmark.

Description:
  Create and view bookmarks.

  By default, the page content is saved within the bookmark, making the
  bookmarked page available for full-text search with `notes search`.
  When `pandoc` is installed, content will be converted to Markdown.

  Bookmark are identified by the `.bookmark.md` file extension. The bookmark
  URL is the first URL in the file within '<' and '>' characters:

    <https://www.example.com>

Examples:
  notes bookmark https://example.com
  notes bookmark https://example.com --tags example,sample,demo
  notes bookmark https://example.com/about --title 'Example Title'
  notes bookmark https://example.com -c 'Example comment.'
  notes bookmark open 5

Shortcut Alias: `b`
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
  notes delete (<id> | <filename> | <path> | <title>) [-f | --force]

Options:
  -f --force  Skip the confirmation prompt.

Description:
  Delete a note.

Examples:
  notes delete 3
  notes delete example.md
  notes delete 'A Document Title'

Shortcut Alias: `d`
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

Examples:
  notes edit 3
  notes edit example.md
  notes edit 'A Document Title'
  echo "Content to append." | notes edit 1

Shortcut Alias: `e`
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
  notes export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
               [<pandoc options>...]
  notes export pandoc (<id> | <filename> | <path> | <title>)
               [<pandoc options>...]

Options:
  -f --force  Skip the confirmation prompt when overwriting an existing file.

Subcommands:
  (default)   Export a file to <path>. If <path> has a different extension
              than the source note, convert the note using `pandoc`.
  pandoc      Export the file to standard output or a file using `pandoc`.
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
  notes export pandoc example.md --from=markdown_strict --to=html

  # Export a Markdown note to a .docx Microsoft Office Word document
  notes export example.md /path/to/example.docx
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

Shortcut Alias: `h`
```

#### `history`

```text
Usage:
  notes history [<id> | <filename> | <path> | <title>]

Description:
  Display notebook history using `tig` [1] (if available) or `git log`.
  When a note is specified, the history for that note is displayed.

    1. https://github.com/jonas/tig

Examples:
  notes history
  notes history example.md
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

Examples:
  notes import ~/Pictures/example.png
  notes import ~/Documents/example.docx
  notes import https://example.com/example.pdf
```

#### `init`

```text
Usage:
  notes init [<remote-url>]

Description:
  Initialize the local git repository.

Examples:
  notes init
  notes init https://github.com/example/example.git
```

#### `list`

```text
Usage:
  notes list [-e [<length>] | --excerpt [<length>]] [--no-id]
             [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
             [--titles] [<id> | <filename> | <path> | <title> | <query>]

Options:
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --no-id                Don't print the id next to each note's filename.
  -n           <limit>   The maximum number of notes to list.
  --<limit>              Shortcut for `-n <limit>`.
  -s --sort              Order notes by id.
  -r --reverse           Order notes by id descending.
  --titles               Show title instead of filename when present.

Description:
  List notes in the current notebook.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

Examples:
  notes list
  notes list example.md -e 10
  notes list --excerpt --no-id
  notes list --titles --reverse
  notes list '^Example.*'
  notes list --10
```

#### `ls`

```text
Usage:
  notes ls [-e [<length>] | --excerpt [<length>]] [--no-id]
           [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
           [<id> | <filename> | <path> | <title> | <query>]

Options:
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --no-id                Don't print the id next to each note's filename.
  -n           <limit>   The maximum number of notes to list.
  --<limit>              Shortcut for `-n <limit>`.
  -s --sort              Order notes by id.
  -r --reverse           Order notes by id descending.

Description:
  List notebooks and notes in the current notebook, displaying note titles
  when available. `notes ls` is a combination of the `notes notebooks`
  and `notes list --titles` commands in one view.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

  Options are passed through to `list`. For more information, see
  `notes help list`.

Examples:
  notes ls
  notes ls example.md -e 10
  notes ls --excerpt --no-id
  notes ls --reverse
  notes list '^Example.*'
  notes list --10
```

#### `move`

```text
Usage:
  notes move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>

Options:
  -f --force  Skip the confirmation prompt.

Description:
  Move the specified note to <notebook>.

Examples:
  notes move 1 example-notebook
  notes move example.md example-notebook

Shortcut Alias: `mv`
```

#### `notebook`

```text
Usage:
  notes notebook

Description:
  Print the current notebook name.

Shortcut Alias: `nb`
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

Description:
  Manage notebooks.

Examples:
  notes notebooks --names
  notes notebooks add Example1
  notes notebooks add Example2 https://github.com/example/example.git

Shortcut Alias: `nbs`
```

#### `remote`

```text
Usage:
  notes remote
  notes remote remove
  notes remote set <url> [-f | --force]

Subcommands:
  (default)  Print the remote URL for the notebook.
  remove     Remove the remote URL from the notebook.
  set        Set the remote URL for the notebook.

Options:
  -f --force  Skip the confirmation prompt.

Description:
  Get, set, and remove the remote repository URL for the current notebook.

Examples:
  notes remote set https://github.com/example/example.git
  notes remove remove
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

Examples:
  # search current notebook for 'example query'
  notes search 'example query'

  # search all notebooks for 'example query'
  notes search 'example query' --all

  # search notes for 'Example' OR 'Sample'
  notes search 'Example|Sample'

  # search for notes containing the hashtag '#example'
  notes search '#example'

  # search with a regular expression for notes containing phone numbers
  notes search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'

Shortcut Alias: `q`
```

#### `shell`

```text
Usage:
  notes shell [<subcommand> [<options>...] | --clear-history]

Optons:
  --clear-history  Clear the `notes` shell history.

Description:
  Start the `notes` interactive shell. Type 'exit' to exit.

  When <subcommand> is present, the command will run as the shell is opened.

Example:
  $ notes shell
  notes> ls 3
  [3] Example

  notes> edit 3 --content "New content."
  Updated [3] Example

  notes> notebook
  home

  notes> exit
  $
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

Examples:
  notes show 1
  notes show example.md --render
  notes show 'A Document Title' --dump --no-color

Shortcut Alias: `s`
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

Shortcut Alias: `u`
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

#### `$NOTES_ENCRYPTION_TOOL`

Default: `openssl`

The tool used for encrypting notes.

Supported Values:
[`openssl`](https://www.openssl.org/),
[`gpg`](https://gnupg.org/)

Example:
```bash
export NOTES_ENCRYPTION_TOOL="gpg"
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

`notes` has [an extensive test suite](test). To run it, install
[Bats](https://github.com/sstephenson/bats) and run `bats test` in the project
root directory.

---
<p align="center">
  Copyright (c) 2015-present William Melody • See LICENSE for details.
</p>

<p align="center">
  <a href="https://github.com/xwmx/notes">github.com/xwmx/notes</a>
</p>

<p align="center">
  📝🔖🔒🔍📔
</p>
