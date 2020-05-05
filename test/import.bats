#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`import\` with no arguments exits with status 1 and prints help." {
  run "${_NOTES}" init
  run "${_NOTES}" import
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

@test "\`import\` with no arguments does not create git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" import
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[NOTES\] Import'
}

# <path> ######################################################################

@test "\`import\` with valid <path> argument creates a new note file." {
  run "${_NOTES}" init

  run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Example Title' "${_NOTEBOOK_PATH}"/*
  [[ "${lines[0]}" =~ "Imported" ]]
}

@test "\`import\` with valid <path> argument creates git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Import'
}

# <directory path> ############################################################

@test "\`import\` with valid <directory path> argument imports a directory." {
  run "${_NOTES}" init

  run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/Example Folder"

  IFS= _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Example Title' "${_NOTEBOOK_PATH}/Example Folder"/*
  [[ -d "${_NOTEBOOK_PATH}/Example Folder" ]]
  [[ -f "${_NOTEBOOK_PATH}/Example Folder/example.md"       ]]
  [[ -f "${_NOTEBOOK_PATH}/Example Folder/example.com.html" ]]
  [[ "${lines[0]}" =~ "Imported" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Import'
}

@test "\`import move\` with valid <directory path> argument moves a directory." {
  run "${_NOTES}" init
  cp -R "${BATS_TEST_DIRNAME}/fixtures/Example Folder" "${_TMP_DIR}"
  [[ -e "${_TMP_DIR}/Example Folder" ]]

  run "${_NOTES}" import move "${_TMP_DIR}/Example Folder"

  IFS= _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ ! -e "${_TMP_DIR}/Example Folder" ]]
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Example Title' "${_NOTEBOOK_PATH}/Example Folder"/*
  [[ -d "${_NOTEBOOK_PATH}/Example Folder" ]]
  [[ -f "${_NOTEBOOK_PATH}/Example Folder/example.md"       ]]
  [[ -f "${_NOTEBOOK_PATH}/Example Folder/example.com.html" ]]
  [[ "${lines[0]}" =~ "Imported" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Import'
}

# <url> ######################################################################

@test "\`import\` with valid <url> argument creates a new note file." {
  run "${_NOTES}" init

  run "${_NOTES}" import "file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q 'Example' "${_NOTEBOOK_PATH}"/*
  [[ "${output}" =~ "Imported" ]]
}

@test "\`import\` with valid <url> argument creates git commit." {
  run "${_NOTES}" init

  run "${_NOTES}" import "file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Import'
  git log | grep -q 'Source'
}

# help ########################################################################

@test "\`help import\` returns usage information." {
  run "${_NOTES}" help import
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes import (<path> | <url>)" ]]
}

