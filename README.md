[![Build Status](https://travis-ci.org/xwmx/notes.svg?branch=master)](https://travis-ci.org/xwmx/notes)

```
__                _
\ \   _ __   ___ | |_ ___  ___
 \ \ | '_ \ / _ \| __/ _ \/ __|
 / / | | | | (_) | ||  __/\__ \
/_/  |_| |_|\___/ \__\___||___/
```

# notes

`notes` is a command line note-taking, bookmarking, and archiving
tool with encryption, search, [Git](https://git-scm.com/)-backed versioning
and syncing, [Pandoc](http://pandoc.org/)-backed conversion, tagging, and more
in a single portable script. `notes` creates notes in text-based formats like
[Markdown](https://daringfireball.net/projects/markdown/) and
[Emacs Org mode](https://orgmode.org/), can organize and
work with files in any format, and can export notes to many document formats.
`notes` can also create private, password-protected encrypted notes and
bookmarks.

With `notes`, you can add and edit notes using Vim, Emacs, VS Code, Sublime
Text, and any other text editor you prefer. `notes` works in any
standard Linux / Unix environment, including macOS and Windows via WSL.
[Optional dependencies](#optional) can be installed to enhance functionality,
but `notes` works great without them.

`notes` uses [Git](https://git-scm.com/) in the background to automatically
record changes and sync with a remote repository, if one has been configured.
`notes` can also be configured to save notes in a location used by a general
purpose syncing utility like Dropbox so notes can be edited in other apps on
any device.

`notes` is designed to be lightweight and portable, with a focus on vendor and
tool independence, while providing a full-featured, intuitive experience. The
entire program is a single well-tested script that can be copied or `curl`ed
anywhere and just work, using a
[progressive enhancement](https://en.wikipedia.org/wiki/Progressive_enhancement)
approach for various experience improvements in more capable environments.
`notes` makes it easy to incorporate other tools, writing apps, and workflows.
`notes` can be used a little, a lot, once in a while, or for just a subset of
features. `notes` is flexible.

#### Dependencies

##### Required

- [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))
  - `notes` works perfectly with Zsh, fish, and any other shell set as your
    primary login shell, the system just needs to have Bash available on it.
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

`notes` leverages standard command line tools and works in standard
Linux / Unix environments. `notes` also checks the environment for some
additional optional tools and uses them to enhance the experience whenever
they are available.

Recommended:

- [Pandoc](https://pandoc.org/)
- [Pygments](http://pygments.org/)
- [rg - ripgrep](https://github.com/BurntSushi/ripgrep)
- [tig](https://github.com/jonas/tig)
- [w3m](https://en.wikipedia.org/wiki/W3m)

Also supported:

- [Ack](http://beyondgrep.com/)
- [Ag - The Silver Searcher](https://github.com/ggreer/the_silver_searcher)
- [GnuPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard)
- [Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser))

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

#### bpkg

To install with [bpkg](https://github.com/bpkg/bpkg):

```bash
bpkg install xwmx/notes
```

#### Make

To install with [Make](https://en.wikipedia.org/wiki/Make_(software)),
clone this repository, navigate to the clone's root directory, and run:

```bash
make install
```

Depending on your system configuration, `sudo` might be required:

```bash
sudo make install
```

#### Manual

To install as an administrator, copy and paste one of the following multi-line
commands:

```bash
# install using curl
sudo curl -L https://raw.github.com/xwmx/notes/master/notes -o /usr/local/bin/notes &&
  sudo chmod +x /usr/local/bin/notes &&
  sudo notes completions install --download

# install using wget
sudo wget https://raw.github.com/xwmx/notes/master/notes -O /usr/local/bin/notes &&
  sudo chmod +x /usr/local/bin/notes &&
  sudo notes completions install --download
```

To install as a user, simply add the `notes` script to your `$PATH`. If
you already have a `~/bin` directory, for example, you can use one of the
following commands:

```bash
# download with curl
curl -L https://raw.github.com/xwmx/notes/master/notes -o ~/bin/notes && chmod +x ~/bin/notes

# download with wget
wget https://raw.github.com/xwmx/notes/master/notes -O ~/bin/notes && chmod +x ~/bin/notes
```

#### Tab Completion

Bash and Zsh tab completion should be enabled when `notes` is installed using
Homebrew, npm, bpkg, or Make, assuming you have the appropriate system
permissions or installed with `sudo`. If completion isn't working after
installing `notes`, see the [completion installation
instructions](etc/README.md).

## Usage

<p align="center">
  <a href="#working-with-notes">Notes</a> •
  <a href="#bookmarks">Bookmarks</a> •
  <a href="#search">Search</a> •
  <a href="#revision-history">History</a> •
  <a href="#notebooks">Notebooks</a> •
  <a href="#syncing-with-remotes">Git Sync</a> •
  <a href="#import--export">Import / Export</a> •
  <a href="#highlight-color-settings">Settings</a> •
  <a href="#interactive-shell">Shell</a> •
  <a href="#shortcut-aliases">Shortcuts</a> •
  <a href="#help">Help</a>
</p>

To get started, simply run:

```bash
notes
```

This will set up your initial "home" notebook where notes will be stored.


### Working with Notes

#### Adding Notes

Use `notes add` to create new notes:

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
environment or [`notes settings`](#settings).

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
----
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

```bash
> notes ls
home
----
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

```bash
> notes ls
home
----
[4] Example Note
[3] 🔒 example-encrypted.md.enc
[2] 🔖 Example Bookmark (example.com)
[1] 🔖 🔒 example-encrypted.bookmark.md.enc
```

`notes` with no subcommand is an alias for `notes ls`, so the examples above
can be run without the `ls`:

```bash
> notes
home
----
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

`notes ls` is a combination of `notes notebooks` and `notes list --titles` in
one view and accepts the same arguments as `notes list`, which lists notes.

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

### Bookmarks

Use `notes bookmark` to create, view, and search bookmarks, links, and
online references. Bookmarks are Markdown notes containing information about
the bookmarked page. To create a new bookmark:

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
text search with `notes search` and `notes bookmark search`. When `pandoc` is
installed, the HTML page content will be converted to Markdown.

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

Search for tagged bookmarks with `notes bookmark search`:

```bash
notes bookmark search '#tagname'
```

`notes bookmark search` has the same full text search as `notes search`.
Search both bookmarks and notes with `notes search`:

```bash
notes search '#tagname'
```

Bookmarks can also be encrypted:

```bash
# create a new password-protected, encrypted bookmark
notes bookmark https://example.com --encrypt
```

#### Opening Bookmarks

`notes bookmark` provides two ways to view bookmarked web pages.

`notes open` opens the bookmarked page in your system's primary web
browser:

```bash
# open bookmark by id
notes open 3
```

`notes peek` opens the bookmarked page in your terminal web browser:

```bash
# peek bookmark by id
notes peek 12
```

`notes open` and `notes peek` also work seamlessly with encrypted bookmarks.
`notes` will simply prompt you for the bookmark's password.

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimal valid bookmark file with `notes add`:

```bash
notes add example.bookmark.md --content "<https://example.com>"
```

#### `bookmark` -- A command line tool for managing bookmarks.

`notes` includes a `bookmark` executable that's a shortcut for
`notes bookmark`, providing a nice, simple interface for creating,
viewing, and searching bookmarks.

Bookmark a page:

```bash
> bookmark https://example.com --tags tag1,tag2
Added [3] 20200101000000.bookmark.md 'Example Domain (example.com)'
```
List bookmarks:

```bash
> bookmark list
[3] 🔖 Example Domain (example.com)
[2] 🔖 Example Bookmark Two (example2.com)
[1] 🔖 Example Bookmark One (example1.com)
```

View bookmark in your terminal web browser:

```bash
> bookmark peek 2
```

Open bookmark in your system's primary web browser:

```bash
> bookmark open 2
```

Perform a full text search of bookmarks and archived page content:

```bash
> bookmark search 'example query'
[10] example.bookmark.md 'Example Bookmark'
--------------------------------------------
5:Lorem ipsum example query.
```

See [`bookmark help`](#bookmark-help) for more information.

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

`notes search` prints the id number, filename, and title of each matched
file, followed by each search query match and its line number, with color
highlighting:

```bash
> notes search 'example'
[314] example.bookmark.md 'Example Bookmark'
--------------------------------------------
1:# Example Bookmark

3:<https://example.com>

[2718] example.md 'Example Note'
------------------------
1:# Example Note
```

`notes search` looks for [`rg`](https://github.com/BurntSushi/ripgrep),
[`ag`](https://github.com/ggreer/the_silver_searcher),
[`ack`](http://beyondgrep.com/), and
[`grep`](https://en.wikipedia.org/wiki/Grep), in that order, and
performs searches using the first tool it finds. `notes search` works
the same regardless of which tool is found and is perfectly fine using
the environment's built-in `grep`. `rg`, `ag`, and `ack` are a lot faster
on large notebooks and there are some subtle differences in color
highlighting.

### Revision History

Whenever a note is added, modified, or deleted, `notes` automatically commits
the change to git transparently in the background. You can view the history of
the notebook or an individual note with:

```bash
# show history for current notebook
notes history

# show history for note number 4
notes history 4

# show history for note with filename example.md
notes history example.md

# show history for note titled 'Example'
notes history Example
```

`notes history` uses `git log` by default and prefers
[`tig`](https://github.com/jonas/tig) when available.

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

Any notebook with a remote URL will sync automatically every time a command is
run in that notebook.

When you use `notes` on multiple systems, you can set a notebook on both
systems to the same remote and `notes` will keep everything in sync in the
background every time there's a change in that notebook.

Since each notebook has its own git history, you can have some notebooks
syncing with remotes while other notebooks are only available locally on that
system.

GitHub, GitLab, Bitbucket, and many other services provide free private git
repositories, so git syncing with `notes` is easy, free, and
vendor-independent. You can also sync your notes using Dropbox, Drive,
Box, Syncthing, or another syncing tool by changing your `notes` directory in
`notes settings` and git syncing will still work simultaneously.

When you have an existing `notes` notebook in a git repository, simply
pass the URL to `notes notebooks add` and `notes` will clone your
existing notebook and start syncing changes automatically:

```bash
# create a new notebook named Example cloned from a private GitLab repository
notes notebooks add Example https://gitlab.com/example/example.git
```

Turn off syncing for a notebook by simply removing the remote:

```bash
# remove the current remote from the current notebook
notes remote remove
```

You can also turn off autosync in `notes settings` and sync manually with
`notes sync`.

### Import / Export

Files of any type can be imported into a notebook. `notes edit`, `notes
open`, and `notes show` will open files in your system's default application
for that file type.

```bash
# import an image file
notes import ~/Pictures/example.png

# open image in your default image viewer
notes open example.png

# import a .docx file
notes import ~/Documents/example.docx

# open .docx file in Word or your system's .docx viewer
notes open example.docx
```

`notes import` can also download and import files directly from the web:

```bash
# import a PDF file from the web
notes import https://example.com/example.pdf
# Imported 'https://example.com/example.pdf' to 'example.pdf'

# open example.pdf in your system's PDF viewer
notes open example.pdf
```

Some imported file types have indicators to make them easier to identify in
lists:

```bash
> notes ls
home
----
[4] 🌄 example-picture.png
[3] 📄 example-document.docx
[2] 📹 example-video.mp4
[1] 🔉 example-audio.mp3
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

### Highlight Color, Settings

`notes` has a minimal text interface and uses color (yellow, by default) to
highlight certain elements like ids, the current notebook name, and the shell
prompt. The highlight color and other options can be changed with
`notes settings`.

```bash
notes settings
```

`notes settings` opens the settings prompt, which prints help information and
provides an easy way to change your settings. To print a list of available
settings, see [`notes help settings`](#settings).

You can update a setting without the prompt using `notes settings set`:

```bash
# set highlight color with name
> notes settings set NOTES_HIGHLIGHT_COLOR 105
NOTES_HIGHLIGHT_COLOR set to '105'

# set highlight color with setting number (6)
> notes setting set 6 105
NOTES_HIGHLIGHT_COLOR set to '105'
```

`NOTES_HIGHLIGHT_COLOR` expects an xterm color number between 0 and 255.
Print a table of available colors and numbers with:

```bash
notes settings colors
```

Print the value of a setting:

```bash
> notes settings get NOTES_HIGHLIGHT_COLOR
105

> notes settings get 6
105
```

Unset a setting and revert to default:

```bash
> notes settings unset NOTES_HIGHLIGHT_COLOR
NOTES_HIGHLIGHT_COLOR restored to the default: '11'

> notes settings get NOTES_HIGHLIGHT_COLOR
11
```

### Interactive Shell

`notes` has an interactive shell that can be started with `notes shell`,
`notes -i`, or `notes --interactive`:

```bash
$ notes -i
notes> ls example
[3] Example
[2] Sample
[1] Demo

notes> edit 3 --content "New content."
Updated [3] Example

notes> bookmark https://example.com
Added [4] example.bookmark.md 'Example Domain (example.com)'

notes> ls
[4] 🔖 Example Domain (example.com)
[3] Example
[2] Sample
[1] Demo

notes> bookmark url 4
https://example.com

notes> search 'example'
[4] example.bookmark.md 'Example Domain (example.com)'
------------------------------------------------------
1:# Example Bookmark

3:<https://example.com>

[3] example.md 'Example'
------------------------
1:# Example

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

# `o` (open): open bookmark 12 in your web browser
notes o 12

# `p` (peek): open bookmark 6 in your terminal browser
notes p 6

# `e` (edit): edit note 5
notes e 5

# `d` (delete): delete note 19
notes d 19

# `s` (show): show note 27
notes s 27

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
n o 12

# edit note 5
n e 5

# search notes for the hashtag '#example'
n q '#example'
```

Similarly, you can `alias b="bookmark"` and do:

```bash
# add a new bookmark
b http://example.com

# open bookmark 12
b o 12

# search bookmarks
b q '#example'
```

For more commands and options, run `notes help` or `notes help <subcommand>`

### Help

<p align="center">
  <a href="#add">add</a> •
  <a href="#bookmark">bookmark</a> •
  <a href="#bookmarks-1">bookmarks</a> •
  <a href="#completions">completions</a> •
  <a href="#count">count</a> •
  <a href="#delete">delete</a> •
  <a href="#edit">edit</a> •
  <a href="#env">env</a> •
  <a href="#export">export</a> •
  <a href="#git">git</a> •
  <a href="#help-1">help</a> •
  <a href="#history">history</a> •
  <a href="#import">import</a> •
  <a href="#init">init</a> •
  <a href="#list">list</a> •
  <a href="#ls">ls</a> •
  <a href="#move">move</a> •
  <a href="#notebook">notebook</a> •
  <a href="#notebooks-1">notebooks</a> •
  <a href="#open">open</a> •
  <a href="#peek">peek</a> •
  <a href="#remote">remote</a> •
  <a href="#rename">rename</a> •
  <a href="#search-1">search</a> •
  <a href="#settings">settings</a> •
  <a href="#shell">shell</a> •
  <a href="#show">show</a> •
  <a href="#status">status</a> •
  <a href="#sync">sync</a> •
  <a href="#use">use</a> •
  <a href="#version">version</a>
</p>

#### `notes help --long`

```text
__                _
\ \   _ __   ___ | |_ ___  ___
 \ \ | '_ \ / _ \| __/ _ \/ __|
 / / | | | | (_) | ||  __/\__ \
/_/  |_| |_|\___/ \__\___||___/

Command line note-taking, bookmarking, and archiving with encryption, search,
Git-backed versioning and syncing, Pandoc-backed format conversion, and more
in a single portable script.

Usage:
  notes [<id> | <filename> | <path> | <title>] [<list options>]
  notes add [<filename> | <content>] [-c <content> | --content <content>]
            [-e | --encrypt] [-f <filename> | --filename <filename>]
            [-t <title> | --title <title>] [--type <type>]
  notes bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--skip-content] [--tags <tag1>,<tag2>...]
                 [--title <title>]
  notes bookmark list [<list options>...]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  notes bookmark search <query>
  notes completions (check | install [-d | --download] | uninstall)
  notes count
  notes delete (<id> | <filename> | <path> | <title>) [-f | --force]
  notes edit (<id> | <filename> | <path> | <title>)
  notes export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
               [<pandoc options>...]
  notes git <git options>...
  notes help [-l | --long]
  notes history [<id> | <filename> | <path> | <title>]
  notes import [copy | download | move] (<path> | <url>) [--convert]
  notes init [<remote-url>]
  notes list [--bookmarks] [-e [<length>] | --excerpt [<length>]] [--no-id]
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
  notes open (<id> | <filename> | <path> | <title>)
  notes peek (<id> | <filename> | <path> | <title>)
  notes remote [remove | set <url> [-f | --force]]
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset)
  notes search <query> [-a | --all] [--bookmarks] [--path]
  notes settings [colors | edit]
  notes settings (get | unset) <setting>
  notes settings set <setting> <value>
  notes shell [<subcommand> [<options>...] | --clear-history]
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]
  notes sync [-a | --all]
  notes use <notebook>
  notes -i | --interactive [<subcommand> [<options>...]]
  notes -h | --help | help [<subcommand>] [-l | --long]
  notes --version | version

Help:
  notes help [<subcommand>]

More Information:
  https://github.com/xwmx/notes

Subcommands:
  (default)    List notes and notebooks. This is an alias for `notes ls`.
  add          Add a new note.
  bookmark     Add, open, list, and search bookmarks.
  bookmarks    List bookmarks.
  completions  Install and uninstall completion scripts.
  count        Print the number of notes.
  delete       Delete a note.
  edit         Edit a note.
  env          Print program environment variables.
  export       Export a note to a variety of different formats.
  git          Alias for `git` within the current notebook.
  help         Display this help information.
  history      Display git history for the current notebook or a note.
  import       Import a file into the current notebook.
  init         Initialize the first notebook.
  list         List notes in the current notebook.
  ls           List notebooks and notes in the current notebook.
  move         Move a note to a different notebook.
  notebook     Manage the current notebook.
  notebooks    Manage notebooks.
  open         Open a bookmark in the primary web browser or edit a note.
  peek         View a bookmark in the terminal web browser or show a note.
  remote       Get, set, and remove the remote URL for the notebook.
  rename       Rename a note.
  search       Search notes.
  settings     Edit configuration settings.
  shell        Start the `notes` interactive shell.
  show         Show a note.
  status       Run `git status` in the current notebook.
  sync         Sync local notebook with the remote repository.
  use          Switch to a notebook.
  version      Display version information.

Program Options:
  -i --interactive  Start the `notes` interactive shell.
  -h --help         Display this help information.
  --version         Display version information.
```

#### `bookmark help`

```text
    __                __                        __
   / /_  ____  ____  / /______ ___  ____ ______/ /__
  / __ \/ __ \/ __ \/ //_/ __ `__ \/ __ `/ ___/ //_/
 / /_/ / /_/ / /_/ / ,< / / / / / / /_/ / /  / ,<
/_.___/\____/\____/_/|_/_/ /_/ /_/\__,_/_/  /_/|_|

bookmark -- A command line tool for managing bookmarks.

Usage:
  bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--skip-content] [--tags <tag1>,<tag2>...]
                 [--title <title>]
  bookmark list [<list options>...]
  bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  bookmark search <query>

Options:
  -c --comment   <comment>      A comment or description for this bookmark.
  --edit                        Open the bookmark in your editor before saving.
  -e --encrypt                  Encrypt the bookmark with a password.
  --skip-content                Omit page content from the note.
  --tags         <tag1>,<tag2>  A comma-separated list of tags.
  --title        <title>        The bookmark title. When not specified,
                                `notes` will use the html <title> tag.

Subcommands:
  list     List bookmarks in the current notebook.
           Shortcut Alias: `ls`
  open     Open the bookmarked page in your system's primary web browser.
           Shortcut Alias: `o`
  peek     Open the bookmarked page in your terminal web browser.
           Alias: `preview`
           Shortcut Alias: `p`
  search   Search bookmarks for <query>.
           Shortcut Alias: `q`
  url      Print the URL for the specified bookmark.

Description:
  Create, view, and search bookmarks.

  By default, the page content is saved within the bookmark, making the
  bookmarked page available for full-text search. When `pandoc` is
  installed, content will be converted to Markdown.

  Bookmark are identified by the `.bookmark.md` file extension. The bookmark
  URL is the first URL in the file within '<' and '>' characters:

    <https://www.example.com>

Examples:
  bookmark https://example.com
  bookmark https://example.com --tags example,sample,demo
  bookmark https://example.com/about --title 'Example Title'
  bookmark https://example.com -c 'Example comment.'
  bookmark list
  bookmark search 'example query'
  bookmark search '^example[[:space:]]regular[[:space:]]expression$'
  bookmark open 5
  bookmark url 10

-----------------------------------------------------
Part of `notes` (https://github.com/xwmx/notes).
For more information, see: `notes help`.
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
  notes bookmark list [<list options>...]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  notes bookmark search <query>

Options:
  -c --comment   <comment>      A comment or description for this bookmark.
  --edit                        Open the bookmark in your editor before saving.
  -e --encrypt                  Encrypt the bookmark with a password.
  --skip-content                Omit page content from the note.
  --tags         <tag1>,<tag2>  A comma-separated list of tags.
  --title        <title>        The bookmark title. When not specified,
                                `notes` will use the html <title> tag.

Subcommands:
  list     List bookmarks in the current notebook.
           Shortcut Alias: `ls`
  open     Open the bookmarked page in your system's primary web browser.
           Shortcut Alias: `o`
  peek     Open the bookmarked page in your terminal web browser.
           Alias: `preview`
           Shortcut Alias: `p`
  search   Search bookmarks for <query>.
           Shortcut Alias: `q`
  url      Print the URL for the specified bookmark.

Description:
  Create, view, and search bookmarks.

  By default, the page content is saved within the bookmark, making the
  bookmarked page available for full-text search. When `pandoc` is
  installed, content will be converted to Markdown.

  Bookmark are identified by the `.bookmark.md` file extension. The bookmark
  URL is the first URL in the file within '<' and '>' characters:

    <https://www.example.com>

Examples:
  notes bookmark https://example.com
  notes bookmark https://example.com --tags example,sample,demo
  notes bookmark https://example.com/about --title 'Example Title'
  notes bookmark https://example.com -c 'Example comment.'
  notes bookmark list
  notes bookmark search 'example query'
  notes bookmark search '^example[[:space:]]regular[[:space:]]expression$'
  notes bookmark open 5
  notes bookmark url 10

Shortcut Alias: `b`
```

#### `bookmarks`

```text
Usage:
  notes bookmarks [<list options>...]

Description:
  List bookmarks with titles. All `notes list` options are supported.
  For more information, see `notes help list`.

Shortcut Alias: `bs`
```

#### `completions`

```text
Usage:
  notes completions (check | install [-d | --download] | uninstall)

Options:
  -d --download  Download the completion scripts and install.

Description:
  Manage completion scripts. For more information, visit:
  https://github.com/xwmx/notes/blob/master/etc/README.md
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
  Initialize the local data directory and generate a ~/.notesrc configuration
  file if it doesn't exist.

Examples:
  notes init
  notes init https://github.com/example/example.gi
```

#### `list`

```text
Usage:
  notes list [--bookmarks] [-e [<length>] | --excerpt [<length>]] [--no-id]
             [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
             [--titles] [<id> | <filename> | <path> | <title> | <query>]

Options:
  --bookmarks            List only bookmarks.
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

Indicators:
  🔖  Bookmark
  🔒  Encrypted
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video
  🔉  Audio

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
  notes ls [--bookmarks] [-e [<length>] | --excerpt [<length>]] [--no-id]
           [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
           [<id> | <filename> | <path> | <title> | <query>]

Options:
  --bookmarks            List only bookmarks.
  -e --excerpt <length>  Print an excerpt <length> lines long under each
                         note's filename [default: 3].
  --no-id                Don't print the id next to each note's filename.
  -n           <limit>   The maximum number of notes to list.
  --<limit>              Shortcut for `-n <limit>`.
  -s --sort              Order notes by id.
  -r --reverse           Order notes by id descending.

Description:
  List notebooks and notes in the current notebook, displaying note titles
  when available. `notes ls` is a combination of `notes notebooks` and
  `notes list --titles` in one view.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

  Options are passed through to `list`. For more information, see
  `notes help list`.

Indicators:
  🔖  Bookmark
  🔒  Encrypted
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video
  🔉  Audio

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

#### `open`

```text
Usage:
  notes open (<id> | <filename> | <path> | <title>)

Description:
  Open the note file. When the note is a bookmark, open the bookmarked page in
  your system's primary web browser. When the note is in a text format or any
  other file type, `open` is the equivalent of `edit`.

See also:
  notes help bookmark
  notes help edit

Shortcut Alias: `o`
```

#### `peek`

```text
Usage:
  notes peek (<id> | <filename> | <path> | <title>)

Description:
  When the note is a bookmark, view the bookmarked page in your terminal web
  browser. When the note is in a text format or any other file type, `peek`
  is the equivalent of `show`.

See also:
  notes help bookmark
  notes help show

Alias: `preview`
Shortcut Alias: `p`
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
  notes search <query> [-a | --all] [--bookmarks] [--path]

Options:
  -a --all     Search all notebooks.
  --bookmarks  Search only bookmarks.
  --path       Print the full path for each file with query matches.

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

  # search for bookmarks containing the hashtag '#example'
  notes search '#example' --bookmarks

  # search with a regular expression for notes containing phone numbers
  notes search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'

Shortcut Alias: `q`
```

#### `settings`

```text
Usage:
  notes settings
  notes settings colors
  notes settings edit
  notes settings get   (<number> | <name>)
  notes settings set   (<number> | <name>) <value>
  notes settings unset (<number> | <name>)

Subcommands:
  (default)  Open the settings prompt.
  colors     Print a table of available colors and their xterm color numbers.
  edit       Open the ~/.notesrc configuration file in `$EDITOR`.
  get        Print the value of a setting.
  set        Assign <value> to a setting.
  unset      Unset a setting, returning it to the default value.

Description:
  Configure `notes`. Use `settings set` to customize a setting and
  `settings unset` to restore the default for a setting.

Settings:
[1] EDITOR
    The command line text editor to use with `notes`.

    • Example Values: 'vim', 'emacs', 'code', 'subl', 'atom', 'macdown'

[2] NOTES_AUTO_SYNC
    By default, operations that trigger a git commit like `add`, `edit`,
    and `delete` will sync notebook changes to the remote repository, if
    one is set. To disable this behavior, set this to '0'.

    • Default Value: '1'

[3] NOTES_DEFAULT_EXTENSION
    The default extension to use for notes files. Change to 'org' for Emacs
    Org mode files, 'rst' for reStructuredText, 'txt' for plain text, or
    whatever you prefer.

    • Default Value: 'md'

[4] NOTES_DIR
    The location of the directory that contains the notebooks. To sync with
    Dropbox, you could create a folder at ~/Dropbox/Notes and use:
    `notes settings set NOTES_DIR ~/Dropbox/Notes`

    • Default Value: '~/.notes'

[5] NOTES_ENCRYPTION_TOOL
    The tool used for encrypting notes.

    • Supported Values: 'openssl', 'gpg'
    • Default Value:    'openssl'

[6] NOTES_HIGHLIGHT_COLOR
    Set highlighting color. This should be set to an xterm color number
    between 0 and 255. To view a table of available colors and numbers, run
    `notes settings colors`.

    • Default Value: '11' (yellow) for 256 color terminals,
                     '3'  (yellow) for  8  color terminals.

Examples:
  notes settings
  notes settings set 3 'org'
  notes settings set NOTES_HIGHLIGHT_COLOR 105
  notes settings unset NOTES_HIGHLIGHT_COLOR
  notes settings colors

```

#### `shell`

```text
Usage:
  notes shell [<subcommand> [<options>...] | --clear-history]

Optons:
  --clear-history  Clear the `notes` shell history.

Description:
  Start the `notes` interactive shell. Type 'exit' to exit.

  `notes shell` recognizes all `notes` subcommands and options, providing
  a streamlined, distraction-free approach for working with `notes`.

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

## Tests

To run the [test suite](test), install
[Bats](https://github.com/bats-core/bats-core) and run `bats test` in the project
root.

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
