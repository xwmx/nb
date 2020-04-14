#!/usr/bin/env bash
###############################################################################
# uninstall.bash
###############################################################################

###############################################################################
# Strict Mode
###############################################################################

set -o nounset
set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail
IFS=$'\n\t'

_get_bash_completion_path() {
  local _bash_completion_path=

  if [[ -n "${BASH_COMPLETION_COMPAT_DIR:-}" ]]
  then
    _bash_completion_path="${BASH_COMPLETION_COMPAT_DIR}"
  fi

  if [[ -z "${_bash_completion_path:-}" ]]
  then
    _bash_completion_path="$(
      pkg-config --variable=completionsdir bash-completion 2>/dev/null || true
    )"
  fi

  if [[ -z "${_bash_completion_path:-}" ]] &&
     [[ -d "/usr/local/etc/bash_completion.d" ]]
  then
    _bash_completion_path="/usr/local/etc/bash_completion.d"
  fi

  if [[ -z "${_bash_completion_path:-}" ]] &&
     [[ -d "/etc/bash_completion.d" ]]
  then
    _bash_completion_path="/etc/bash_completion.d"
  fi

  printf "%s\\n" "${_bash_completion_path:-}"
} && _get_bash_completion_path
