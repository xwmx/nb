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
    set -l _completions $_commands

    if test -e $_cache_path
      set __lines (head -n2 $_cache_path)
      set _commands_cached $__lines[1]
      set _notebooks_cached $__lines[2]
    end

    if test "$_commands_cached" != (string join " " $_commands)
      or test "$_notebooks_cached" != (string join " " $_notebooks)
      # Construct <nootbook>:<subcommand> completions.
      for __notbook in $_notebooks
        for __command in $_commands
          if test -n $__notbook
            and test -n $__command
            set -a _completions $__notbook:$__command
          end
        end
      end

      set _directory_path (dirname $_cache_path)
      mkdir -p $_directory_path

      begin
        echo $_commands
        echo $_notebooks
        printf "%s\\n" $_completions
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

  if test -e $_cache_path
    set -la _completions_cached (cat $_cache_path)
    printf "%s\\n" $_completions_cached[3..-1]

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
