#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'import' with no arguments exits with status 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "'import' with no arguments does not create git commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" import

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Import'
}

# piped input #################################################################

@test "'import' with piped path imports files." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run bash -c "echo \"${_TMP_DIR}/fixtures/example.md\" | ${_NB} import"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/home/example.md" ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/home/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Imported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'import' with multiple piped paths imports files." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run bash -c "echo \"${_TMP_DIR}/fixtures/example.com\"* | ${_NB} import"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds files:

  [[ -f "${NB_DIR}/home/example.com-og.html"  ]]
  [[ -f "${NB_DIR}/home/example.com.html"     ]]
  [[ -f "${NB_DIR}/home/example.com.md"       ]]

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com-og.html") \
    <(cat "${NB_DIR}/home/example.com-og.html")

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com.html")    \
    <(cat "${NB_DIR}/home/example.com.html")

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com.md")      \
    <(cat "${NB_DIR}/home/example.com.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Imported            ]]
  [[ "${lines[0]}" =~ example.com-og.html ]]
  [[ "${lines[1]}" =~ Imported            ]]
  [[ "${lines[1]}" =~ example.com.html    ]]
  [[ "${lines[2]}" =~ Imported            ]]
  [[ "${lines[2]}" =~ example.com.md      ]]
}

@test "'import' with piped \`ls\` imports files." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run bash -c "ls example.com* | ${_NB} import"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds files:

  [[ -f "${NB_DIR}/home/example.com-og.html"  ]]
  [[ -f "${NB_DIR}/home/example.com.html"     ]]
  [[ -f "${NB_DIR}/home/example.com.md"       ]]

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com-og.html") \
    <(cat "${NB_DIR}/home/example.com-og.html")

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com.html")    \
    <(cat "${NB_DIR}/home/example.com.html")

  diff                                                \
    <(cat "${_TMP_DIR}/fixtures/example.com.md")      \
    <(cat "${NB_DIR}/home/example.com.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Imported            ]]
  [[ "${lines[0]}" =~ example.com-og.html ]]
  [[ "${lines[1]}" =~ Imported            ]]
  [[ "${lines[1]}" =~ example.com.html    ]]
  [[ "${lines[2]}" =~ Imported            ]]
  [[ "${lines[2]}" =~ example.com.md      ]]
}

# <path> ######################################################################

@test "'import' with valid <path> argument creates a new note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1        ]]
  [[ "${lines[0]}" =~ "Imported"  ]]
  grep -q '# Example Title' "${NB_DIR}/home"/*

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'import' with valid <path> argument creates git commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.md"

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
}

@test "'import' with valid <path> argument gets a unique filename." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 2      ]]
  [[ "${lines[0]}" =~ Imported  ]]
  [[ "${lines[0]}" =~ example-1 ]]
  grep -q '# Example Title' "${NB_DIR}/home"/*
}

# <directory path> ############################################################

@test "'import' with valid <directory path> argument imports a directory." {
  {
    "${_NB}" init
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/Example Folder"

  IFS= _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*
  [[ -d "${NB_DIR}/home/Example Folder" ]]
  [[ -f "${NB_DIR}/home/Example Folder/example.md"       ]]
  [[ -f "${NB_DIR}/home/Example Folder/example.com.html" ]]
  [[ "${lines[0]}" =~ "Imported" ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported        ]]
  [[ "${output}" =~ Example\ Folder ]]
}

@test "'import move' with valid <directory path> argument moves a directory." {
  {
    "${_NB}" init
    cp -R "${NB_TEST_BASE_PATH}/fixtures/Example Folder" "${_TMP_DIR}"
    [[ -e "${_TMP_DIR}/Example Folder" ]]
  }

  run "${_NB}" import move "${_TMP_DIR}/Example Folder"

  IFS= _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ ! -e "${_TMP_DIR}/Example Folder" ]]
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*
  [[ -d "${NB_DIR}/home/Example Folder" ]]
  [[ -f "${NB_DIR}/home/Example Folder/example.md"       ]]
  [[ -f "${NB_DIR}/home/Example Folder/example.com.html" ]]
  [[ "${lines[0]}" =~ "Imported" ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported        ]]
  [[ "${output}" =~ Example\ Folder ]]
}

# * (glob) arguments ##########################################################

@test "'import' with valid * (glob) argument copies multiple files and directories." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./*

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 10                                   ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  [[    -d "${_TMP_DIR}/fixtures/Example Folder"              ]]
  [[    -d "${NB_DIR}/home/Example Folder"                    ]]
  [[    -f "${NB_DIR}/home/Example Folder/example.md"         ]]
  [[    -f "${NB_DIR}/home/Example Folder/example.com.html"   ]]
  [[    "${output}" =~ Example\ Folder                        ]]

  [[    -d "${_TMP_DIR}/fixtures/bin"                         ]]
  [[    -d "${NB_DIR}/home/bin"                               ]]
  [[    -f "${NB_DIR}/home/bin/bookmark"                      ]]
  [[    -f "${NB_DIR}/home/bin/mock_editor"                   ]]
  [[    "${lines[1]}" =~ Imported                             ]]
  [[    "${output}" =~ bin                                    ]]

  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"   ]]
  [[    -f "${NB_DIR}/home/copy-deprecated.nb-plugin"         ]]
  [[    "${lines[2]}" =~ Imported                             ]]
  [[    "${output}" =~ copy-deprecated.nb-plugin              ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"         ]]
  [[    -f "${NB_DIR}/home/example.com-og.html"               ]]
  [[    "${lines[3]}" =~ Imported                             ]]
  [[    "${output}" =~ example.com-og.html                    ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

@test "'import' with valid *.md (glob) argument copies multiple markdown files." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./*.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[    -f "${NB_DIR}/home/example.com.md"                  ]]
  [[    "${output}" =~ example.com.md                       ]]

  [[    -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${NB_DIR}/home/example.md"                      ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[ !  -d "${NB_DIR}/home/Example Folder"                  ]]
  [[ !  "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${NB_DIR}/home/bin"                             ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${NB_DIR}/home/copy-deprecated.nb-plugin"       ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${NB_DIR}/home/example.com-og.html"             ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                      ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

@test "'import' with multiple arguments copies multiple files or directories." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import "Example Folder" example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[ !  -f "${NB_DIR}/home/example.com.md"                  ]]
  [[ !  "${output}" =~ example.com.md                       ]]

  [[    -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${NB_DIR}/home/example.md"                      ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[    -d "${NB_DIR}/home/Example Folder"                  ]]
  [[    "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${NB_DIR}/home/bin"                             ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${NB_DIR}/home/copy-deprecated.nb-plugin"       ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${NB_DIR}/home/example.com-og.html"             ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

@test "'import move' with valid * (glob) argument moves multiple files and directories." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move ./*

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 10                                 ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  [[ !  -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[    -d "${NB_DIR}/home/Example Folder"                  ]]
  [[    -f "${NB_DIR}/home/Example Folder/example.md"       ]]
  [[    -f "${NB_DIR}/home/Example Folder/example.com.html" ]]
  [[    "${output}" =~ Example\ Folder                      ]]

  [[ !  -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[    -d "${NB_DIR}/home/bin"                             ]]
  [[    -f "${NB_DIR}/home/bin/bookmark"                    ]]
  [[    -f "${NB_DIR}/home/bin/mock_editor"                 ]]
  [[    "${lines[1]}" =~ Imported                           ]]
  [[    "${output}" =~ bin                                  ]]

  [[ !  -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[    -f "${NB_DIR}/home/copy-deprecated.nb-plugin"       ]]
  [[    "${lines[2]}" =~ Imported                           ]]
  [[    "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[    -f "${NB_DIR}/home/example.com-og.html"             ]]
  [[    "${lines[3]}" =~ Imported                           ]]
  [[    "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

@test "'import move' with valid *.md (glob) argument moves multiple markdown files." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move ./*.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[    -f "${NB_DIR}/home/example.com.md"                  ]]
  [[    "${output}" =~ example.com.md                       ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${NB_DIR}/home/example.md"                      ]]
  [[    "${output}" =~ example.md                           ]]

  [[    -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[ !  -d "${NB_DIR}/home/Example Folder"                  ]]
  [[ !  "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${NB_DIR}/home/bin"                             ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${NB_DIR}/home/copy-deprecated.nb-plugin"       ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${NB_DIR}/home/example.com-og.html"             ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

@test "'import move' with multiple arguments moves multiple files or directories." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import move "Example Folder" example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}" -eq 2                                  ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com.md"            ]]
  [[ !  -f "${NB_DIR}/home/example.com.md"                  ]]
  [[ !  "${output}" =~ example.com.md                       ]]

  [[ !  -e "${_TMP_DIR}/fixtures/example.md"                ]]
  [[    -f "${NB_DIR}/home/example.md"                      ]]
  [[    "${output}" =~ example.md                           ]]

  [[ !  -e "${_TMP_DIR}/fixtures/Example Folder"            ]]
  [[    -d "${NB_DIR}/home/Example Folder"                  ]]
  [[    "${output}" =~ Example\ Folder                      ]]

  [[    -e "${_TMP_DIR}/fixtures/bin"                       ]]
  [[ !  -d "${NB_DIR}/home/bin"                             ]]
  [[ !  "${output}" =~ bin                                  ]]


  [[    -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin" ]]
  [[ !  -f "${NB_DIR}/home/copy-deprecated.nb-plugin"       ]]
  [[ !  "${output}" =~ copy-deprecated.nb-plugin            ]]

  [[    -e "${_TMP_DIR}/fixtures/example.com-og.html"       ]]
  [[ !  -f "${NB_DIR}/home/example.com-og.html"             ]]
  [[ !  "${output}" =~ example.com-og.html                  ]]

  # creates git commit
  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
}

# <url> ######################################################################

@test "'import' with valid <url> argument creates a new note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" import "file://${NB_TEST_BASE_PATH}/fixtures/example.com.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))
  [[ "${#_files[@]}" -eq 1 ]]

  grep -q 'Example' "${NB_DIR}/home"/*

  [[ "${output}" =~ "Imported" ]]

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
  git log | grep -q 'Source'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported          ]]
  [[ "${output}" =~ example.com.html  ]]
}

@test "'import --convert' with valid <url> creates and converts a new note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" import \
    --convert         \
    "file://${NB_TEST_BASE_PATH}/fixtures/example.com.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))
  [[ "${#_files[@]}" -eq 1 ]]

  cat "${NB_DIR}/home/${_files[0]}"

  grep -q '# Example Domain' "${NB_DIR}/home/${_files[0]}"

  [[ "${output}" =~ "Imported" ]]

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
  git log | grep -q 'Source'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported          ]]
  [[ "${output}" =~ example.com.html  ]]
}

@test "'import download' with valid <url> argument creates a new note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" import download "file://${NB_TEST_BASE_PATH}/fixtures/example.com.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))
  [[ "${#_files[@]}" -eq 1 ]]

  grep -q 'Example' "${NB_DIR}/home"/*

  [[ "${output}" =~ "Imported" ]]

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'
  git log | grep -q 'Source'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Imported          ]]
  [[ "${output}" =~ example.com.html  ]]
}

# `notebook` ##################################################################

@test "'import notebook' with valid <path> and <name> imports." {
  "${_NB}" init

  run "${_NB}" import notebook                      \
    "${NB_TEST_BASE_PATH}/fixtures/Example Folder"  \
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
