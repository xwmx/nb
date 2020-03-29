#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`import\` with no arguments exits with status 1 and prints help." {
  run "${_NOTES}" init
  run "${_NOTES}" import
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
}

@test "\`import\` with no arguments does not create git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" import
  cd "${NOTES_DATA_DIR}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Import') ]]
}

# <path> ######################################################################

@test "\`import\` with valid <path> argument creates a new note file." {
  run "${_NOTES}" init
  run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Example Title' "${NOTES_DATA_DIR}"/*) ]]
}

@test "\`import\` with valid <path> argument creates git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"
  cd "${NOTES_DATA_DIR}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Import') ]]
}

# <url> ######################################################################

@test "\`import\` with valid <url> argument creates a new note file." {
  run "${_NOTES}" init
  run "${_NOTES}" import "http://example.net"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep 'Example' "${NOTES_DATA_DIR}"/*) ]]
}

@test "\`import\` with valid <url> argument creates git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" import "http://example.net"
  cd "${NOTES_DATA_DIR}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Import') ]]
}

# help ########################################################################

@test "\`help add\` returns usage information." {
  run "${_NOTES}" help add
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes add [<note>] [--type <type>]" ]]
}

