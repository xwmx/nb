#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

# no argument #################################################################

@test "\`edit\` with no argument exits and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    _original="$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  }

  run "${_NB}" edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not update note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  ! git log | grep -q '\[nb\] Edit'

  # Prints help information
  [[ "${lines[0]}" =~ Usage\:       ]]
  [[ "${lines[1]}" =~ \ \ nb\ edit  ]]
}

# <selector> ##################################################################

@test "\`edit <selector>\` with empty repo exits with 1 and prints message." {
  {
    run "${_NB}" init
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
  [[ "${lines[0]}" =~ 1             ]]
}

# <scope>:<selector> ##########################################################

@test "\`edit <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one: -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                        ]]
    [[ -e "${NB_DIR}/one/${_filename}"          ]]
    [[ ! "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor  ]]
  }

  run "${_NB}" edit "one:${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor  ]]

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<scope>:edit <selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one: -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                        ]]
    [[ -e "${NB_DIR}/one/${_filename}"          ]]
    [[ ! "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor  ]]
  }

  run "${_NB}" one:edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor  ]]

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<scope>:<selector> edit\` alternative with edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "one:${_filename}" edit --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/one/${_filename}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ Example\ content\.  ]]

  # Prints output
  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "\`<selector> <scope>:edit\` alternative with edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "${_filename}" one:edit --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/one/${_filename}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ Example\ content\.  ]]

  # Prints output
  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

# <selector> (no changes) #####################################################

@test "\`edit\` with no changes does not print output." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor_no_op" &&
    run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z ${output}     ]]
}

@test "\`edit\` encrypted with no changes does not print output." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content." \
      --encrypt --password example

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor_no_op" &&
    run "${_NB}" edit "${_filename}" --password example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z ${output}     ]]
}

# <filename> ##################################################################

@test "\`edit\` with <filename> argument edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "\`edit\` with <filename> with spaces edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Note name with spaces.md"

    _filename="Note name with spaces.md"

    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:                    ]]
  [[ "${output}" =~ [0-9]+                      ]]
  [[ "${output}" =~ Note\ name\ with\ spaces.md ]]
}

# <id> ########################################################################

@test "\`edit <id>\` edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "\`<id> edit\` alternative edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example initial content."

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    [[ ! "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]
  }

  run "${_NB}" 1 edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/${_filename}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`edit\` with <path> argument edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit "${_NOTEBOOK_PATH}/${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]

}

# <title> #####################################################################

@test "\`edit\` with <title> argument edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"
  }

  run "${_NB}" edit "${_title}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# piped #######################################################################

@test "\`edit\` with piped content edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Example"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original="$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  }

  run bash -c "echo '## Piped' | ${_NB} edit 1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]
  grep -q '# Example' "${_NOTEBOOK_PATH}"/*
  grep -q '## Piped' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# --content option ############################################################

@test "\`edit\` with --content option edits without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"
  }

  run "${_NB}" edit 1 --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ Example\ content\.  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "\`edit\` with empty --content option exits with 1" {
  {
    run "${_NB}" init
    run "${_NB}" add "Example initial content."

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"
    _original="$(cat "${_NOTEBOOK_PATH}/${_filename}")"

    [[ ! "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]
  }

  run "${_NB}" edit 1 --content

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not update note file
  [[ ! "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor   ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_original}"  ]]

  # Prints error message
  [[ "${output}" =~ requires\ a\ valid\ argument ]]
}

# encrypted ###################################################################

@test "\`edit\` with encrypted file edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Content" --encrypt --password=example

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    _original_hash="$(_get_hash "${_NOTEBOOK_PATH}/${_filename}")"
  }

  run "${_NB}" edit 1 --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0
  [[ ${status} -eq 0 ]]

  # Updates file
  [[ "$(_get_hash "${_NOTEBOOK_PATH}/${_filename}")" != "${_original_hash}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# $EDITOR #####################################################################

@test "\`edit <id>\` with multi-word \$EDITOR edits properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add --content "Example"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    "${_NB}" set editor "mock_editor --flag"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "\`edit <id>\` with multi-word \$EDITOR edits properly with filename with spaces." {
  {
    run "${_NB}" init
    run "${_NB}" add --filename "multi-word filename.md"

    "${_NB}" set editor "mock_editor --flag"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/multi-word filename.md")" =~ mock_editor ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# help ########################################################################

@test "\`help edit\` exits with status 0 and prints help information." {
  run "${_NB}" help edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" == "Usage:"      ]]
  [[ "${lines[1]}" =~ \ \ nb\ edit  ]]
}
