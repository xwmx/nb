<p align="center">
  <img 	src="docs/images/nb.png"
  		alt="nb"
  		width="200"/>
</p>

<p align="center">
  <a href="https://travis-ci.org/xwmx/nb" rel="nofollow">
    <img  src="https://travis-ci.org/xwmx/nb.svg?branch=master"
          alt="Build Status"
          style="max-width:100%;">
  </a>
</p>

# `❯ nb`

`nb` is a command line note-taking, bookmarking, archiving, and research
management tool with encryption, advanced search,
[Git](https://git-scm.com/)-backed versioning and syncing,
[Pandoc](http://pandoc.org/)-backed conversion,
global and local notebooks, tagging, customizable color themes,
plain-text data storage, and more, all in a single portable script.

`nb` creates notes in text-based formats like
[Markdown](https://en.wikipedia.org/wiki/Markdown),
[Emacs Org mode](https://orgmode.org/),
and [LaTeX](https://www.latex-project.org/),
can work with files in any format, can import and export notes to many
document formats, and can create private, password-protected encrypted
notes and bookmarks. With `nb`, you can add and edit notes using Vim, Emacs,
VS Code, Sublime Text, and any other text editor you prefer. `nb` works in
any standard Linux / Unix environment, including macOS and Windows via WSL.
[Optional dependencies](#optional) can be installed to enhance functionality,
but `nb` works great without them.

<p align="center">
  <img 	src="https://xwmx.github.io/misc/nb/images/nb-theme-nb-home.png"
  	   	alt="home"
  	   	width="450"/>
</p>

`nb` is also a powerful text-based CLI bookmarking system that includes:

- local full-text search of cached page content with regular expression support,
- tagging,
- convenient filtering and listing,
- [Internet Archive Wayback Machine](https://archive.org/web/) snapshot lookup for
  broken links,
- and easy viewing of bookmarked pages in the terminal and your regular web browser.

Page information is automatically downloaded, compiled, and saved into normal Markdown
documents made for humans, so bookmarks are easy to edit just like any other note.

<p align="center">
  <img 	src="https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-bookmarks.png"
  		  alt="bookmarks"
  		  width="450"/>
</p>

`nb` uses [Git](https://git-scm.com/) in the background to automatically
record changes and sync with a remote repository, if one has been configured.
`nb` can also be configured to save notes in a location used by a general
purpose syncing utility like Dropbox so they can be edited in other apps on
any device.

<p align="center">
  <img 	src="https://xwmx.github.io/misc/nb/images/nb-theme-console-empty.png"
  		  alt="bookmarks"
  		  width="450"/>
</p>

`nb` is designed to be portable, future-focused, and vendor independent,
providing a full-featured, intuitive, and enjoyable experience within a
user-centric text interface.
The entire program is a single well-tested shell script
that can be copied or `curl`ed almost anywhere and just work, using
[progressive enhancement](https://en.wikipedia.org/wiki/Progressive_enhancement)
for various experience improvements in more capable environments.
`nb` makes it easy to incorporate other tools, writing apps, and workflows.
`nb` can be used a little, a lot, once in a while, or for just a subset of
features. `nb` is flexible.

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
  - `nb` works perfectly with Zsh, fish, and any other shell set as your
    primary login shell, the system just needs to have Bash available on it.
- [Git](https://git-scm.com/)
- A text editor with command line support, such as:
  - [Vim](https://en.wikipedia.org/wiki/Vim_\(text_editor\)),
  - [Emacs](https://en.wikipedia.org/wiki/Emacs),
  - [Visual Studio Code](https://code.visualstudio.com/),
  - [Sublime Text](https://www.sublimetext.com/),
  - [micro](https://github.com/zyedidia/micro),
  - [nano](https://en.wikipedia.org/wiki/GNU_nano),
  - [Atom](https://atom.io/),
  - [TextMate](https://macromates.com/),
  - [MacDown](https://macdown.uranusjr.com/),
  - [some of these](https://github.com/topics/text-editor),
  - [and many of these.](https://en.wikipedia.org/wiki/List_of_text_editors)

##### Optional

`nb` leverages standard command line tools and works in standard
Linux / Unix environments. `nb` also checks the environment for some
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

Most installation methods below should work in most Linux and BSD
environments.

When installing with Make or using the manual commands on Ubuntu, WSL,
and Alpine Linux, the recommended dependencies will also be installed,
along with Bash and Zsh completion scripts.

#### macOS / Homebrew

To install with [Homebrew](http://brew.sh/):

```bash
brew install xwmx/taps/nb
```

Installing `nb` with Homebrew also installs the recommended dependencies
and completion scripts.

#### Ubuntu, Windows WSL, Alpine, and others

##### npm

To install with [npm](https://www.npmjs.com/package/notes.sh):

```bash
npm install --global notes.sh
```

Note: Installing through `npm` only installs completion scripts.
On Ubuntu, WSL, and Alpine, you can
run `nb env install` to install the optional dependencies.

##### bpkg

To install with [bpkg](https://github.com/bpkg/bpkg):

```bash
bpkg install xwmx/nb
```

##### Make

To install with [Make](https://en.wikipedia.org/wiki/Make_(software)),
clone this repository, navigate to the clone's root directory, and run:

```bash
make install
```

Depending on your system configuration, `sudo` might be required:

```bash
sudo make install
```

To install as an administrator, copy and paste one of the following multi-line
commands:

```bash
# install using wget
sudo wget https://raw.github.com/xwmx/nb/master/nb -O /usr/local/bin/nb &&
  sudo chmod +x /usr/local/bin/nb &&
  sudo nb env install

# install using curl
sudo curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
  sudo chmod +x /usr/local/bin/nb &&
  sudo nb env install
```

Manually installed copies of `nb` can be updated using the `nb update`
command.

###### User-only Installation

To install with just user permissions, simply add the `nb` script to your
`$PATH`. If you already have a `~/bin` directory, for example, you can use
one of the following commands:

```bash
# download with wget
wget https://raw.github.com/xwmx/nb/master/nb -O ~/bin/nb && chmod +x ~/bin/nb

# download with curl
curl -L https://raw.github.com/xwmx/nb/master/nb -o ~/bin/nb && chmod +x ~/bin/nb
```

#### Tab Completion

Bash and Zsh tab completion should be enabled when `nb` is installed using
the methods above, assuming you have the appropriate system
permissions or installed with `sudo`. If completion isn't working after
installing `nb`, see the [completion installation
instructions](etc/README.md).

## Overview

<p align="center">
  <a href="#-working-with-notes">Notes</a> •
  <a href="#-bookmarks">Bookmarks</a> •
  <a href="#-search">Search</a> •
  <a href="#revision-history">History</a> •
  <a href="#-notebooks">Notebooks</a> •
  <a href="#git-sync">Git Sync</a> •
  <a href="#import--export">Import / Export</a> •
  <a href="#settings">Settings</a> •
  <a href="#-color-themes">Color Themes</a> •
  <a href="#interactive-shell">Shell</a> •
  <a href="#shortcut-aliases">Shortcuts</a> •
  <a href="#help">Help</a>
</p>

To get started, simply run:

```bash
nb
```

`nb` stores notes in notebooks, and `nb` sets up your initial "home" notebook
the first time it runs.

By default, notebooks and notes are global (at `~/.nb`), so they are always available to
`nb` regardless of the current working directory. `nb` also supports [local
notebooks](#global-and-local-notebooks).

### 📝 Working with Notes

#### Adding Notes

Use `nb add` to create new notes:

```bash
# create a new note in your text editor
nb add

# create a new note with the filename 'example.md'
nb add example.md

# create a new note containing "This is a note."
nb add "This is a note."

# create a new note with piped content
echo "Note content." | nb add

# create a new password-protected, encrypted note
nb add --title "Secret Document" --encrypt
```

`nb add` with no arguments or input will open the new, blank note in your
environment's preferred text editor. You can change your editor using the
`$EDITOR` environment variable or [`nb settings`](#settings).

`nb` files are [Markdown](https://daringfireball.net/projects/markdown/)
files by default. To change the file type, see `nb help add`.

Password-protected notes are encrypted with AES-256 using OpenSSL by
default. GPG is also supported and can be configured in `nb settings`.
Encrypted notes can be decrypted using the OpenSSL and GPG command line
tools directly, so you aren't dependent on `nb` to decrypt your
files.

##### Shortcut Alias: `a`

`nb` includes single-character shortcuts for many commands, including
`a` for `add`:

```bash
# create a new note in your text editor
nb a

# create a new note with the filename 'example.md'
nb a example.md

# create a new note containing "This is a note."
nb a "This is a note."
```

#### Listing Notes

To list notes and notebooks, run `nb ls`:

```bash
> nb ls
home
----
[3] example.md · "Example content."
[2] todos.md · "Todos:"
[1] ideas.md · "- Example idea one."
```

Notebooks are listed above the line, with the current notebook
highlighted and/or underlined, depending on terminal capabilities.

Notes from the current notebook are listed in the order they were last
modified. By default, each note is listed with its id, filename, and an
excerpt from the first line of the note. When a note has a title, the
title is displayed instead of the filename and first line.

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
in the output of `nb ls`:

```bash
> nb ls
home
----
[3] Example Title
[2] Todos
[1] Ideas
```

Pass an id, filename, or title to view the listing for that note:

```bash
> nb ls Todos
[2] Todos
```

```bash
> nb ls 3
[3] Example Title
```

If there is no immediate match, `nb` will list items with titles and
filenames that fuzzy match the query:

```bash
> nb ls 'idea'
[1] Ideas
```

A case-insensitive regular expression can also be to filter filenames and
titles:

```bash
> nb ls '^example.*'
[3] Example Title
```

For full text search, see `nb help search`.

To view excerpts of notes, use the `--excerpt` or `-e` option:

```bash
> nb ls 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt.
```

Bookmarks and encrypted notes are indicated with `🔖` and `🔒`, making them
easily identifiable in lists:

```bash
> nb ls
home
----
[4] Example Note
[3] 🔒 example-encrypted.md.enc
[2] 🔖 Example Bookmark (example.com)
[1] 🔖 🔒 example-encrypted.bookmark.md.enc
```

`nb` with no subcommand is an alias for `nb ls`, so the examples above
can be run without the `ls`:

```bash
> nb
home
----
[3] Example Title
[2] Todos
[1] Ideas

> nb '^example.*'
[3] Example Title

> nb 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt
```

On most systems, when the list of notes is longer than the terminal
can display on one screen, `nb ls` will open the list in
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

`nb ls` is a combination of `nb notebooks` and `nb list` in one view
and accepts the same arguments as `nb list`, which lists only notes.

For more information about options for listing notes, run `nb help ls` and
`nb help list`.

#### Editing Notes

You can edit a note in your editor using its id, filename, or title:

```bash
# edit note by id
nb edit 3

# edit note by filename
nb edit example.md

# edit note by title
nb edit 'A Document Title'
```

`nb edit` can also receive piped content, which it will append to the
specified note:

```bash
echo "Content to append." | nb edit 1
```

When a note is encrypted, `nb edit` will prompt you for the note password,
open the unencrypted content in your editor, and then automatically reencrypt
the note when you are done editing.

##### Shortcut Alias: `e`

Like `add`, `edit` has a shortcut alias, `e`:

```bash
# edit note by id
nb e 3

# edit note by filename
nb e example.md

# edit note by title
nb e 'A Document Title'
```

#### Viewing Notes

Notes can be viewed using `nb show`:

```bash
# show note by id
nb show 3

# show note by filename
nb show example.md

# show note by title
nb show 'A Document Title'
```

By default, `nb show` will open the note in
[`less`](https://linux.die.net/man/1/less), with syntax highlighting if
[Pygments](http://pygments.org/) is installed, and you can navigate with the
same keys used in `nb ls`:

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
nb show example.md --render
# opens example.md as an HTML page in w3m or lynx
```

`nb show` also supports previewing other file types in the terminal,
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

When using `nb show` with other file types or if the above tools are not
available, `nb show` will open files in your system's preferred application
for each type.

`nb show` is primarily intended for previewing notes and files within
the terminal. To view files in the system's preferred GUI application,
use [`nb open`](#import--export).

##### Shortcut Alias: `s`

`show` is aliased to `s`:

```bash
# show note by id
nb s 3

# show note by filename
nb s example.md

# show note by title
nb s 'A Document Title'
```

#### Deleting Notes

Deleting notes works the same, accepting an id, filename, or title to
specify the note:

```bash
# delete note by id
nb delete 3

# delete note by filename
nb delete example.md

# delete note by title
nb delete 'A Document Title'
```

By default, `nb delete` will display a confirmation prompt. To skip, use the
`--force` / `-f` option:

```bash
nb delete 3 --force
```

##### Shortcut Alias: `d`

`delete` has the alias `d`:

```bash
# delete note by id
nb d 3

# delete note by filename
nb d example.md

# delete note by title
nb d 'A Document Title'
```

### 🔖 Bookmarks

`nb` is a powerful bookmark management system, enabling you to to view, search,
and manage your bookmarks, links, and online references. Bookmarks are
Markdown notes containing information about the bookmarked page.

To create a new bookmark pass a URL as the first argument to `nb`:

```bash
nb https://example.com
```

`nb` automatically generates a bookmark using information from the page:

```markdown
# Example Domain (example.com)

<https://example.com>

## Description

Example meta description.

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

`nb` embeds the page content in the bookmark, making it available for full
text search with `nb search` and `nb bookmark search`. When `pandoc` is
installed, the HTML page content will be converted to Markdown.

Bookmarks can be tagged using the `--tags` option. Tags are converted
into hashtags:

```bash
nb https://example.com --tags tag1,tag2
```
```markdown
# Example Domain (example.com)

<https://example.com>

## Description

Example meta description.

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

Search for tagged bookmarks with `nb bookmark search`:

```bash
nb bookmark search '#tagname'
```

`nb bookmark search` has the same full text search as `nb search`.
Search both bookmarks and notes for tags with `nb search`:

```bash
nb search '#tagname'
```

`nb bookmark search` and `nb search` also automatically search archived
page content:

```bash
> nb bookmark search 'example query'
[10] example.bookmark.md 'Example Bookmark (example.com)'
---------------------------------------------------------
5:Lorem ipsum example query.
```

Bookmarks can also be encrypted:

```bash
# create a new password-protected, encrypted bookmark
nb https://example.com --encrypt
```

Encrypted bookmarks require a password before they can be viewed or
opened.

`nb bookmark` and `nb bookmark list` can be used to list and
filter bookmarks:

```bash
> nb bookmark
Add: nb <url> Help: nb help bookmark
------------------------------------
[3] 🔖 🔒 Example Three (example.com)
[2] 🔖 Example Two (example.com)
[1] 🔖 Example One (example.com)

> nb bookmark list two
[2] 🔖 Example Two (example.com)
```

##### Shortcut Alias: `b`

`bookmark` can also be used with the alias `b`:

```bash
> nb b
Add: nb <url> Help: nb help bookmark
------------------------------------
[3] 🔖 🔒 Example Three (example.com)
[2] 🔖 Example Two (example.com)
[1] 🔖 Example One (example.com)

> nb b two
[2] 🔖 Example Two (example.com)
```

#### Opening Bookmarks

`nb` provides multiple ways to view bookmarked web pages.

`nb bookmark open` and `nb open` open the bookmarked page in your
system's primary web browser:

```bash
# open bookmark by id
nb open 3
```

`nb bookmark peek` and `nb peek` open the bookmarked page in your
terminal web browser:

```bash
# peek bookmark by id
nb peek 12
```

When used with bookmarks, `nb open` and `nb peek` are aliases for
`nb bookmark open` and `nb bookmark peek`.

`open` and `peek` subcommands also work seamlessly with encrypted bookmarks.
`nb` will simply prompt you for the bookmark's password.

`open` and `peek` automatically check whether the URL is still valid.
If the page has been removed, `nb` can check the [Internet Archive
Wayback Machine](https://archive.org/web/) for an archived copy.

##### Shortcut Aliases: `o` and `p`

`open` and `peek` can also be used with the shortcut aliases `o` and
`p`:

```bash
# open bookmark by id
nb o 3

# peek bookmark by id
nb p 12
```

#### Bookmark File Format

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimal valid bookmark file with `nb add`:

```bash
nb add example.bookmark.md --content "<https://example.com>"
```

#### `bookmark` -- A command line tool for managing bookmarks.

`nb` includes `bookmark`, a full-featured, streamlined command line
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

`bookmark` is a shortcut for `nb bookmark`, accepts all of the same
subcommands and options, and behaves identically.

See [`bookmark help`](#bookmark-help) for more information.

### 🔍 Search

Use `nb search` to search your notes, with support for regular
expressions and tags:

```bash
# search current notebook for 'example query'
nb search 'example query'

# search all notebooks for 'example query'
nb search 'example query' --all

# search nb for 'Example' OR 'Sample'
nb search 'Example|Sample'

# search for nb containing the hashtag '#example'
nb search '#example'

# search with a regular expression for nb containing phone numbers
nb search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'

# search bookmarks for 'example'
nb search 'example' --type bookmark
```

`nb search` prints the id number, filename, and title of each matched
file, followed by each search query match and its line number, with color
highlighting:

```bash
> nb search 'example'
[314]  example.bookmark.md 'Example Bookmark (example.com)'
----------------------------------------------------------
1:# Example Bookmark (example.com)

3:<https://example.com>

[2718] example.md 'Example Note'
--------------------------------
1:# Example Note
```

To just print the note information line without the content matches, use
the `-l` or `--list` option:

```bash
> nb search 'example' --list
[314]  example.bookmark.md 'Example Bookmark (example.com)'
[2718] example.md 'Example Note'
```

`nb search` looks for [`rg`](https://github.com/BurntSushi/ripgrep),
[`ag`](https://github.com/ggreer/the_silver_searcher),
[`ack`](http://beyondgrep.com/), and
[`grep`](https://en.wikipedia.org/wiki/Grep), in that order, and
performs searches using the first tool it finds. `nb search` works
mostly the same regardless of which tool is found and is perfectly fine using
the environment's built-in `grep`. `rg`, `ag`, and `ack` are faster and there
are some subtle differences in color highlighting.

##### Shortcut Alias: `q`

`search` can also be used with the alias `q` (for "query"):

```bash
# search for 'example' and print matching excerpts
nb q 'example'

# search for 'example' and list each matching file
nb q -l 'example'
```

### Revision History

Whenever a note is added, modified, or deleted, `nb` automatically commits
the change to git transparently in the background. You can view the history of
the notebook or an individual note with:

```bash
# show history for current notebook
nb history

# show history for note number 4
nb history 4

# show history for note with filename example.md
nb history example.md

# show history for note titled 'Example'
nb history Example
```

`nb history` uses `git log` by default and prefers
[`tig`](https://github.com/jonas/tig) when available.

### 📔 Notebooks

You can create additional notebooks, each of which has its own version history.

Create a new notebook:

```bash
# add a notebook named example
nb notebooks add example
```

`nb` and `nb ls` list the available notebooks above the list of notes:

```bash
> nb ls
example · home
--------------
[3] Title Three
[2] Title Two
[1] Title One
```

Commands in `nb` run within the current notebook, and identifiers like id,
filename, and title refer to notes within the current notebook.
`nb edit 3`, for example, tells `nb` to `edit` note with id `3` within the
current notebook.

To switch to a different notebook, use `nb use`:

```bash
# switch to the notebook named 'example'
nb use example
```

If you are in one notebook and you want to perform a command in a
different notebook without switching to it, add the notebook name with a
colon before the command name:

```bash
# show note 5 in the notebook named 'example'
nb example:show 5
```

You can similarly set the notebook name as a modifier to the id, filename, or
title:

```bash
# edit note 12 in the notebook named 'example'
nb edit example:12
```

When a notebook name is specified without a command, `nb` runs `nb ls` in the
specified notebook:

```bash
> nb example:
example · home
--------------
[3] Title Three
[2] Title Two
[1] Title One
```

Notes can also be moved between notebooks:

```bash
# move note 3 from the current notebook to 'example'
nb move 3 example
```

#### Global and Local Notebooks

##### Global Notebooks

By default, all `nb` notebooks are global, making them always accessible in
the terminal regardless of the current working directory. Global notebooks are
stored in the directory configured in [`NB_DIR`](#settings-list---long), which is
`~/.nb` by default.

##### Local Notebooks

`nb` also supports creating and working with local notebooks. Local
notebooks are notebooks that are anywhere on the system outside
of `NB_DIR`. When `nb` runs within a local notebook, the local
notebook is set as the current notebook:

```bash
> nb ls
local · example · home
----------------------
[3] Title Three
[2] Title Two
[1] Title One
```

A local notebook is always referred to by the name `local` and otherwise
behaves just like a global notebook whenever a command is run from within it:

```bash
# move note titled 'Todos' from the home notebook to the local notebook
nb move home:Todos local

# move note 1 from the local notebook to the home notebook
nb move 1 home

# search the local notebook and all global notebooks for <query string>
nb search 'query string' --all
```

Local notebooks can be created with [`nb notebooks init`](#notebooks-1):

```bash
# initialize the current directory as a notebook
nb notebooks init

# create a new notebook at ~/example
nb notebooks init ~/example

# clone an existing notebook to ~/example
nb notebooks init ~/example https://github.com/example/example.git
```

Local notebooks can also be created by exporting a global notebook:

```bash
# export global notebook named 'example' to '../path/to/destination'
nb notebooks export example ../path/to/destination
```

Local notebooks can also be imported, making them global:

```bash
# import notebook or folder at '../path/to/notebook'
nb notebooks import ../path/to/notebook
```

#### Archiving Notebooks

Notebooks can be archived:

```bash
# archive the current notebook
nb notebooks archive

# archive the notebook named 'example'
nb notebooks archive example
```

When a notebook is archived it is not included in `ls` output, synced
automatically with `sync --all`, or included in `search --all`.

```bash
> nb ls
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
nb use example

# run the `list` subcommand in the archived notebook 'example'
nb example:list
```

Check a notebook's archival status with `nb notebooks status`:

```bash
> nb notebooks status example
example is archived.
```

Unarchiving a notebook is simple:

```bash
# unarchive the current notebook
nb notebooks unarchive

# unarchive the notebook named 'example'
nb notebooks unarchive example
```

For more information about working with notebooks, run `nb help notebooks`.

### Git Sync

Each notebook can be synced with a remote git repository by setting the
remote URL:

```bash
# set the current notebook's remote to a private GitHub repository
nb remote set https://github.com/example/example.git
```

Any notebook with a remote URL will sync automatically every time a command is
run in that notebook.

When you use `nb` on multiple systems, you can set a notebook on both
systems to the same remote and `nb` will keep everything in sync in the
background every time there's a change in that notebook.

Since each notebook has its own git history, you can have some notebooks
syncing with remotes while other notebooks are only available locally on that
system.

Many services provide free private git repositories, so git syncing with
`nb` is easy, free, and vendor-independent. You can also sync your notes
using Dropbox, Drive, Box, Syncthing, or another syncing tool by changing
your `nb` directory in `nb settings` and git syncing will still work
simultaneously.

When you have an existing `nb` notebook in a git repository, simply
pass the URL to `nb notebooks add` and `nb` will clone your
existing notebook and start syncing changes automatically:

```bash
# create a new notebook named Example cloned from a private GitLab repository
nb notebooks add Example https://gitlab.com/example/example.git
```

Turn off syncing for a notebook by removing the remote:

```bash
# remove the current remote from the current notebook
nb remote remove
```

You can also turn off autosync in `nb settings` and sync manually with
`nb sync`.

### Import / Export

Files of any type can be imported into a notebook. `nb edit` and `nb
open` will open files in your system's default application for that file type.

```bash
# import an image file
nb import ~/Pictures/example.png

# open image in your default image viewer
nb open example.png

# import a .docx file
nb import ~/Documents/example.docx

# open .docx file in Word or your system's .docx viewer
nb open example.docx
```

`nb import` can also download and import files directly from the web:

```bash
# import a PDF file from the web
nb import https://example.com/example.pdf
# Imported 'https://example.com/example.pdf' to 'example.pdf'

# open example.pdf in your system's PDF viewer
nb open example.pdf
```

Some imported file types have indicators to make them easier to identify in
lists:

```bash
> nb ls
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
nb export example.md /path/to/example.docx

# Export a note titled 'Movies' to an HTML web page.
nb export Movies /path/to/example.html
```

### Settings

`nb settings` opens the settings prompt, which provides an easy way to
change your `nb` settings.

```bash
nb settings
```

To update a setting in the prompt, enter the setting name or number,
then enter the new value, and `nb` will add the setting to your
`~/.nbrc` configuration file.

#### Example: editor

`nb` can be configured to use a specific command line editor using the
`editor` setting.

The settings prompt for a setting can be started by passing the setting
name or number to `nb settings`:

```bash
> nb settings editor
[6] editor
    ------
    The command line text editor to use with `nb`.

      • Example Values: 'vim', 'emacs', 'code', 'subl', 'atom', 'macdown'

EDITOR is currently set to vim

Enter a new value, unset to set to the default value, or q to quit.
Value:
```

A setting can also be updated without the prompt using `nb settings set`:

```bash
# set editor with setting name
> nb settings set editor code
EDITOR set to code

# set highlight color with setting number (6)
> nb settings set 6 code
EDITOR set to code
```

Print the value of a setting:

```bash
> nb settings get editor
code

> nb settings get 6
code
```

Unset a setting and revert to default:

```bash
> nb settings unset editor
EDITOR restored to the default: vim

> nb settings get editor
vim
```

For more information about settings, see [`nb help settings`](#settings-1) and
[`nb settings list --long`](#settings-list---long).

### 🎨 Color Themes

`nb` has a minimal text interface and uses color to highlight certain
elements like ids, the current notebook name, the shell prompt, and
divider lines.

`nb` includes several built-in color themes and supports user-created color
themes. The color theme can be configured in `notes settings`:

```bash
> nb settings color_theme
[4] color_theme
    -----------
    The color theme. `nb` has several customizable built-in themes,
    listed below.

    Additional themes can be installed in the $NB_DIR/.themes directory.
    Themes have an .nb-theme or .nb-theme.sh extension and contain a
    single if statment assigning the color environment variables to
    tput ANSI color numbers.

      Example:

        # file: ~/.nb/.themes/example.nb-theme.sh
        if [[ "${NB_COLOR_THEME}" == "example" ]]
        then
          export NB_COLOR_PRIMARY=68
          export NB_COLOR_SECONDARY=8
        fi

    To view a list of available color numbers, run `nb settings colors`

    Available themes:

       blacklight, console, desert, electro, forest, monochrome, nb
       ocean, raspberry, unicorn

NB_COLOR_THEME is currently set to nb

Enter a new value, unset to set to the default value, or q to quit.
Value:
```

The primary and secondary colors can also be configured individually,
making the built-in color schemes easily customizable in
`notes settings`. Use `notes settings color_primary` and
`notes settings color_secondary` to open the color settings prompts,
which also both print a table of color values to choose from:

```bash
> nb settings color_primary

[...color table omitted...]

[2] color_primary
    -------------
    The primary color used to highlight identifiers and messages. Often this
    can be set to an xterm color number between 0 and 255. Some terminals
    support many more colors. To view a table of 256 common colors and numbers,
    run: `nb settings colors`
    To view a color for a number, run: `nb settings colors <number>`

      • Default Value: '68' (blue) for 256 color terminals,
                       '4'  (blue) for  8  color terminals.

NB_COLOR_PRIMARY is currently set to 162

Enter a new value, unset to set to the default value, or q to quit.
Value:
```

#### Built-in Themes

##### `blacklight`

| ![blacklight](https://xwmx.github.io/misc/nb/images/nb-theme-blacklight-home.png)  |  ![blacklight](https://xwmx.github.io/misc/nb/images/nb-theme-blacklight-bookmarks.png)
|:--:|:--:|
| 	|    |

##### `console`

| ![console](https://xwmx.github.io/misc/nb/images/nb-theme-console-home.png)  |  ![console](https://xwmx.github.io/misc/nb/images/nb-theme-console-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `desert`

| ![desert](https://xwmx.github.io/misc/nb/images/nb-theme-desert-home.png)  |  ![desert](https://xwmx.github.io/misc/nb/images/nb-theme-desert-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `electro`

| ![electro](https://xwmx.github.io/misc/nb/images/nb-theme-electro-home.png)  |  ![electro](https://xwmx.github.io/misc/nb/images/nb-theme-electro-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `forest`

| ![forest](https://xwmx.github.io/misc/nb/images/nb-theme-forest-home.png)  |  ![forest](https://xwmx.github.io/misc/nb/images/nb-theme-forest-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `monochrome`

| ![monochrome](https://xwmx.github.io/misc/nb/images/nb-theme-monochrome-home.png)  |  ![monochrome](https://xwmx.github.io/misc/nb/images/nb-theme-monochrome-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `nb` (default)

| ![nb](https://xwmx.github.io/misc/nb/images/nb-theme-nb-home.png)  |  ![nb](https://xwmx.github.io/misc/nb/images/nb-theme-nb-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `ocean`

| ![ocean](https://xwmx.github.io/misc/nb/images/nb-theme-ocean-home.png)  |  ![ocean](https://xwmx.github.io/misc/nb/images/nb-theme-ocean-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `raspberry`

| ![raspberry](https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-home.png)  |  ![raspberry](https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-bookmarks.png) |
|:--:|:--:|
| 	|    |

##### `unicorn`

| ![unicorn](https://xwmx.github.io/misc/nb/images/nb-theme-unicorn-home.png)  |  ![unicorn](https://xwmx.github.io/misc/nb/images/nb-theme-unicorn-bookmarks.png) |
|:--:|:--:|
| 	|    |

#### Shell Theme Support

- [`astral` Zsh Theme](https://github.com/xwmx/astral) - Displays the
    current notebook name in the context line of the prompt.

### Interactive Shell

`nb` has an interactive shell that can be started with `nb shell`,
`nb -i`, or `nb --interactive`:

```bash
$ nb shell
__          _
\ \   _ __ | |__
 \ \ | '_ \| '_ \
 / / | | | | |_) |
/_/  |_| |_|_.__/
------------------
nb shell started. Enter ls to list notes and notebooks.
Enter help for a list of subcommands. Enter exit to exit.
nb> ls
home
----
[3] Example
[2] Sample
[1] Demo

nb> edit 3 --content "New content."
Updated [3] Example

nb> bookmark https://example.com
Added [4] example.bookmark.md 'Example Domain (example.com)'

nb> ls
home
----
[4] 🔖 Example Domain (example.com)
[3] Example
[2] Sample
[1] Demo

nb> bookmark url 4
https://example.com

nb> search 'example'
[4] example.bookmark.md 'Example (example.com)'
-----------------------------------------------
1:# Example (example.com)

3:<https://example.com>

[3] example.md 'Example'
------------------------
1:# Example

nb> exit
$
```

The `nb` shell recognizes all `nb` subcommands and options,
providing a streamlined, distraction-free approach for working with `nb`.

### Shortcut Aliases

Several core `nb` subcommands have single-character aliases to make
them faster to work with:

```bash
# `a` (add): add a new note named 'example.md'
nb a example.md

# `b` (bookmark): list bookmarks
nb b

# `o` (open): open bookmark 12 in your web browser
nb o 12

# `p` (peek): open bookmark 6 in your terminal browser
nb p 6

# `e` (edit): edit note 5
nb e 5

# `d` (delete): delete note 19
nb d 19

# `s` (show): show note 27
nb s 27

# `q` (search): search notes for 'example query'
nb q 'example query'

# `h` (help): display the help information for the `add` subcommand
nb h add

# `u` (use): switch to example-notebook
nb u example-notebook
```

If `b` is available on your system, you can add `alias b="bookmark"` to your
`~/.bashrc` or equivalent, which will enable you to:

```bash
# add a new bookmark
b http://example.com

# open bookmark 12
b o 12

# edit bookmark 5
b e 5

# search bookmarks
b q '#example'
```

For more commands and options, run `nb help` or `nb help <subcommand>`

### Help

<p align="center">
  <a href="#nb-help">nb</a> •
  <a href="#bookmark-help">bookmark</a>
  </br>---</br>
  <a href="#add">add</a> •
  <a href="#bookmark">bookmark</a> •
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
  <a href="#notebooks">notebooks</a> •
  <a href="#open">open</a> •
  <a href="#peek">peek</a> •
  <a href="#remote">remote</a> •
  <a href="#rename">rename</a> •
  <a href="#search">search</a> •
  <a href="#settings-1">settings</a> •
  <a href="#shell">shell</a> •
  <a href="#show">show</a> •
  <a href="#status">status</a> •
  <a href="#sync">sync</a> •
  <a href="#update">update</a> •
  <a href="#use">use</a> •
  <a href="#version">version</a>
</p>

#### `nb help`

```text
__          _
\ \   _ __ | |__
 \ \ | '_ \| '_ \
 / / | | | | |_) |
/_/  |_| |_|_.__/

`nb` · `notes` && `bookmark`

Command line note-taking, bookmarking, and archiving with encryption, search,
Git-backed versioning and syncing, Pandoc-backed format conversion, and more
in a single portable script.

Usage:
  nb [<id> | <filename> | <path> | <title>] [<list options>...]
  nb [<url>] [<bookmark options>...]
  nb add [<filename> | <content>] [-c <content> | --content <content>]
         [-e | --encrypt] [-f <filename> | --filename <filename>]
         [-t <title> | --title <title>] [--type <type>]
  nb bookmark [<list options>...]
  nb bookmark <url> [-c <comment> | --comment <comment>] [--edit]
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [--raw-content] [--related <url>]... [--skip-content]
              [--tags <tag1>,<tag2>...] [--title <title>]
  nb bookmark [list [<list options>...]]
  nb bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  nb bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  nb bookmark search <query>
  nb completions (check | install [-d | --download] | uninstall)
  nb count
  nb delete (<id> | <filename> | <path> | <title>) [-f | --force]
  nb edit (<id> | <filename> | <path> | <title>)
          [-e <editor> | --editor <editor>]
  nb export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
            [<pandoc options>...]
  nb export notebook <name> [<path>]
  nb git <git options>...
  nb help [<subcommand> | --readme]
  nb history [<id> | <filename> | <path> | <title>]
  nb import [copy | download | move] (<path> | <url>) [--convert]
  nb import notebook <path> [<name>]
  nb init [<remote-url>]
  nb list [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
          [-n <limit> | --<limit>] [-s | --sort] [-r | --reverse]
          [-t <type> | --type <type> | --<type>]
          [<id> | <filename> | <path> | <title> | <query>]
  nb ls [<list options>...]
  nb move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>
  nb notebooks [<name>] [--archived] [--global] [--local] [--names]
               [--no-color] [--paths] [--unarchived]
  nb notebooks add <name> [<remote-url>]
  nb notebooks (archive | open | peek | status | unarchive) [<name>]
  nb notebooks current [--path]
  nb notebooks delete <name> [-f | --force]
  nb notebooks (export <name> [<path>] | import <path>)
  nb notebooks init [<path> [<remote-url>]]
  nb notebooks rename <old-name> <new-name>
  nb notebooks use <name>
  nb open (<id> | <filename> | <path> | <title>)
  nb peek (<id> | <filename> | <path> | <title>)
  nb remote [remove | set <url> [-f | --force]]
  nb rename (<id> | <filename> | <path> | <title>) [-f | --force]
            (<name> | --reset | --to-bookmark | --to-note)
  nb search <query> [-a | --all] [-t <type> | --type <type> | --<type>]
                    [-l | --list] [--path]
  nb settings [<number> [<value>] | <name> [<value>]]
  nb settings [colors [<number>] | edit | list [--long]]
  nb settings (get | show | unset) (<number> | <name>)
  nb settings set (<number> | <name>) <value>
  nb shell [<subcommand> [<options>...] | --clear-history]
  nb show (<id> | <filename> | <path> | <title>) [--dump [--no-color]]
          [--filename | --id | --path | --render | --title]
  nb sync [-a | --all]
  nb use <notebook>
  nb -i | --interactive [<subcommand> [<options>...]]
  nb -h | --help | help [<subcommand> | --readme]
  nb --version | version

Help:
  nb help <subcommand>  View help information for <subcommand>
  nb help --readme      Download and view the `nb` README file.

More Information:
  https://github.com/xwmx/nb

Subcommands:
  (default)    List notes and notebooks. This is an alias for `nb ls`.
               When a <url> is provided, create a new bookmark.
  add          Add a new note.
  bookmark     Add, open, list, and search bookmarks.
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
  notebooks    Manage notebooks.
  open         Open a bookmark in the primary web browser or edit a note.
  peek         View a bookmark in the terminal web browser or show a note.
  remote       Get, set, and remove the remote URL for the notebook.
  rename       Rename a note.
  search       Search notes.
  settings     Edit configuration settings.
  shell        Start the `nb` interactive shell.
  show         Show a note.
  status       Run `git status` in the current notebook.
  sync         Sync local notebook with the remote repository.
  use          Switch to a notebook.
  version      Display version information.

Program Options:
  -i, --interactive   Start the `nb` interactive shell.
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
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [--raw-content] [--related <url>]... [--skip-content]
              [--tags <tag1>,<tag2>...] [--title <title>]
  bookmark list [<list options>...]
  bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  bookmark search <query>

Options:
  -c, --comment <comment>    A comment or description for this bookmark.
  --edit                     Open the bookmark in your editor before saving.
  -e, --encrypt              Encrypt the bookmark with a password.
  -f, --filename <filename>  The filename for the bookmark. It is recommended
                             to omit the extension so the default bookmark
                             extension is used.
  --raw-content              Save the page content as HTML.
  --related <url>            A URL for a page related to the bookmarked page.
                             Multiple `--related` flags can be used in a
                             command to save multiple related URLs.
  --skip-content             Omit page content from the note.
  --tags <tag1>,<tag2>...    A comma-separated list of tags.
  --title <title>            The bookmark title. When not specified,
                             `nb` will use the html <title> tag.

Subcommands:
  (default)  Add a new bookmark for <url>, or list bookmarks.
             Bookmarks can also be added with `nb <url>`
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
  bookmark https://example.com --encrypt
  bookmark https://example.com --tags example,sample,demo
  bookmark https://example.com/about -c 'Example comment.'
  bookmark https://example.com/faqs -f example-filename
  bookmark list
  bookmark search 'example query'
  bookmark open 5

------------------------------------------
Part of `nb` (https://github.com/xwmx/nb).
For more information, see: `nb help`.
```

### Subcommands

#### `add`

```text
Usage:
  nb add [<filename> | <content>] [-c <content> | --content <content>]
         [-e | --encrypt] [-f <filename> | --filename <filename>]
         [-t <title> | --title <title>] [--type <type>]

Options:
  -c, --content <content>     The content for the new note.
  -e, --encrypt               Encrypt the note with a password.
  -f, --filename <filename>   The filename for the new note. The default
                              extension is used when the extension is omitted.
  -t, --title <title>         The title for a new note. If `--title` is
                              present, the filename will be derived from the
                              title, unless `--filename` is specified.
  --type <type>               The file type for the new note, as a file
                              extension.

Description:
  Create a new note.

  If no arguments are passed, a new blank note file is opened with
  `$EDITOR`, currently set to 'code'. If a non-option argument is
  passed, `nb` will treat it as a <filename≥ if a file extension is found.
  If no file extension is found, `nb` will treat the string as
  <content> and will create a new note without opening the editor.
  `nb add` can also create a new note with piped content.

  `nb` creates Markdown files by default. To create a note with a
  different file type, use the extension in the filename or use the `--type`
  option. To change the default file type, use `nb settings`.

  When the `-e` / `--encrypt` option is used, `nb` will encrypt the
  note with AES-256 using OpenSSL by default, or GPG, if configured in
  `nb settings`.

Examples:
  nb add
  nb add example.md
  nb add "Note content."
  nb add example.md --title "Example Title" --content "Example content."
  echo "Note content." | nb add
  nb add -f "Secret Document" --encrypt

Aliases: `create`, `new`
Shortcut Alias: `a`
```

#### `bookmark`

```text
Usage:
  nb bookmark [<list options>...]
  nb bookmark <url> [-c <comment> | --comment <comment>] [--edit]
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [--raw-content] [--related <url>]... [--skip-content]
              [--tags <tag1>,<tag2>...] [--title <title>]
  nb bookmark list [<list options>...]
  nb bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  nb bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  nb bookmark search <query>

Options:
  -c, --comment <comment>    A comment or description for this bookmark.
  --edit                     Open the bookmark in your editor before saving.
  -e, --encrypt              Encrypt the bookmark with a password.
  -f, --filename <filename>  The filename for the bookmark. It is recommended
                             to omit the extension so the default bookmark
                             extension is used.
  --raw-content              Save the page content as HTML.
  --related <url>            A URL for a page related to the bookmarked page.
                             Multiple `--related` flags can be used in a
                             command to save multiple related URLs.
  --skip-content             Omit page content from the note.
  --tags <tag1>,<tag2>...    A comma-separated list of tags.
  --title <title>            The bookmark title. When not specified,
                             `nb` will use the html <title> tag.

Subcommands:
  (default)  Add a new bookmark for <url>, or list bookmarks.
             Bookmarks can also be added with `nb <url>`
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
  nb https://example.com
  nb bookmark https://example.com
  nb bookmark https://example.com --encrypt
  nb bookmark https://example.com --tags example,sample,demo
  nb bookmark https://example.com/about -c 'Example comment.'
  nb bookmark https://example.com/faqs -f example-filename
  nb bookmark list
  nb bookmark search 'example query'
  nb bookmark open 5

Shortcut Alias: `b`
```

#### `completions`

```text
Usage:
  nb completions (check | install [-d | --download] | uninstall)

Options:
  -d, --download  Download the completion scripts and install.

Description:
  Manage completion scripts. For more information, visit:
  https://github.com/xwmx/nb/blob/master/etc/README.md
```

#### `count`

```text
Usage:
  nb count

Description:
  Print the number of items in the current notebook.
```

#### `delete`

```text
Usage:
  nb delete (<id> | <filename> | <path> | <title>) [-f | --force]

Options:
  -f, --force   Skip the confirmation prompt.

Description:
  Delete a note.

Examples:
  nb delete 3
  nb delete example.md
  nb delete 'A Document Title'

Shortcut Alias: `d`
```

#### `edit`

```text
Usage:
  nb edit (<id> | <filename> | <path> | <title>)
          [-e <editor> | --editor <editor>]

Options:
  -e, --editor <editor>  Edit the note with <editor>, overriding the editor
                         specified in the `$EDITOR` environment variable.

Description:
  Open the specified note in `$EDITOR` or <editor> if specified. Any data
  piped to `nb edit` will be appended to the file.

  Non-text files will be opened in your system's preferred app or program for
  that file type.

Examples:
  nb edit 3
  nb edit example.md
  nb edit 'A Document Title'
  echo "Content to append." | nb edit 1

Shortcut Alias: `e`
```

#### `env`

```text
Usage:
  nb env

Description:
  Print program environment and configuration information.
```

#### `export`

```text
Usage:
  nb export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
            [<pandoc options>...]
  nb export notebook <name> [<path>]
  nb export pandoc (<id> | <filename> | <path> | <title>)
            [<pandoc options>...]

Options:
  -f, --force   Skip the confirmation prompt when overwriting an existing file.

Subcommands:
  (default)     Export a file to <path>. If <path> has a different extension
                than the source note, convert the note using `pandoc`.
  notebook      Export the notebook <name> to the current directory or <path>.
                Alias for `nb notebooks export`.
  pandoc        Export the file to standard output or a file using `pandoc`.
                `export pandoc` prints to standard output by default.

Description:
  Export a file or notebook.

  If Pandoc [1] is available, convert the note from its current format
  to the format of the output file as indicated by the file extension
  in <path>. Any additional arguments are passed directly to Pandoc.
  See the Pandoc help information for available options.

    1. http://pandoc.org/

Examples:
  # Export an Emacs Org mode note
  nb export example.org /path/to/example.org

  # Export a Markdown note to HTML and print to standard output
  nb export pandoc example.md --from=markdown_strict --to=html

  # Export a Markdown note to a .docx Microsoft Office Word document
  nb export example.md /path/to/example.docx
```

#### `git`

```text
Usage:
  nb git <git options>...

Description:
  Alias for `git` within the current notebook.
```

#### `help`

```text
Usage:
  nb help [<subcommand> | --readme]

Options:
  --readme   Download and view the `nb` README file.

Description:
  Print the program help information. When a subcommand name is passed, print
  the help information for the subcommand.

Shortcut Alias: `h`
```

#### `history`

```text
Usage:
  nb history [<id> | <filename> | <path> | <title>]

Description:
  Display notebook history using `tig` [1] (if available) or `git log`.
  When a note is specified, the history for that note is displayed.

    1. https://github.com/jonas/tig

Examples:
  nb history
  nb history example.md
```

#### `import`

```text
Usage:
  nb import (<path> | <url>)
  nb import copy <path>
  nb import download <url> [--convert]
  nb import move <path>
  nb import notebook <path> [<name>]

Options:
  --convert  Convert HTML content to Markdown.

Subcommands:
  (default) Copy or download the file in <path> or <url>.
  copy      Copy the file at <path> into the current notebook.
  download  Download the file at <url> into the current notebook.
  move      Copy the file at <path> into the current notebook.
  notebook  Import the local notebook at <path> to make it global.

Description:
  Copy, move, or download files into the current notebook or import
  a local notebook to make it global.

Examples:
  nb import ~/Pictures/example.png
  nb import ~/Documents/example.docx
  nb import https://example.com/example.pdf
```

#### `init`

```text
Usage:
  nb init [<remote-url>]

Description:
  Initialize the local data directory and generate a ~/.nbrc configuration
  file if it doesn't exist.

Examples:
  nb init
  nb init https://github.com/example/example.git
```

#### `list`

```text
Usage:
  nb list [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
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
  nb list
  nb list example.md -e 10
  nb list --excerpt --no-id
  nb list --filenames --reverse
  nb list '^Example.*'
  nb list --10
  nb list --type document
```

#### `ls`

```text
Usage:
  nb ls [-e [<length>] | --excerpt [<length>]] [--filenames] [--no-id]
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
  when available. `nb ls` is a combination of `nb notebooks` and
  `nb list` in one view.

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
  `nb help list`.

Indicators:
  🔖  Bookmark
  🔒  Encrypted
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video
  🔉  Audio
  📂  Folder

Examples:
  nb ls
  nb ls example.md -e 10
  nb ls --excerpt --no-id
  nb ls --reverse
  nb ls '^Example.*'
  nb ls --10
  nb ls --type document
```

#### `move`

```text
Usage:
  nb move (<id> | <filename> | <path> | <title>) [-f | --force] <notebook>

Options:
  -f, --force   Skip the confirmation prompt.

Description:
  Move the specified note to <notebook>.

Examples:
  nb move 1 example-notebook
  nb move example.md example-notebook

Shortcut Alias: `mv`
```

#### `notebooks`

```text
Usage:
  nb notebooks [<name>] [--archived] [--global] [--local] [--names]
               [--no-color] [--paths] [--unarchived]
  nb notebooks add <name> [<remote-url>]
  nb notebooks (archive | open | peek | status | unarchive) [<name>]
  nb notebooks current [--path]
  nb notebooks delete <name> [-f | --force]
  nb notebooks (export <name> [<path>] | import <path>)
  nb notebooks init [<path> [<remote-url>]]
  nb notebooks rename <old-name> <new-name>
  nb notebooks use <name>

Options:
  --archived    Only list archived notebooks.
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
             Aliases: `notebooks create`, `notebooks new`
  archive    Set the current notebook or notebook <name> to 'archived' status.
  export     Export the notebook <name> to the current directory or <path>,
             making it usable as a local notebook.
  import     Import the local notebook at <path> to make it global.
  init       Create a new local notebook. Specify a <path> or omit to
             initialize the current working directory as a local notebook.
             Specify <remote-url> to clone an existing notebook.
  current    Print the current notebook name.
  delete     Delete a notebook.
  open       Open the current notebook directory or notebook <name> in your
             file browser, explorer, or finder.
             Shortcut Alias: `o`
  peek       Open the current notebook directory or notebook <name> in the
             first tool found in this list:
             `ranger` [1], `mc` [2], `exa` [3] or `ls`.
             Shortcut Alias: `p`
  rename     Rename a notebook.
  status     Print the archival status of the current notebook or
             notebook <name>.
  unarchive  Remove 'archived' status from current notebook or notebook <name>.
  use        Switch to a notebook.

    1. https://ranger.github.io/
    2. https://en.wikipedia.org/wiki/Midnight_Commander
    3. https://github.com/ogham/exa

Description:
  Manage notebooks.

Examples:
  nb notebooks --names
  nb notebooks add Example1
  nb notebooks add Example2 https://github.com/example/example.git

Shortcut Alias: `n`
```

#### `open`

```text
Usage:
  nb open (<id> | <filename> | <path> | <title>)

Description:
  Open the note file. When the note is a bookmark, open the bookmarked page in
  your system's primary web browser. When the note is in a text format or any
  other file type, `open` is the equivalent of `edit`.

See also:
  nb help bookmark
  nb help edit

Shortcut Alias: `o`
```

#### `peek`

```text
Usage:
  nb peek (<id> | <filename> | <path> | <title>)

Description:
  When the note is a bookmark, view the bookmarked page in your terminal web
  browser. When the note is in a text format or any other file type, `peek`
  is the equivalent of `show`.

See also:
  nb help bookmark
  nb help show

Alias: `preview`
Shortcut Alias: `p`
```

#### `remote`

```text
Usage:
  nb remote
  nb remote remove
  nb remote set <url> [-f | --force]

Subcommands:
  (default)     Print the remote URL for the notebook.
  remove        Remove the remote URL from the notebook.
  set           Set the remote URL for the notebook.

Options:
  -f, --force   Skip the confirmation prompt.

Description:
  Get, set, and remove the remote repository URL for the current notebook.

Examples:
  nb remote set https://github.com/example/example.git
  nb remove remove
```

#### `rename`

```text
Usage:
  nb rename (<id> | <filename> | <path> | <title>) [-f | --force]
            (<name> | --reset | --to-bookmark | --to-note)

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
  nb rename example.md example.org

  # Rename note 3 (example.md) to "New Name.md"
  nb rename 3 "New Name"

  # Rename 'example.bookmark.md' to 'New Name.bookmark.md'
  nb rename example.bookmark.md "New Name"

  # Rename note 3 ('example.md') to bookmark named 'example.bookmark.md'
  nb rename 3 --to-bookmark
```

#### `search`

```text
Usage:
  nb search <query> [-a | --all] [-t <type> | --type <type> | --<type>]
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
  nb search 'example query'

  # search all notebooks for 'example query'
  nb search 'example query' --all

  # search notes for 'Example' OR 'Sample'
  nb search 'Example|Sample'

  # search for bookmarks containing the hashtag '#example'
  nb search '#example' --type bookmark

  # search with a regular expression for notes containing phone numbers
  nb search '^(1?(-?\d{3})-?)?(\d{3})(-?\d{4})$'

Shortcut Alias: `q`
```

#### `settings`

```text
Usage:
  nb settings [<number> [<value>] | <name> [<value>]]
  nb settings colors [<number>]
  nb settings edit
  nb settings get   (<number> | <name>)
  nb settings list  [--long]
  nb settings set   (<number> | <name>) <value>
  nb settings show  (<number> | <name>)
  nb settings unset (<number> | <name>)

Subcommands:
  (default)  Open the settings prompt, to <number> or <name>, if present.
             When <value> is also present, assign <value> to the setting.
  colors     Print a table of available colors and their xterm color numbers.
             When <number> is provided, print the number in its color.
  edit       Open the `nb` configuration file in `$EDITOR`.
  get        Print the value of a setting.
  list       List information about available settings.
  set        Assign <value> to a setting.
  show       Print the help information and current value of a setting.
  unset      Unset a setting, returning it to the default value.

Description:
  Configure `nb`. Use `nb settings set` to customize a setting and
  `nb settings unset` to restore the default for a setting.

Examples:
  nb settings
  nb settings set 5 'org'
  nb settings set color_primary 105
  nb settings unset color_primary
  nb settings colors
  nb settings colors 105

Alias: `set`
```

##### `settings list --long`

```text
[1] auto_sync
    ---------
    By default, operations that trigger a git commit like `add`, `edit`,
    and `delete` will sync notebook changes to the remote repository, if
    one is set. To disable this behavior, set this to '0'.

      • Default Value: '1'

[2] color_primary
    -------------
    The primary color used to highlight identifiers and messages. Often this
    can be set to an xterm color number between 0 and 255. Some terminals
    support many more colors. To view a table of 256 common colors and numbers,
    run: `nb settings colors`
    To view a color for a number, run: `nb settings colors <number>`

      • Default Value: '68' (blue) for 256 color terminals,
                       '4'  (blue) for  8  color terminals.

[3] color_secondary
    ---------------
    The color used for lines and footer elements. Like color_primary, this
    can often be set to an xterm color number between 0 and 255. view a
    table of 256 common colors and numbers, run: `nb settings colors`
    To view a color for a number, run: `nb settings colors <number>`

      • Default Value: '8'

[4] color_theme
    -----------
    The color theme. `nb` has several customizable built-in themes,
    listed below.

    Additional themes can be installed in the $NB_DIR/.themes directory.
    Themes have an .nb-theme or .nb-theme.sh extension and contain a
    single if statment assigning the color environment variables to
    tput ANSI color numbers.

      Example:

        # file: ~/.nb/.themes/example.nb-theme.sh
        if [[ "${NB_COLOR_THEME}" == "example" ]]
        then
          export NB_COLOR_PRIMARY=68
          export NB_COLOR_SECONDARY=8
        fi

    To view a list of available color numbers, run `nb settings colors`

    Available themes:

       blacklight, console, desert, electro, forest, monochrome, nb
       ocean, raspberry, unicorn

      • Default Value: 'nb'

[5] default_extension
    -----------------
    The default extension to use for notes files. Change to 'org' for Emacs
    Org mode files, 'rst' for reStructuredText, 'txt' for plain text, or
    whatever you prefer.

      • Default Value: 'md'

[6] editor
    ------
    The command line text editor to use with `nb`.

      • Example Values: 'vim', 'emacs', 'micro', 'code', 'subl' 'macdown'

[7] encryption_tool
    ---------------
    The tool used for encrypting notes.

      • Supported Values: 'openssl', 'gpg'
      • Default Value:    'openssl'

[8] footer
    ------
    By default, `nb ls` includes a footer with example commands for
    easy reference. To hide this footer, set this to '0'.

      • Default Value: '1'

[9] nb_dir
    ------
    The location of the directory that contains the notebooks. To sync with
    Dropbox, you could create a folder at ~/Dropbox/Notes and use:
    `nb settings set NB_DIR ~/Dropbox/Notes`

      • Default Value: '~/.nb'
```

#### `shell`

```text
Usage:
  nb shell [<subcommand> [<options>...] | --clear-history]

Optons:
  --clear-history  Clear the `nb` shell history.

Description:
  Start the `nb` interactive shell. Type 'exit' to exit.

  `nb shell` recognizes all `nb` subcommands and options, providing
  a streamlined, distraction-free approach for working with `nb`.

  When <subcommand> is present, the command will run as the shell is opened.

Example:
  $ nb shell
  nb> ls 3
  [3] Example

  nb> edit 3 --content "New content."
  Updated [3] Example

  nb> notebook
  home

  nb> exit
  $
```

#### `show`

```text
Usage:
  nb show (<id> | <filename> | <path> | <title>) [--dump [--no-color]]
          [--filename | --id | --path | --render | --title]

Options:
  --dump      Print to standard output.
  --filename  Print the filename of the item.
  --id        Print the id number of the item.
  --path      Print the full path of the item.
  --no-color  When used with `--dump`, print the note without highlighting.
  --render    Use `pandoc` [1] to render the file to HTML and display with
              `lynx` [2] (if available) or `w3m` [3]. If `pandoc` is not
              available, `--render` is ignored.
  --title     Print the title of the note.

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
  nb show 1
  nb show example.md --render
  nb show 'A Document Title' --dump --no-color

Shortcut Alias: `s`
```

#### `status`

```text
Usage:
  nb status

Description:
  Run `git status` the current notebook.
```

#### `sync`

```text
Usage:
  nb sync [-a | --all]

Options:
  -a, --all   Sync all active notebooks.

Description:
  Sync the current local notebook with the remote repository.
```

#### `update`

```text
Description:
  Update `nb` to the latest version. You will be prompted for
  your password if administrator priviledges are required.

  If `nb` was installed using a package manager like npm or
  Homebrew, use the package manager's upgrade functionality instead
  of this command.
```

#### `use`

```text
Usage:
  nb use <notebook>

Description:
  Switch to the specified notebook. Shortcut for `nb notebooks use`.

Shortcut Alias: `u`
```

#### `version`

```text
Usage:
  nb version

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
  <a href="https://github.com/xwmx/nb">github.com/xwmx/nb</a>
</p>

<p align="center">
  📝🔖🔒🔍📔
</p>
