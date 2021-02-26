<p align="center">
  <img  src="https://raw.githubusercontent.com/xwmx/nb/master/docs/assets/images/nb.png"
        alt="nb"
        width="200">
</p>

<p align="center">
  <a href="https://github.com/xwmx/nb/actions" rel="nofollow">
    <img  src="https://img.shields.io/github/workflow/status/xwmx/nb/nb%20%C2%B7%20Test%20Suite"
          alt="Build Status"
          style="max-width:100%;">
  </a>
</p>

<br>

`nb` is a command line note-taking, bookmarking, archiving,
and knowledge base application with:

- plain-text data storage,
- [encryption](#password-protected-encrypted-notes-and-bookmarks),
- [filtering](#listing-notes), [pinning](#-pinning), [#tagging](#-tagging), and [search](#-search),
- [Git](https://git-scm.com/)-backed [versioning](#-revision-history) and [syncing](#-git-sync),
- [Pandoc](https://pandoc.org/)-backed [conversion](#%EF%B8%8F-import--export),
- <a href="#-linking">[[wiki-style linking]]</a> with terminal-first [browsing](#-browsing),
- global and local [notebooks](#-notebooks),
- customizable [color themes](#-color-themes),
- extensibility through [plugins](#-plugins),

and more, all in a single portable, user-friendly script.

`nb` creates notes in text-based formats like
[Markdown](https://en.wikipedia.org/wiki/Markdown),
[Org](https://orgmode.org/),
and [LaTeX](https://www.latex-project.org/),
can work with files in any format, can import and export notes to many
document formats, and can create private, password-protected encrypted
notes and bookmarks. With `nb`, you can write notes using Vim, Emacs,
VS Code, Sublime Text, and any other text editor you like. `nb` works in
any standard Linux / Unix environment, including macOS and Windows via WSL.
[Optional dependencies](#optional) can be installed to enhance functionality,
but `nb` works great without them.

<p align="center">
  <img  src="https://xwmx.github.io/misc/nb/images/nb-theme-nb-home.png?v=3"
        alt="home"
        width="450">
</p>

`nb` is also a powerful text-based CLI bookmarking system that includes:

- local full-text search of cached page content with regular expression support,
- tagging,
- convenient filtering and listing,
- [Internet Archive Wayback Machine](https://archive.org/web/) snapshot lookup for
  broken links,
- easy viewing of bookmarked pages in the terminal and your regular web browser.

Page information is automatically downloaded, compiled, and saved into normal Markdown
documents made for humans, so bookmarks are easy to edit just like any other note.

<p align="center">
  <img  src="https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-bookmarks.png?v=3"
        alt="bookmarks"
        width="450">
</p>

`nb` uses [Git](https://git-scm.com/) in the background to automatically
record changes and sync notebooks with remote repositories.
`nb` can also be configured to sync notebooks using a general purpose
syncing utility like Dropbox so notes can be edited in other apps
on any device.

<p align="center">
  <img  src="https://xwmx.github.io/misc/nb/images/nb-theme-console-empty.png?v=3"
        alt="welcome"
        width="450">
</p>

`nb` is designed to be portable, future-focused, and vendor independent,
providing a full-featured and intuitive experience within a highly composable
user-centric text interface.
The entire program is a single [well-tested](#tests)
shell script that can be
installed, copied, or `curl`ed almost anywhere and just work, using
a strategy inspired by
[progressive enhancement](https://en.wikipedia.org/wiki/Progressive_enhancement)
for various experience improvements in more capable environments. `nb` works great
whether you have one notebook with just a few notes or dozens of
notebooks containing thousands of notes, bookmarks, and other items.
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

<br/>

<h1 align="center" id="nb"><code>nb</code></h1>

<p align="center">
	Versions: 6.0.0-alpha
	•
	<a href="https://xwmx.github.io/nb/">5.7.8</a>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#overview">Overview</a> •
  <a href="#help">Help</a>
</p>

### Installation

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

- [`bat`](https://github.com/sharkdp/bat)
- [`ncat`](https://nmap.org/ncat/)
- [`pandoc`](https://pandoc.org/)
- [`rg`](https://github.com/BurntSushi/ripgrep)
- [`tig`](https://github.com/jonas/tig)
- [`w3m`](https://en.wikipedia.org/wiki/W3m)

Also supported for various enhancements:

[Ack](https://beyondgrep.com/),
[`afplay`](https://ss64.com/osx/afplay.html),
[Ag - The Silver Searcher](https://github.com/ggreer/the_silver_searcher),
[`exa`](https://github.com/ogham/exa),
[`ffplay`](https://ffmpeg.org/ffplay.html),
[ImageMagick](https://imagemagick.org/),
[GnuPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard),
[`highlight`](http://www.andre-simon.de/doku/highlight/en/highlight.php),
[`imgcat`](https://www.iterm2.com/documentation-images.html),
[kitty's `icat` kitten](https://sw.kovidgoyal.net/kitty/kittens/icat.html),
[Links](https://en.wikipedia.org/wiki/Links_(web_browser)),
[Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser)),
[Midnight Commander](https://en.wikipedia.org/wiki/Midnight_Commander),
[`mpg123`](https://en.wikipedia.org/wiki/Mpg123),
[MPlayer](https://en.wikipedia.org/wiki/MPlayer),
[ncat](https://nmap.org/ncat/),
[note-link-janitor](https://github.com/andymatuschak/note-link-janitor)
(via [plugin](https://github.com/xwmx/nb/blob/master/plugins/backlink.nb-plugin)),
[`pdftotext`](https://en.wikipedia.org/wiki/Pdftotext),
[Pygments](https://pygments.org/),
[Ranger](https://ranger.github.io/),
[readability-cli](https://gitlab.com/gardenappl/readability-cli),
[`rga` / ripgrep-all](https://github.com/phiresky/ripgrep-all),
[`termpdf.py`](https://github.com/dsanson/termpdf.py),
[vifm](https://vifm.info/)

#### macOS / Homebrew

To install version 5.7.8 with [Homebrew](https://brew.sh/):

```bash
brew tap xwmx/taps
brew install nb
```

Installing `nb` with Homebrew also installs the recommended dependencies
above and completion scripts for Bash and Zsh.

#### Ubuntu, Windows WSL, and others

##### npm

To install version 5.7.8 with [npm](https://www.npmjs.com/package/nb.sh):

```bash
npm install -g nb.sh
```

After `npm` installation completes, run
`sudo "$(which nb)" completions install`
to install Bash and Zsh completion scripts (recommended).

On Ubuntu and WSL, you can run [`sudo "$(which nb)" env install`](#env)
to install the optional dependencies.

*`nb` is also available under its original package name,
[notes.sh](https://www.npmjs.com/package/notes.sh),
which comes with an extra `notes` executable wrapping `nb`.*

##### Download and Install

To install as an administrator, copy and paste one of the following multi-line
commands:

```bash
# install using wget
sudo wget https://raw.github.com/xwmx/nb/master/nb -O /usr/local/bin/nb &&
  sudo chmod +x /usr/local/bin/nb &&
  sudo nb completions install

# install using curl
sudo curl -L https://raw.github.com/xwmx/nb/master/nb -o /usr/local/bin/nb &&
  sudo chmod +x /usr/local/bin/nb &&
  sudo nb completions install
```

On Ubuntu and WSL, you can run [`sudo nb env install`](#env) to install
the optional dependencies.

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

Installing with just user permissions doesn't include the optional
dependencies or completions, but `nb` works without them. If you have
`sudo` access and want to install the completion scripts and
dependencies, run the following command:

```bash
sudo nb env install
```

##### Make

To install with [Make](https://en.wikipedia.org/wiki/Make_(software)),
clone this repository, navigate to the clone's root directory, and run:

```bash
sudo make install
```

This will also install the completion scripts on all systems and the
recommended dependencies on Ubuntu and WSL.

##### bpkg

To install with [bpkg](https://github.com/bpkg/bpkg):

```bash
bpkg install xwmx/nb
```

#### Tab Completion

Bash and Zsh tab completion should be enabled when `nb` is installed using
the methods above, assuming you have the appropriate system
permissions or installed with `sudo`. If completion isn't working after
installing `nb`, see the [completion installation
instructions](https://github.com/xwmx/nb/tree/master/etc).

#### Updating

When `nb` is installed using a package manager like npm or
Homebrew, use the package manager's upgrade functionality to update `nb` to
the latest version. When installed via other methods, `nb` can be updated to
the latest version using the [`nb update`](#update) subcommand.

## Overview

<p align="center">
  <a href="#-notes">Notes</a> •
  <a href="#adding-notes">Adding</a> •
  <a href="#listing-notes">Listing</a> •
  <a href="#editing-notes">Editing</a> •
  <a href="#viewing-notes">Viewing</a> •
  <a href="#deleting-notes">Deleting</a> •
  <a href="#-bookmarks">Bookmarks</a> •
  <a href="#-tagging">Tagging</a> •
  <a href="#-linking">Linking</a> •
  <a href="#-browsing">Browsing</a> •
  <a href="#-zettelkasten">Zettelkasten</a> •
  <a href="#-folders">Folders</a> •
  <a href="#-pinning">Pinning</a> •
  <a href="#-search">Search</a> •
  <a href="#-revision-history">History</a> •
  <a href="#-notebooks">Notebooks</a> •
  <a href="#-git-sync">Git Sync</a> •
  <a href="#%EF%B8%8F-import--export">Import / Export</a> •
  <a href="#%EF%B8%8F-set--settings"><code>set</code> & Settings</a> •
  <a href="#-color-themes">Color Themes</a> •
  <a href="#-plugins">Plugins</a> •
  <a href="#-nb-interactive-shell">Shell</a> •
  <a href="#shortcut-aliases">Shortcuts</a> •
  <a href="#help">Help</a> •
  <a href="#specifications">Specifications</a> •
  <a href="#tests">Tests</a>
</p>

<p align="center">
  <em>Some new features described below are currently available in the git
repository and will be included in version 6.0.0.</em>
</p>

<p align="center">
  <em><a href="https://github.com/xwmx/nb/tree/5.7.8#nb">Version 5.7.8 Documentation</a></em>
</p>

To get started, simply run:

```bash
nb
```

`nb` sets up your initial "home" notebook the first time it runs.

By default, notebooks and notes are global (at `~/.nb`), so they are always available to
`nb` regardless of the current working directory. `nb` also supports
[local notebooks](#global-and-local-notebooks).

### 📝 Notes

#### Adding Notes

Use [`nb add`](#add) to create new notes:

```bash
# create a new note in your text editor
nb add

# create a new note with the filename "example.md"
nb add example.md

# create a new note containing "This is a note."
nb add "This is a note."

# create a new note with piped content
echo "Note content." | nb add

# create a new password-protected, encrypted note titled "Secret Document"
nb add --title "Secret Document" --encrypt

# create a new note in the notebook named "example"
nb example:add "This is a note."

# create a new note in the folder named "sample"
nb add sample/
```

`nb add` with no arguments or input will open the new, blank note in your
environment's preferred text editor. You can change your editor using the
`$EDITOR` environment variable or [`nb set editor`](#editor).

`nb` files are [Markdown](https://daringfireball.net/projects/markdown/)
files by default. The default file type can be changed to whatever you
like using [`nb set default_extension`](#default_extension).

`nb add` has smart argument parsing and behaves differently depending on
the types of arguments it receives. When a filename with extension is
specified, a new note with that filename is opened in the editor:

```bash
nb add example.md
```

When a string is specified, a new note is immediately created with that
string as the content and the editor is not opened:

```bash
> nb add "This is a note."
Added: [1] 20200101000000.md
```

`nb add <string>` is useful for quickly jotting down notes directly
via the command line. Quoting content is optional, but recommended.

When no filename is specified, `nb add` uses the current datetime as
the filename.

`nb add` can also recieve piped content, which behaves the same as
`nb add <string>`:

```bash
# create a new note containing "Note content."
> echo "Note content." | nb add
Added: [6] 20200101000100.md

# create a new note containing the clipboard contents on macOS
> pbpaste | nb add
Added: [7] 20200101000200.md

# create a new note containing the clipboard contents using xclip
> xclip -o | nb add
Added: [8] 20200101000300.md
```

Content can be passed with the `--content` option, which will also
create a new note without opening the editor:

```bash
nb add --content "Note content."
```

When content is piped, specified with `--content`, or passed as a
string argument, use the `--edit` flag to open the file in the editor
before the change is committed.

The title, filename, and content can also be specified with long and
short options:

```bash
> nb add --filename "example.md" -t "Example Title" -c "Example content."
Added: [9] example.md "Example Title"
```

The `-t <title>` / `--title <title>` option will also set the filename
to the title, lowercased with spaces and non-filename characters replaced
with underscores:

```bash
> nb add --title "Example Title" "Example content."
Added: [10] example_title.md "Example Title"
```

Tags can be added with the `--tags <tag1>,<tag2>...` option, which takes
a comma separated list of tags, converts them to
[#hashtags](#-tagging), and inserts them between the title and content:

```bash
> nb add "Example content." --title "Tagged Example" --tags tag1,tag2
Added: [11] tagged_example.md "Tagged Example"

> nb show 11 --print
# Tagged Example

#tag1 #tag2

Example content.
```

Search for tagged items with [`nb search` / `nb q`](#search):

```bash
nb search "#tag1" "#tag2"
```

Files can be created with any file type either by specifying the
extension in the filename, the extension by itself, or via
the `--type <type>` option:

```bash
# open a new Org file in the editor
nb add example.org

# open a new reStructuredText file in the editor
nb add --type rst

# open a new JavaScript file in the editor
nb add .js
```

Combining a type argument with piped clipboard content provides a very
convenient way to save code snippets using a clipboard utility such as
`pbpaste`, `xclip`, or
[`pb`](https://github.com/xwmx/pb):

```bash
# save the clipboard contents as a JavaScript file in the current notebook
pb | nb add .js

# save the clipboard contents as a Rust file in the "rust" notebook
# using the shortcut alias `a`
pb | nb a rust: .rs

# save the clipboard contents as a Haskell file named "example.hs" in the
# "snippets" notebook using the shortcut alias `a`
pb | nb a snippets: example.hs
```

Use [`nb show`](#show) to view code snippets with automatic syntax
highlighting and [`nb edit`](#edit) to open in your editor.

Piping, `--title <title>`, `--tags <tag-list>`, `--content <content>`, and
content passed in an argument can be combined as needed to create notes
with content from multiple input methods and sources using a single
command:

```bash
> pb | nb a "Argument content." \
    --title "Sample Title"      \
    --tags  tag1,tag2           \
    --content "Option content."
Added: [12] sample_title.md "Sample Title"

> nb show 12 --print
# Sample Title

#tag1 #tag2

Argument content.

Option content.

Clipboard content.
```

For a full list of options available for `nb add`, run [`nb help add`](#add).

##### Password-Protected Encrypted Notes and Bookmarks

Password-protected notes and [bookmarks](#-bookmarks) are created with
the `-e` / `--encrypt` flag and are encrypted with AES-256 using OpenSSL
by default. GPG is also supported and can be configured with
[`nb set encryption_tool`](#encryption_tool).

Each protected note and bookmark is encrypted individually with its own
password. When an encrypted item is viewed, edited, or opened, `nb`
will simply prompt for the item's password before proceeding. After an
item is edited, `nb` automatically re-encrypts it and saves the new
version.

Encrypted notes can also be decrypted using the OpenSSL and GPG command
line tools directly, so you aren't dependent on `nb` to decrypt your
files.

##### Shortcut Alias: `a`

`nb` includes single-character shortcuts for many commands, including
`a` for `add`:

```bash
# create a new note in your text editor
nb a

# create a new note with the filename "example.md"
nb a example.md

# create a new note containing "This is a note."
nb a "This is a note."

# create a new note containing the clipboard contents with xclip
xclip -o | nb a

# create a new note in the notebook named "example"
nb example:a
```

##### Other Aliases: `create`, `new`

`nb add` can also be invoked with `nb create` and `nb new` for convenience:

```bash
# create a new note containing "Example note content."
nb new "Example note content."

# create a new note with the title "Example Note Title"
nb create --title "Example Note Title"
```

#### Listing Notes

To list notes and notebooks, run [`nb ls`](#ls):

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
`nb ls` also includes a footer with example commands for easy reference.
The notebook header and command footer can be configured or hidden with
[`nb set header`](#header) and
[`nb set footer`](#footer).

Notes from the current notebook are listed in the order they were last
modified. By default, each note is listed with its id, filename, and an
excerpt from the first line of the note. When a note has a title, the
title is displayed instead of the filename and first line.

Markdown titles can be defined within a note using
[either Markdown `h1` style](https://daringfireball.net/projects/markdown/syntax#header)
or [YAML front matter](#front-matter):

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

[Org](https://orgmode.org/) and [LaTeX](https://www.latex-project.org/)
titles are recognized in `.org` and `.latex` files:

```org
#+TITLE: Example Org Title
```

```latex
\title{Example LaTeX Title}
```

Once defined, titles are displayed in place of the filename and first line
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

If there is no exact match, `nb` will list items with titles and
filenames that fuzzy match the query:

```bash
> nb ls "idea"
[1] Ideas
```

A case-insensitive regular expression can also be used to filter
filenames and titles:

```bash
> nb ls "^example.*"
[3] Example Title
```

Multiple words act like an `OR` filter, listing any titles or filenames that
match any of the words:

```bash
> nb ls example ideas
[3] Example Title
[1] Ideas
```

When multiple words are quoted, filter titles and filenames for that phrase:

```bash
> nb ls "example title"
[3] Example Title
```

For full text search, see [Search](#-search).

To view excerpts of notes, use the `--excerpt` or `-e` option, which
optionally accepts a length:

```bash
> nb ls 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt.

> nb ls 3 -e 8
[3] Example Title
-----------------
# Example Title

This is an example excerpt.

More example content:
- one
- two
- three
```

Several classes of file types are represented with emoji to make them
easily identifiable in lists. For example, bookmarks and encrypted notes
are listed with `🔖` and `🔒`:

```bash
> nb ls
home
----
[4] Example Note
[3] 🔒 encrypted-note.md.enc
[2] 🔖 Example Bookmark (example.com)
[1] 🔖 🔒 encrypted.bookmark.md.enc
```

File types include:

```text
 🔉  Audio
 📖  Book
 🔖  Bookmark
 🔒  Encrypted
 📂  Folder
 🌄  Image
 📄  PDF, Word, or Open Office document
 📹  Video
```

By default, items are listed starting with the most recently modified.
To reverse the order, use the `-r` or `--reverse` flag:

```bash
> nb ls
home
----
[2] Todos
[3] Example Title
[1] Ideas

> nb ls --reverse
[1] Ideas
[3] Example Title
[2] Todos
```

Notes can be sorted with the `-s` / `--sort` flag, which can be combined
with `-r` / `--reverse`:

```bash
> nb ls
home
----
[2] Todos
[3] Example Title
[1] Ideas

> nb ls --sort
[1] Ideas
[2] Todos
[3] Example Title

> nb ls --sort --reverse
[3] Example Title
[2] Todos
[1] Ideas
```

`nb` with no subcommand behaves like an alias for `nb ls`, so the examples
above can be run without the `ls`:

```bash
> nb
home
----
[2] Todos
[3] Example Title
[1] Ideas

> nb "^example.*"
[3] Example Title

> nb 3 --excerpt
[3] Example Title
-----------------
# Example Title

This is an example excerpt.

> nb 3 -e 8
[3] Example Title
-----------------
# Example Title

This is an example excerpt.

More example content:
- one
- two
- three

> nb --sort
[1] Ideas
[2] Todos
[3] Example Title

> nb --sort --reverse
[3] Example Title
[2] Todos
[1] Ideas
```

Short options can be combined for brevity:

```bash
# equivalent to `nb --sort --reverse --excerpt 2` and `nb -s -r -e 2`:
> nb -sre 2
[3] Example Title
-----------------
# Example Title

[2] Todos
---------
Todos
=====
[1] Ideas
---------
---
title: Ideas
```

`nb` and `nb ls` display the 20 most recently modified items. The default
limit can be changed with [`nb set limit <number>`](#limit).
To list a different number of items on a per-command basis, use the
`-n <limit>`, `--limit <limit>`, `--<limit>`, `-a`, or `--all` flags:

```bash
> nb -n 1
home
----
[5] Example Five
4 omitted. 5 total.

> nb --limit 2
home
----
[5] Example Five
[4] Example Four
3 omitted. 5 total.

> nb --3
home
----
[5] Example Five
[4] Example Four
[3] Example Three
2 omitted. 5 total.

> nb --all
home
----
[5] Example Five
[4] Example Four
[3] Example Three
[2] Example Two
[1] Example One
```

`nb ls` is a combination of [`nb notebooks`](#notebooks) and [`nb list`](#list)
in one view and accepts the same arguments as `nb list`, which lists only
notes without the notebook list and with no limit by default:

```bash
> nb list
[100] Example One Hundred
[99]  Example Ninety-Nine
[98]  Example Ninety-Eight
... lists all notes ...
[2]   Example Two
[1]   Example One
```

For more information about options for listing notes, run [`nb help ls`](#ls)
and [`nb help list`](#list).

#### Editing Notes

You can edit a note in your editor by passing its id, filename, or title
to [`nb edit`](#edit):

```bash
# edit note by id
nb edit 3

# edit note by filename
nb edit example.md

# edit note by title
nb edit "A Document Title"

# edit note 12 in the notebook named "example"
nb edit example:12

# edit note 12 in the notebook named "example", alternative
nb example:12 edit

# edit note 12 in the notebook named "example", alternative
nb example:edit 12
```

`edit` and other subcommands that take an identifier can be called with the
identifier and subcommand name reversed:

```bash
# edit note by id
nb 3 edit
```

`nb edit` can also receive piped content, which it will append to the
specified note without opening the editor:

```bash
echo "Content to append." | nb edit 1
```

Content can be passed with the `--content` option, which will also
append the content without opening the editor:

```bash
nb edit 1 --content "Content to append."
```

Use the `--overwrite` option to overwrite existing file content and
the `--prepend` option to prepend the new content before existing
content.

When content is piped or specified with `--content`, use the `--edit`
flag to open the file in the editor before the change is committed.

##### Editing Encrypted Notes

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
nb e "A Document Title"

# edit note by id, alternative
nb 3 e

# edit note 12 in the notebook named "example"
nb e example:12

# edit note 12 in the notebook named "example", alternative
nb example:12 e

# edit note 12 in the notebook named "example", alternative
nb example:e 12
```

For `nb edit` help information, run [`nb help edit`](#edit).

#### Viewing Notes

Notes can be viewed using [`nb show`](#show):

```bash
# show note by id
nb show 3

# show note by filename
nb show example.md

# show note by title
nb show "A Document Title"

# show note by id, alternative
nb 3 show

# show note 12 in the notebook named "example"
nb show example:12

# show note 12 in the notebook named "example", alternative
nb example:12 show

# show note 12 in the notebook named "example", alternative
nb example:show 12
```

By default, `nb show` will open the note in
[`less`](https://linux.die.net/man/1/less), with syntax highlighting if
[`bat`](https://github.com/sharkdp/bat),
[`highlight`](http://www.andre-simon.de/doku/highlight/en/highlight.php),
or
[Pygments](https://pygments.org/)
is installed. You can navigate in `less` using the following keys:

```text
Key               Function
---               --------
mouse scroll      Scroll up or down
arrow up or down  Scroll one line up or down
f                 Jump forward one window
b                 Jump back one window
d                 Jump down one half window
u                 Jump up one half window
/<query>          Search for <query>
n                 Jump to next <query> match
q                 Quit
```

*If `less` scrolling isn't working in [iTerm2](https://www.iterm2.com/),
go to* "Settings" -> "Advanced" -> "Scroll wheel sends arrow keys when in
alternate screen mode" *and change it to* "Yes".
*[More info](https://stackoverflow.com/a/37610820)*

Use the `-p` / `--print` option to print to standard output with syntax
highlighting:

```bash
> nb show 123 --print
# Example Title

Example content:

- one
- two
- three
```

Use `nb show --print --no-color` to print without syntax highlighting.

When [Pandoc](https://pandoc.org/) is available, use the `-r` / `--render`
option to render the note to HTML and open it in your terminal browser:

```bash
nb show example.md --render
# opens example.md as an HTML page in w3m, links, or lynx
```

`nb show` also supports previewing other file types in the terminal,
depending on the tools available in the environment. Supported file types and
tools include:

- PDF files:
  - [`termpdf.py`](https://github.com/dsanson/termpdf.py)
    with [kitty](https://sw.kovidgoyal.net/kitty/)
  - [`pdftotext`](https://en.wikipedia.org/wiki/Pdftotext)
- Audio files:
  - [`mplayer`](https://en.wikipedia.org/wiki/MPlayer)
  - [`afplay`](https://ss64.com/osx/afplay.html)
  - [`mpg123`](https://en.wikipedia.org/wiki/Mpg123)
  - [`ffplay`](https://ffmpeg.org/ffplay.html)
- Images:
  - [ImageMagick](https://imagemagick.org/) with a terminal that
    supports [sixels](https://en.wikipedia.org/wiki/Sixel)
  - [`imgcat`](https://www.iterm2.com/documentation-images.html) with
    [iTerm2](https://www.iterm2.com/)
  - [kitty's `icat` kitten](https://sw.kovidgoyal.net/kitty/kittens/icat.html)
- Folders / Directories:
  - [`ranger`](https://ranger.github.io/)
  - [Midnight Commander (`mc`)](https://en.wikipedia.org/wiki/Midnight_Commander)
- Word Documents:
  - [Pandoc](https://pandoc.org/)
- EPUB ebooks:
  - [Pandoc](https://pandoc.org/) with
    [`w3m`](https://en.wikipedia.org/wiki/W3m),
    [`links`](https://en.wikipedia.org/wiki/Links_(web_browser)), or
    [`lynx`](https://en.wikipedia.org/wiki/Lynx_(web_browser))

When using `nb show` with other file types or if the above tools are not
available, `nb show` will open files in your system's preferred application
for each type.

`nb show` also provides [options](#show) for querying information about an
item. For example, use the `--added` / `-a` and `--updated` / `-u` flags to
print the date and time that an item was added or updated:

```bash
> nb show 2 --added
2020-01-01 01:01:00 -0700

> nb show 2 --updated
2020-02-02 02:02:00 -0700
```

`nb show` is primarily intended for viewing items within the terminal.
To view a file in the system's preferred GUI application,
use [`nb open`](#open).

For full `nb show` usage information, run [`nb help show`](#show).

##### Shortcut Alias: `s`

`show` is aliased to `s`:

```bash
# show note by id
nb s 3

# show note by filename
nb s example.md

# show note by title
nb s "A Document Title"

# show note by id, alternative
nb 3 s

# show note 12 in the notebook named "example"
nb s example:12

# show note 12 in the notebook named "example", alternative
nb example:12 s

# show note 12 in the notebook named "example", alternative
nb example:s 12
```

##### Alias: `view`

`nb show` can also be invoked with `nb view` for convenience:

```bash
# show note by id
nb view 3

# show note by filename
nb view example.md

# show note by title
nb view "A Document Title"

# show note by id, alternative
nb 3 view
```

#### Deleting Notes

To delete a note, pass its id, filename, or title to
[`nb delete`](#delete):

```bash
# delete note by id
nb delete 3

# delete note by filename
nb delete example.md

# delete note by title
nb delete "A Document Title"

# delete note by id, alternative
nb 3 delete

# delete note 12 in the notebook named "example"
nb delete example:12

# delete note 12 in the notebook named "example", alternative
nb example:12 delete

# show note 12 in the notebook named "example", alternative
nb example:delete 12
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
nb d "A Document Title"

# delete note by id, alternative
nb 3 d

# delete note 12 in the notebook named "example"
nb d example:12

# delete note 12 in the notebook named "example", alternative
nb example:12 d

# delete note 12 in the notebook named "example", alternative
nb example:d 12
```

For `nb delete` help information, run [`nb help delete`](#delete).

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
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

`nb` embeds the page content in the bookmark, making it available for full
text search with [`nb search`](#search). When [Pandoc](https://pandoc.org/)
is installed, the HTML page content will be converted to Markdown. When
[readability-cli](https://gitlab.com/gardenappl/readability-cli) is
installed, markup is cleaned up to focus on content.

In addition to caching the page content, you can also include a quote from
the page using the `-q` / `--quote` option:

```bash
nb https://example.com --quote "Example quote line one.

Example quote line two."
```
```markdown
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Quote

> Example quote line one.
>
> Example quote line two.

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

Add a comment to a bookmark using the `-c` / `--comment` option:

```bash
nb https://example.com --comment "Example comment."
```
```markdown
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Comment

Example comment.

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

Bookmarks can be tagged using the `-t` / `--tags` option. Tags are converted
into [#hashtags](#-tagging):

```bash
nb https://example.com --tags tag1,tag2
```
```markdown
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Tags

#tag1 #tag2

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

Search for tagged bookmarks with [`nb search` / `nb q`](#search):

```bash
nb search "#tag1"

nb q "#tag"
```

`nb search` / `nb q` automatically searches archived page content:

```bash
> nb q "example query"
[10] 🔖 example.bookmark.md "Example Bookmark (example.com)"
------------------------------------------------------------
5:Lorem ipsum example query.
```

Bookmarks can also be encrypted:

```bash
# create a new password-protected, encrypted bookmark
nb https://example.com --encrypt
```

Encrypted bookmarks require a password before they can be viewed or
opened.

#### Listing and Filtering Bookmarks

[`nb bookmark`](#bookmark) and `nb bookmark list` can be used to list
and filter only bookmarks:

```bash
> nb bookmark
Add: nb <url> Help: nb help bookmark
------------------------------------
[3] 🔖 🔒 example.bookmark.md.enc
[2] 🔖 Bookmark Two (example.com)
[1] 🔖 Bookmark One (example.com)

> nb bookmark list two
[2] 🔖 Bookmark Two (example.com)
```

Bookmarks are also included in `nb`, `nb ls`, and `nb list`:

```bash
> nb
home
----
[7] 🔖 Bookmark Three (example.com)
[6] Example Note
[5] 🔖 Bookmark Two (example.net)
[4] Sample Note
[3] 🔖 🔒 example-encrypted.bookmark.md.enc
[2] Demo Note
[1] 🔖 Bookmark One (example.com)
```

Use the [`--type <type>` / `--<type>`](#ls) option as a filter to display
only bookmarks:

```bash
> nb --type bookmark
[7] 🔖 Bookmark Three (example.com)
[5] 🔖 Bookmark Two (example.net)
[3] 🔖 🔒 example-encrypted.bookmark.md.enc
[1] 🔖 Bookmark One (example.com)

> nb --bookmark
[7] 🔖 Bookmark Three (example.com)
[5] 🔖 Bookmark Two (example.net)
[3] 🔖 🔒 example-encrypted.bookmark.md.enc
[1] 🔖 Bookmark One (example.com)
```

`nb` saves the domain in the title, making it easy to filter by domain
using any list subcommands:

```bash
> nb example.com
[7] 🔖 Bookmark Three (example.com)
[1] 🔖 Bookmark One (example.com)
```

For more listing options, see [`nb help ls`](#ls), [`nb help list`](#list),
and [`nb help bookmark`](#bookmark).

##### Shortcut Alias: `b`

`bookmark` can also be used with the alias `b`:

```bash
> nb b
Add: nb <url> Help: nb help bookmark
------------------------------------
[7] 🔖 Bookmark Three (example.com)
[5] 🔖 Bookmark Two (example.net)
[3] 🔖 🔒 example-encrypted.bookmark.md.enc
[1] 🔖 Bookmark One (example.com)

> nb b example.net
[5] 🔖 Bookmark Two (example.net)
```

#### Opening and Viewing Bookmarked Pages

`nb` provides multiple ways to view bookmarked web pages.

[`nb open`](#open) opens the bookmarked page in your
system's primary web browser:

```bash
# open bookmark by id
nb open 3

# open bookmark 12 in the notebook named "example"
nb open example:12

# open bookmark 12 in the notebook named "example", alternative
nb example:12 open

# open bookmark 12 in the notebook named "example", alternative
nb example:open 12
```

[`nb peek`](#peek) (alias: `preview`) opens the bookmarked page
in your terminal web browser, such as
[w3m](https://en.wikipedia.org/wiki/W3m),
[Links](https://en.wikipedia.org/wiki/Links_(web_browser)), or
[Lynx](https://en.wikipedia.org/wiki/Lynx_(web_browser)):

```bash
# peek bookmark by id
nb peek 3

# peek bookmark 12 in the notebook named "example"
nb peek example:12

# peek bookmark 12 in the notebook named "example", alternative
nb example:12 peek

# peek bookmark 12 in the notebook named "example", alternative
nb example:peek 12
```
`open` and `peek` subcommands also work seamlessly with encrypted bookmarks.
`nb` will simply prompt you for the bookmark's password.

`open` and `peek` automatically check whether the URL is still valid.
If the page has been removed, `nb` can check the [Internet Archive
Wayback Machine](https://archive.org/web/) for an archived copy.

The preferred terminal web browser can be set using the `$BROWSER`
environment variable, assigned in `~/.bashrc`, `~/.zshrc`, or similar:

```bash
export BROWSER=lynx
```

When `$BROWSER` is not set, `nb` looks for
[`w3m`](https://en.wikipedia.org/wiki/W3m),
[`links`](https://en.wikipedia.org/wiki/Links_(web_browser)), and
[`lynx`](https://en.wikipedia.org/wiki/Lynx_(web_browser))
and uses the first one it finds.

`$BROWSER` can also be used to easy specify the terminal browser for an
individual command:

```bash
> BROWSER=links nb 12 peek
# opens the URL from bookmark 12 in links

> BROWSER=w3m nb 12 peek
# opens the URL from bookmark 12 in w3m
```

`nb show` and `nb edit` can also be used to view and edit bookmark files,
which include the cached page converted to Markdown.

`nb show <id> --render` / `nb show <id> -r` displays the bookmark file
converted to HTML in the terminal web browser, including all bookmark fields
and the cached page content, providing a cleaned-up, distraction-free,
locally-served view of the page content along with all of your notes.

##### Shortcut Aliases: `o` and `p`

`open` and `peek` can also be used with the shortcut aliases `o` and
`p`:

```bash
# open bookmark by id
nb o 3

# open bookmark 12 in the notebook named "example"
nb o example:12

# open bookmark 12 in the notebook named "example", alternative
nb example:12 o

# peek bookmark by id
nb p 3

# peek bookmark 12 in the notebook named "example"
nb p example:12

# peek bookmark 12 in the notebook named "example", alternative
nb example:12 p
```

#### Bookmark File Format

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimally valid bookmark file with `nb add`:

```bash
nb add example.bookmark.md --content "<https://example.com>"
```

For a full overview, see
[`nb` Markdown Bookmark File Format](#nb-markdown-bookmark-file-format).

#### `bookmark` -- A command line tool for managing bookmarks.

`nb` includes [`bookmark`](#bookmark-help), a full-featured command line
interface for creating, viewing, searching, and editing bookmarks.

`bookmark` is a shortcut for the `nb bookmark` subcommand, accepting all
of the same subcommands and options with identical behavior.

Bookmark a page:

```bash
> bookmark https://example.com --tags tag1,tag2
Added: [3] 🔖 20200101000000.bookmark.md "Example Title (example.com)"
```
List and filter bookmarks with `bookmark` and `bookmark list`:

```bash
> bookmark
Add: bookmark <url> Help: bookmark help
---------------------------------------
[3] 🔖 🔒 example.bookmark.md.enc
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
> bookmark search "example query"
[10] 🔖 example.bookmark.md "Example Bookmark (example.com)"
------------------------------------------------------------
5:Lorem ipsum example query.
```

See [`bookmark help`](#bookmark-help) for more information.

### 🏷 Tagging

`nb` recognizes [#hashtags](#-tagging) defined anywhere within a
text document. Notes and bookmarks can be tagged when they are created
using the `--tags <tag1>,<tag2>...` option, which is available with
[`nb add`](#add), [`nb <url>`](#nb-help), and
[`nb bookmark`](#bookmark). `--tags` takes a comma-separated list of
tags, converts them to [#hashtags](#-tagging), and adds them to the
document.

Tags added to notes with `nb add --tags` are placed between the title
and body text:

```bash
> nb add --title "Example Title" "Example note content." --tags tag1,tag2
```

```markdown
# Example Title

#tag1 #tag2

Example note content.
```

Tags added to bookmarks with `nb <url> --tags` and `nb bookmark <url> --tags`
are placed in a _Tags_ section:

```bash
> nb https://example.com --tags tag1,tag2
```

```markdown
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Tags

#tag1 #tag2

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

Tagged items can be searched with [`nb search` / `nb q`](#search):

```bash
# search for and list items in any notebook tagged with "#tag1"
nb search "#tag1" --all --list

# search for and list items in any notebook tagged with "#tag1", shortcut and short options
nb q "#tag1" -al

# search for items in the current notebook tagged with both "#tag1" AND "#tag2"
nb q "#tag1" "#tag2"

# search for items in the current notebook tagged with both "#tag1" AND "#tag2", long option
nb q "#tag1" --and "#tag2"

# search for items in the current notebook tagged with either "#tag1" OR "#tag2"
nb q "#tag1|#tag2"

# search for items in the current notebook tagged with either "#tag1" OR "#tag2", long option
nb q "#tag1" --or "#tag2"
```

Linked tags can be [browsed](#-browsing) with [`nb browse`](#browse),
providing another dimension of browsability in terminal and GUI web
browsers, complimenting <a href="#-linking">[[wiki-style linking]]</a>.

Tags in notes, bookmarks, files in text-based formats, Word `.docx` documents,
and [Open Document](https://en.wikipedia.org/wiki/OpenDocument) `.odt`
files are rendered as links to the list of items in the notebook sharing
that tag:

```bash
❯nb · example : 321

Example Title

#tag1 #tag2

Example content with link to [[Sample Title]].

More example content:
- one
- two
- three
```

Use the `-q` / `--query` option to open `nb browse` to the list of all
items in the current notebook or a specified notebook or folder
that share a tag:

```bash
# open to a list of items tagged with "#tag2" in the "example" notebook
> nb browse example: --query "#tag2"
❯nb · example

search: [#tag2               ]

[example:321] Example Title
[example:654] Sample Title
[example:789] Demo Title

# shortcut alias and short option
> nb br example: -q "#tag2"
❯nb · example

search: [#tag2               ]

[example:321] Example Title
[example:654] Sample Title
[example:789] Demo Title
```

For more information about full-text search, see
[Search](#-search) and [`nb search`](#search). For more information
about browsing, see [Browsing](#-browsing) and [`nb browse`](#browse).

### 🔗 Linking

*Version 6.0.0-alpha*

Notes, bookmarks, files in text-based formats, Word `.docx` documents,
and [Open Document](https://en.wikipedia.org/wiki/OpenDocument) `.odt`
files can reference other items using
<a href="#-linking">[[wiki-style links]]</a>, making `nb` a powerful
terminal-first platform for
[Zettelkasten](#-zettelkasten)
and other link-based note-taking methods.

To add a link from a note or bookmark to another in the same notebook,
include the id, title, or relative path for the target item
within double square brackets anywhere in the linking document:

```text
# link to item with id 123 in the root level of current notebook
[[123]]

# link to item titled "Example Title" in the root level of the current notebook
[[Example Title]]

# link to item with id 456 in the folder named "Sample Folder"
[[Sample Folder/456]]

# link to item titled "Demo Title" in the folder named "Sample Folder"
[[Sample Folder/Demo Title]]
```

To link to an item in another notebook, add the notebook name with a
colon before the identifier:

```text
# link to item 123 in the "sample" folder in the "example" notebook
[[example:sample/123]]

# link to the item titled "Example Title" in the "demo" notebook
[[demo:Example Title]]

# link to the item with filename "Example File.md" in the "sample" notebook
[[sample:Example File.md]]
```

<a href="#-linking">[[wiki-style links]]</a> cooperate well with
[Org links](https://orgmode.org/guide/Hyperlinks.html), which have
a similar syntax, providing a convenient option for linking collections
of Org files.

For more information about identifying items, see [Selectors](#selectors).

### 🌍 Browsing

*Version 6.0.0-alpha*

Use [`nb browse`](#browse) (shortcut: `nb br`) to browse, view, edit,
and search linked notes, bookmarks, notebooks, folders, and other items using
a terminal or GUI web browser.

`nb browse` includes an embedded, terminal-first web application that
renders <a href="#-linking">[[wiki-style links]]</a> and
[#hashtags](#-tagging)
as internal links, enabling you to browse your notes and notebooks in web
browsers, including seamlessly browsing to and from the offsite links in
bookmarks and notes.

```bash
> nb browse
❯nb · home

search: [                    ]

[home:6]  📌 Example Markdown Title
[home:12] 🔒 example-encrypted.md.enc
[home:11] 🔖 Example Bookmark (example.com)
[home:10] 🔖 🔒 example-encrypted.bookmark.md.enc
[home:9]  Example .org Title
[home:8]  🌄 example-image.png
[home:7]  📄 example.pdf
[home:5]  🔉 example-audio.mp3
[home:4]  Example LaTeX Title
[home:3]  📹 example-video.mp4
[home:2]  example.md
[home:1]  📂 Example Folder
```

Items are displayed using the same format as `nb` and `nb ls`, including
pinned items, with each list item linked. Lists are automatically paginated
to fit the height of the terminal window.

```bash
> nb browse example:sample/demo/
❯nb · example : sample / demo /

search: [                    ]

[example:sample/demo/7] Title Seven
[example:sample/demo/6] Title Six
[example:sample/demo/5] Title Five
[example:sample/demo/4] Title Four
[example:sample/demo/3] Title Three

next ❯
```

`nb browse` is designed to make it easy to navigate within terminal
browsers using only keyboard commands, with mouse interactions also
supported.

`nb browse` opens in [w3m](https://en.wikipedia.org/wiki/W3m) (recommended),
[Links](https://en.wikipedia.org/wiki/Links_\(web_browser\)),
[Lynx](https://en.wikipedia.org/wiki/Lynx_\(web_browser\)), or in the
browser set in the `$BROWSER` environment variable.

To open a specific item in `nb browse`, pass the [selector](#selectors)
for the item, folder, or notebook to `nb browse`:

```bash
# open the item titled "Example Title" in the folder named "Sample" in the "example" notebook
> nb browse example:sample/Example\ Title
❯nb · example : sample / 987

Example Title

#tag1 #tag2

Example content with link to [[Demo Title]].

More example content:

  • one
  • two
  • three
```

Items can also be browsed with [`nb show --browse`](#show) /
[`nb show -b`](#show), which behaves identically.

The `nb browse` interface includes breadcrumbs that can be used to
quickly navigate to back to parent folders, the current notebook, or
jump to other notebooks.

`nb browse` is particularly useful for [bookmarks](#-bookmarks). Cached
content is rendered in the web browser, and internal and external links
are easily accessible directly in the terminal, providing a
convenient, distraction-free approach for browsing collections
of bookmarks.

```bash
> nb browse text:formats/markdown/123
❯nb · text : formats / markdown / 123 · edit
Daring Fireball: Markdown (daringfireball.net)

https://daringfireball.net/projects/markdown/

Related

  • https://en.wikipedia.org/wiki/Markdown

Comments

See also:

  • [[text:formats/org]]
  • [[cli:apps/nb]]

Tags

#markup #plain-text

Content

Daring Fireball: Markdown

Download

Markdown 1.0.1 (18 KB) — 17 Dec 2004

Introduction

Markdown is a text-to-HTML conversion tool for web writers. Markdown allows
you to write using an easy-to-read, easy-to-write plain text format, then
convert it to structurally valid XHTML (or HTML).
```

Items can be edited within a terminal or GUI browser using the `edit`
link on the item page or by opening the item with `nb browse --edit`,
with the form resized to fit the current terminal window:

```bash
> nb browse text:formats/markdown/123 --edit
❯nb · text : formats / markdown / 123 · editing

[# Daring Fireball: Markdown (daringfireball.net) ]
[                                                 ]
[<https://daringfireball.net/projects/markdown/>  ]
[                                                 ]
[## Related                                       ]
[                                                 ]
[- <https://example.com>                          ]
[                                                 ]
[## Comments                                      ]
[                                                 ]
[See also:                                        ]
[                                                 ]
[- [[text:formats/org]]                           ]
[- [[cli:apps/nb]]                                ]
[                                                 ]
[## Content                                       ]
[                                                 ]

[save] · last: 2021-01-01 01:00:00
```

Terminal browsers can also be configured to use your editor.

To open `nb browse` in the system's primary GUI web browser, use
`nb browse --gui` / `nb browse -g`:

```bash
# open the item with id 123 in the "sample" notebook in the system's primary GUI browser
nb browse sample:123 --gui
```

`nb browse` includes a search field that can be used for easy searches
in the current notebook or folder while browsing. For full-featured
search, see [Search](#-search) and [`nb search`](#search).

`nb browse` depends on [`ncat`](https://nmap.org/ncat/) and
[`pandoc`](https://pandoc.org/). When only `pandoc` is available, the
current note will be rendered and
<a href="#-linking">[[wiki-style links]]</a>
go to unrendered, original files.
If neither `pandoc` nor `ncat` is available, `nb` falls back to
[`nb show`](#show).

##### `browse` Privacy

Terminal web browsers don't use JavaScript, so visits are not visible to
many web analytics tools. `nb browse` includes a number of additional
features to enhance privacy and avoid leaking information:

- Page content is cached locally within each bookmark file, making it readable
  in a terminal or GUI browser without visiting the original website.
- `<img>` tags in bookmarked content are removed to avoid requests.
- Outbound links are automatically rewritten to use an
  [exit page redirect](https://geekthis.net/post/hide-http-referer-headers/#exit-page-redirect)
  to mitigate leaking information via the
  [referer header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer).
- All pages include the `<meta name="referrer" content="no-referrer" />` tag.
- Links include a `rel="noopener noreferrer"` attribute.
- `lynx` is opened with the `-noreferer` option.

##### Shortcut Alias: `br`

`nb browse` can also be used with the alias `br`:

```bash
# open the current notebook in the terminal web browser
nb br

# open the item with id 123 in the "example" notebook using the terminal web browser
nb br example:123

# open the notebook named "sample" in the GUI web browser
nb br sample: -g
```

For more information, see [`nb browse`](#browse).

### 🗂 Zettelkasten

Zettelkasten (German: "slip box") is a method of note-taking and personal
knowledge management modeled around a few key features:

- Notes are taken liberally on index cards.
- Each note is numbered for easy reference.
- Index cards are organized into boxes.
- Index cards can reference other index cards.
- Cards can include tags and other metadata.

Since `nb` works directly on plain-text files organized in normal system
directories in normal git repositories, `nb` is a very close digital analogue
to physical zettelkasten note-taking.

|    Zettelkasten   |                       `nb`                    |
|:-----------------:|:---------------------------------------------:|
| index cards       | [notes](#-notes) and [bookmarks](#-bookmarks) |
| numbering         | ids and [selectors](#selectors)               |
| slip boxes        | [notebooks](#-notebooks)                      |
| tags              | [#tags](#-tagging)                            |
| metadata          | [front matter](#front-matter)                 |
| cross-references  |  <a href="#-linking">[[wiki-style links]]</a> |
| fast note-taking  | [`nb add` / `nb a`](#adding-notes)            |

For more information about Zettelkasten, see
[Wikipedia](https://en.wikipedia.org/wiki/Zettelkasten).

### 📂 Folders

*Version 6.0.0-alpha*

Items can be organized in folders. To add a note to a folder, call
`nb add` with the folder's relative path within the notebook
followed by a slash:

```bash
# add a new note in the folder named "example"
nb add example/

# add a new note in the folder named "demo" in "example"
nb add example/demo/
```

`nb` automatically creates any intermediate folders as needed.

Folders can be created directly using `nb add --type folder`:

```bash
# create a new folder named "sample"
nb add sample --type folder

# create a folder named "example" containing a folder named "demo"
nb add example/demo --type folder
```

To list the items in a folder, pass the folder relative path to
`nb`, [`nb ls`](#ls), [`nb list`](#list), or [`nb browse`](#browse)
with a trailing slash:

```bash
> nb example/demo/
home
----
[example/demo/3] Title Three
[example/demo/2] Title Two
[example/demo/1] Title One
```

Folders can also be identified by the folder's id and listed with
a trailing slash:

```bash
> nb list
[1] 📂 example

> nb list 1/
[example/2] 📂 demo
[example/1] document.md

> nb list 1/2/
[example/demo/3] Title Three
[example/demo/2] Title Two
[example/demo/1] Title One
```

Items in folders can be idenitified with the folder's relative
path using either folder ids or names, followed by the id,
title, or filename of the item:

```bash
# list item 1 ("Title One", one.md) in the example/demo/ folder
nb list example/demo/1

# edit item 1 ("Title One", one.md) in the example/demo/ folder
nb edit example/2/one.md

# show item 1 ("Title One", one.md) in the example/demo/ folder
nb show 1/2/Title\ One

# delete item 1 ("Title One", one.md) in the example/demo/ folder
nb delete 1/demo/1
```

For folders and items in other notebooks, combine the relative path with
the notebook name, separated by a colon:

```bash
# list the contents of the "sample" folder in the "example" notebook
nb example:sample/

# add an item to the "sample/demo" folder in the "example" notebook
nb add example:sample/demo/

# edit item 3 in the "sample/demo" folder in the "example" notebook
nb edit example:sample/demo/3
```

[Browse](#-browsing) starting at any folder with [`nb browse`](#browse):

```bash
> nb browse example:sample/demo/
❯nb · example : sample / demo /

search: [                    ]

[example:sample/demo/5] Title Five
[example:sample/demo/4] Title Four
[example:sample/demo/3] Title Three
[example:sample/demo/2] Title Two
[example:sample/demo/1] Title One
```

For more information about identifying folders, see [Selectors](#selectors).

### 📌 Pinning

*Version 6.0.0-alpha*

Items can be pinned so they appear first in `nb`, [`nb ls`](#ls), and
[`nb browse`](#browse):

```bash
> nb
home
----
[2] 📌 Title Two
[5] Title Five
[4] Title Four
[3] Title Three
[1] Title One
```

Use [`nb pin`](#pin) and [`nb unpin`](#unpin) to pin and unpin items:

```bash
> nb
home
----
[5] Title Five
[4] Title Four
[3] Title Three
[2] Title Two
[1] Title One

> nb pin 4
Pinned: [4] four.md "Title Four"

> nb pin 1
Pinned: [1] one.md "Title One"

> nb
home
----
[4] 📌 Title Four
[1] 📌 Title One
[5] Title Five
[3] Title Three
[2] Title Two

> nb unpin 4
Unpinned: [4] four.md "Title Four"

> nb
home
----
[1] 📌 Title One
[5] Title Five
[4] Title Four
[3] Title Three
[2] Title Two
```

`nb` can also be configured to pin notes that contain a specified
[#hashtag](#-tagging) or other search pattern. To enable tag / search-based
pinning, set the `$NB_PINNED_PATTERN` environment variable to the desired
[#tag](#-tagging) or pattern.

For example, to treat all items tagged with `#pinned` as pinned items,
add the following line to your `~/.nbrc` file, which can be opened in
your editor with `nb settings edit`:

```bash
export NB_PINNED_PATTERN="#pinned"
```

All indicator icons in `nb` can be customized, so to
use a different character as the pindicator, simply add a line
like the following to your `~/.nbrc` file:

```bash
export NB_INDICATOR_PINNED="💖"
```

```bash
> nb
home
----
[1] 💖 Title One
[5] Title Five
[4] Title Four
[3] Title Three
[2] Title Two
```

### 🔍 Search

Use [`nb search`](#search) (shortcut: `nb q`) to perform full
text searches, with support for regular expressions, [#tags](#-tagging),
and both `AND` and `OR` queries:

```bash
# search current notebook for "example query"
nb search "example query"

# search the notebook "example" for "example query"
nb search example: "example query"

# search the folder named "demo" for "example query"
nb search demo/ "example query"

# search all unarchived notebooks for "example query" and list matching items
nb search "example query" --all --list

# search for "example" AND "demo" with multiple arguments
nb search "example" "demo"

# search for "example" AND "demo" with option
nb search "example" --and "demo"

# search for "example" OR "sample" with argument
nb search "example|sample"

# search for "example" OR "sample" with option
nb search "example" --or "sample"

# search items containing the hashtag "#example"
nb search "#example"

# search with a regular expression
nb search "\d\d\d-\d\d\d\d"

# search bookmarks for "example"
nb search "example" --type bookmark

# search bookmarks for "example", alternative
nb b q "example"

# search the current notebook for "example query"
nb q "example query"

# search the notebook named "example" for "example query"
nb q example: "example query"

# search all unarchived notebooks for "example query" and list matching items
nb q -la "example query"
```

`nb search` prints the id number, filename, and title of each matched
file, followed by each search query match and its line number, with color
highlighting:

```bash
> nb search "example"
[314]  🔖 example.bookmark.md "Example Bookmark (example.com)"
--------------------------------------------------------------
1:# Example Bookmark (example.com)

3:<https://example.com>

[2718] example.md "Example Note"
--------------------------------
1:# Example Note
```

To just print the note information line without the content matches, use
the `-l` or `--list` option:

```bash
> nb search "example" --list
[314]  🔖 example.bookmark.md "Example Bookmark (example.com)"
[2718] example.md "Example Note"
```

Multiple query arguments are treated as `AND` queries, returning items that
match all queries. `AND` queries can also be specified with the `--and <query>`
option:

```bash
# search for items tagged with "#example" AND "#demo" AND "#sample" using
# multiple arguments
nb q "#example" "#demo" "#sample"

# options
nb q "#example" --and "#demo" --and "#sample"
```

`nb` matches `AND` query terms regardless of where they appear in a
document, an improvement over most approaches for performing `AND`
queries with command line tools, which typically only match terms
appearing on the same line.

`OR` queries return items that match at least one of the queries and can
be created by separating terms in a single argument with a pipe
character `|` or with the `--or <query>` option:

```bash
# search for "example" OR "sample" with argument
nb q "example|sample"

# search for "example" OR "sample" with option
nb q "example" --or "sample"
```

`--or` and `--and` queries can be used together:

```bash
nb q "example" --or "sample" --and "demo"
# equivalent: example|sample AND demo|sample
```

`nb search` leverages Git's powerful built-in
[`git grep`](https://git-scm.com/docs/git-grep), which uses the git object
cache to perform searches faster than other available tools. `nb` also
supports performing searches with alternative search tools using
the `--utility <name>` option.

Supported alternative search tools:
- [`rga`](https://github.com/phiresky/ripgrep-all)
- [`rg`](https://github.com/BurntSushi/ripgrep)
- [`ag`](https://github.com/ggreer/the_silver_searcher)
- [`ack`](https://beyondgrep.com/)
- [`grep`](https://en.wikipedia.org/wiki/Grep)

##### Shortcut Alias: `q`

`search` can also be used with the alias `q` (for "query"):

```bash
# search for "example" and print matching excerpts
nb q "example"

# search for "example" and list each matching file
nb q -l "example"

# search for "example" in all unarchived notebooks
nb q -a "example"

# search for "example" in the notbook named "sample"
nb sample:q "example"
```

For more information about search, see [`nb help search`](#search).

### 🗒 Revision History

Whenever a note is added, modified, or deleted, `nb` automatically commits
the change to git transparently in the background.

Use [`nb history`](#history) to view the history of the notebook or an
individual note:

```bash
# show history for current notebook
nb history

# show history for note number 4
nb history 4

# show history for note with filename example.md
nb history example.md

# show history for note titled "Example"
nb history Example

# show history for the notebook named "example"
nb example:history

# show history for the notebook named "example", alternative
nb history example:

# show the history for note 12 in the notebook named "example"
nb history example:12
```

`nb history` uses `git log` by default and prefers
[`tig`](https://github.com/jonas/tig) when available.

### 📚 Notebooks

You can create additional notebooks, each of which has its own version history.

Create a new notebook with [`nb notebooks add`](#notebooks):

```bash
# add a notebook named example
nb notebooks add example
```

`nb` and `nb ls` list the available notebooks above the list of notes:

```bash
> nb
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

To switch to a different notebook, use [`nb use`](#use):

```bash
# switch to the notebook named "example"
nb use example
```

If you are in one notebook and you want to perform a command in a
different notebook without switching to it, add the notebook name with a
colon before the command name:

```bash
# add a new note in the notebook "example"
nb example:add

# add a new note in the notebook "example", shortcut alias
nb example:a

# show note 5 in the notebook "example"
nb example:show 5

# show note 5 in the notebook "example", shortcut alias
nb example:s 5

# edit note 12 in the notebook "example"
nb example:edit 12

# edit note 12 in the notebook "example", shortcut alias
nb example:e 12

# search for "example query" in the notebook "example"
nb example:search "example query"

# search for "example query" in the notebook "example", shortcut alias
nb example:q "example query"

# show the revision history of the notebook "example"
nb example:history
```

The notebook name with colon can also be used as a modifier to the id,
filename, or title:

```bash
# edit note 12 in the notebook "example"
nb edit example:12

# edit note 12 in the notebook "example", shortcut alias
nb e example:12

# edit note 12 in the notebook "example", alternative
nb example:12 edit

# edit note 12 in the notebook "example", alternative, shortcut alias
nb example:12 e

# show note titled "misc" in the notebook "example"
nb show example:misc

# show note titled "misc" in the notebook "example", shortcut alias
nb s example:misc

# delete note with filename "todos.md" in the notebook "example", alternative
nb example:todos.md delete

# delete note with filename "todos.md" in the notebook "example", alternative,
# shortcut alias
nb example:todos.md d
```

When a notebook name with colon is called without a subcommand, `nb` runs
`nb ls` in the specified notebook:

```bash
> nb example:
example · home
--------------
[example:3] Title Three
[example:2] Title Two
[example:1] Title One
```

A bookmark can be created in another notebook by specifying the notebook
name with colon, then a space, then the URL and bookmark options:

```bash
# create a new bookmark in a notebook named "sample"
> nb sample: https://example.com --tags tag1,tag2
```

Notes can also be moved between notebooks:

```bash
# move note 3 from the current notebook to "example"
nb move 3 example:

# move note 5 in the notebook "example" to the notebook "sample"
nb move example:5 sample:
```

##### Example Workflow

The flexibility of `nb`'s argument handling makes it easy to build commands
step by step as items are listed, filtered, viewed, and edited, particularly
in combination with shell history:

```bash
# list items in the "example" notebook
> nb example:
example · home
--------------
[example:3] Title Three
[example:2] Title Two
[example:1] Title One

# filter list
> nb example: three
[example:3] Title Three

# view item
> nb example:3 show
# opens item in `less`

# edit item
> nb example:3 edit
# opens item in $EDITOR
```

##### Notebooks and Tab Completion

[`nb` tab completion](#tab-completion) is optimized for frequently running
commands in various notebooks using the colon syntax, so installing the
completion scripts is recommended and makes working with notebooks easy,
fluid, and fun.

For example, listing the contents of a notebook is usually as simple as typing
the first two or three characters of the name, then press the \<tab\> key,
then press \<enter\>:

```bash
> nb exa<tab>
# completes to "example:"
> nb example:
example · home
--------------
[example:3] Title Three
[example:2] Title Two
[example:1] Title One
```

Scoped notebook commands are also available in tab completion:

```bash
> nb exa<tab>
# completes to "example:"
> nb example:hi<tab>
# completes to "example:history"
```

#### Notebooks, Tags, and Taxonomy

`nb` is optimized to work well with a bunch of notebooks, so notebooks are
a really good way to organize your notes and bookmarks by top-level topic.

Tags are searchable across notebooks and can be created ad hoc, making
notebooks and tags distinct and complementary organizational systems in `nb`.

Search for a tag in or across notebooks with
[`nb search`](#search) / [`nb q`](#search):

```bash
# search for #tag in the current notebook
nb q "#tag"

# search for #tag in all notebooks
nb q "#tag" -a

# search for #tag in the "example" notebook
nb q example: "#tag"
```

#### Global and Local Notebooks

##### Global Notebooks

By default, all `nb` notebooks are global, making them always accessible in
the terminal regardless of the current working directory. Global notebooks are
stored in the directory configured in [`nb set nb_dir`](#nb_dir), which is
`~/.nb` by default.

##### Local Notebooks

`nb` also supports creating and working with local notebooks. Local
notebooks are notebooks that are anywhere on the system outside
of `NB_DIR`. Any folder can be an `nb` local notebook, which is just a normal
folder that has been initialized as a git repository and contains an `nb`
.index file. Initializing a folder as an `nb` local notebook is a very easy
way to add structured git versioning to any folder of documents and
other files.

When `nb` runs within a local notebook, the local notebook is set as the
current notebook:

```bash
> nb
local · example · home
----------------------
[3] Title Three
[2] Title Two
[1] Title One
```

A local notebook is always referred to by the name `local` and otherwise
behaves just like a global notebook whenever a command is run from within it:

```bash
# add a new note in the local notebook
nb add

# edit note 15 in the local notebook
nb edit 15

# move note titled "Todos" from the home notebook to the local notebook
nb move home:Todos local:

# move note 1 from the local notebook to the home notebook
nb move 1 home:

# search the local notebook for <query string>
nb search "query string"

# search the local notebook and all unarchived global notebooks for <query string>
nb search "query string" --all
```

Local notebooks can be created with [`nb notebooks init`](#notebooks):

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
# export global notebook named "example" to "../path/to/destination"
nb notebooks export example ../path/to/destination

# alternative
nb export example ../path/to/destination
```

Local notebooks can also be imported, making them global:

```bash
# import notebook or folder at "../path/to/notebook"
nb notebooks import ../path/to/notebook

# alternative
nb import ../path/to/notebook
```

`nb notebooks init` and `nb notebooks import` can be used together to
easily turn any directory of existing files into a global `nb` notebook:

```bash
> ls
example-directory

> nb notebooks init example-directory
Initialized local notebook: /home/username/example-directory

> nb notebooks import example-directory
Imported notebook: example-directory

> nb notebooks
example-directory
home
```

#### Archiving Notebooks

Notebooks can be archived using [`nb notebooks archive`](#notebooks):

```bash
# archive the current notebook
nb notebooks archive

# archive the notebook named "example"
nb notebooks archive example
```

When a notebook is archived it is not included in [`nb`](#ls) /
[`nb ls`](#ls) output, [`nb search --all`](#search), or tab completion,
nor synced automatically with [`nb sync --all`](#sync).

```bash
> nb
example1 · example2 · example3 · [1 archived]
---------------------------------------------
[3] Title Three
[2] Title Two
[1] Title One
```

Archived notebooks can still be used individually using normal notebook
commands:

```bash
# switch the current notebook to the archived notebook "example"
nb use example

# run the `list` subcommand in the archived notebook "example"
nb example:list
```

Check a notebook's archival status with
[`nb notebooks status`](#notebooks):

```bash
> nb notebooks status example
example is archived.
```

Use [`nb notebooks unarchive`](#notebooks) to unarchive a notebook:

```bash
# unarchive the current notebook
nb notebooks unarchive

# unarchive the notebook named "example"
nb notebooks unarchive example
```

For more information about working with notebooks, see
[`nb help notebooks`](#notebooks).

For technical details about notebooks, see
[`nb` Notebook Specification](#nb-notebook-specification).

### 🔄 Git Sync

Each notebook can be synced with a remote git repository by setting the
remote URL using [`nb remote`](#remote):

```bash
# set the current notebook's remote to a private GitHub repository
nb remote set https://github.com/example/example.git

# set the remote for the notebook named "example"
nb example:remote set https://github.com/example/example.git
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
your `nb` directory with [`nb set nb_dir <path>`](#nb_dir)
and git syncing will still work simultaneously.

When you have an existing `nb` notebook in a git repository, simply
pass the URL to [`nb notebooks add`](#notebooks) and `nb` will clone
your existing notebook and start syncing changes automatically:

```bash
# create a new notebook named "example" cloned from a private GitLab repository
nb notebooks add example https://gitlab.com/example/example.git
```

Turn off syncing for a notebook by removing the remote:

```bash
# remove the remote from the current notebook
nb remote remove

# remove the remote from the notebook named "example"
nb example:remote remove
```

Automatic git syncing can be turned on or off with
[`nb set auto_sync`](#auto_sync).

To sync manually, use [`nb sync`](#sync):

```bash
# manually sync the current notebook
nb sync

# manually sync the notebook named "example"
nb example:sync
```

To bypass `nb` syncing and run `git` commands directly within a
notebook, use [`nb git`](#git):

```bash
# run `git fetch` in the current notebook
nb git fetch origin

# run `git status` in the notebook named "example"
nb example:git status
```

#### Private Repositories and Git Credentials

Syncing with private repositories requires configuring git to not prompt
for credentials. For repositories cloned over HTTPS,
[credentials can be cached with git
](https://docs.github.com/en/free-pro-team@latest/github/using-git/caching-your-github-credentials-in-git).
For repositories cloned over SSH,
[keys can be added to the ssh-agent
](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

Use [`nb sync`](#sync) within a notebook to determine whether your
configuration is working. If `nb sync` displays a password prompt,
then follow the instructions above to configure your credentials.
The password prompt can be used to authenticate, but `nb` does not
cache or otherwise handle git credentials in any way, so there will
likely be multiple password prompts during each sync if credentials
are not configured.

#### Sync Conflict Resolution

`nb` handles git operations automatically, so you shouldn't ever need
to use the `git` command line tool directly. `nb` merges changes when
syncing and handles conflicts using a couple different strategies.

When [`nb sync`](#sync) encounters a conflict in a text file and can't
cleanly merge overlapping local and remote changes, `nb` saves both
versions within the file separated by git conflict markers and prints a
message indicating which file(s) contain conflicting text.
Use [`nb edit`](#edit) to remove the conflict markers and delete any
unwanted text.

For example, in the following file, the second list item was changed on
two systems, and git has no way to determine which one we want to keep:

```
# Example Title

- List Item apple
<<<<<<< HEAD
- List Item apricot
=======
- List Item pluot
>>>>>>> 719od01... [nb] Commit
- List Item plum
```

The local change is between the lines starting with `<<<<<<<` and
`=======`, while the remote change is between the `=======` and
`>>>>>>>` lines.

To resolve this conflict by keeping both items, simply edit the file
with `nb edit` and remove the lines starting with `<<<<<<<`, `=======`,
and `>>>>>>>`:

```
# Example Title

- List Item apple
- List Item apricot
- List Item pluot
- List Item plum
```

When `nb` encounters a conflict in a binary file, such as an encrypted
note, both versions of the file are saved in the notebook as individual
files, with `--conflicted-copy` appended to the filename of the version
from the remote. To resolve a conflicted copy of a binary file, compare
both versions and merge them manually, then delete the `--conflicted-copy`.

If you do encounter a conflict that `nb` says it can't merge at all,
[`nb git`](#git) and [`nb run`](#run) can be used to perform git and
shell operations within the notebook to resolve the conflict manually.
Please also [open an issue](https://github.com/xwmx/nb/issues/new)
with any relevant details that could inform a strategy for handling any
such cases automatically.

### ↕️ Import / Export

Files of any type can be imported into a notebook using
[`nb import`](#import). [`nb edit`](#edit) and [`nb open`](#open) will open
files in your system's default application for that file type.

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

Multiple filenames and globbing are supported:

```bash
# import all files and directories in the current directory
nb import ./*

# import all markdown files in the current directory
nb import ./*.md

# import example.md and sample.md in the current directory
nb import example.md sample.md
```

`nb import` can also download and import files directly from the web:

```bash
# import a PDF file from the web
nb import https://example.com/example.pdf
# Imported "https://example.com/example.pdf" to "example.pdf"

# open example.pdf in your system's PDF viewer
nb open example.pdf
```

Some imported file types have indicators to make them easier to identify in
lists:

```bash
> nb
home
----
[6] 📖 example-ebook.epub
[5] 🌄 example-picture.png
[4] 📄 example-document.docx
[3] 📹 example-video.mp4
[2] 🔉 example-audio.mp3
[1] 📂 Example Folder
```

Notes, bookmarks, and other files can be exported using [`nb export`](#export).
If [Pandoc](https://pandoc.org/) is installed, notes can be automatically
converted to any of the
[formats supported by Pandoc](https://pandoc.org/MANUAL.html#option--to).
By default, the output format is determined by the file extension:

```bash
# export a Markdown note to a .docx Microsoft Office Word document
nb export example.md /path/to/example.docx

# export a note titled "Movies" to an HTML web page.
nb export Movies /path/to/example.html
```

For more control over the `pandoc` options, use the
[`nb export pandoc`](#export) subcommand:

```bash
# export note 42 as an epub with pandoc options
nb export pandoc 42 --from markdown_strict --to epub -o path/to/example.epub
```

[`nb export notebook`](#export) and [`nb import notebook`](#import) can be
used to export and import notebooks:

```bash
# export global notebook named "example" to "../path/to/destination"
nb export notebook example ../path/to/destination

# import notebook or folder at "../path/to/notebook"
nb import notebook ../path/to/notebook
```

[`nb export notebook`](#export) and [`nb import notebook`](#import) behave
like aliases for [`nb notebooks export`](#notebooks) and
[`nb notebooks import`](#notebooks), and the subcommands can be used
interchangeably.

For more information about imported and exported notebooks, see
[Global and Local Notebooks](#global-and-local-notebooks).

For `nb import` and `nb export` help information, see
[`nb help import`](#import) and [`nb help export`](#export).

### ⚙️ `set` & Settings

[`nb set`](#settings) and [`nb settings`](#settings) open the settings
prompt, which provides an easy way to change your `nb` settings.

```bash
nb set
```

To update a setting in the prompt, enter the setting name or number,
then enter the new value, and `nb` will add the setting to your
`~/.nbrc` configuration file.

#### Example: editor

`nb` can be configured to use a specific command line editor using the
`editor` setting.

The settings prompt for a setting can be started by passing the setting
name or number to [`nb set`](#settings):

```bash
> nb set editor
[6]  editor
     ------
     The command line text editor used by `nb`.

     • Example Values:

         atom
         code
         emacs
         macdown
         mate
         micro
         nano
         pico
         subl
         vi
         vim

EDITOR is currently set to vim

Enter a new value, unset to set to the default value, or q to quit.
Value:
```

A setting can also be updated without the prompt by passing both the name
and value to `nb set`:

```bash
# set editor with setting name
> nb set editor code
EDITOR set to code

# set editor with setting number (6)
> nb set 6 code
EDITOR set to code

# set the color theme to blacklight
> nb set color_theme blacklight
NB_COLOR_THEME set to blacklight

# set the default `ls` limit to 10
> nb set limit 10
NB_LIMIT set to 10
```

Use [`nb settings get`](#settings) to print the value of a setting:

```bash
> nb settings get editor
code

> nb settings get 6
code
```

Use [`nb settings unset`](#settings) to unset a setting and revert to
the default:

```bash
> nb settings unset editor
EDITOR restored to the default: vim

> nb settings get editor
vim
```

`nb set` and `nb settings` are aliases that refer to the same subcommand, so
the two subcommand names can be used interchangably.

For more information about `set` and `settings`, see
[`nb help settings`](#settings) and
[`nb settings list --long`](#settings-list---long).

### 🎨 Color Themes

`nb` uses color to highlight various interface elements, including ids, the
current notebook name, the shell prompt, and divider lines.

`nb` includes several built-in color themes and also supports user-defined
themes. The current color theme can be set using
[`nb set color_theme`](#color_theme):

```bash
nb set color_theme
```

#### Built-in Color Themes

##### `blacklight`

| ![blacklight](https://xwmx.github.io/misc/nb/images/nb-theme-blacklight-home.png?v=3)  |  ![blacklight](https://xwmx.github.io/misc/nb/images/nb-theme-blacklight-bookmarks.png?v=3)
|:--:|:--:|
|    |    |

##### `console`

| ![console](https://xwmx.github.io/misc/nb/images/nb-theme-console-home.png?v=3)  |  ![console](https://xwmx.github.io/misc/nb/images/nb-theme-console-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `desert`

| ![desert](https://xwmx.github.io/misc/nb/images/nb-theme-desert-home.png?v=3)  |  ![desert](https://xwmx.github.io/misc/nb/images/nb-theme-desert-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `electro`

| ![electro](https://xwmx.github.io/misc/nb/images/nb-theme-electro-home.png?v=3)  |  ![electro](https://xwmx.github.io/misc/nb/images/nb-theme-electro-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `forest`

| ![forest](https://xwmx.github.io/misc/nb/images/nb-theme-forest-home.png?v=3)  |  ![forest](https://xwmx.github.io/misc/nb/images/nb-theme-forest-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `nb` (default)

| ![nb](https://xwmx.github.io/misc/nb/images/nb-theme-nb-home.png?v=3)  |  ![nb](https://xwmx.github.io/misc/nb/images/nb-theme-nb-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `ocean`

| ![ocean](https://xwmx.github.io/misc/nb/images/nb-theme-ocean-home.png?v=3)  |  ![ocean](https://xwmx.github.io/misc/nb/images/nb-theme-ocean-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `raspberry`

| ![raspberry](https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-home.png?v=3)  |  ![raspberry](https://xwmx.github.io/misc/nb/images/nb-theme-raspberry-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `smoke`

| ![smoke](https://xwmx.github.io/misc/nb/images/nb-theme-monochrome-home.png?v=3)  |  ![smoke](https://xwmx.github.io/misc/nb/images/nb-theme-monochrome-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `unicorn`

| ![unicorn](https://xwmx.github.io/misc/nb/images/nb-theme-unicorn-home.png?v=3)  |  ![unicorn](https://xwmx.github.io/misc/nb/images/nb-theme-unicorn-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

##### `utility`

| ![utility](https://xwmx.github.io/misc/nb/images/nb-theme-utility-home.png?v=3)  |  ![utility](https://xwmx.github.io/misc/nb/images/nb-theme-utility-bookmarks.png?v=3) |
|:--:|:--:|
|    |    |

#### Custom Color Themes

Color themes are [`nb` plugins](#-plugins) with a `.nb-theme` file
extension and contain one `if` statement indicating the name and setting
the color environment variables to `tput` ANSI color numbers:

```bash
# turquoise.nb-theme
if [[ "${NB_COLOR_THEME}" == "turquoise" ]]
then
  export NB_COLOR_PRIMARY=43
  export NB_COLOR_SECONDARY=38
fi
```

View this theme as a complete file:
[`plugins/turquoise.nb-theme`](https://github.com/xwmx/nb/blob/master/plugins/turquoise.nb-theme)

Themes can be installed using [`nb plugins`](#plugins):

```bash
> nb plugins install https://github.com/xwmx/nb/blob/master/plugins/turquoise.nb-theme
Plugin installed:
/home/example/.nb/.plugins/turquoise.nb-theme
```

Once a theme is installed, use [`nb set color_theme`](#color_theme) to set it
as the current theme:

```bash
> nb set color_theme turquoise
NB_COLOR_THEME set to turquoise
```

The primary and secondary colors can also be overridden individually, making
color themes easily customizable:

```bash
# open the settings prompt for the primary color
nb set color_primary

# open the settings prompt for the secondary color
nb set color_secondary
```

To view a table of available colors and numbers, run:

```bash
nb set colors
```

#### Syntax Highlighting Theme

`nb` displays files with syntax highlighting when
[`bat`](https://github.com/sharkdp/bat),
[`highlight`](http://www.andre-simon.de/doku/highlight/en/highlight.php),
or
[Pygments](https://pygments.org/)
is installed.

When `bat` is installed, syntax highlighting color themes are
available for both light and dark terminal backgrounds.
To view a list of available themes and set the syntax highlighting color
theme, use [`nb set syntax_theme`](#syntax_theme).

### $ Shell Theme Support

- [`astral` Zsh Theme](https://github.com/xwmx/astral) - Displays the
    current notebook name in the context line of the prompt.

### 🔌 Plugins

`nb` includes support for plugins, which can be used to create new
subcommands, design themes, and otherwise extend the functionality of `nb`.

`nb` supports two types of plugins, identified by their file extensions:

<dl>
  <dt><code>.nb-theme</code></dt>
  <dd>Plugins defining <a href="#custom-color-themes">color themes</a>.</dd>
  <dt><code>.nb-plugin</code></dt>
  <dd>Plugins defining new subcommands and adding functionality.</dd>
</dl>

Plugins are managed with the [`nb plugins`](#plugins) subcommand and
are installed in the `${NB_DIR}/.plugins` directory.

Plugins can be installed from either a URL or a path using the
[`nb plugins install`](#plugins) subcommand.

```bash
# install a plugin from a URL
nb plugins install https://raw.githubusercontent.com/xwmx/nb/master/plugins/copy.nb-plugin

# install a plugin from a standard GitHub URL
nb plugins install https://github.com/xwmx/nb/blob/master/plugins/example.nb-plugin

# install a theme from a standard GitHub URL
nb plugins install https://github.com/xwmx/nb/blob/master/plugins/turquoise.nb-theme

# install a plugin from a path
nb plugins install plugins/example.nb-plugin
```

The `<url>` should be the full URL to the plugin file. `nb` also
recognizes regular GitHub URLs, which can be used interchangably with
raw GitHub URLs.

Installed plugins can be listed with [`nb plugins`](#plugins), which
optionally takes a name and prints full paths:

```bash
> nb plugins
copy.nb-plugin
example.nb-plugin
turquoise.nb-theme

> nb plugins copy.nb-plugin
copy.nb-plugin

> nb plugins --paths
/home/example/.nb/.plugins/copy.nb-plugin
/home/example/.nb/.plugins/example.nb-plugin
/home/example/.nb/.plugins/turquoise.nb-theme

> nb plugins turquoise.nb-theme --paths
/home/example/.nb/.plugins/turquoise.nb-theme
```

Use [`nb plugins uninstall`](#plugins) to uninstall a plugin:

```bash
> nb plugins uninstall example.nb-plugin
Plugin successfully uninstalled:
/home/example/.nb/.plugins/example.nb-plugin
```

#### Creating Plugins

Plugins are written in a Bash-compatible shell scripting language and
have an `.nb-plugin` extension.

`nb` includes a few example plugins:

- [`example.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/example.nb-plugin)
- [`copy.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/copy.nb-plugin)
- [`ebook.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/ebook.nb-plugin)

Create a new subcommand in three easy steps:

##### 1. Add the new subcommand name with `_subcommands add <name>`:

```bash
_subcommands add "example"
```

##### 2. Define help and usage text with `_subcommands describe <subcommand> <usage>`:

```bash
_subcommands describe "example" <<HEREDOC
Usage:
  nb example

Description:
  Print "Hello, World!"
HEREDOC
```

##### 3. Define the subcommand as a function, named with a leading underscore:

```bash
_example() {
  printf "Hello, World!\\n"
}
```

That's it! 🎉

View the complete plugin:
[`plugins/example.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/example.nb-plugin)

With `example.nb-plugin` installed, `nb` includes an `nb example` subcommand
that prints "Hello, World!"

For a full example,
[`copy.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/copy.nb-plugin)
adds copy / duplicate functionality to `nb` and demonstrates how to create a
plugin using `nb` subcommands and simple shell scripting.

You can install any plugin you create locally with
`nb plugins install <path>`, and you can publish it on GitHub, GitLab, or
anywhere else online and install it with `nb plugins install <url>`.

#### API

The `nb` API is the [command line interface](#nb-help), which is designed for
composability and provides a variety of powerful options for interacting with
notes, bookmarks, notebooks, and `nb` functionality. Within plugins,
subcommands can be called using their function names, which are named with
leading underscores. Options can be used to output information in formats
suitable for parsing and processing:

```bash
# print the content of note 3 to standard output with no color
_show 3 --print --no-color

# list all unarchived global notebook names
_notebooks --names --no-color --unarchived --global

# list all filenames in the current notebook
_list --filenames --no-id --no-indicator

# print the path to the current notebook
_notebooks current --path
```

##### Selectors

Items in `nb` are primarily identified using structured arguments
that are referred to internally as "selectors". Selectors are like
addresses for notebooks, folders, and items. A selector can be as simple
as an id like `123` or folder path like `example/`, or it can combine
multiple elements to identify an item in a nested folder within a
particular notebook, such as
`cli:tools/shellcheck/home-page.bookmark.md`.

A selector is constructed by specifying the notebook name, folder path,
and item identifier in the following pattern:

```text
notebook:folder/path/item-idenitifer
```

Notebooks are identified by the notebook name followed by a colon. When
no folder path or item identifer is specified, the command runs in the
root folder of the notebook:

```bash
# list items in the "example" notebook
nb example:

# add a new note named "Example Title" to the "example" notebook
nb add example: --title "Example Title"

# edit item with id "123" in the notebook "example"
nb edit example:123
```

A notebook selector can also be combined with a subcommand name to
run the command within the notebook:

```bash
# list all items in the "example" notebook and display excerpts
nb example:list -e

# edit item with id "123" in the "example" notebook
nb example:edit 123

# show the git history for the notebook named "example"
nb example:history
```

Folders are identified by relative path from the notebook root,
using either names or ids:

```bash
# list items in the folder named "sample" in the folder named demo"
nb sample/demo/

# add a new item to the folder named "demo" in the folder with id "3"
nb add 3/demo/

# show the history of the folder with id "4" in the folder named
# "sample" in the notebook named "example"
nb history example:sample/4/
```

A trailing slash indicates that the command is expected to operate on
the contents of the folder. When a trailing slash is omitted, the
selector refers to the folder itself:

```bash
> nb list sample
[1] 📂 sample

> nb list sample/
[sample/3] Title Three
[sample/2] Title Two
[sample/1] Title One
```

For more information about folders, see [Folders](#-folders).

An item is identified by id, filename, or title, optionally preceeded by
notebook name or folder path:

```bash
# edit item with id "123"
nb edit 123

# open the item titled "demo title" in the folder with id "3"
nb open 3/demo\ title

# show "file.md" in the "sample" folder in the "example" notebook
nb show example:sample/file.md
```

Items can also be specified using the full path:

```bash
# edit "demo.md" in the "sample" folder in the "home" notebook
nb edit /home/example/.nb/home/sample/demo.md
```

##### Examples

*Idenitifer Selectors*

```text
123
example.md
title
relative/path/to/123
relative/path/to/demo.md
relative/path/to/title
/full/path/to/sample.md
notebook:123
notebook:example.md
notebook:title
notebook:relative/path/to/123
notebook:relative/path/to/demo.md
notebook:relative/path/to/title
```

*Subcommand Selectors*

```text
notebook:
notebook:show
notebook:history
notebook:a
notebook:q
```

`nb` automatically scans arguments for selectors with notebook names and
updates the current notebook if a valid one is found.

Identifier selectors are passed to subcommands as arguments along with
any subcommand options. Use [`show <selector>`](#show) to query
information about the file specified in the selector. For example, to
obtain the filename of a selector-specified file, use
`show <selector> --filename`:

```bash
_example() {
  local _selector="${1:-}"
  [[ -z "${_selector:-}" ]] && printf "Usage: example <selector>\\n" && exit 1

  # Get the filename using the selector.
  local _filename
  _filename="$(_show "${_selector}" --filename)"

  # Rest of subcommand function...
}
```

[`notebooks current --path`](#notebooks) returns the path to the current
notebook:

```bash
# _example() continued:

# get the notebook path
local _notebook_path
_notebook_path="$(_notebooks current --path)"

# print the file at "${_notebook_path}/${_filename}" to standard output
cat "${_notebook_path}/${_filename}"
```

See
[`copy.nb-plugin`](https://github.com/xwmx/nb/blob/master/plugins/copy.nb-plugin)
for a practical example using both [`show <selector> --filename`](#show) and
[`notebooks current --path`](#notebooks) along with other
subcommands called using their underscore-prefixed function names.

### Metadata

Metadata in `nb` is primarily derived from git, the filesystem, and file
content, treating git and the filesystem like overlapping document databases.
For example, displayed timestamps are derived from
[`git log`](https://git-scm.com/docs/git-log), with [`nb show --added`](#show)
displaying the datetime of the first commit containing the file and
[`nb show --updated`](#show) displaying the datetime of the last commit in
which the file was modified.

`nb` also uses plain-text files to store ids and state information in
git, including
[`.index` files](https://github.com/xwmx/nb#index-files),
[`.pindex` files](https://github.com/xwmx/nb#pindex-files),
and [`.archived` files](https://github.com/xwmx/nb#archived-notebooks).

#### Front Matter

User-defined metadata can be added to notes in `nb` using ["front
matter"](https://jekyllrb.com/docs/front-matter/). Front matter is a
simple, human accessible, and future-proof method for defining metadata
fields in plain text and is well supported in tools for working with
Markdown.

Front matter is defined within a Markdown file with triple-dashed lines
(`---`) indicating the start and end of the block, with each field represented
by a key name with a colon followed by the value:


```markdown
---
title: Example Title
author: xwmx
year: 2021
---

Example content.

More example content:

- one
- two
- three
```

Any metadata can be placed in the front matter block. `nb` uses the
`title:` field for listing, filtering, and selecting items, if one is
present, and ignores any other fields.

The simple `key: value` syntax is suitable for many metadata fields.
More complex data can be defined using additional
[YAML](https://en.wikipedia.org/wiki/YAML)
capabilities.

### > `nb` Interactive Shell

`nb` has an interactive shell that can be started with
[`nb shell`](#shell), `nb -i`, or `nb --interactive`:

```bash
$ nb shell
__          _
\ \   _ __ | |__
 \ \ | '_ \| '_ \
 / / | | | | |_) |
/_/  |_| |_|_.__/
------------------
nb shell started. Enter ls to list notes and notebooks.
Enter help for usage information. Enter exit to exit.
nb> ls
home
----
[3] Example
[2] Sample
[1] Demo

nb> edit 3 --content "New content."
Updated: [3] Example

nb> bookmark https://example.com
Added: [4] 🔖 example.bookmark.md "Example Title (example.com)"

nb> ls
home
----
[4] 🔖 Example Title (example.com)
[3] Example
[2] Sample
[1] Demo

nb> bookmark url 4
https://example.com

nb> search "example"
[4] example.bookmark.md "Example (example.com)"
-----------------------------------------------
1:# Example (example.com)

3:<https://example.com>

[3] example.md "Example"
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
# `a` (add): add a new note named "example.md"
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

# `q` (search): search notes for "example query"
nb q "example query"

# `h` (help): display the help information for the `add` subcommand
nb h add

# `u` (use): switch to example-notebook
nb u example-notebook
```

For more commands and options, run `nb help` or `nb help <subcommand>`

### Help

<p align="center">
  <a href="#nb-help">nb</a> •
  <a href="#bookmark-help">bookmark</a> •
  <a href="#subcommands">subcommands</a> •
  <a href="#plugins-1">plugins</a>
</p>

#### `nb help`

```text
__          _
\ \   _ __ | |__
 \ \ | '_ \| '_ \
 / / | | | | |_) |
/_/  |_| |_|_.__/

[nb] Command line note-taking, bookmarking, archiving with plain-text data
storage, encryption, filtering and search, Git-backed versioning and syncing,
Pandoc-backed conversion, global and local notebooks, customizable color
themes, plugins, and more in a single portable, user-friendly script.

Help:
  nb help               Display this help information.
  nb help <subcommand>  View help information for <subcommand>.
  nb help --colors      View information about color settings.
  nb help --readme      View the `nb` README file.

Usage:
  nb
  nb [<ls options>...] [<id> | <filename> | <path> | <title> | <notebook>]
  nb [<url>] [<bookmark options>...]
  nb add [<notebook>:][<filename> | <folder-path> | <content>]
         [-c <content> | --content <content>] [--edit] [-e | --encrypt]
         [-f <filename> | --filename <filename>] [--folder <folder-path>]
         [--tags <tag1>,<tag2>...] [-t <title> | --title <title>]
         [--type <type>]
  nb add folder [<name>]
  nb bookmark [<ls options>...]
  nb bookmark <url> [-c <comment> | --comment <comment>] [--edit]
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [-q | --quote] [-r <url> | --related <url>]... [--save-source]
              [--skip-content] [-t <tag1>,<tag2>... | --tags <tag1>,<tag2>...]
              [--title <title>]
  nb bookmark [list [<list-options>...]]
  nb bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  nb bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  nb bookmark search <query>
  nb browse [<notebook>:][<id> | <filename> | <title> | <path>]
            [-e | --edit] [-g | --gui] [--notebooks] [--print]
            [-q | --query <query>] [-s | --serve]
  nb completions (check | install [-d | --download] | uninstall)
  nb count [<notebook>:][<relative-path>]
  nb delete [<notebook>:](<id> | <filename> | <path> | <title>)...
            [-f | --force]
  nb edit (<id> | <filename> | <path> | <title>)
          [-c <content> | --content <content>] [--edit]
          [-e <editor> | --editor <editor>] [--overwrite] [--prepend]
  nb export (<id> | <filename> | <path> | <title>) <path> [-f | --force]
            [<pandoc options>...]
  nb export notebook <name> [<path>]
  nb export pandoc (<id> | <filename> | <path> | <title>)
            [<pandoc options>...]
  nb git [checkpoint [<message>] | dirty]
  nb git <git-options>...
  nb help [<subcommand>] [-p | --print]
  nb help [-c | --colors] | [-r | --readme] | [-s | --short] [-p | --print]
  nb history [<id> | <filename> | <path> | <title>]
  nb import [copy | download | move] (<path>... | <url>) [--convert]
  nb import notebook <path> [<name>]
  nb init [<remote-url>]
  nb list [-e [<length>] | --excerpt [<length>]] [--filenames]
          [-n <limit> | --limit <limit> |  --<limit>] [--no-id]
          [--no-indicator] [-p | --pager] [--paths] [-s | --sort]
          [-r | --reverse] [-t <type> | --type <type> | --<type>]
          [<id> | <filename> | <path> | <title> | <query>]
  nb ls [-a | --all] [-e [<length>] | --excerpt [<length>]] [--filenames]
        [-n <limit> | --limit <limit> | --<limit>] [--no-footer] [--no-header]
        [--no-id] [--no-indicator] [-p | --pager] [--paths] [-s | --sort]
        [-r | --reverse] [-t <type> | --type <type> | --<type>]
        [<id> | <filename> | <path> | <title> | <query>]
  nb move [<notebook>:](<id> | <filename> | <path> | <title>) [-f | --force]
          ([<notebook>:][<path>] | --reset | --to-bookmark | --to-note)
  nb notebooks [<name>] [--archived] [--global] [--local] [--names]
               [--paths] [--unarchived]
  nb notebooks add <name> [<remote-url>]
  nb notebooks (archive | open | peek | status | unarchive) [<name>]
  nb notebooks current [--path | --selected | --filename [<filename>]]
                       [--global | --local]
  nb notebooks delete <name> [-f | --force]
  nb notebooks (export <name> [<path>] | import <path>)
  nb notebooks init [<path> [<remote-url>]]
  nb notebooks rename <old-name> <new-name>
  nb notebooks select <selector>
  nb notebooks show (<name> | <path> | <selector>) [--archived]
                    [--escaped | --name | --path | --filename [<filename>]]
  nb notebooks use <name>
  nb open (<id> | <filename> | <path> | <title> | <notebook>)
  nb peek (<id> | <filename> | <path> | <title> | <notebook>)
  nb pin [<notebook>:](<id> | <filename> | <path> | <title>)
  nb plugins [<name>] [--paths]
  nb plugins install [<path> | <url>] [--force]
  nb plugins uninstall <name> [--force]
  nb remote [remove | set <url> [-f | --force]]
  nb run <command> [<arguments>...]
  nb search <query>... [-a | --all] [--and <query>] [--or <query>]
            [-l | --list]  [--path] [-t <type> | --type <type> | --<type>]
            [--utility <name>]
  nb set [<name> [<value>] | <number> [<value>]]
  nb settings [colors [<number> | themes] | edit | list [--long]]
  nb settings (get | show | unset) (<name> | <number>)
  nb settings set (<name> | <number>) <value>
  nb shell [<subcommand> [<options>...] | --clear-history]
  nb show [<notebook>:](<id> | <filename> | <path> | <title>)
          [[-a | --added] | [-b | --browse] | --filename | --id | --info-line |
          --path | [-p | --print] [-r | --render] | --title | --type [<type>] |
          [-u | --updated]] [--no-color]
  nb show <notebook>
  nb subcommands [add <name>...] [alias <name> <alias>]
                 [describe <name> <usage>]
  nb sync [-a | --all]
  nb unpin [<notebook>:](<id> | <filename> | <path> | <title>)
  nb update
  nb use <notebook>
  nb -i | --interactive [<subcommand> [<options>...]]
  nb -h | --help | help [<subcommand> | --readme]
  nb --no-color
  nb --version | version

Subcommands:
  (default)    List notes and notebooks. This is an alias for `nb ls`.
               When a <url> is provided, create a new bookmark.
  add          Add a note, folder, or file.
  bookmark     Add, open, list, and search bookmarks.
  browse       Browse, view, and edit linked items in terminal and GUI browsers.
  completions  Install and uninstall completion scripts.
  count        Print the number of items in a notebook or folder.
  delete       Delete a note.
  edit         Edit a note.
  export       Export a note to a variety of different formats.
  git          Run `git` commands within the current notebook.
  help         View help information for the program or a subcommand.
  history      View git history for the current notebook or a note.
  import       Import a file into the current notebook.
  init         Initialize the first notebook.
  list         List notes in the current notebook.
  ls           List notebooks and notes in the current notebook.
  move         Move or rename a note.
  notebooks    Manage notebooks.
  open         Open a bookmarked web page or notebook folder, or edit a note.
  peek         View a note, bookmarked web page, or notebook in the terminal.
  pin          Pin an item so it appears first in lists.
  plugins      Install and uninstall plugins and themes.
  remote       Get, set, and remove the remote URL for the notebook.
  run          Run shell commands within the current notebook.
  search       Search notes.
  settings     Edit configuration settings.
  shell        Start the `nb` interactive shell.
  show         Show a note or notebook.
  status       Run `git status` in the current notebook.
  subcommands  List, add, alias, and describe subcommands.
  sync         Sync local notebook with the remote repository.
  unpin        Unpin a pinned item.
  update       Update `nb` to the latest version.
  use          Switch to a notebook.
  version      Display version information.

Notebook Usage:
  nb <notebook>:[<subcommand>] [<identifier>] [<options>...]
  nb <subcommand> <notebook>:<identifier> [<options>...]

Program Options:
  -i, --interactive   Start the `nb` interactive shell.
  -h, --help          Display this help information.
  --no-color          Print without color highlighting.
  --version           Display version information.

More Information:
  https://github.com/xwmx/nb
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
  bookmark [<ls options>...]
  bookmark <url> [-c <comment> | --comment <comment>] [--edit]
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [-q | --quote] [-r <url> | --related <url>]... [--save-source]
              [--skip-content] [-t <tag1>,<tag2>... | --tags <tag1>,<tag2>...]
              [--title <title>]
  bookmark list [<list-options>...]
  bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  bookmark search <query>

Options:
  -c, --comment <comment>      A comment or description for this bookmark.
  --edit                       Open the bookmark in your editor before saving.
  -e, --encrypt                Encrypt the bookmark with a password.
  -f, --filename <filename>    The filename for the bookmark. It is
                               recommended to omit the extension so the
                               default bookmark extension is used.
  -q, --quote <quote>          A quote or excerpt from the saved page.
                               Alias: `--excerpt`
  -r, --related <url>          A URL for a page related to the bookmarked page.
                               Multiple `--related` flags can be used in a
                               command to save multiple related URLs.
  --save-source                Save the page source as HTML.
  --skip-content               Omit page content from the note.
  -t, --tags <tag1>,<tag2>...  A comma-separated list of tags.
  --title <title>              The bookmark title. When not specified,
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
  bookmarked page available for full-text search. When Pandoc [1] is
  installed, the HTML content will be converted to Markdown before saving.
  When readability-cli [2] is install, markup is cleaned up to focus on
  content.

  `peek` opens the page in `w3m` [3] or `lynx` [4] when available.
  To specify a preferred browser, set the `$BROWSER` environment variable
  in your .bashrc, .zshrc, or equivalent, e.g., `export BROWSER="lynx"`.

  Bookmarks are identified by the `.bookmark.md` file extension. The
  bookmark URL is the first URL in the file within "<" and ">" characters:

    <https://www.example.com>

    1. https://pandoc.org/
    2. https://gitlab.com/gardenappl/readability-cli
    3. https://en.wikipedia.org/wiki/W3m
    4. https://en.wikipedia.org/wiki/Lynx_(web_browser)

Examples:
  bookmark https://example.com
  bookmark https://example.com --encrypt
  bookmark https://example.com --tags example,sample,demo
  bookmark https://example.com/about -c "Example comment."
  bookmark https://example.com/faqs -f example-filename
  bookmark https://example.com --quote "Example quote or excerpt."
  bookmark list
  bookmark search "example query"
  bookmark open 5

------------------------------------------
Part of `nb` (https://github.com/xwmx/nb).
For more information, see: `nb help`.
```

### Subcommands

<p align="center">
  <a href="#add">add</a> •
  <a href="#bookmark">bookmark</a> •
  <a href="#browse">browse</a> •
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
  <a href="#pin">pin</a> •
  <a href="#plugins">plugins</a> •
  <a href="#remote">remote</a> •
  <a href="#run">run</a> •
  <a href="#search">search</a> •
  <a href="#settings">settings</a> •
  <a href="#shell">shell</a> •
  <a href="#show">show</a> •
  <a href="#status">status</a> •
  <a href="#subcommands-1">subcommands</a> •
  <a href="#sync">sync</a> •
  <a href="#unpin">unpin</a> •
  <a href="#update">update</a> •
  <a href="#use">use</a> •
  <a href="#version">version</a>
</p>

#### `add`

```text
Usage:
  nb add [<notebook>:][<filename> | <folder-path> | <content>]
         [-c <content> | --content <content>] [--edit] [-e | --encrypt]
         [-f <filename> | --filename <filename>] [--folder <folder-path>]
         [--tags <tag1>,<tag2>...] [-t <title> | --title <title>]
         [--type <type>]
  nb add folder [<name>]

Options:
  -c, --content <content>     The content for the new note.
  --edit                      Open the note in the editor before saving when
                              content is piped or passed as an argument.
  -e, --encrypt               Encrypt the note with a password.
  -f, --filename <filename>   The filename for the new note.
  --folder <folder-path>      Add within the folder located at <folder-path>.
  --tags <tag1>,<tag2>....    A comma-separated list of tags.
  -t, --title <title>         The title for a new note. If `--title` is
                              present, the filename will be derived from the
                              title, unless `--filename` is specified.
  --type <type>               The file type for the new note, as a file
                              extension.

Description:
  Create a new note or folder.

  If no arguments are passed, a new blank note file is opened with
  `$EDITOR`, currently set to "example". If a non-option argument is
  passed, `nb` will treat it as a <filename≥ if a file extension is found.
  If no file extension is found, `nb` will treat the string as
  <content> and will create a new note without opening the editor.
  `nb add` can also create a new note with piped content.

  `nb` creates Markdown files by default. To create a note with a
  different file type, use the extension in the filename or use the `--type`
  option. To change the default file type, use `nb set default_extension`.

  When the `-e` / `--encrypt` option is used, `nb` will encrypt the
  note with AES-256 using OpenSSL by default, or GPG, if configured in
  `nb set encryption_tool`.

Examples:
  nb add
  nb add example.md
  nb add "Note content."
  nb add example.md --title "Example Title" --content "Example content."
  echo "Note content." | nb add
  nb add -t "Secret Document" --encrypt
  nb add example/document.md
  nb add folder sample/demo
  nb example:add
  nb example:add -t "Title"
  nb a
  nb a "Note content."
  nb example:a
  nb example:a -t "Title"

Aliases: `create`, `new`
Shortcut Alias: `a`
```

#### `bookmark`

```text
Usage:
  nb bookmark [<ls options>...]
  nb bookmark <url> [-c <comment> | --comment <comment>] [--edit]
              [-e | --encrypt] [-f <filename> | --filename <filename>]
              [-q | --quote] [-r <url> | --related <url>]... [--save-source]
              [--skip-content] [-t <tag1>,<tag2>... | --tags <tag1>,<tag2>...]
              [--title <title>]
  nb bookmark list [<list-options>...]
  nb bookmark (open | peek | url) (<id> | <filename> | <path> | <title>)
  nb bookmark (edit | delete) (<id> | <filename> | <path> | <title>)
  nb bookmark search <query>

Options:
  -c, --comment <comment>      A comment or description for this bookmark.
  --edit                       Open the bookmark in your editor before saving.
  -e, --encrypt                Encrypt the bookmark with a password.
  -f, --filename <filename>    The filename for the bookmark. It is
                               recommended to omit the extension so the
                               default bookmark extension is used.
  -q, --quote <quote>          A quote or excerpt from the saved page.
                               Alias: `--excerpt`
  -r, --related <url>          A URL for a page related to the bookmarked page.
                               Multiple `--related` flags can be used in a
                               command to save multiple related URLs.
  --save-source                Save the page source as HTML.
  --skip-content               Omit page content from the note.
  -t, --tags <tag1>,<tag2>...  A comma-separated list of tags.
  --title <title>              The bookmark title. When not specified,
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
  bookmarked page available for full-text search. When Pandoc [1] is
  installed, the HTML content will be converted to Markdown before saving.
  When readability-cli [2] is install, markup is cleaned up to focus on
  content.

  `peek` opens the page in `w3m` [3], `links` [4], or `lynx` [5] when
  available. To specify a preferred browser, set the `$BROWSER` environment
  variable in your .bashrc, .zshrc, or equivalent, e.g.: export BROWSER="links"

  Bookmarks are identified by the `.bookmark.md` file extension. The
  bookmark URL is the first URL in the file within "<" and ">" characters:

    <https://www.example.com>

    1. https://pandoc.org/
    2. https://gitlab.com/gardenappl/readability-cli
    3. https://en.wikipedia.org/wiki/W3m
    4. https://en.wikipedia.org/wiki/Links_(web_browser)
    5. https://en.wikipedia.org/wiki/Lynx_(web_browser)

Examples:
  nb https://example.com
  nb example: https://example.com
  nb https://example.com --encrypt
  nb https://example.com --tags example,sample,demo
  nb https://example.com/about -c "Example comment."
  nb https://example.com/faqs -f example-filename
  nb https://example.com --quote "Example quote or excerpt."
  nb bookmark list
  nb bookmark search "example query"
  nb bookmark open 5
  nb b

Shortcut Alias: `b`
```

#### `browse`

```text
Usage:
  nb browse [<notebook>:][<id> | <filename> | <title> | <path>]
            [-e | --edit] [-g | --gui] [--notebooks] [--print]
            [-q | --query <query>] [-s | --serve]

Options:
  -e, --edit            Open the edit view for the item in the browser.
  -g, --gui             Open in the system's primary GUI web browser.
  --notebooks           Browse notebooks.
  --print               Print to standard output.
  -q, --query <query>   Open to the search results for <query>.
  -s, --serve           Start the web application server.

Description:
  Browse, view, and edit linked notes, bookmarks, notebooks, folders, and
  other items using the terminal or GUI web browser.

  `browse` includes an embedded, terminal-first web application that
  renders [[wiki-style links]] and #tags as internal links, enabling you
  to browse your notes and notebooks in your terminal web browser, as well
  as seamlessly browse to and from the offsite links in bookmarks and notes.

  To link to a note or bookmark from another, include the selector for the
  target item within double square brackets anywhere in the linking document:

    # link to item 123 in the "sample" folder in the "example" notebook
    [[example:sample/123]]

    # link to the item titled "Example Title" in the "demo" notebook
    [[demo:Example Title]]

  `browse` supports `w3m` [1] (recommended), `links` [2], and `lynx` [3]
  and depends on `ncat` [4] and `pandoc` [5]:

    1. https://en.wikipedia.org/wiki/W3m
    2. https://en.wikipedia.org/wiki/Links_(web_browser)
    3. https://en.wikipedia.org/wiki/Lynx_(web_browser)
    4. https://nmap.org/ncat/
    5. https://pandoc.org/

Examples:
  nb browse
  nb browse example:
  nb browse Example\ Folder/
  nb browse 123
  nb browse demo:456

Shortcut Alias: `br`
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
  nb count [<notebook>:][<relative-path>]

Description:
  Print the number of items in the first level of the current notebook,
  <notebook>, or the folder at <relative-path>.
```

#### `delete`

```text
Usage:
  nb delete [<notebook>:](<id> | <filename> | <path> | <title>)...
            [-f | --force]

Options:
  -f, --force   Skip the confirmation prompt.

Description:
  Delete one or more items.

Examples:
  nb delete 3
  nb delete example.md
  nb delete "A Document Title"
  nb 3 delete --force
  nb example:delete 12
  nb delete example:12
  nb example:12 delete
  nb d 3
  nb 3 d
  nb d example:12
  nb example:12 d

Shortcut Alias: `d`
```

#### `edit`

```text
Usage:
  nb edit (<id> | <filename> | <path> | <title>)
          [-c <content> | --content <content>] [--edit]
          [-e <editor> | --editor <editor>] [--overwrite] [--prepend]

Options:
  -c, --content <content>  Content to add to the item.
  --edit                   Open the note in the editor before saving when
                           content is piped or passed as an argument.
  -e, --editor <editor>    Edit the note with <editor>, overriding the editor
                           specified in the `$EDITOR` environment variable.
  --overwrite              Overwrite existing content with <content> and
                           standard input.
  --prepend                Prepend <content> and standard input before
                           existing content.

Description:
  Open the specified note in `$EDITOR` or <editor> if specified. Content
  piped to `nb edit` or passed using the `--content` option will will be
  appended to the file without opening it in the editor, unless the
  `--edit` flag is specified.

  Non-text files will be opened in your system's preferred app or program for
  that file type.

Examples:
  nb edit 3
  nb edit example.md
  nb edit "A Document Title"
  echo "Content to append." | nb edit 1
  nb 3 edit
  nb example:edit 12
  nb edit example:12
  nb example:12 edit
  nb e 3
  nb 3 e
  nb e example:12
  nb example:12 e

Shortcut Alias: `e`
```

#### `env`

```text
Usage:
  nb env [install]

Subcommands:
  install  Install dependencies on supported systems.

Description:
  Print program environment and configuration information, or install
  dependencies.
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

    1. https://pandoc.org/

Examples:
  # Export an Org note
  nb export example.org /path/to/example.org

  # Export a Markdown note to HTML and print to standard output
  nb export pandoc example.md --from=markdown_strict --to=html

  # Export a Markdown note to a .docx Microsoft Office Word document
  nb export example.md /path/to/example.docx

  # Export note 12 in the "sample" notebook to HTML
  nb export sample:12 /path/to/example.html
```

#### `git`

```text
Usage:
  nb git [checkpoint [<message>] | dirty]
  nb git <git-options>...

Subcommands:
  checkpoint    Create a new git commit in the current notebook and sync with
                the remote if `nb set auto_sync` is enabled.
  dirty         0 (success, true) if there are uncommitted changes in
                <notebook-path>. 1 (error, false) if <notebook-path> is clean.

Description:
  Run `git` commands within the current notebook directory.

Examples:
  nb git status
  nb git diff
  nb git log
  nb example:git status
```

#### `help`

```text
Usage:
  nb help [<subcommand>] [-p | --print]
  nb help [-c | --colors] | [-r | --readme] | [-s | --short] [-p | --print]

Options:
  -c, --colors  View information about color themes and color settings.
  -p, --print   Print to standard output / terminal.
  -r, --readme  View the `nb` README file.
  -s, --short   Print shorter help without subcommand descriptions.

Description:
  Print the program help information. When a subcommand name is passed, print
  the help information for the subcommand.

Examples:
  nb help
  nb help add
  nb help import
  nb h notebooks
  nb h e

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
  nb 3 history
  nb history example:
  nb example:history
  nb example:history 12
  nb history example:12
  nb example:12 history
```

#### `import`

```text
Usage:
  nb import (<path>... | <url>)
  nb import copy <path>...
  nb import download <url> [--convert]
  nb import move <path>...
  nb import notebook <path> [<name>]

Options:
  --convert  Convert HTML content to Markdown.

Subcommands:
  (default) Copy or download the file(s) at <path> or <url>.
  copy      Copy the file(s) at <path> into the current notebook.
  download  Download the file at <url> into the current notebook.
  move      Move the file(s) at <path> into the current notebook.
  notebook  Import the local notebook at <path> to make it global.

Description:
  Copy, move, or download files into the current notebook or import
  a local notebook to make it global.

Examples:
  nb import ~/Pictures/example.png
  nb import ~/Documents/example.docx
  nb import https://example.com/example.pdf
  nb example:import https://example.com/example.jpg
  nb import ./*
  nb import ./*.md
```

#### `init`

```text
Usage:
  nb init [<remote-url>]

Description:
  Initialize the local data directory and generate configuration file for `nb`
  if it doesn't exist yet at:

      ~/.nbrc

Examples:
  nb init
  nb init https://github.com/example/example.git
```

#### `list`

```text
Usage:
  nb list [-e [<length>] | --excerpt [<length>]] [--filenames]
          [-n <limit> | --limit <limit> |  --<limit>] [--no-id]
          [--no-indicator] [-p | --pager] [--paths] [-s | --sort]
          [-r | --reverse] [-t <type> | --type <type> | --<type>]
          [<id> | <filename> | <path> | <title> | <query>]

Options:
  -e, --excerpt [<length>]        Print an excerpt <length> lines long under
                                  each note's filename [default: 3].
  --filenames                     Print the filename for each note.
  -n, --limit <limit>, --<limit>  The maximum number of notes to list.
  --no-id                         Don't include the id in list items.
  --no-indicator                  Don't include the indicator in list items.
  -p, --pager                     Display output in the pager.
  --paths                         Print the full path to each item.
  -s, --sort                      Order notes by id.
  -r, --reverse                   List items in reverse order.
  -t, --type <type>, --<type>     List items of <type>. <type> can be a file
                                  extension or one of the following types:
                                  archive, audio, book, bookmark, document,
                                  folder, image, note, text, video

Description:
  List notes in the current notebook.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

Indicators:
  🔉  Audio
  📖  Book
  🔖  Bookmark
  🔒  Encrypted
  📂  Folder
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video

Examples:
  nb list
  nb list example.md -e 10
  nb list --excerpt --no-id
  nb list --filenames --reverse
  nb list "^Example.*"
  nb list --10
  nb list --type document
  nb example:list
```

#### `ls`

```text
Usage:
  nb ls [-a | --all] [-e [<length>] | --excerpt [<length>]] [--filenames]
        [-n <limit> | --limit <limit> | --<limit>] [--no-footer] [--no-header]
        [--no-id] [--no-indicator] [-p | --pager] [--paths] [-s | --sort]
        [-r | --reverse] [-t <type> | --type <type> | --<type>]
        [<id> | <filename> | <path> | <title> | <query>]

Options:
  -a, --all                       Print all items in the notebook. Equivalent
                                  to no limit.
  -e, --excerpt [<length>]        Print an excerpt <length> lines long under
                                  each note's filename [default: 3].
  --filenames                     Print the filename for each note.
  -n, --limit <limit>, --<limit>  The maximum number of listed items.
                                  [default: 20]
  --no-header                     Print without header.
  --no-footer                     Print without footer.
  --no-id                         Don't include the id in list items.
  --no-indicator                  Don't include the indicator in list items.
  -p, --pager                     Display output in the pager.
  --paths                         Print the full path to each item.
  -s, --sort                      Order notes by id.
  -r, --reverse                   List items in reverse order.
  -t, --type <type>, --<type>     List items of <type>. <type> can be a file
                                  extension or one of the following types:
                                  archive, audio, book, bookmark, document,
                                  folder, image, note, text, video

Description:
  List notebooks and notes in the current notebook, displaying note titles
  when available. `nb ls` is a combination of `nb notebooks` and
  `nb list` in one view.

  When <id>, <filename>, <path>, or <title> are present, the listing for the
  matching note will be displayed. When no match is found, titles and
  filenames will be searched for any that match <query> as a case-insensitive
  regular expression.

  Options are passed through to `list`. For more information, see
  `nb help list`.

Indicators:
  🔉  Audio
  📖  Book
  🔖  Bookmark
  🔒  Encrypted
  📂  Folder
  🌄  Image
  📄  PDF, Word, or Open Office document
  📹  Video

Examples:
  nb
  nb --all
  nb ls
  nb ls example.md -e 10
  nb ls --excerpt --no-id
  nb ls --reverse
  nb ls "^Example.*"
  nb ls --10
  nb ls --type document
  nb example:
  nb example: -ae
  nb example:ls
```

#### `move`

```text
Usage:
  nb move [<notebook>:](<id> | <filename> | <path> | <title>) [-f | --force]
          ([<notebook>:][<path>] | --reset | --to-bookmark | --to-note)

Options:
  -f, --force     Skip the confirmation prompt.
  --reset         Reset the filename to the last modified timestamp.
  --to-bookmark   Preserve the existing filename and replace the extension
                  with ".bookmark.md" to convert the note to a bookmark.
  --to-note       Preserve the existing filename and replace the bookmark's
                  ".bookmark.md" extension with ".md" to convert the bookmark
                  to a Markdown note.

Description:
  Move or rename a note. Move the note to <path> or change the file type.
  When file extension is omitted, the existing extension will be used.

  `move` and `rename` are aliases and can be used interchangably.

Examples:
  # Move "example.md" to "example.org"
  nb move example.md sample.org

  # Rename note 3 ("example.md") to "New Name.md"
  nb rename 3 "New Name"

  # Rename "example.bookmark.md" to "New Name.bookmark.md"
  nb move example.bookmark.md "New Name"

  # Rename note 3 ("example.md") to bookmark named "example.bookmark.md"
  nb rename 3 --to-bookmark

  # Move note 12 into "Sample Folder" in the "demo" notebook
  nb move example:12 demo:Sample\ Folder/

  # Rename note 12 in the "example" notebook to "sample.md"
  nb rename example:12 "sample.md"

Alias: `rename`
Shortcut Alias: `mv`
```

#### `notebooks`

```text
Usage:
  nb notebooks [<name>] [--archived] [--global] [--local] [--names]
               [--paths] [--unarchived]
  nb notebooks add <name> [<remote-url>]
  nb notebooks (archive | open | peek | status | unarchive) [<name>]
  nb notebooks current [--path | --selected | --filename [<filename>]]
                       [--global | --local]
  nb notebooks delete <name> [-f | --force]
  nb notebooks (export <name> [<path>] | import <path>)
  nb notebooks init [<path> [<remote-url>]]
  nb notebooks rename <old-name> <new-name>
  nb notebooks select <selector>
  nb notebooks show (<name> | <path> | <selector>) [--archived]
                    [--escaped | --name | --path | --filename [<filename>]]
  nb notebooks use <name>

Options:
  --archived               List archived notebooks, or return archival status
                           with `show`.
  --escaped                Print the notebook name with spaces escaped.
  --filename [<filename>]  Print an available filename for the notebooks. When
                           <filename> is provided, check for an existing file
                           and provide a filename with an appended sequence
                           number for uniqueness.
  --global                 List global notebooks or the notebook set globally
                           with `use`.
  --local                  Exit with 0 if current within a local notebook,
                           otherwise exit with 1.
  -f, --force              Skip the confirmation prompt.
  --name, --names          Print the notebook name.
  --path, --paths          Print the notebook path.
  --selected               Exit with 0 if the current notebook differs from
                           the current global notebook, otherwise exit with 1.
  --unarchived             Only list unarchived notebooks.

Subcommands:
  (default)  List notebooks.
  add        Create a new global notebook. When an existing notebook's
             <remote-url> is specified, create the new global notebook as a
             clone of <remote-url>.
             Aliases: `notebooks create`, `notebooks new`
  archive    Set the current notebook or notebook <name> to "archived" status.
  export     Export the notebook <name> to the current directory or <path>,
             making it usable as a local notebook.
  import     Import the local notebook at <path> to make it global.
  init       Create a new local notebook. Specify a <path> or omit to
             initialize the current working directory as a local notebook.
             Specify <remote-url> to clone an existing notebook.
  current    Print the current notebook name or path.
  delete     Delete a notebook.
  open       Open the current notebook directory or notebook <name> in your
             file browser, explorer, or finder.
             Shortcut Alias: `o`
  peek       Open the current notebook directory or notebook <name> in the
             first tool found in the following list:
             `ranger` [1], `mc` [2], `vifm` [3], `exa` [4], or `ls`.
             Shortcut Alias: `p`
  rename     Rename a notebook.
  select     Set the current notebook from a colon-prefixed selector.
             Not persisted. Selection format: <notebook>:<identifier>
  status     Print the archival status of the current notebook or
             notebook <name>.
  show       Show and return information about a specified notebook.
  unarchive  Remove "archived" status from current notebook or notebook <name>.
  use        Switch to a notebook.

    1. https://ranger.github.io/
    2. https://en.wikipedia.org/wiki/Midnight_Commander
    3. https://vifm.info/
    4. https://github.com/ogham/exa

Description:
  Manage notebooks.

Examples:
  nb notebooks --names
  nb notebooks add sample
  nb notebooks add example https://github.com/example/example.git
  nb n current --path
  nb n archive example

Shortcut Alias: `n`
```

#### `open`

```text
Usage:
  nb open (<id> | <filename> | <path> | <title> | <notebook>)

Description:
  Open a note or notebook. When the note is a bookmark, open the bookmarked
  page in your system's primary web browser. When the note is in a text format
  or any other file type, `open` is the equivalent of `edit`. `open`
  with a notebook opens the notebook folder in the system's file browser.

Examples:
  nb open 3
  nb open example.bookmark.md
  nb 3 open
  nb example:open 12
  nb open example:12
  nb example:12 open
  nb o 3
  nb 3 o
  nb o example:12
  nb example:12 o

See also:
  nb help bookmark
  nb help edit

Shortcut Alias: `o`
```

#### `peek`

```text
Usage:
  nb peek (<id> | <filename> | <path> | <title> | <notebook>)

Description:
  View a note or notebook in the terminal. When the note is a bookmark, view
  the bookmarked page in your terminal web browser. When the note is in a text
  format or any other file type, `peek` is the equivalent of `show`. When
  used with a notebook, `peek` opens the notebook folder first tool found in
  the following list: `ranger` [1], `mc` [2], `exa` [3], or `ls`.

    1. https://ranger.github.io/
    2. https://en.wikipedia.org/wiki/Midnight_Commander
    3. https://github.com/ogham/exa

Examples:
  nb peek 3
  nb peek example.bookmark.md
  nb 3 peek
  nb example:peek 12
  nb peek example:12
  nb example:12 peek
  nb p 3
  nb 3 p
  nb p example:12
  nb example:12 p

See also:
  nb help bookmark
  nb help show

Alias: `preview`
Shortcut Alias: `p`
```

#### `pin`

```text
Usage:
  nb pin [<notebook>:](<id> | <filename> | <path> | <title>)

Description:
  Pin an item so it appears first in lists.

Examples:
  nb pin 123
  nb pin example:sample/321
```

#### `plugins`

```text
Usage:
  nb plugins [<name>] [--paths] [--force]
  nb plugins install [<path> | <url>] [--force]
  nb plugins uninstall <name>

Options:
  --paths  Print the full path to each plugin.

Subcommands:
  (default)  List plugins.
  install    Install a plugin from a <path> or <url>.
  uninstall  Uninstall the specified plugin.

Description:
  Manage plugins and themes.

Plugin Extensions:
  .nb-theme   Plugins defining color themes.
  .nb-plugin  Plugins defining new subcommands and functionality.
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
  nb remote remove
```

#### `run`

```text
Usage:
  nb run <command> [<arguments>...]

Description:
  Run shell commands within the current notebook directory.

Examples:
  nb run ls -la
  nb run find . -name 'example*'
  nb run rg example
```

#### `search`

```text
Usage:
  nb search <query>... [-a | --all] [--and <query>] [--or <query>]
            [-l | --list]  [--path] [-t <type> | --type <type> | --<type>]
            [--utility <name>]

Options:
  -a, --all                     Search all unarchived notebooks.
  --and <query>                 Add a AND query.
  -l, --list                    Print the id, filename, and title listing for
                                each matching file, without the excerpt.
  --or <query>                  Add an OR query.
  --path                        Print the full path for each matching file.
  -t, --type <type>, --<type>   Search items of <type>. <type> can be a file
                                extension or one of the following types:
                                note, bookmark, document, archive, image,
                                video, audio, folder, text
  --utility <name>              The name of the search utility to search with.

Description:
  Perform a full text search.

  Multiple query arguments are treated as AND queries, returning items that
  match all queries. AND queries can also be specified with the --and <query>
  option. The --or <query> option can be used to specify an OR query,
  returning items that match at least one of the queries.

  `nb search` is powered by Git's built-in `git grep` tool. `nb` also
  supports performing searches with alternative search tools using the
  --utility <name> option.

  Supported alternative search tools:
    1. `rga`   https://github.com/phiresky/ripgrep-all
    2. `rg`    https://github.com/BurntSushi/ripgrep
    3. `ag`    https://github.com/ggreer/the_silver_searcher
    4. `ack`   https://beyondgrep.com/
    5. `grep`  https://en.wikipedia.org/wiki/Grep

Examples:
  # search current notebook for "example query"
  nb search "example query"

  # search the notebook "example" for "example query"
  nb search example: "example query"

  # search all notebooks for "example query" and list matching items
  nb search "example query" --all --list

  # search for items matching "Example" AND "Demo"
  nb search "Example" "Demo"
  nb search "Example" --and "Demo"

  # search for items matching "Example" OR "Sample"
  nb search "Example|Sample"
  nb search "Example" --or "Sample"

  # search with a regular expression
  nb search "\d\d\d-\d\d\d\d"

  # search the current notebook for "example query"
  nb q "example query"

  # search all notebooks for "example query" and list matching items
  nb q -la "example query"

Shortcut Alias: `q`
```

#### `settings`

```text
Usage:
  nb set [<name> [<value>] | <number> [<value>]]
  nb settings colors [<number> | themes]
  nb settings edit
  nb settings get   (<name> | <number>)
  nb settings list  [--long]
  nb settings set   (<name> | <number>) <value>
  nb settings show  (<name> | <number>)
  nb settings unset (<name> | <number>)

Subcommands:
  (default)  Open the settings prompt, to <name> or <number>, if present.
             When <value> is also present, assign <value> to the setting.
  colors     Print a table of available colors and their xterm color numbers.
             When <number> is provided, print the number in its color.
             `settings colors themes` prints a list of installed themes.
  edit       Open the `nb` configuration file in `$EDITOR`.
  get        Print the value of a setting.
  list       List information about available settings.
  set        Assign <value> to a setting.
  show       Print the help information and current value of a setting.
  unset      Unset a setting, returning it to the default value.

Description:
  Configure `nb`. Use `nb settings set` to customize a setting and
  `nb settings unset` to restore the default for a setting.

  Use the `nb set` alias to quickly assign values to settings:

    nb set color_theme blacklight
    nb set limit 40

Examples:
  nb settings
  nb set 5 "org"
  nb set color_primary 105
  nb set unset color_primary
  nb set color_secondary unset
  nb settings colors
  nb settings colors 105
  nb set limit 15

Alias: `set`
```

##### `auto_sync`

```text
[1]  auto_sync
     ---------
     By default, operations that trigger a git commit like `add`, `edit`,
     and `delete` will sync notebook changes to the remote repository, if
     one is set. To disable this behavior, set this to "0".

     • Default Value: 1
```

##### `color_primary`

```text
[2]  color_primary
     -------------
     The primary color used to highlight identifiers and messages. Often this
     can be set to an xterm color number between 0 and 255. Some terminals
     support many more colors.

     • Default Value: 68 (blue) for 256 color terminals,
                      4  (blue) for  8  color terminals.
```

##### `color_secondary`

```text
[3]  color_secondary
     ---------------
     The color used for lines and footer elements. Often this can be set to an
     xterm color number between 0 and 255. Some terminals support many more
     colors.

     • Default Value: 8
```

##### `color_theme`

```text
[4]  color_theme
     -----------
     The color theme.

     To view screenshots of the built-in themes, visit:

         https://git.io/nb-docs-color-themes

     `nb` supports custom, user-defined themes. To learn more, run:

         nb help --colors

     To change the syntax highlighting theme, use:

         nb set syntax_theme

     • Available themes:

         blacklight
         console
         desert
         electro
         forest
         nb
         ocean
         raspberry
         smoke
         unicorn
         utility

     • Default Value: nb
```

##### `default_extension`

```text
[5]  default_extension
     -----------------
     The default extension to use for note files. Change to "org" for
     Org files, "rst" for reStructuredText, "txt" for plain text, or
     whatever you prefer.

     • Default Value: md
```

##### `editor`

```text
[6]  editor
     ------
     The command line text editor used by `nb`.

     • Example Values:

         atom
         code
         emacs
         macdown
         mate
         micro
         nano
         pico
         subl
         vi
         vim
```

##### `encryption_tool`

```text
[7]  encryption_tool
     ---------------
     The tool used for encrypting notes.

     • Supported Values: openssl, gpg
     • Default Value:    openssl
```

##### `footer`

```text
[8]  footer
     ------
     By default, `nb` and `nb ls` include a footer with example commands.
     To hide this footer, set this to "0".

     • Default Value: 1
```

##### `header`

```text
[9]  header
     ------
     By default, `nb` and `nb ls` include a header listing available notebooks.
     Set the alignment, or hide the header with "0".

     • Supported Values:

         0  Hide Header
         1  Dynamic Alignment
              - Left justified when list is shorter than terminal width.
              - Center aligned when list is longer than terminal width.
         2  Center Aligned (default)
         3  Left Justified

     • Default Value: 1
```

##### `limit`

```text
[10] limit
     -----
     The maximum number of notes included in the `nb` and `nb ls` lists.

     • Default Value: 20
```

##### `nb_dir`

```text
[11] nb_dir
     ------
     The location of the directory that contains the notebooks.

     For example, to sync all notebooks with Dropbox, create a folder at
     `~/Dropbox/Notes` and run: `nb settings set nb_dir ~/Dropbox/Notes`

     • Default Value: ~/.nb
```

##### `syntax_theme`

```text
[12] syntax_theme
     ------------
     The syntax highlighting theme. View examples with:

         bat --list-themes

     • Available themes:

         1337
         DarkNeon
         Dracula
         GitHub
         Monokai Extended
         Monokai Extended Bright
         Monokai Extended Light
         Monokai Extended Origin
         Nord
         OneHalfDark
         OneHalfLight
         Solarized (dark)
         Solarized (light)
         Sublime Snazzy
         TwoDark
         ansi-dark
         ansi-light
         base16
         base16-256
         gruvbox
         gruvbox-light
         gruvbox-white
         zenburn

     • Default Value: base16
```

#### `shell`

```text
Usage:
  nb shell [<subcommand> [<options>...] | --clear-history]

Optons:
  --clear-history  Clear the `nb` shell history.

Description:
  Start the `nb` interactive shell. Type "exit" to exit.

  `nb shell` recognizes all `nb` subcommands and options, providing
  a streamlined, distraction-free approach for working with `nb`.

  When <subcommand> is present, the command will run as the shell is opened.

Example:
  $ nb shell
  nb> ls 3
  [3] Example

  nb> edit 3 --content "New content."
  Updated: [3] Example

  nb> notebook
  home

  nb> exit
  $
```

#### `show`

```text
Usage:
  nb show [<notebook>:](<id> | <filename> | <path> | <title>)
          [[-a | --added] | [-b | --browse] | --filename | --id | --info-line |
          --path | [-p | --print] [-r | --render] | --title | --type [<type>] |
          [-u | --updated]] [--no-color]
  nb show <notebook>

Options:
  -a, --added      Print the date and time when the item was added.
  -b, --browse     Open the item with `nb browse`.
  --filename       Print the filename of the item.
  --id             Print the id number of the item.
  --info-line      Print the id, filename, and title of the item.
  --no-color       Show without syntax highlighting.
  --path           Print the full path of the item.
  -p, --print      Print to standard output / terminal.
  -r, --render     Use `pandoc` [1] to render the file to HTML and display
                   in the terminal web browser. If either `pandoc` or a
                   browser are unavailable, `-r` / `--render` is ignored.
  --title          Print the title of the note.
  --type [<type>]  Print the file extension or, when <type> is specified,
                   return true if the item matches <type>. <type> can be a
                   file extension or one of the following types:
                   archive, audio, bookmark, document, folder, image,
                   text, video
  -u, --updated    Print the date and time of the last recorded change.

Description:
  Show an item or notebook. Notes in text file formats can be rendered or
  printed to standard output. Non-text files will be opened in your system's
  preferred app or program for that file type.

  By default, the item will be opened using `less` or the program configured
  in the `$PAGER` environment variable. Use the following keys to navigate
  in `less` (see `man less` for more information):

    Key               Function
    ---               --------
    mouse scroll      Scroll up or down
    arrow up or down  Scroll one line up or down
    f                 Jump forward one window
    b                 Jump back one window
    d                 Jump down one half window
    u                 Jump up one half window
    /<query>          Search for <query>
    n                 Jump to next <query> match
    q                 Quit

  To skip the pager and print to standard output, use the `-p` / `--print`
  option.

  `-r` / `--render` automatically uses either `w3m` [2], `links` [3],
  or `lynx` [4]. To specify a preferred browser, set the `$BROWSER`
  environment variable in your .bashrc, .zshrc, or equivalent, e.g.,
  `export BROWSER="links"`.

  If `bat` [5], `highlight` [6], or Pygments [7] is installed, notes are
  printed with syntax highlighting.

    1. https://pandoc.org/
    2. https://en.wikipedia.org/wiki/W3m
    3. https://en.wikipedia.org/wiki/Links_(web_browser)
    4. https://en.wikipedia.org/wiki/Lynx_(web_browser)
    5. https://github.com/sharkdp/bat
    6. http://www.andre-simon.de/doku/highlight/en/highlight.php
    7. https://pygments.org/

Examples:
  nb show 1
  nb show example.md --render
  nb show "A Document Title" --print --no-color
  nb 1 show
  nb example:show 12
  nb show example:12
  nb example:12 show
  nb s 1
  nb 1 s
  nb s example:12
  nb example:12 s

Alias: `view`
Shortcut Alias: `s`
```

#### `status`

```text
Usage:
  nb status

Description:
  Run `git status` the current notebook.
```

#### `subcommands`

```text
Usage:
  nb subcommands [add <name>...] [alias <name> <alias>]
                 [describe <name> <usage>]

Subcommands:
  add       Add a new subcommand.
  alias     Create an <alias> of a given subcommand <name>, with linked help.
            Note that aliases must also be added with `subcommands add`.
  describe  Set the usage text displayed with `nb help <subcommand>`.
            This can be assigned as a heredoc, which is recommended, or
            as a string argument.

Description:
  List, add, alias, and describe subcommands. New subcommands, aliases, and
  descriptions are not persisted, so `add`, `alias`, `describe` are
  primarily for plugins.
```

#### `sync`

```text
Usage:
  nb sync [-a | --all]

Options:
  -a, --all   Sync all unarchived notebooks.

Description:
  Sync the current local notebook with the remote repository.

Private Repositories and Git Credentials:
  Syncing with private repositories requires configuring git to not prompt
  for credentials.

  For repositories cloned over HTTPS, credentials can be cached with git.
  For repositories cloned over SSH, keys can be added to the ssh-agent.

  More Information:
    https://github.com/xwmx/nb#private-repositories-and-git-credentials

Sync Conflict Resolution:
  When `nb sync` encounters a conflict in a text file and can't merge
  overlapping local and remote changes, both versions are saved in the
  file, separated by git conflict markers. Use `nb edit` to remove the
  conflict markers and delete any unwanted text.

  When `nb sync` encounters a conflict in a binary file, such as an
  encrypted note or bookmark, both versions of the file are saved in the
  notebook as individual files, one with `--conflicted-copy` appended to
  the filename.

  More Information:
    https://github.com/xwmx/nb#sync-conflict-resolution
```
#### `unpin`

```text
Usage:
  nb unpin [<notebook>:](<id> | <filename> | <path> | <title>)

Description:
  Unpin a pinned item.

Examples:
  nb unpin 123
  nb unpin example:sample/321
```

#### `update`

```text
Usage:
  nb update

Description:
  Update `nb` to the latest version. You will be prompted for
  your password if administrator privileges are required.

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

Example:
  nb use example

Shortcut Alias: `u`
```

#### `version`

```text
Usage:
  nb version

Description:
  Display version information.
```

### Plugins

<p align="center">
  <a href="#backlink">backlink</a> •
  <a href="#copy">copy</a> •
  <a href="#ebook">ebook</a> •
  <a href="#example">example</a>
</p>

#### `backlink`

```text
Usage:
  nb backlink [--force]

Description:
  Add backlinks to notes. Crawl notes in a notebook for [[wiki-style links]]
  and append a "Backlinks" section to each linked file that lists passages
  referencing the note.

  To link to a note from within another note, surround the title of the
  target note in double square brackets:

      Example with link to [[Target Note Title]] in content.

  Depends on note-link-janitor:
    https://github.com/andymatuschak/note-link-janitor

    Requirement: every note in the notebook must have a title.
```

#### `copy`

```text
Usage:
  nb copy (<id> | <filename> | <path> | <title>)

Description:
  Create a copy of the specified item in the current notebook.

Alias: `duplicate`
```

#### `ebook`

```text
Usage:
  nb ebook new <name>
  nb ebook publish

Subcommands:
  ebook new      Create a new notebook initialized with placeholder files for
                 authoring an ebook.
  ebook publish  Generate a .epub file using the current notebook contents.

Description:
  Ebook authoring with `nb`.

  `nb ebook new` creates a notebook populated with initial placeholder files
  for creating an ebook. Edit the title page and chapters using normal `nb`
  commands, then use `nb ebook publish` to generate an epub file.

  Chapters are expected to be markdown files with sequential numeric
  filename prefixes for ordering:

    01-example.md
    02-sample.md
    03-demo.md

  Create new chapters with `nb add`:

    nb add --filename "04-chapter4.md"

  title.txt contains the book metadata in a YAML block. For more information
  about the fields for this file, visit:

    https://pandoc.org/MANUAL.html#epub-metadata

  stylesheet.css contains base styling for the generated ebook. It can be used
  as it is and can also be edited using `nb edit`.

  As with all `nb` notebooks, changes are recorded automatically in git,
  providing automatic version control for all ebook content, source, and
  metadata files.

  Generated epub files are saved in the notebook and can be previewed in the
  terminal with `nb show`. Export a generated epub file with `nb export`:

    nb export 12 .

More info:
  https://pandoc.org/epub.html
```

#### `example`

```text
Usage:
  nb example

Description:
  Print "Hello, World!"
```

## Specifications

### `nb` Markdown Bookmark File Format

#### Extension

`.bookmark.md`

#### Description

`nb` bookmarks are Markdown documents created using a combination of
user input and data from the bookmarked page. The `nb` bookmark format
is intended to be readable, editable, and clearly organized for
greatest accessibility.

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimally valid bookmark file with `nb add`:

```bash
nb add example.bookmark.md --content "<https://example.com>"
```

This creates a file with the name `example.bookmark.md` containing:

```markdown
<https://example.com>
```

In a full bookmark, information is separated into sections,
with each bookmark section indicated by a Markdown `h2` heading.

#### Example

````markdown
# Example Title (example.com)

<https://example.com>

## Description

Example description.

## Quote

> Example quote line one.
>
> Example quote line two.

## Comment

Example comment.

## Related

- <https://example.net>
- <https://example.org>

## Tags

#tag1 #tag2

## Content

Example Title
=============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)

## Source

```html
<!doctype html>
<html>
  <head>
    <title>Example Title</title>
    <meta name="description" content="Example description." />
  </head>

  <body>
    <h1>Example Title</h1>
    <p>
      This domain is for use in illustrative examples in documents. You may
      use this domain in literature without prior coordination or asking for
      permission.
    </p>
    <p>
      <a href="https://www.iana.org/domains/example">More information...</a>
    </p>
  </body>
</html>
```
````

#### Elements

##### Title

`Optional`

A markdown `h1` heading containing the content of the bookmarked page's
HTML `<title>` or [`og:title`](https://ogp.me/) tag, if present, followed by
the domain within parentheses.

###### Examples

```markdown
# Example Title (example.com)
```
```markdown
# (example.com)
```

##### URL

`Required`

The URL of the bookmarked resource, with surrounding angle brackets
(`<`, `>`).

This is the only required element.

##### `## Description`

`Optional`

A text element containing the content of the bookmarked page's meta description
or [`og:description`](https://ogp.me/) tag, if present.

##### `## Quote`

`Optional`

A markdown quote block containing a user-specified excerpt from the bookmarked
resource.

##### `## Comment`

`Optional`

A text element containing a comment written by the user.

##### `## Related`

`Optional`

A Markdown list of angle bracketed (`<`, `>`) URLs that are related to the
bookmarked resource.

##### `## Tags`

`Optional`

A list of tags represented as `#hashtags` separated by individual spaces.

##### `## Content`

`Optional`

The full content of the bookmarked page, converted to Markdown.

The `## Content` section makes the page content available locally for
full-text search and viewing of page content. The source HTML is converted
to inline Markdown to reduce the amount of markup, make it more readable,
and make page conent easily viewable in the terminal as markdown and
streamlined HTML in terminal web browsers.

##### `## Source`

`Optional`

A fenced code block with `html` language identifier containing the source HTML
from the bookmarked page.

`nb` does not save the page source by default. `nb` uses this section to save
the source HTML page content when `pandoc` is not available to convert it to
Markdown.

### `nb` Notebook Specification

An `nb` notebook is a directory that contains a valid `.git` directory,
indicating that it has been initialized as a git repository, and a `.index`
file in the root directory.

#### `.index` Files

A notebook folder index is a text file named `.index` in any folder
within the notebook directory. `.index` contains a list of visible
filenames within the folder, one per line, and the line number of each
filename represents the id. `.index` files are included in the git repository
so ids are preserved across systems.

##### Operations

<dl>
  <dt><code>add</code></dt>
  <dd>Append a new line containing the filename to <code>.index</code>.</dd>
  <dt><code>update</code></dt>
  <dd>Overwrite the existing filename in <code>.index</code> with the new filename.</dd>
  <dt><code>delete</code></dt>
  <dd>Delete the filename, preserving the newline, leaving the line blank.</dd>
  <dt><code>reconcile</code></dt>
  <dd>Remove duplicate lines, preserving existing blank lines, <code>add</code> entries for new files, and <code>delete</code> entries for deleted files.</dd>
  <dt><code>rebuild</code></dt>
  <dd>Delete and rebuild <code>.index</code>, listing files by most recently modified, reversed.</dd>
</dl>

##### `index` Subcommand

`nb` manages the `.index` of each folder within a notebook using an internal
`index` subcommand.

###### `nb help index`

```text
Usage:
  nb index add <filename>
  nb index delete <filename>
  nb index get_basename <id>
  nb index get_id <filename>
  nb index get_max_id
  nb index rebuild [--ancestors]
  nb index reconcile [--ancestors]
  nb index show
  nb index update <existing-filename> <new-filename>
  nb index verify
  nb index <subcommand> <options>... [<folder-path>]

Options:
  --ancestors   Perform the action on all folders within the notebook that
                are ancestors of the current folder.

Subcommands:
  add           Add <filename> to the index.
  delete        Delete <filename> from the index.
  get_basename  Print the filename / basename at the specified <id>.
  get_id        Get the id for <filename>.
  get_max_id    Get the maximum id for the folder.
  rebuild       Rebuild the index, listing files by last modified, reversed.
                Some ids will change. Prefer `nb index reconcile`.
  reconcile     Remove duplicates and update index for added and deleted files.
  show          Print the index.
  update        Overwrite the <existing-filename> entry with <new-filename>.
  verify        Verify that the index matches the folder contents.

Description:
  Manage the index for the current folder or the folder at <folder-path>,
  which can be passed as the final argument to any `index` subcommand.

  `index` is used internally by `nb` and using it manually will
  probably corrupt the index. If something goes wrong with an index,
  fix it with `nb index reconcile`.

  An index is a text file named '.index' in any folder within a notebook.
  .index contains a list of filenames and the line number of each filename
  represents the id. .index files are included in the git repository so
  ids are preserved across systems.
```

#### `.pindex` Files

Any folder may contain an optional plain text file named `.pindex`
containing a list of basenames from that folder, one per line, that should
be treated as "pinned", meaning they appear first in some list operations
like `nb` and `nb ls`. Entires are added to a `.pindex` file with
[`nb pin`](#pin) and removed with [`nb unpin`](#unpin).

#### Archived Notebooks

A notebook is considered archived when it contains a file named `.archived`
at the root level of the notebook directory.

## Tests

With more than 1,400 tests spanning over 30,000 lines, `nb` is really
mostly a [test suite](https://github.com/xwmx/nb/tree/master/test).
[Tests run continuously via GitHub Actions](https://github.com/xwmx/nb/actions)
on recent versions of both Ubuntu and macOS to account for differences between
BSD and GNU tools and Bash versions.
To run the tests locally, install
[Bats](https://github.com/bats-core/bats-core)
and the [recommended dependencies](#optional),
then run `bats test` within the project root directory.

---
<p align="center">
  Copyright (c) 2015-present <a href="https://www.williammelody.com/">William Melody</a> • See LICENSE for details.
</p>

<p align="center">
  <a href="https://github.com/xwmx/nb">github.com/xwmx/nb</a>
</p>

<p align="center">
  📝🔖🔒🔍📔
</p>
