#!/usr/bin/env bats

load test_helper

_setup_search() {
  "${_NB}" init &>/dev/null
  cat <<HEREDOC | "${_NB}" add "first.md"
# one
idyl
HEREDOC
  cat <<HEREDOC | "${_NB}" add "second.md"
# two
sweetish
HEREDOC
  cat <<HEREDOC | "${_NB}" add "third.md"
# three
sweetish
HEREDOC
}

_search_all_setup() {
  _setup_search
  "${_NB}" notebooks add one
  "${_NB}" use one
  "${_NB}" add example.md --title "sweetish"
  "${_NB}" notebooks add two
  "${_NB}" use two
  "${_NB}" add example.md --title "sweetish"
  "${_NB}" notebooks archive two
  [[ -e "${NB_DIR}/two/.archived" ]]
}

# `search` ####################################################################

@test "'search' exits with status 1 and prints help information." {
  {
    _setup_search

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                        ]]
  [[ "${lines[0]}" =~ Usage\:               ]]
  [[ "${lines[1]}" =~ nb\ search\ \<query\> ]]
}
