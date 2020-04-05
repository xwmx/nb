#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`edit\` with no argument exits and prints help." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _original="$(cat "${NOTES_DATA_DIR}/${_filename}")"

  run "${_NOTES}" edit
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not update note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_original}" ]]

  # Does not create git commit
  cd "${NOTES_DATA_DIR}" || return 1
  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  [[ ! $(git log | grep '\[NOTES\] Edit') ]]

  # Prints help information
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes edit (<id> | <filename> | <path> | <title>)" ]]
}

# <selector> ##################################################################

@test "\`edit <selector>\` with empty repo exits with 1 and prints message." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" edit 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Note not found." ]]
}

# <scope>:<selector> ##########################################################

@test "\`edit <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "one"
    run "${_NOTES}" one:add
    _filename=$("${_NOTES}" one:list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -n "${_filename}" ]]
  [[ -e "${NOTES_DIR}/one/${_filename}" ]]

  run "${_NOTES}" edit one:"${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${output}" =~ Updated\ \[one:[0-9]+\]\ one:[A-Za-z0-9]+.md ]]
}

# <selector> (no changes) #####################################################

@test "\`edit\` with no changes does not print outpout." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run export EDITOR="cat" && "${_NOTES}" edit "${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ -z ${output} ]]
}

# <filename> ##################################################################

@test "\`edit\` with <filename> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit "${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

# Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <id> ########################################################################

@test "\`edit\` with <id> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`edit\` with <path> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit "${NOTES_DATA_DIR}/${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]

}

# <title> #####################################################################

@test "\`edit\` with <title> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" edit "${_title}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# piped #######################################################################

@test "\`edit\` with piped content edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Example"
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run bash -c "echo '## Piped' | ${_NOTES} edit 1"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]
  [[ $(grep '# Example' "${NOTES_DATA_DIR}"/*) ]]
  [[ $(grep '## Piped' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# encrypted ###################################################################

@test "\`edit\` with encrypted file edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Content" --encrypt --password=example
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit 1 --password=example
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]

  # Updates file
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]

  # Deletes temp files.
  [[ ! "$(ls /tmp/notes*)" ]]
}

# help ########################################################################

@test "\`help edit\` exits with status 0 and prints help information." {
  run "${_NOTES}" help edit
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes edit (<id> | <filename> | <path> | <title>)" ]]
}
