#!/usr/bin/env bats

load test_helper

_setup_rename() {
  run "${_NB}" init
  run "${_NB}" add "initial example name.md"
}

# no argument #################################################################

@test "\`rename\` with no arguments exits with 1, does nothing, and prints help." {
  {
    _setup_rename

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename --force

  printf "\${status}: '%s'\\n" "${status}"
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
  ! git log | grep -q '\[nb\] Rename'

  # Prints help
  [[ "${lines[0]}" =~ Usage\:       ]]
  [[ "${lines[1]}" =~ "  nb rename" ]]
}

# <filename> ##################################################################

@test "\`rename\` with <filename> argument renames without errors." {
  {
    _setup_rename

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE.org" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.org"     ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.org')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.org               ]]
}

@test "\`rename\` with extension-less <filename> argument uses source extension." {
  {
    _setup_rename

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

@test "\`rename\` bookmark with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init

    _filename="initial sample name.bookmark.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"      ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.bookmark.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.bookmark.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ sample\ name.bookmark.md ]]
  [[ "${output}" =~ renamed\ to                       ]]
  [[ "${output}" =~ EXAMPLE.bookmark.md               ]]
}

@test "\`rename\` bookmark with extension <filename> argument uses target extension." {
  {
    "${_NB}" init

    _filename="initial sample name.bookmark.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ sample\ name.bookmark.md ]]
  [[ "${output}" =~ renamed\ to                       ]]
  [[ "${output}" =~ EXAMPLE.md                        ]]
}

@test "\`rename\` note with bookmark extension <filename> argument uses target extension." {
  {
    "${_NB}" init

    _filename="initial sample name.md"

    "${_NB}" add "${_filename}"

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"      ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.bookmark.md" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.bookmark.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ sample\ name.md          ]]
  [[ "${output}" =~ renamed\ to                       ]]
  [[ "${output}" =~ EXAMPLE.bookmark.md               ]]
}

@test "\`rename\` with existing <filename> exits with status 1." {
  {
    _setup_rename

    run "${_NB}" add "EXAMPLE.org"

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                      ]]
  [[ "${output}" =~ 'File already exists' ]]
  [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
}

# <id> ########################################################################

@test "\`rename <id>\` with extension-less <filename> argument uses source extension." {
  {
    _setup_rename

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename 1 "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

@test "\`<id> rename\` with extension-less <filename> argument uses source extension." {
  {
    _setup_rename

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" 1 rename "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  [[ -e "${_NOTEBOOK_PATH}/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

# <filename> --reset ##########################################################

@test "\`rename --reset\` with <filename> argument renames without errors." {
  {
    _setup_rename

    _original=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    _filename="test.md"

    "${_NB}" rename "${_original}" "${_filename}" --force

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" --reset --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ [A-Za-z0-9]+.md      ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ test.md         ]]
  [[ "${output}" =~ renamed\ to     ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <filename> --to- ############################################################

@test "\`rename --to-bookmark\` with note renames without errors." {
  {
    "${_NB}" init

    _filename="example.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ example.bookmark.md ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ example.md          ]]
  [[ "${output}" =~ renamed\ to         ]]
  [[ "${output}" =~ example.bookmark.md ]]
}

@test "\`rename 1 sample --to-bookmark\` with note renames without errors." {
  {
    "${_NB}" init

    _filename="example.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "sample" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ sample.bookmark.md ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ example.md          ]]
  [[ "${output}" =~ renamed\ to         ]]
  [[ "${output}" =~ sample.bookmark.md  ]]
}

@test "\`rename 1 sample.demo --to-bookmark\` discards extension and renames." {
  {
    "${_NB}" init

    _filename="example.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" "sample.demo" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ sample.bookmark.md ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ example.md          ]]
  [[ "${output}" =~ renamed\ to         ]]
  [[ "${output}" =~ sample.bookmark.md  ]]
}

@test "\`rename --to-note\` with bookmark renames without errors." {
  {
    "${_NB}" init

    _filename="example.bookmark.md"

    "${_NB}" add "${_filename}" --content "<https://example.com>"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" rename "${_filename}" --to-note --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ example.md ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  cat "${_NOTEBOOK_PATH}/.index"

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ example.bookmark.md ]]
  [[ "${output}" =~ renamed\ to         ]]
  [[ "${output}" =~ example.md          ]]
}

# <scope> #####################################################################

@test "\`rename <scope>:<id>\` with extension-less <filename> argument uses source extension." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "initial example name.md"

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${NB_DIR}/one/${_filename}" ]]
  }

  run "${_NB}" rename one:1 "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NB_DIR}/one/${_filename}"  ]]
  [[ -e "${NB_DIR}/one/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

@test "\`<scope>:rename <id>\` with extension-less <filename> argument uses source extension." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "initial example name.md"

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${NB_DIR}/one/${_filename}" ]]
  }

  run "${_NB}" one:rename 1 "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NB_DIR}/one/${_filename}"  ]]
  [[ -e "${NB_DIR}/one/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

@test "\`<scope>:<id> rename\` with extension-less <filename> argument uses source extension." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "initial example name.md"

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${NB_DIR}/one/${_filename}" ]]
  }

  run "${_NB}" one:1 rename "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NB_DIR}/one/${_filename}"  ]]
  [[ -e "${NB_DIR}/one/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

@test "\`<id> <scope>:rename\` with extension-less <filename> argument uses source extension." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "initial example name.md"

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -e "${NB_DIR}/one/${_filename}" ]]
  }

  run "${_NB}" 1 one:rename "EXAMPLE" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NB_DIR}/one/${_filename}"  ]]
  [[ -e "${NB_DIR}/one/EXAMPLE.md"      ]]

  # Creates git commit
  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rename'

  # Updates index
  [[ "$("${_NB}" index get_id 'EXAMPLE.md')" == '1' ]]

  # Prints output
  [[ "${output}" =~ initial\ example\ name.md ]]
  [[ "${output}" =~ renamed\ to               ]]
  [[ "${output}" =~ EXAMPLE.md                ]]
}

# help ########################################################################

@test "\`help rename\` exits with status 0." {
  run "${_NB}" help rename

  [[ ${status} -eq 0 ]]
}

@test "\`help rename\` prints help information." {
  run "${_NB}" help rename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage\:     ]]
  [[ "${lines[1]}" =~ \nb\ rename ]]
}
