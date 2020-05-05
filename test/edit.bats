#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

# no argument #################################################################

@test "\`edit\` with no argument exits and prints help." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }
  _original="$(cat "${_NOTEBOOK_PATH}/${_filename}")"

  run "${_NOTES}" edit
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not update note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_original}" ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  ! git log | grep -q '\[NOTES\] Edit'

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
  [[ "${lines[0]}" == "Note not found: '1'." ]]
}

# <scope>:<selector> ##########################################################

@test "\`edit <scope>:<selector>\` with <filename> argument prints scoped output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "one"
    run "${_NOTES}" one:add
    _filename=$("${_NOTES}" one:list -n 1 --no-id --filenames | head -1)
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

@test "\`edit\` with no changes does not print output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "example.md" --content "Example content."
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor_no_op" &&
    run "${_NOTES}" edit "${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ -z ${output} ]]
}

@test "\`edit\` encrypted with no changes does not print output." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "example.md" --content "Example content." \
      --encrypt --password example
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor_no_op" &&
    run "${_NOTES}" edit "${_filename}" --password example
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
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit "${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

@test "\`edit\` with <filename> with spaces edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "Note name with spaces.md"
    _filename="Note name with spaces.md"
    [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  }

  run "${_NOTES}" edit "${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ Note\ name\ with\ spaces.md ]]
}

# <id> ########################################################################

@test "\`edit\` with <id> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`edit\` with <path> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit "${_NOTEBOOK_PATH}/${_filename}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]

}

# <title> #####################################################################

@test "\`edit\` with <title> argument edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" edit "${_title}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# piped #######################################################################

@test "\`edit\` with piped content edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Example"
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run bash -c "echo '## Piped' | ${_NOTES} edit 1"

  printf "\${status}: %s\\n" "${status}"
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
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

# encrypted ###################################################################

@test "\`edit\` with encrypted file edits properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Content" --encrypt --password=example
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" edit 1 --password=example
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]

  # Updates file
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" != "${_original}" ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Edit'

  # Prints output
  [[ "${output}" =~ Updated\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
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
