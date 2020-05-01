#!/usr/bin/env bats

load test_helper

_setup_rename() {
  run "${_NOTES}" init
  run "${_NOTES}" add "initial example name.md"
}

# no argument #################################################################

@test "\`rename\` with no arguments exits with 1, does nothing, and prints help." {
  _setup_rename
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not rename note file
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Rename') ]]

  # Prints help
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ "  notes rename" ]]
}

# <filename> ##################################################################

@test "\`rename\` with <filename> argument renames without errors." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.org" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.org')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ example\ name.md\'\ renamed\ to\ \'EXAMPLE.org\' ]]
}

@test "\`rename\` with extension-less <filename> argument uses source extension." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ example\ name.md\'\ renamed\ to\ \'EXAMPLE.md\' ]]
}

@test "\`rename\` bookmark with extension-less <filename> argument uses source extension." {
  {
    "${_NOTES}" init
    _filename="initial sample name.bookmark.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.bookmark.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.bookmark.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ sample\ name.bookmark.md\' ]]
  [[ "${output}" =~ renamed\ to\ \'EXAMPLE.bookmark.md\'   ]]
}

@test "\`rename\` bookmark with extension <filename> argument uses target extension." {
  {
    "${_NOTES}" init
    _filename="initial sample name.bookmark.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.md" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ sample\ name.bookmark.md\' ]]
  [[ "${output}" =~ renamed\ to\ \'EXAMPLE.md\'   ]]
}

@test "\`rename\` notes with bookmark extension <filename> argument uses target extension." {
  {
    "${_NOTES}" init
    _filename="initial sample name.md"
    "${_NOTES}" add "${_filename}"
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.bookmark.md" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.bookmark.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.bookmark.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ sample\ name.md\' ]]
  [[ "${output}" =~ renamed\ to\ \'EXAMPLE.bookmark.md\'   ]]
}

@test "\`rename\` with existing <filename> exits with status 1." {
  {
    _setup_rename
    run "${_NOTES}" add "EXAMPLE.org"
    _filename=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'File already exists' ]]
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
}

# <id> ########################################################################

@test "\`rename <id>\` with extension-less <filename> argument uses source extension." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename 1 "EXAMPLE" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'initial\ example\ name.md\'\ renamed\ to\ \'EXAMPLE.md\' ]]
}

# <filename> --reset ##########################################################

@test "\`rename --reset\` with <filename> argument renames without errors." {
  {
    _setup_rename
    _original=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    _filename="test.md"
    "${_NOTES}" rename "${_original}" "${_filename}" --force
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" --reset --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${_files[0]}" =~ [A-Za-z0-9]+.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'test.md\'\ renamed\ to\ \'[A-Za-z0-9]+.md\' ]]
}

# <filename> --to- ############################################################

@test "\`rename --to-bookmark\` with note renames without errors." {
  {
    "${_NOTES}" init
    _filename="example.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  echo "\${_filename:-}: ${_filename:-}"

  run "${_NOTES}" rename "${_filename}" --to-bookmark --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${_files[0]}" =~ example.bookmark.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'example.md\'\ renamed\ to\ \'example.bookmark.md\' ]]
}

@test "\`rename 1 sample --to-bookmark\` with note renames without errors." {
  {
    "${_NOTES}" init
    _filename="example.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "sample" --to-bookmark --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${_files[0]}" =~ sample.bookmark.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'example.md\'\ renamed\ to\ \'sample.bookmark.md\' ]]
}

@test "\`rename 1 sample.demo --to-bookmark\` discards extension and renames." {
  {
    "${_NOTES}" init
    _filename="example.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "sample.demo" --to-bookmark --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${_files[0]}" =~ sample.bookmark.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'example.md\'\ renamed\ to\ \'sample.bookmark.md\' ]]
}

@test "\`rename --to-note\` with bookmark renames without errors." {
  {
    "${_NOTES}" init
    _filename="example.bookmark.md"
    "${_NOTES}" add "${_filename}" --content "<https://example.com>"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" --to-note --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${_files[0]}" =~ example.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ \'example.bookmark.md\'\ renamed\ to\ \'example.md\' ]]
}

# help ########################################################################

@test "\`help rename\` exits with status 0." {
  run "${_NOTES}" help rename
  [[ ${status} -eq 0 ]]
}

@test "\`help rename\` prints help information." {
  run "${_NOTES}" help rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ \notes\ rename ]]
}
