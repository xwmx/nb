#!/usr/bin/env bats

load test_helper

_setup_move() {
  run "${_NOTES}" init
  run "${_NOTES}" add
  run "${_NOTES}" notebooks add "destination"
}

# no argument #################################################################

@test "\`move\` with no arguments exits with status 1." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
}

@test "\`move\` with no arguments does not delete note file." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`move\` with no arguments does not create git commit." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move --force

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`move\` with no argument prints help information." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes move (<index> | <filename> | <path> | <title>) [--force] <notebook>" ]]
}

# <selector> ##################################################################

@test "\`move <selector> <notebook>\` with empty repo exits with 1 and prints help." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" move 0 "destination"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes move (<index> | <filename> | <path> | <title>) [--force] <notebook>" ]]
}

@test "\`move <invalid> <notebook>\` exits with 1 and prints help." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "invalid" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes move (<index> | <filename> | <path> | <title>) [--force] <notebook>" ]]
}

@test "\`move <selector> <invalid>\` exits with 1 and prints help." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move 0 "invalid" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes move (<index> | <filename> | <path> | <title>) [--force] <notebook>" ]]
}

@test "\`move <selector> <notebook> (no force)\` returns 0 and moves note." {
  skip "Determine how to test interactive prompt."
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${_filename}" "destination"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

# <scope>:<selector> ##########################################################

@test "\`move <scope>:<selector> <notebook>\` with <filename> argument moves note." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "one"
    run "${_NOTES}" use "one"
    run "${_NOTES}" add
    _filename=$(notes list -n 1 --no-index | head -1)
    echo "\${_filename:-}: ${_filename:-}"
    run "${_NOTES}" use "home"
  }
  [[ -n "${_filename}" ]]
  [[ -e "${NOTES_DIR}/one/${_filename}" ]]

  run "${_NOTES}" move one:"${_filename}" "home" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \'home\':\'[A-Za-z0-9]+.md\' ]]
}

# <filename> ##################################################################

@test "\`move\` with <filename> argument exits with status 0." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`moves\` with <filename> argument moves note file." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`move\` with <filename> argument creates git commit." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${_filename}" "destination" --force

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`move\` with <filename> argument prints output." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \'destination\':\'[A-Za-z0-9]+.md\' ]]
}

# <index> #####################################################################

@test "\`move\` with <index> argument exits with status 0." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move 0 "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`move\` with <index> argument moves note file." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move 0 "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`move\` with <index> argument creates git commit." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move 0 "destination" --force

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`move\` with <index> argument prints output." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move 0 "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \'destination\':\'[A-Za-z0-9]+.md\' ]]
}

# <path> ######################################################################

@test "\`move\` with <path> argument exits with status 0." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${NOTES_DATA_DIR}/${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`move\` with <path> argument moves note file." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${NOTES_DATA_DIR}/${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`move\` with <path> argument creates git commit." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${NOTES_DATA_DIR}/${_filename}" "destination" --force

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`move\` with <path> argument prints output." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${NOTES_DATA_DIR}/${_filename}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \'destination\':\'[A-Za-z0-9]+.md\' ]]
}

# <title> #####################################################################

@test "\`move\` with <title> argument exits with status 0." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" move "${_title}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`move\` with <title> argument moves note file." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" move "${_title}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`move\` with <title> argument creates git commit." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" move "${_title}" "destination" --force

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`move\` with <title> argument prints output." {
  {
    _setup_move
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" move "${_title}" "destination" --force
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \'destination\':\'[A-Za-z0-9]+.md\' ]]
}

# help ########################################################################

@test "\`help move\` exits with status 0." {
  run "${_NOTES}" help move
  [[ ${status} -eq 0 ]]
}

@test "\`help move\` prints help information." {
  run "${_NOTES}" help move
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes move (<index> | <filename> | <path> | <title>) [--force] <notebook>" ]]
}
