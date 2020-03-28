#!/usr/bin/env bats

load test_helper

# `notes list` (empty) ########################################################

@test "\`list\` (empty) exits with 1 and lists files." {
  run "${_NOTES}" init
  run "${_NOTES}" list
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 notes.

Add a note:
  notes add
Usage information:
  notes help"
  [[ "${_expected}" == "${output}" ]]
}

# `notes list` ################################################################

@test "\`list\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    sleep 1
    "${_NOTES}" add "# two"
    sleep 1
    "${_NOTES}" add "# three"
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[0]}" =~ ${_files[2]} ]]
  [[ "${lines[1]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[1]}" =~ ${_files[1]} ]]
  [[ "${lines[2]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[2]}" =~ ${_files[0]} ]]
}

# `notes list --no-id` ########################################################

@test "\`list --no-id\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    sleep 1
    "${_NOTES}" add "# two"
    sleep 1
    "${_NOTES}" add "# three"
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --no-id
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" == "${_files[2]}" ]]
  [[ "${lines[1]}" == "${_files[1]}" ]]
  [[ "${lines[2]}" == "${_files[0]}" ]]
}

# `notes list --no-color` #####################################################

@test "\`list --no-color\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    sleep 1
    "${_NOTES}" add "# two"
    sleep 1
    "${_NOTES}" add "# three"
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'[3] ${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" == "[3] ${_files[2]}" ]]
  [[ "${lines[1]}" == "[2] ${_files[1]}" ]]
  [[ "${lines[2]}" == "[1] ${_files[0]}" ]]
}

# `notes list (-e | --excerpt)` ###############################################

_setup_list_excerpt() {
  "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# two
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# three
line two
line three
line four
HEREDOC
}

@test "\`list -e\` exits with 0 and displays 5 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list -e
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list -e 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list -e 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}

@test "\`list -e 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list -e 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list --excerpt\` exits with 0 and displays 5 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --excerpt
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list --excerpt 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --excerpt 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}

@test "\`list --excerpt 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --excerpt 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

# `notes list -n <limit>` #####################################################

_setup_list_limit() {
  "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# two
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# three
line two
line three
line four
HEREDOC
}

@test "\`list -n\` exits with 0 and displays full list." {
  {
    _setup_list_limit
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list -n
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list -n 2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list -n 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

# `notes list --titles` #######################################################

@test "\`list --titles\` exits with 0 and displays a list of titles." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
line one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list --titles
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ three$          ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ 20[0-9]+\.md$   ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ one$            ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `notes list <selection>` ####################################################

@test "\`list <selection>\` exits with 0 and displays the selection." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# two
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list 1
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[0]}" =~ [*1*] ]]
  [[ "${lines[0]}" =~ ${_files[0]} ]]
}

@test "\`list <invalid-selection>\` exits with 1 and displays a message." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" list invalid
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" =~ Not\ found:\ invalid$ ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "${_NOTES}" help list
  [[ ${status} -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "${_NOTES}" help list
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes list [(-e | --excerpt) [<length>]] [--no-id] [-n <limit>] [--titles]" ]]
}
