#!/usr/bin/env bash
###############################################################################
# no_browser_env.sh
#
# `BASH_ENV` script for simulating an environment without a terminal web
# browser installed. Overrides the `hash` builtin, which is what
# `_command_exists` uses to locate `w3m` and `links`, so that tests exercise
# the "no browser available" code paths even when a browser is installed.
#
# Usage:
#   BASH_ENV="${NB_TEST_BASE_PATH}/fixtures/no_browser_env.sh" \
#     run "${_NB}" helpers _web_browser --check
###############################################################################

hash() {
  if [[ "${1:-}" == "w3m" || "${1:-}" == "links" ]]
  then
    return 1
  fi

  builtin hash "${@:-}"
}

export -f hash
