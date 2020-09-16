#!/usr/bin/env bash
###############################################################################
# copy / duplicate
#
# A plugin for `nb`.
#
# https://github.com/xwmx/nb
###############################################################################

# Add commands to the $_SUBCOMMANDS array to make them available to `nb`.
_SUBCOMMANDS+=(
  copy
  duplicate
)

# Add commands to the $_DOCUMENTED_SUBCOMMANDS array to include them in
# tab completions.
_DOCUMENTED_SUBCOMMANDS+=(
  copy
  duplicate
)

# Add commands to the $_GIT_SUBCOMMANDS array to ensure that git cleanup is
# performed before they run.
_GIT_SUBCOMMANDS+=(
  copy
  duplicate
)

desc "copy" <<HEREDOC
Usage:
  ${_ME} copy (<id> | <filename> | <path> | <title>)

Description:
  Create a copy of the specified item in the current notebook.
HEREDOC
_copy() {
  local _selection="${1:-}"

  if [[ -z "${_selection:-}" ]]
  then
    _exit_1 _help "copy"
  fi

  # Get the basename from the selection.
  local _source_basename
  _source_basename="$(_get_selection_basename "${_selection}")"

  # Set the current notebooks based on selection.
  _set_selection_notebook "${_source_basename}"

  # Get a unique basename based on the source basename.
  local _target_basename
  _target_basename="$(_get_unique_basename "${_source_basename}")"

  # Print the source contents and pipe to `_add()`.
  _show "${_source_basename}" --no-color --print | _add "${_target_basename}"
}
_alias_subcommand "copy" "duplicate"
