#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`import\` with no arguments exits with status 1 and prints help." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "\`import\` with no arguments does not create git commit." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Import'
}

# <path> ######################################################################

@test "\`import\` with valid <path> argument creates a new note file." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_NOTEBOOK_PATH}/"))

  [[ "${#_files[@]}" -eq 1        ]]
  [[ "${lines[0]}" =~ "Imported"  ]]
  grep -q '# Example Title' "${_NOTEBOOK_PATH}"/*
}

@test "\`import\` with valid <path> argument creates git commit." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
}

@test "\`import\` with valid <path> argument gets a unique filename." {
  {
    run "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_NOTEBOOK_PATH}/"))

  [[ "${#_files[@]}" -eq 2      ]]
  [[ "${lines[0]}" =~ Imported  ]]
  [[ "${lines[0]}" =~ example-1 ]]
  grep -q '# Example Title' "${_NOTEBOOK_PATH}"/*
}

# <directory path> ############################################################

@test "\`import\` with valid <directory path> argument imports a directory." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/Example Folder"

  IFS= _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${status}: '%s'\\n" "${status}"
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
  git log | grep -q '\[nb\] Import'
}

@test "\`import move\` with valid <directory path> argument moves a directory." {
  {
    run "${_NB}" init
    cp -R "${BATS_TEST_DIRNAME}/fixtures/Example Folder" "${_TMP_DIR}"
    [[ -e "${_TMP_DIR}/Example Folder" ]]
  }

  run "${_NB}" import move "${_TMP_DIR}/Example Folder"

  IFS= _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${status}: '%s'\\n" "${status}"
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
  git log | grep -q '\[nb\] Import'
}

# <url> ######################################################################

@test "\`import\` with valid <url> argument creates a new note file." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import "file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]

  grep -q 'Example' "${_NOTEBOOK_PATH}"/*

  [[ "${output}" =~ "Imported" ]]

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
  git log | grep -q 'Source'
}

@test "\`import --convert\` with valid <url> creates and converts a new note file." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import \
    --convert         \
    "file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]

  cat "${_NOTEBOOK_PATH}/${_files[0]}"

  grep -q 'Example Domain' "${_NOTEBOOK_PATH}/${_files[0]}"
  grep -q '==============' "${_NOTEBOOK_PATH}/${_files[0]}"

  [[ "${output}" =~ "Imported" ]]

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
  git log | grep -q 'Source'
}

# `notebook` ##################################################################

@test "\`import notebook\` with valid <path> and <name> imports." {
  run "${_NB}" init

  run "${_NB}" import notebook                      \
    "${BATS_TEST_DIRNAME}/fixtures/Example Folder"  \
    "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}"

  [[ ${status} -eq 0                ]]
  [[ -d "${NB_DIR}/example"         ]]
  [[ "${lines[0]}" =~ "Imported"    ]]
  "${_NB}" notebooks | grep -q 'example'
}

# help ########################################################################

@test "\`help import\` returns usage information." {
  run "${_NB}" help import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ Usage\:         ]]
  [[ "${lines[1]}" =~ \ \ nb\ import  ]]
}

