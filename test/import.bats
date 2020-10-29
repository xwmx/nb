#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'import' with no arguments exits with status 1 and prints help." {
  {
    run "${_NB}" init
  }

  run "${_NB}" import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "'import' with no arguments does not create git commit." {
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

@test "'import' with valid <path> argument creates a new note file." {
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

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'import' with valid <path> argument creates git commit." {
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

@test "'import' with valid <path> argument gets a unique filename." {
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

@test "'import' with valid <directory path> argument imports a directory." {
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

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported        ]]
  [[ "${output}" =~ Example\ Folder ]]
}

@test "'import move' with valid <directory path> argument moves a directory." {
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

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported        ]]
  [[ "${output}" =~ Example\ Folder ]]
}

# * (glob) arguments ##########################################################

@test "'import' with valid * (glob) argument copies multiple files and directories." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./*

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 8                                      ]]

  grep -q '# Example Title' "${_NOTEBOOK_PATH}/Example Folder"/*

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"                ]]
  [[    -d "${_NOTEBOOK_PATH}/Example Folder"                   ]]
  [[    -f "${_NOTEBOOK_PATH}/Example Folder/example.md"        ]]
  [[    -f "${_NOTEBOOK_PATH}/Example Folder/example.com.html"  ]]
  [[    "${output}" =~ Example\ Folder                          ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                           ]]
  [[    -d "${_NOTEBOOK_PATH}/bin"                              ]]
  [[    -f "${_NOTEBOOK_PATH}/bin/bookmark"                     ]]
  [[    -f "${_NOTEBOOK_PATH}/bin/mock_editor"                  ]]
  [[    "${lines[1]}" =~ Imported                               ]]
  [[    "${output}" =~ bin                                      ]]

  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"     ]]
  [[    -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"        ]]
  [[    "${lines[2]}" =~ Imported                               ]]
  [[    "${output}" =~ copy-deprecated.nb-plugin                ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"           ]]
  [[    -f "${_NOTEBOOK_PATH}/example.com-og.html"              ]]
  [[    "${lines[3]}" =~ Imported                               ]]
  [[    "${output}" =~ example.com-og.html                      ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

@test "'import' with valid *.md (glob) argument copies multiple markdown files." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./*.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[    -f "${_NOTEBOOK_PATH}/example.com.md"               ]]
  [[    "${output}" =~ example.com.md                       ]]

  [[    -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${_NOTEBOOK_PATH}/example.md"                   ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[ !  -d "${_NOTEBOOK_PATH}/Example Folder"               ]]
  [[ !  "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${_NOTEBOOK_PATH}/bin"                          ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"    ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com-og.html"          ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

@test "'import' with multiple arguments copies multiple files or directories." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import "Example Folder" example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com.md"               ]]
  [[ !  "${output}" =~ example.com.md                       ]]

  [[    -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${_NOTEBOOK_PATH}/example.md"                   ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[    -d "${_NOTEBOOK_PATH}/Example Folder"               ]]
  [[    "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${_NOTEBOOK_PATH}/bin"                          ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"    ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com-og.html"          ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

@test "'import move' with valid * (glob) argument moves multiple files and directories." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move ./*

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 8                                      ]]

  grep -q '# Example Title' "${_NOTEBOOK_PATH}/Example Folder"/*

  [[ !  -e "${_TMP_DIR}/fixtures/Example Folder"                ]]
  [[    -d "${_NOTEBOOK_PATH}/Example Folder"                   ]]
  [[    -f "${_NOTEBOOK_PATH}/Example Folder/example.md"        ]]
  [[    -f "${_NOTEBOOK_PATH}/Example Folder/example.com.html"  ]]
  [[    "${output}" =~ Example\ Folder                          ]]

  [[ !  -e "${_TMP_DIR}/fixtures/bin"                           ]]
  [[    -d "${_NOTEBOOK_PATH}/bin"                              ]]
  [[    -f "${_NOTEBOOK_PATH}/bin/bookmark"                     ]]
  [[    -f "${_NOTEBOOK_PATH}/bin/mock_editor"                  ]]
  [[    "${lines[1]}" =~ Imported                               ]]
  [[    "${output}" =~ bin                                      ]]

  [[ !  -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"     ]]
  [[    -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"        ]]
  [[    "${lines[2]}" =~ Imported                               ]]
  [[    "${output}" =~ copy-deprecated.nb-plugin                ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.com-og.html"           ]]
  [[    -f "${_NOTEBOOK_PATH}/example.com-og.html"              ]]
  [[    "${lines[3]}" =~ Imported                               ]]
  [[    "${output}" =~ example.com-og.html                      ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

@test "'import move' with valid *.md (glob) argument moves multiple markdown files." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move ./*.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[    -f "${_NOTEBOOK_PATH}/example.com.md"               ]]
  [[    "${output}" =~ example.com.md                       ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${_NOTEBOOK_PATH}/example.md"                   ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[ !  -d "${_NOTEBOOK_PATH}/Example Folder"               ]]
  [[ !  "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${_NOTEBOOK_PATH}/bin"                          ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"    ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com-og.html"          ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

@test "'import move' with multiple arguments moves multiple files or directories." {
  {
    run "${_NB}" init

    cp -R "${BATS_TEST_DIRNAME}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move "Example Folder" example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${_NOTEBOOK_PATH}/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com.md"               ]]
  [[ !  "${output}" =~ example.com.md                       ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${_NOTEBOOK_PATH}/example.md"                   ]]
  [[    "${output}" =~ example.md                           ]]

  [[ !  -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[    -d "${_NOTEBOOK_PATH}/Example Folder"               ]]
  [[    "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${_NOTEBOOK_PATH}/bin"                          ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${_NOTEBOOK_PATH}/copy-deprecated.nb-plugin"    ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${_NOTEBOOK_PATH}/example.com-og.html"          ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

# <url> ######################################################################

@test "'import' with valid <url> argument creates a new note file." {
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

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported          ]]
  [[ "${output}" =~ example.com.html  ]]
}

@test "'import --convert' with valid <url> creates and converts a new note file." {
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

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported          ]]
  [[ "${output}" =~ example.com.html  ]]
}

# `notebook` ##################################################################

@test "'import notebook' with valid <path> and <name> imports." {
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

  # Prints output
  [[ "${output}" =~ Imported  ]]
  [[ "${output}" =~ example   ]]
}

# help ########################################################################

@test "'help import' returns usage information." {
  run "${_NB}" help import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ Usage\:         ]]
  [[ "${lines[1]}" =~ \ \ nb\ import  ]]
}
