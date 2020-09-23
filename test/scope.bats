#!/usr/bin/env bats

load test_helper

_setup_scope() {
  "${_NB}" init
  "${_NB}" notebooks add one
  "${_NB}" use one
  "${_NB}" add "# first"
  "${_NB}" use home
  "${_NB}" notebooks add two
}

# `nb <name>:notebook` #####################################################

@test "\`nb one:notebook\` exits with 0 and scoped \`notebook\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" =~ "one" ]]
}

@test "\`nb two:notebook\` exits with 0 and scoped \`notebook\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" two:notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" =~ "two" ]]
}

@test "\`nb one:invalid\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:invalid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                ]]
  [[ "${lines[0]}" =~ Not\ found    ]]
  [[ "${lines[0]}" =~ one\:invalid  ]]
}

@test "\`nb one:1\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ "first" ]]
}

# `nb <name>:` ################################################################
# NOTE: Additional tests in ls.bats ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@test "\`nb one:\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[2]}" =~ "first" ]]
}

@test "\`nb one: --no-id\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one: --no-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" = "first"  ]]
}

@test "\`nb two:\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" two:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[2]}" =~ 0\ notes\.  ]]
}

@test "\`nb invalid:\` exits with 1 and prints error." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" invalid:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                        ]]
  [[ "${lines[0]}" =~ Notebook\ not\ found  ]]
  [[ "${lines[0]}" =~ invalid               ]]
}

# `nb <url>` ##################################################################

@test "\`nb <name>: <url>\` creates bookmark." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" two: "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/two/"

  _files=($(ls "${NB_DIR}/two/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0                            ]]

  # Creates new note with bookmark filename
  printf "\${_filename}: '%s'\\n" "${_filename}"
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1                      ]]

  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${BATS_TEST_DIRNAME}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/two/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/two/${_filename}")" == "${_bookmark_content}" ]]

  grep -q '# Example Domain' "${NB_DIR}/two"/*

  # Creates git commit
  cd "${NB_DIR}/one" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${NB_DIR}/two/.index"                                  ]]
  [[ "$(ls "${NB_DIR}/two")" == "$(cat "${NB_DIR}/two/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

@test "\`nb <name>:<url>\` (no space) creates bookmark." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" "two:${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/two/"

  _files=($(ls "${NB_DIR}/two/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0                            ]]

  # Creates new note with bookmark filename
  printf "\${_filename}: '%s'\\n" "${_filename}"
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1                      ]]

  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${BATS_TEST_DIRNAME}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/two/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/two/${_filename}")" == "${_bookmark_content}" ]]

  grep -q '# Example Domain' "${NB_DIR}/two"/*

  # Creates git commit
  cd "${NB_DIR}/one" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${NB_DIR}/two/.index"                                  ]]
  [[ "$(ls "${NB_DIR}/two")" == "$(cat "${NB_DIR}/two/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

# `nb show <notebook>:<identifier>` ########################################

@test "\`nb show one:first --dump\` exits with 0 and prints scoped file content." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" show one:first --dump

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]
  [[ "${output}" =~ "first" ]]
}

@test "\`nb show <current>:first --dump\` exits with 0 and prints scoped file content." {
  {
    _setup_scope &>/dev/null
    run "${_NB}" use one
  }

  run "${_NB}" show one:first --dump

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]
  [[ "${output}" =~ "first" ]]
}
