[![Build Status](https://travis-ci.org/xwmx/notes.svg?branch=master)](https://travis-ci.org/xwmx/notes)

# `❯ notes`

`notes` is a command line note-taking, bookmarking, archiving, and research
management tool with encryption, advanced search,
[Git](https://git-scm.com/)-backed versioning and syncing,
[Pandoc](http://pandoc.org/)-backed conversion,
global and local notebooks, tagging, and more, all in a single portable script.
`notes` creates notes in text-based formats like
[Markdown](https://en.wikipedia.org/wiki/Markdown) and
[Emacs Org mode](https://orgmode.org/),
can work with files in any format, and can export notes to many document
formats. `notes` can also create private, password-protected encrypted notes and
bookmarks.

With `notes`, you can add and edit notes using Vim, Emacs, VS Code, Sublime
Text, and any other text editor you prefer. `notes` works in any
standard Linux / Unix environment, including macOS and Windows via WSL.
[Optional dependencies](#optional) can be installed to enhance functionality,
but `notes` works great without them.

`notes` includes `bookmark`, a powerful, full-featured, and intuitive CLI
bookmarking system with local full-text search of cached page content, tagging,
convenient filtering and listing, Wayback Machine snapshot lookup
for broken links, and easy viewing of bookmarked pages in the
terminal and your regular web browser. Page information is automatically
downloaded, compiled, and saved into normal Markdown documents made for humans,
so bookmarks are easy to edit just like any other note.

`notes` uses [Git](https://git-scm.com/) in the background to automatically
record changes and sync with a remote repository, if one has been configured.
`notes` can also be configured to save notes in a location used by a general
purpose syncing utility like Dropbox so notes can be edited in other apps on
any device.

`notes` is designed to be lightweight and portable, with a focus on vendor and
tool independence, while providing a full-featured, intuitive experience in a
user-centric text interface. The entire program is a single well-tested script
that can be copied or `curl`ed anywhere and just work, using a
[progressive enhancement](https://en.wikipedia.org/wiki/Progressive_enhancement)
approach for various experience improvements in more capable environments.
`notes` makes it easy to incorporate other tools, writing apps, and workflows.
`notes` can be used a little, a lot, once in a while, or for just a subset of
features. `notes` is flexible.

<p align="center">
  📝
  🔖
  🔒
  🔍
  📔
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#overview">Overview</a> •
  <a href="#help">Help</a>
</p>

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

Also supported for various enhancements:

[Ack](http://beyondgrep.com/),
[`afplay`](https://ss64.com/osx/afplay.html),
[Ag - The Silver Searcher](https://github.com/ggreer/the_silver_searcher),
[`exa`](https://github.com/ogham/exa),
[`ffplay`](http://ffmpeg.org/ffplay.html),
[ImageMagick](https://imagemagick.org/),
[GnuPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard),
[`imgcat`](https://www.iterm2.com/documentation-images.html),
[kitty's `icat` kitten](https://sw.kovidgoyal.net/kitty/kittens/icat.html),
[Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser)),
[Midnight Commander](https://en.wikipedia.org/wiki/Midnight_Commander),
[`mpg123`](https://en.wikipedia.org/wiki/Mpg123),
[MPlayer](https://en.wikipedia.org/wiki/MPlayer),
[`pdftotext`](https://en.wikipedia.org/wiki/Pdftotext),
[Ranger](https://ranger.github.io/)

### Installation

#### Homebrew

To install with [Homebrew](http://brew.sh/):

```bash
brew install xwmx/taps/notes
```

Installing `notes` with Homebrew also installs the recommended dependencies
above.

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

## Overview

<p align="center">
  <a href="#working-with-notes">Notes</a> •
  <a href="#bookmarks">Bookmarks</a> •
  <a href="#search">Search</a> •
  <a href="#revision-history">History</a> •
  <a href="#notebooks">Notebooks</a> •
  <a href="#git-sync">Git Sync</a> •
  <a href="#import--export">Import / Export</a> •
  <a href="#settings">Settings</a> •
  <a href="#interactive-shell">Shell</a> •
  <a href="#shortcut-aliases">Shortcuts</a> •
  <a href="#help">Help</a>
</p>

To get started, simply run:

```bash
notes
```

`notes` sets up your initial "home" notebook the first time it runs.
Now it's ready for you to start adding notes.

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
`$EDITOR` environment variable or [`notes settings`](#settings).

`notes` files are [Markdown](https://daringfireball.net/projects/markdown/)
files by default. To change the file type, see `notes help add`.

Password-protected notes are encrypted with AES-256 using OpenSSL by
default. GPG is also supported and can be configured in `notes settings`.
Encrypted notes can be decrypted using the OpenSSL and GPG command line
tools directly, so you aren't dependent on `notes` to decrypt your
files.

#### Listing Notes

To list notes and notebooks, run `notes ls`:

```bash
> notes ls
home
----
[3] example.md · "Example content."
[2] todos.md · "Todos:"
[1] ideas.md · "- Example idea one."
```

Notebooks are listed above the line, with the current notebook highlighted.
Notes from the current notebook are listed with each id and either the
filename or title, if one is present. When no title is present, the
first line of the note file is displayed next to the filename.

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

Once defined, titles will be displayed in place of the filename and first line
in the output of `notes ls`:

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

On most systems, when the list of notes is longer than the terminal
can display on one screen, `notes ls` will open the list in
[`less`](https://en.wikipedia.org/wiki/Less_(Unix)). Use the following
keys to navigate in `less` (see [`man less`](https://linux.die.net/man/1/less)
for more information):

```text
Key               Function
---               --------
mouse scroll      Scroll up / down
arrow up / down   Scroll one line up / down
f                 Move forward one page
b                 Move back one page
/<query>          Search for <query>
n                 Jump to next <query> match
q                 Quit
```

`notes ls` is a combination of `notes notebooks` and `notes list` in one view
and accepts the same arguments as `notes list`, which lists only notes.

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

#### Viewing Notes

Notes can be viewed using `notes show`:

```bash
# show note by id
notes show 3

# show note by filename
notes show example.md

# show note by title
notes show 'A Document Title'
```

By default, `notes show` will open the note in
[`less`](https://linux.die.net/man/1/less), with syntax highlighting if
[Pygments](http://pygments.org/) is installed, and you can navigate with the
same keys used in `notes ls`:

```text
Key               Function
---               --------
mouse scroll      Scroll up / down
arrow up / down   Scroll one line up / down
f                 Move forward one page
b                 Move back one page
/<query>          Search for <query>
n                 Jump to next <query> match
q                 Quit
```

When [Pandoc](http://pandoc.org/) is available, use the `--render` option to
render the note to HTML and open it in your terminal browser:

```bash
notes show example.md --render
# opens example.md as an HTML page in w3m or lynx
```

`notes show` also supports previewing other file types in the terminal,
depending on the tools available in the environment. Supported tools
and file types include:

- [`pdftotext`](https://en.wikipedia.org/wiki/Pdftotext) - PDF files
- [`mplayer`](https://en.wikipedia.org/wiki/MPlayer),
  [`afplay`](https://ss64.com/osx/afplay.html),
  [`mpg123`](https://en.wikipedia.org/wiki/Mpg123),
  [`ffplay`](http://ffmpeg.org/ffplay.html) - Audio files
- [ImageMagick](https://imagemagick.org/),
  [`imgcat`](https://www.iterm2.com/documentation-images.html),
  [kitty's `icat` kitten](https://sw.kovidgoyal.net/kitty/kittens/icat.html) - Images
- [`ranger`](https://ranger.github.io/),
  [`mc`](https://en.wikipedia.org/wiki/Midnight_Commander) - Folders /
  Directories

When using `notes show` with other file types or if the above tools are not
available, `notes show` will open files in your system's preferred application
for each type.

`notes show` is primarily intended for previewing notes and files within
the terminal. To view files in the system's preferred GUI application,
use [`notes open`](#import--export).

#### Deleting Notes

Deleting notes works the same, accepting an id, filename, or title to
specify the note:

```bash
# delete note by id
notes delete 3

# delete note by filename
notes delete example.md

# delete note by title
notes delete 'A Document Title'
```

By default, `notes delete` will display a confirmation prompt. To skip, use the
`--force` / `-f` option:

```bash
notes delete 3 --force
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
Search both bookmarks and notes for tags with `notes search`:

```bash
notes search '#tagname'
```

`notes bookmark search` and `notes search` also automatically search archived
page content:

```bash
> notes bookmark search 'example query'
[10] example.bookmark.md 'Example Bookmark (example.com)'
---------------------------------------------------------
5:Lorem ipsum example query.
```

Bookmarks can also be encrypted:

```bash
# create a new password-protected, encrypted bookmark
notes bookmark https://example.com --encrypt
```

Encrypted bookmarks require a password before they can be viewed or
opened.

`notes bookmark` and `notes bookmark list` can be used to list and
filter bookmarks:

```bash
> notes bookmark
Add: notes bookmark <url> Help: notes help bookmark
---------------------------------------------------
[3] 🔖 🔒 Example Three (example.com)
[2] 🔖 Example Two (example.com)
[1] 🔖 Example One (example.com)

> notes bookmark list two
[2] 🔖 Example Two (example.com)
```

#### Opening Bookmarks

`notes` provides multiple ways to view bookmarked web pages.

`notes bookmark open` and `notes open` open the bookmarked page in your
system's primary web browser:

```bash
# open bookmark by id
notes open 3
```

`notes bookmark peek` and `notes peek` open the bookmarked page in your
terminal web browser:

```bash
# peek bookmark by id
notes peek 12
```

When used with bookmarks, `notes open` and `notes peek` are aliases for
`notes bookmark open` and `notes bookmark peek`.

`open` and `peek` subcommands also work seamlessly with encrypted bookmarks.
`notes` will simply prompt you for the bookmark's password.

`open` and `peek` automatically check whether the URL is still valid.
If the page has been removed, `notes` can check the [Internet Archive
Wayback Machine](https://archive.org/web/) for an archived copy.

#### Bookmark File Format

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimal valid bookmark file with `notes add`:

```bash
notes add example.bookmark.md --content "<https://example.com>"
```

#### `bookmark` -- A command line tool for managing bookmarks.

`notes` includes `bookmark`, a full-featured, streamlined command line
interface for creating, viewing, searching, and editing bookmarks.

Bookmark a page:

```bash
> bookmark https://example.com --tags tag1,tag2
Added [3] 20200101000000.bookmark.md 'Example Domain (example.com)'
```
List and filter bookmarks with `bookmark` and `bookmark list`:

```bash
> bookmark
Add: bookmark <url> Help: bookmark help
---------------------------------------
[3] 🔖 🔒 Example Three (example.com)
[2] 🔖 Example Two (example.com)
[1] 🔖 Example One (example.com)

> bookmark list two
[2] 🔖 Example Two (example.com)
```

View a bookmark in your terminal web browser:

```bash
> bookmark peek 2
```

Open a bookmark in your system's primary web browser:

```bash
> bookmark open 2
```

Perform a full text search of bookmarks and archived page content:

```bash
> bookmark search 'example query'
[10] example.bookmark.md 'Example Bookmark (example.com)'
---------------------------------------------------------
5:Lorem ipsum example query.
```

`bookmark` is simply a shortcut for `notes bookmark`, accepts all of the same
subcommands and options, and behaves identically.

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

# search bookmarks for 'example'
notes search 'example' --type bookmark
```

`notes search` prints the id number, filename, and title of each matched
file, followed by each search query match and its line number, with color
highlighting:

```bash
> notes search 'example'
[314] example.bookmark.md 'Example Bookmark (example.com)'
----------------------------------------------------------
1:# Example Bookmark (example.com)

3:<https://example.com>

[2718] example.md 'Example Note'
--------------------------------
1:# Example Note
```

`notes search` looks for [`rg`](https://github.com/BurntSushi/ripgrep),
[`ag`](https://github.com/ggreer/the_silver_searcher),
[`ack`](http://beyondgrep.com/), and
[`grep`](https://en.wikipedia.org/wiki/Grep), in that order, and
performs searches using the first tool it finds. `notes search` works
mostly the same regardless of which tool is found and is perfectly fine using
the environment's built-in `grep`. `rg`, `ag`, and `ack` are faster and there
are some subtle differences in color highlighting.

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

#### Global and Local Notebooks

##### Global Notebooks

By default, all `notes` notebooks are global, making them always accessible in
the terminal regardless of the current working directory. Global notebooks are
stored in the directory configured in [`NOTES_DIR`](#settings-list), which is
`~/.notes` by default.

##### Local Notebooks

`notes` also supports creating and working with local notebooks. Local
notebooks are simply notebooks that are anywhere on the system outside
of `NOTES_DIR`. When `notes` runs within a local notebook, the local
notebook is set as the current notebook:

```bash
> notes ls
local · example2 · example3
---------------------------
[3] Title Three
[2] Title Two
[1] Title One
```

A local notebook is always referred to by the name `local` and otherwise
behaves just like a global notebook whenever a command is run from within it:

```bash
# move note titled 'Todos' from the home notebook to the local notebook
notes move home:Todos local

# move note 1 from the local notebook to the home notebook
notes move 1 home

# search the local notebook and all global notebooks for <query string>
notes search 'query string' --all
```

Local notebooks can be created with [`notes notebooks init`](#notebooks-1):

```bash
# initialize the current directory as a notebook
notes notebooks init

# create a new notebook at ~/example
notes notebooks init ~/example

# clone an existing notebook to ~/example
notes notebooks init ~/example https://github.com/example/example.git
```

#### Archiving Notebooks

Notebooks can be archived:

```bash
# archive the current notebook
notes notebook archive

# archive the notebook named 'example'
notes example:notebook archive
```

When a notebook is archived it is not included in `ls` output, synced
automatically with `sync --all`, or included in `search --all`.

```bash
> notes ls
example1 · example2 · example3 · [1 archived]
---------------------------------------------
[3] Title Three
[2] Title Two
[1] Title One
```

Archived notebooks can still be used individually using normal notebook
commands:

```bash
# switch the current notebook to the archived notebook 'example'
notes use example

# run the `list` subcommand in the archived notebook 'example'
notes example:list
```

Check a notebook's archival status with `notes notebook status`:

```bash
> notes notebook status
example is archived.
```

Unarchiving a notebook is simple:

```bash
# unarchive the current notebook
notes notebook unarchive

# unarchive the notebook named 'example'
notes example:notebook unarchive
```

For more information about working with notebooks, run `notes help notebooks`
and `notes help notebook`.

### Git Sync

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

Many services provide free private git repositories, so git syncing with
`notes` is easy, free, and vendor-independent. You can also sync your notes
using Dropbox, Drive, Box, Syncthing, or another syncing tool by changing
your `notes` directory in `notes settings` and git syncing will still work
simultaneously.

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

Files of any type can be imported into a notebook. `notes edit` and `notes
open` will open files in your system's default application for that file type.

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
[5] 🌄 example-picture.png
[4] 📄 example-document.docx
[3] 📹 example-video.mp4
[2] 🔉 example-audio.mp3
[1] 📂 Example Folder
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

### Settings

`notes settings` opens the settings prompt, which provides an easy way to
change your `notes` settings. To print a list of available settings, see
[`notes help settings`](#settings-1).

```bash
notes settings
```

To update a setting in the prompt, enter the setting name or number,
then enter the new value, and `notes` will add the setting to your
`~/.notesrc` configuration file.

#### Example: Highlight Color

`notes` has a minimal text interface and uses color (blue, by default) to
highlight certain elements like ids, the current notebook name, and the shell
prompt.

You can update a setting without the prompt using `notes settings set`:

```bash
# set highlight color with name
> notes settings set notes_highlight_color 105
NOTES_HIGHLIGHT_COLOR set to '105'

# set highlight color with setting number (6)
> notes setting set 6 105
NOTES_HIGHLIGHT_COLOR set to '105'
```

`notes_highlight_color` expects an xterm color number between 0 and 255,
and can support higher values for terminals that support many colors.
Print a table of common colors and numbers with:

```bash
notes settings colors
```

Print the value of a setting:

```bash
> notes settings get notes_highlight_color
105

> notes settings get 6
105
```

Unset a setting and revert to default:

```bash
> notes settings unset notes_highlight_color
NOTES_HIGHLIGHT_COLOR restored to the default: '4'

> notes settings get notes_highlight_color
4
```

### Interactive Shell

`notes` has an interactive shell that can be started with `notes shell`,
`notes -i`, or `notes --interactive`:

```bash
$ notes -i
__                _
\ \   _ __   ___ | |_ ___  ___
 \ \ | '_ \ / _ \| __/ _ \/ __|
 / / | | | | (_) | ||  __/\__ \
/_/  |_| |_|\___/ \__\___||___/
-------------------------------
notes shell started. Enter ls to list notes and notebooks.
Enter help for a list of subcommands. Enter exit to exit.
notes> ls
home
----
[3] Example
[2] Sample
[1] Demo

notes> edit 3 --content "New content."
Updated [3] Example

notes> bookmark https://example.com
Added [4] example.bookmark.md 'Example Domain (example.com)'

notes> ls
home
----
[4] 🔖 Example Domain (example.com)
[3] Example
[2] Sample
[1] Demo

notes> bookmark url 4
https://example.com

notes> search 'example'
[4] example.bookmark.md 'Example (example.com)'
-----------------------------------------------
1:# Example (example.com)

3:<https://example.com>

[3] example.md 'Example'
------------------------
1:# Example

notes> exit
$
```

The `notes` shell recognizes all `notes` subcommands and options,
providing a streamlined, distraction-free approach for working with `notes`.

### Shell Theme Support

- [`astral` Zsh Theme](https://github.com/xwmx/astral) - Displays the
    current notebook name in the context line of the prompt.

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
  <a href="#notes-help">notes</a> •
  <a href="#bookmark-help">bookmark</a>
  </br>---</br>
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
  <a href="#settings-1">settings</a> •
  <a href="#shell">shell</a> •
  <a href="#show">show</a> •
  <a href="#status">status</a> •
  <a href="#sync">sync</a> •
  <a href="#use">use</a> •
  <a href="#version">version</a>
</p>

#### `notes help`

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
  notes [<id> | <filename> | <path> | <title>] [<list options>...]
  notes add [<filename> | <content>] [-c <content> | --content <content>]
            [-e | --encrypt] [-f <filename> | --filename <filename>]
            [-t <title> | --title <title>] [--type <type>]
  notes bookmark [<list options>...]
  notes bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--raw-content] [--related <url>]...
                 [--skip-content] [--tags <tag1>,<tag2>...] [--title <title>]
  notes bookmark [list [<list options>...]]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  notes bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  notes bookmark search <query>
  notes bookmarks [<list options>...]
  notes completions (check | install [-d | --download] | uninstall)
  notes count
  notes delete (<id> | <filename> | <path> | <title>) [-f | --force]
  notes edit (<id> | <filename> | <path> | <title>)
             [-e <editor> | --editor <editor>]
  notes export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
               [<pandoc options>...]
  notes git <git options>...
  notes help [<subcommand> | --readme]
  notes history [<id> | <filename> | <path> | <title>]
  notes import [copy | download | move] (<path> | <url>) [--convert]
  notes init [<remote-url>]
  notes list [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
             [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
             [-t <type> | --type <type> | --<type>]
             [<id> | <filename> | <path> | <title> | <query>]
  notes ls [<list options>...]
  notes move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>
  notes notebook [archive | open | peek | status | unarchive]
  notes notebooks [<name>] [--archived] [--global] [--local] [--names]
                  [--no-color] [--paths] [--unarchived]
  notes notebooks add <name> [<remote-url>]
  notes notebooks init [<path> [<remote-url>]]
  notes notebooks [current [--path] | use <name>]
  notes notebooks delete <name> [-f | --force]
  notes notebooks rename <old-name> <new-name>
  notes open (<id> | <filename> | <path> | <title>)
  notes peek (<id> | <filename> | <path> | <title>)
  notes remote [remove | set <url> [-f | --force]]
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset |
               --to-bookmark | --to-note) [-f | --force]
  notes search <query> [-a | --all] [-t <type> | --type <type> | --<type>]
                       [-l | --list] [--path]
  notes settings [colors [<number>] | edit | list]
  notes settings (get | unset) <setting>
  notes settings set <setting> <value>
  notes shell [<subcommand> [<options>...] | --clear-history]
  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]
             [--dump [--no-color]]
  notes sync [-a | --all]
  notes use <notebook>
  notes -i | --interactive [<subcommand> [<options>...]]
  notes -h | --help | help [<subcommand> | --readme]
  notes --version | version

Help:
  notes help <subcommand>  View help information for <subcommand>
  notes help --readme      Download and view the `notes` README file.

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
  -i, --interactive   Start the `notes` interactive shell.
  -h, --help          Display this help information.
  --version           Display version information.
```

#### `bookmark help`

```text
    __                __                        __
   / /_  ____  ____  / /______ ___  ____ ______/ /__
  / __ \/ __ \/ __ \/ //_/ __ `__ \/ __ `/ ___/ //_/
 / /_/ / /_/ / /_/ / ,< / / / / / / /_/ / /  / ,<
/_.___/\____/\____/_/|_/_/ /_/ /_/\__,_/_/  /_/|_|

bookmark -- Command line bookmarking with tagging, encryption,
full-text page content search with regular expression support,
GUI and terminal browser support, and data stored in plain text
Markdown files with Git-backed versioning and syncing.

Usage:
  bookmark [<list options>...]
  bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--raw-content] [--related <url>]...
                 [--skip-content] [--tags <tag1>,<tag2>...] [--title <title>]
  bookmark list [<list options>...]
  bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  bookmark search <query>

Options:
  -c, --comment <comment>   A comment or description for this bookmark.
  --edit                    Open the bookmark in your editor before saving.
  -e, --encrypt             Encrypt the bookmark with a password.
  --raw-content             Save the page content as HTML.
  --related <url>           A URL for a page related to the bookmarked page.
                            Multiple `--related` flags can be used in a
                            command to save multiple related URLs.
  --skip-content            Omit page content from the note.
  --tags <tag1>,<tag2>...   A comma-separated list of tags.
  --title <title>           The bookmark title. When not specified,
                            `notes` will use the html <title> tag.

Subcommands:
  (default)  Add a new bookmark for <url>, or list bookmarks.
  delete     Delete a bookmark.
  edit       Edit a bookmark.
  list       List bookmarks in the current notebook.
             Shortcut Alias: `ls`
  open       Open the bookmarked page in your system's primary web browser.
             Shortcut Alias: `o`
  peek       Open the bookmarked page in your terminal web browser.
             Alias: `preview`
             Shortcut Alias: `p`
  search     Search bookmarks for <query>.
             Shortcut Alias: `q`
  url        Print the URL for the specified bookmark.

Description:
  Create, view, search, edit, and delete bookmarks.

  By default, the html page content is saved within the bookmark, making the
  bookmarked page available for full-text search. When `pandoc` is
  installed, the HTML content will be converted to Markdown before saving.

  Bookmarks are identified by the `.bookmark.md` file extension. The
  bookmark URL is the first URL in the file within '<' and '>' characters:

    <https://www.example.com>

Examples:
  bookmark https://example.com
  bookmark https://example.com --tags example,sample,demo
  bookmark https://example.com/about -c 'Example comment.'
  bookmark list
  bookmark search 'example query'
  bookmark open 5

------------------------------------------------
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
  -c, --content <content>     The content for the new note.
  -e, --encrypt               Encrypt the note with a password.
  -f, --filename <filename>   The filename for the new note.
  -t, --title <title>         The title for a new note. If `--title` is
                              present, the filename will be derived from the
                              title, unless `--filename` is specified.
  --type <type>               The file type for the new note, as a file
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
  notes bookmark [<list options>...]
  notes bookmark <url> [-c <comment> | --comment <comment>] [--edit]
                 [-e | --encrypt] [--raw-content] [--related <url>]...
                 [--skip-content] [--tags <tag1>,<tag2>...] [--title <title>]
  notes bookmark list [<list options>...]
  notes bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  notes bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  notes bookmark search <query>

Options:
  -c, --comment <comment>   A comment or description for this bookmark.
  --edit                    Open the bookmark in your editor before saving.
  -e, --encrypt             Encrypt the bookmark with a password.
  --raw-content             Save the page content as HTML.
  --related <url>           A URL for a page related to the bookmarked page.
                            Multiple `--related` flags can be used in a
                            command to save multiple related URLs.
  --skip-content            Omit page content from the note.
  --tags <tag1>,<tag2>...   A comma-separated list of tags.
  --title <title>           The bookmark title. When not specified,
                            `notes` will use the html <title> tag.

Subcommands:
  (default)  Add a new bookmark for <url>, or list bookmarks.
  delete     Delete a bookmark.
  edit       Edit a bookmark.
  list       List bookmarks in the current notebook.
             Shortcut Alias: `ls`
  open       Open the bookmarked page in your system's primary web browser.
             Shortcut Alias: `o`
  peek       Open the bookmarked page in your terminal web browser.
             Alias: `preview`
             Shortcut Alias: `p`
  search     Search bookmarks for <query>.
             Shortcut Alias: `q`
  url        Print the URL for the specified bookmark.

Description:
  Create, view, search, edit, and delete bookmarks.

  By default, the html page content is saved within the bookmark, making the
  bookmarked page available for full-text search. When `pandoc` is
  installed, the HTML content will be converted to Markdown before saving.

  Bookmarks are identified by the `.bookmark.md` file extension. The
  bookmark URL is the first URL in the file within '<' and '>' characters:

    <https://www.example.com>

Examples:
  notes bookmark https://example.com
  notes bookmark https://example.com --tags example,sample,demo
  notes bookmark https://example.com/about -c 'Example comment.'
  notes bookmark list
  notes bookmark search 'example query'
  notes bookmark open 5

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
  -d, --download  Download the completion scripts and install.

Description:
  Manage completion scripts. For more information, visit:
  https://github.com/xwmx/notes/blob/master/etc/README.md
```

#### `count`

```text
Usage:
  notes count

Description:
  Print the number of items in the current notebook.
```

#### `delete`

```text
Usage:
  notes delete (<id> | <filename> | <path> | <title>) [-f | --force]

Options:
  -f, --force   Skip the confirmation prompt.

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
             [-e <editor> | --editor <editor>]

Options:
  -e, --editor <editor>  Edit the note with <editor>, overriding the editor
                         specified in the `$EDITOR` environment variable.

Description:
  Open the specified note in `$EDITOR` or <editor> if specified. Any data
  piped to `notes edit` will be appended to the file.

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
  Print program environment and configuration information.
```

#### `export`

```text
Usage:
  notes export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
               [<pandoc options>...]
  notes export pandoc (<id> | <filename> | <path> | <title>)
               [<pandoc options>...]

Options:
  -f, --force   Skip the confirmation prompt when overwriting an existing file.

Subcommands:
  (default)     Export a file to <path>. If <path> has a different extension
                than the source note, convert the note using `pandoc`.
  pandoc        Export the file to standard output or a file using `pandoc`.
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
  notes help [<subcommand> | --readme]

Options:
  --readme   Download and view the `notes` README file.

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
  --convert  Convert HTML content to Markdown.

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
  notes init https://github.com/example/example.git
```

#### `list`

```text
Usage:
  notes list [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
             [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
             [-t <type> | --type <type> | --<type>]
             [<id> | <filename> | <path> | <title> | <query>]

Options:
  -e, --excerpt [<length>]      Print an excerpt <length> lines long under
                                each note's filename [default: 3].
  --filenames                   Print the filename for each note.
  --no-id                       Don't include the id in list items.
  -n <limit>                    The maximum number of notes to list.
  --<limit>                     Shortcut for `-n <limit>`.
  -s, --sort                    Order notes by id.
  -r, --reverse                 Order notes by id descending.
  -t, --type <type>, --<type>   List items of <type>. <type> can be a file
                                extension or one of the following types:
                                note, bookmark, document, archive, image,
                                video, audio, folder

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
  📂  Folder

Examples:
  notes list
  notes list example.md -e 10
  notes list --excerpt --no-id
  notes list --filenames --reverse
  notes list '^Example.*'
  notes list --10
  notes list --type document
```

#### `ls`

```text
Usage:
  notes ls [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
           [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
           [-t <type> | --type <type> | --<type>]
           [<id> | <filename> | <path> | <title> | <query>]

Options:
  -e, --excerpt [<length>]      Print an excerpt <length> lines long under
                                each note's filename [default: 3].
  --filenames                   Print the filename for each note.
  --no-id                       Don't include the id in list items.
  -n <limit>                    The maximum number of notes to list.
  --<limit>                     Shortcut for `-n <limit>`.
  -s, --sort                    Order notes by id.
  -r, --reverse                 Order notes by id descending.
  -t, --type <type>, --<type>   List items of <type>. <type> can be a file
                                extension or one of the following types:
                                note, bookmark, document, archive, image,
                                video, audio, folder

Description:
  List notebooks and notes in the current notebook, displaying note titles
  when available. `notes ls` is a combination of `notes notebooks` and
  `notes list` in one view.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

  On most systems, if the list of notes is longer than the terminal can
  display on one screen, the list will be opened in `less`. Use the
  following keys to navigate in `less` (see `man less` for more):

    Key               Function
    ---               --------
    mouse scroll      Scroll up / down
    arrow up / down   Scroll one line up / down
    f                 Move forward one page
    b                 Move back one page
    /<query>          Search for <query>
    n                 Jump to next <query> match
    q                 Quit

  Options are passed through to `list`. For more information, see
  `notes help list`.

Indicators:
  🔖  Bookmark
  🔒  Encrypted
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video
  🔉  Audio
  📂  Folder

Examples:
  notes ls
  notes ls example.md -e 10
  notes ls --excerpt --no-id
  notes ls --reverse
  notes ls '^Example.*'
  notes ls --10
  notes ls --type document
```

#### `move`

```text
Usage:
  notes move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>

Options:
  -f, --force   Skip the confirmation prompt.

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
  notes notebook [archive | open | peek | status | unarchive]

Subcommands:
  archive     Set the notebook to 'archived' status.
  open        Open the notebook directory in your file browser, explorer, or
              finder.
              Shortcut Alias: `o`
  peek        Open the notebook directory the first tool found in this list:
              `ranger` [1], `mc` [2], `exa` [3] or `ls`.
              Shortcut Alias: `p`
  status      Print the archival status of the current notebook.
  unarchive   Remove 'archived' status from notebook.

    1. https://ranger.github.io/
    2. https://en.wikipedia.org/wiki/Midnight_Commander
    3. https://github.com/ogham/exa

Description:
  Print, archive, or open the current notebook.

  Archiving a notebook hides it from `ls` output.

Shortcut Alias: `n`
```

#### `notebooks`

```text
Usage:
  notes notebooks [<name>] [--archived] [--global] [--local] [--names]
                  [--no-color] [--paths] [--unarchived]
  notes notebooks add <name> [<remote-url>]
  notes notebooks init [<path> [<remote-url>]]
  notes notebooks current [--path]
  notes notebooks delete <name> [-f | --force]
  notes notebooks rename <old-name> <new-name>
  notes notebooks use <name>

Options:
  --achived     Only list archived notebooks.
  --global      List global notebooks.
  --local       List local notebook.
  -f, --force   Skip the confirmation prompt.
  --names       Only print each notebook's name.
  --no-color    Print names without highlighting the current notebook.
  --path        Print the path of the current notebook.
  --paths       Print the path of each notebook.
  --unarchived  Only list unarchived notebooks.

Subcommands:
  (default)  List notebooks.
  add        Create a new global notebook. When an existing notebook's
             <remote-url> is specified, create the new global notebook as a
             clone of <remote-url>.
  init       Create a new local notebook. Specify a <path> or omit to
             initialize the current working directory as a local notebook.
             Specify <remote-url> to clone an existing notebook.
  current    Print the current notebook name.
  delete     Delete a notebook.
  rename     Rename a notebook.
  use        Switch to a notebook.

Description:
  Manage notebooks.

Examples:
  notes notebooks --names
  notes notebooks add Example1
  notes notebooks add Example2 https://github.com/example/example.git

Shortcut Alias: `ns`
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
  (default)     Print the remote URL for the notebook.
  remove        Remove the remote URL from the notebook.
  set           Set the remote URL for the notebook.

Options:
  -f, --force   Skip the confirmation prompt.

Description:
  Get, set, and remove the remote repository URL for the current notebook.

Examples:
  notes remote set https://github.com/example/example.git
  notes remove remove
```

#### `rename`

```text
Usage:
  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset |
               --to-bookmark | --to-note) [-f | --force]

Options:
  -f, --force     Skip the confirmation prompt.
  --reset         Reset the filename to the last modified timestamp.
  --to-bookmark   Preserve the existing filename and replace the extension
                  with '.bookmark.md' to convert the note to a bookmark.
  --to-note       Preserve the existing filename and replace the bookmark's
                  '.bookmark.md' extension with '.md' to convert the bookmark
                  to a Markdown note.

Description:
  Rename a note. Set the filename to <name> for the specified note file. When
  file extension is omitted, the existing extension will be used.

Examples:
  # Rename 'example.md' to 'example.org'
  notes rename example.md example.org

  # Rename note 3 (example.md) to "New Name.md"
  notes rename 3 "New Name"

  # Rename 'example.bookmark.md' to 'New Name.bookmark.md'
  notes rename example.bookmark.md "New Name"

  # Rename note 3 ('example.md') to bookmark named 'example.bookmark.md'
  notes rename 3 --to-bookmark
```

#### `search`

```text
Usage:
  notes search <query> [-a | --all] [-t <type> | --type <type> | --<type>]
                       [-l | --list] [--path]

Options:
  -a, --all                     Search all active notebooks.
  -l, --list                    Print the id, filename, and title listing for
                                each matching file, without the excerpt.
  --path                        Print the full path for each matching file.
  -t, --type <type>, --<type>   List items of <type>. <type> can be a file
                                extension or one of the following types:
                                note, bookmark, document, archive, image,
                                video, audio, folder
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
  notes search '#example' --type bookmark

  # search with a regular expression for notes containing phone numbers
  notes search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'

Shortcut Alias: `q`
```

#### `settings`

```text
Usage:
  notes settings
  notes settings colors [<number>]
  notes settings edit
  notes settings get   (<number> | <name>)
  notes settings list
  notes settings set   (<number> | <name>) <value>
  notes settings unset (<number> | <name>)

Subcommands:
  (default)  Open the settings prompt.
  colors     Print a table of available colors and their xterm color numbers.
             When <number> is provided, print the number in its color.
  edit       Open the ~/.notesrc configuration file in `$EDITOR`.
  get        Print the value of a setting.
  list       List information about available settings.
  set        Assign <value> to a setting.
  unset      Unset a setting, returning it to the default value.

Description:
  Configure `notes`. Use `notes settings set` to customize a setting and
  `notes settings unset` to restore the default for a setting.

Examples:
  notes settings
  notes settings set 3 'org'
  notes settings set notes_highlight_color 105
  notes settings unset notes_highlight_color
  notes settings colors
  notes settings colors 105
```

##### `settings list`

```text
[1] editor
    ------
    The command line text editor to use with `notes`.
      • Example Values: 'vim', 'emacs', 'code', 'subl', 'atom', 'macdown'

[2] notes_auto_sync
    ---------------
    By default, operations that trigger a git commit like `add`, `edit`,
    and `delete` will sync notebook changes to the remote repository, if
    one is set. To disable this behavior, set this to '0'.
      • Default Value: '1'

[3] notes_default_extension
    -----------------------
    The default extension to use for notes files. Change to 'org' for Emacs
    Org mode files, 'rst' for reStructuredText, 'txt' for plain text, or
    whatever you prefer.
      • Default Value: 'md'

[4] notes_dir
    ---------
    The location of the directory that contains the notebooks. To sync with
    Dropbox, you could create a folder at ~/Dropbox/Notes and use:
    `notes settings set NOTES_DIR ~/Dropbox/Notes`
      • Default Value: '~/.notes'

[5] notes_encryption_tool
    ---------------------
    The tool used for encrypting notes.
      • Supported Values: 'openssl', 'gpg'
      • Default Value:    'openssl'

[6] notes_highlight_color
    ---------------------
    Set highlighting color. Often this can be set to an xterm color number
    between 0 and 255. Some terminals support many more colors. To view a
    table of 256 common colors and numbers, run: `notes settings colors`
    To view a color for a number, run: `notes settings colors <number>`
      • Default Value: '68' (blue) for 256 color terminals,
                       '4'  (blue) for  8  color terminals.
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

  By default, the note will be opened using `less` or the program configured
  in the `$PAGER` environment variable. Use the following keys to navigate
  in `less` (see `man less` for more information):

    Key               Function
    ---               --------
    mouse scroll      Scroll up / down
    arrow up / down   Scroll one line up / down
    f                 Move forward one page
    b                 Move back one page
    /<query>          Search for <query>
    n                 Jump to next <query> match
    q                 Quit

  To skip the pager and print to standard output, use the `--dump` option.

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
  -a, --all   Sync all active notebooks.

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
