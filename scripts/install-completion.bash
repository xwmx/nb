#!/usr/bin/env bash
###############################################################################
# install-completion.bash
###############################################################################

set -o nounset
set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail
IFS=$'\n\t'

_MY_DIR="$(cd "$(dirname "$0")"; pwd)"
if [[ -z "${_MY_DIR}" ]] && [[ ! -d "${_MY_DIR}" ]]
then
  exit 1
fi

_install_completion() {
  local _bash_completion_path=
  _bash_completion_path="$("${_MY_DIR}/get-bash-completion-path.bash")"

  if [[ -n "${_bash_completion_path:-}" ]] &&
     [[ -d "${_bash_completion_path}"   ]] &&
     [[ ! -e "${_bash_completion_path}/notes-completion.bash" ]]
  then
    cp \
      "${_MY_DIR}/../etc/notes-completion.bash" \
      "${_bash_completion_path}/notes-completion.bash"
  fi

  local _zsh_completion_path="/usr/local/share/zsh/site-functions"

  if [[ -d "${_zsh_completion_path}" ]] &&
     [[ ! -e "${_zsh_completion_path}/_notes" ]]
  then
    cp \
      "${_MY_DIR}/../etc/notes-completion.zsh" \
      "${_zsh_completion_path}/_notes"
  fi

} && _install_completion "$@"
