# notes

```
             _
 _ __   ___ | |_ ___  ___
| '_ \ / _ \| __/ _ \/ __|
| | | | (_) | ||  __/\__ \
|_| |_|\___/ \__\___||___/
```

A simple, portable, command line note-taking and syncing tool that stores data in markdown files automatically versioned with git.

## Usage

```
Usage:
  notes add [<note>]
  notes delete (<index> | <filename>)
  notes edit (<index> | <filename>)
  notes init [<remote url>]
  notes list ([-e | --excerpt [<length>]] | [--noindex])
  notes ls
  notes log
  notes search <query> [--path]
  notes show (<index> | <filename>) ([--dump] | [--path])
  notes sync
  notes -h | --help | help
  notes --version | version

Subcommands:
  add      Add a new note.
  delete   Delete a note.
  edit     Edit a note.
  help     Display this help information.
  init     Initialize the local notes repository.
  list     List all notes. Optionally, an excerpt of each note can be printed.
  ls       List with an excerpt. This is an alias for `notes list -e`.
  log      Display git history using `tig` (if available) or `git log`.
  search   Search notes.
  show     Show a note.
  sync     Sync notes with the remote repository.
  version  Display version information.

Options:
  --dump                 Print to standard output.
  -e --excerpt <length>  Print an excerpt from each note with an optional
                         length in number of lines [default: 3].
  -h --help              Display this help information.
  --noindex              Don't print the index number for each listing.
  --path                 Print the absolute path to the note file.
  --version              Display version information.
```
