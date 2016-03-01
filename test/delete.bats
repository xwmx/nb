#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`delete\` with no argument exits with status 1." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
}

@test "\`delete\` with no argument does not delete note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`delete\` with no argument does not create git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`delete\` with no argument prints help information." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes delete <index>" ]]
}

# <selector> ##################################################################

@test "\`delete <selector>\` with empty repo exits with 1 and prints help." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" delete 0
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes delete <index>" ]]
}

# <scope>:<selector> ##########################################################

@test "\`delete <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebook add "one"
    run "${_NOTES}" use "one"
    run "${_NOTES}" add
    _filename=$(notes list -n 1 --no-index | head -1)
    echo "\${_filename:-}: ${_filename:-}"
    run "${_NOTES}" use "home"
  }
  [[ -n "${_filename}" ]]
  [[ -e "${NOTES_DIR}/one/${_filename}" ]]

  run "${_NOTES}" delete one:"${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Deleted\ one:[A-Za-z0-9]+.md ]]
}

# <filename> ##################################################################

@test "\`delete\` with <filename> argument exits with status 0." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete "${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`delete\` with <filename> argument deletes note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`delete\` with <filename> argument creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete "${_filename}"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`delete\` with <filename> argument prints output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Deleted\ home:[A-Za-z0-9]+.md ]]
}

# <index> #####################################################################

@test "\`delete\` with <index> argument exits with status 0." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete 0
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`delete\` with <index> argument deletes note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete 0
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`delete\` with <index> argument creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete 0

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`delete\` with <index> argument prints output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete 0
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Deleted\ home:[A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`delete\` with <path> argument exits with status 0." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete "${NOTES_DATA_DIR}/${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`delete\` with <path> argument deletes note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${NOTES_DATA_DIR}/${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`delete\` with <path> argument creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" delete "${NOTES_DATA_DIR}/${_filename}"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`delete\` with <path> argument prints output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${NOTES_DATA_DIR}/${_filename}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Deleted\ home:[A-Za-z0-9]+.md ]]
}

# <title> #####################################################################

@test "\`delete\` with <title> argument exits with status 0." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" delete "${_title}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`delete\` with <title> argument deletes note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" delete "${_title}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`delete\` with <title> argument creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" delete "${_title}"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]
}

@test "\`delete\` with <title> argument prints output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" delete "${_title}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${output}" =~ Deleted\ home:[A-Za-z0-9]+.md ]]
}

# help ########################################################################

@test "\`help delete\` exits with status 0." {
  run "${_NOTES}" help delete
  [[ ${status} -eq 0 ]]
}

@test "\`help delete\` prints help information." {
  run "${_NOTES}" help delete
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes delete <index>" ]]
}
