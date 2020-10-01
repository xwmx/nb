#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`delete\` with no argument exits with 1, prints help, and does not delete." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1                      ]]

  # Does not delete note file
  [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Delete'

  # Prints help information
  [[ "${lines[0]}" =~ Usage\:             ]]
  [[ "${lines[1]}" =~ \ \ nb\ delete      ]]
}

# <selector> ##################################################################

@test "\`delete <selector>\` with empty repo exits with 1 and prints message." {
  {
    run "${_NB}" init
  }

  run "${_NB}" delete 1 --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
  [[ "${lines[0]}" =~ 1             ]]
}

@test "\`delete <selector> (no force)\` returns 0 and deletes note." {
  skip "Determine how to test interactive prompt."
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  }

  run "${_NB}" delete "${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                        ]]
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
}

# <scope>:<selector> ##########################################################

@test "\`delete <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: '${_filename:-}'"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list --no-id --filenames

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" delete one:"${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ Deleted:            ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<scope>:delete <selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: '${_filename:-}'"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list --no-id --filenames

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" one:delete "${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ Deleted:            ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<scope>:<selector> delete\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: '${_filename:-}'"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list --no-id --filenames

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" one:"${_filename}" delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ Deleted:            ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<selector> <scope>:delete\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: '${_filename:-}'"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list --no-id --filenames

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "${_filename}" one:delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ Deleted:            ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

# <filename> ##################################################################

@test "\`delete\` with <filename> argument deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  }

  run "${_NB}" delete "${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <id> ########################################################################

@test "\`delete <id>\` deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  }

  run "${_NB}" delete 1 --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "\`<id> delete\` with deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}"  ]]
  }

  run "${_NB}" 1 delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`delete\` with <path> argument deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" delete "${_NOTEBOOK_PATH}/${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <title> #####################################################################

@test "\`delete\` with <title> argument deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"
    _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}"   ]]
  }

  run "${_NB}" delete "${_title}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <folder> #################################################################

@test "\`delete\` with <folder> argument deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/Example Folder"

    IFS= _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" delete "${_filename}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                        ]]

  # Deletes note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}"  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
  [[ "${_original_index}" != "$(cat "${_NOTEBOOK_PATH}/.index")"        ]]

  # Prints output
  [[ "${output}" =~ Deleted:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ Example\ Folder ]]
}

# help ########################################################################

@test "\`help delete\` exits with status 0." {
  run "${_NB}" help delete

  [[ ${status} -eq 0 ]]
}

@test "\`help delete\` prints help information." {
  run "${_NB}" help delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:"    ]]
  [[ "${lines[1]}" =~ nb\ delete  ]]
}
