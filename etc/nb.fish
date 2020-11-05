#!/usr/bin/env fish
###############################################################################
# __          _
# \ \   _ __ | |__
#  \ \ | '_ \| '_ \
#  / / | | | | |_) |
# /_/  |_| |_|_.__/
#
# `nb` · `notes` && `bookmark`
#
# Command line note-taking, bookmarking, and archiving with encryption, search,
# Git-backed versioning and syncing, Pandoc-backed format conversion, and more
# in a single portable script.
#
# https://github.com/xwmx/nb
###############################################################################

function _nb_subcommands
  # _cache_completions()
  #
  # Usage:
  #   _cache_completions [-e/--erase file] <path>
  #
  # Description:
  #   Cache completions for `nb`. Generating completions can be slow and
  #   native shell caching doesn't appear to help.
  #
  #   This function will be written into a temporary file and executed.
  #   You can remove the file after executing itself by the -e/--erase option.
  function _cache_completions
    argparse -n _cache_completions -N 1 "e/erase=" -- $argv
      or return 1
    set _cache_path $argv[1]

    set _commands (nb subcommands)
    set _notebooks (nb notebooks --names --no-color --unarchived)

    if test -e $_cache_path
      set __lines (head -n2 $_cache_path)
      set _commands_cached $__lines[1]
      set _notebooks_cached $__lines[2]
    end

    if test "$_commands_cached" != (string join " " $_commands)
      or test "$_notebooks_cached" != (string join " " $_notebooks)

      for __command in $_commands
        if eval set -q __desc_$__command
          set -a _completions $__command\t$___desc
          continue
        end

        set ___help (nb help $__command | string join \t)

        # Read the description up to 40 chars.
        set ___desc (string match -r 'Description:\t  (.*?)\.' $___help)[2]
        if test -z $___desc
          set -a _completions $__command
          continue
        end
        set ___desc (string replace -a \t '' $___desc | string sub -l 40)
        if test (string length $___desc) = 40
          set ___desc (string sub -l 38 $___desc)……
        end

        set -a _completions $__command\t$___desc
        eval set __desc_$__command \$___desc

        # When __command is an alias for another command, also set the
        # description for that.
        set ___original_name (string match -r 'Usage:\s+nb\s+(\S+)' $___help)[2]
        if test -n $___original_name
          and test "$___original_name" != $__command
          and not set -q __desc_$___original_name
          eval set __desc_$___original_name \$___desc
        end

        # When __command has aliases, also set the description for them.
        set ___aliases (string match -r 'Aliases: `([^\t]*)`' $___help)[2]
        if test -n $___aliases
          set ___aliases (string split '`, `' $___aliases)
          for ___alias in $___aliases
            if not eval set -q __desc_$___alias
              eval set __desc_$___alias \$___desc
            end
          end
        end
      end

      # Construct <nootbook>:<subcommand> completions.
      for __notebook in $_notebooks
        for __command in $_commands
          if test -n $__notebook
            and test -n $__command
            if eval set -q __desc_$__command
              eval set -a _completions \$__notebook:\$__command\\t\$__desc_$__command
            else
              set -a _completions $__notebook:$__command
            end
          end
        end
      end

      set _directory_path (dirname $_cache_path)
      mkdir -p $_directory_path

      begin
        echo $_commands
        echo $_notebooks
        printf "%s\n" $_completions
      end > $_cache_path
    end

    if set -q _flag_erase
      rm $_flag_erase
    end
  end

  set _nb_dir (nb env | grep "NB_DIR" | cut -d = -f 2)

  if test -z $_nb_dir
    or not test -e $_nb_dir
    return
  else if test -L $_nb_dir
    set _nb_dir (realpath $_nb_dir)
  end

  if not test -d $_nb_dir
    return
  end

  set _cache_path $_nb_dir/.cache/nb-completion-cache-fish

  if not test -e $_cache_path
    _cache_completions $_cache_path
  end

  # list all notes to complete
  nb run ls | sed -e 's/$/'\t'file/'

  if test -e $_cache_path
    tail -n+3 $_cache_path

    # write the func itself into a temporary file and execute it in background
    set _tmp_file (mktemp -t nb-completion)
    begin
      functions _cache_completions
      echo "_cache_completions -e $_tmp_file $_cache_path"
    end > $_tmp_file
    fish $_tmp_file &
  end
end

complete -c nb -fa "(_nb_subcommands)"
