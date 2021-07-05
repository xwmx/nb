#!/usr/bin/env bats

load test_helper

# local notebook ##############################################################

@test "'import <path> <folder>/' with local notebook imports file." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add folder "Example Folder"

    [[ -d "${_TMP_DIR}/Local Notebook/Example Folder"       ]]
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.md" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_TMP_DIR}/Local Notebook/Example Folder/"))

  [[ "${#_files[@]}" -eq 1                                  ]]
  grep -q '# Example Title' "${_TMP_DIR}/Local Notebook/Example Folder"/*

  # Adds to index:

  [[ -e "${_TMP_DIR}/Local Notebook/Example Folder/.index"  ]]

  diff                                                      \
    <(ls "${_TMP_DIR}/Local Notebook/Example Folder")       \
    <(cat "${_TMP_DIR}/Local Notebook/Example Folder/.index")

  # Creates git commit:

  cd "${_TMP_DIR}/Local Notebook" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)"                   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${lines[0]}" =~ \
Imported\ .*[.*Example\ Folder/1.*].*\ .*Example\ Folder/example.md.*\ \"Example\ Title\" ]]
  [[ "${lines[0]}" =~ \
\"Example\ Title\"\ from\ .*${NB_TEST_BASE_PATH}/fixtures/example.md                      ]]
}

@test "'import <path>' with local notebook imports file." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init
  }

  run "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_TMP_DIR}/Local Notebook/"))

  [[ "${#_files[@]}" -eq 1                  ]]
  grep -q '# Example Title' "${_TMP_DIR}/Local Notebook"/*

  # Adds to index:

  [[ -e "${_TMP_DIR}/Local Notebook/.index" ]]

  diff                                      \
    <(ls "${_TMP_DIR}/Local Notebook")      \
    <(cat "${_TMP_DIR}/Local Notebook/.index")

  # Creates git commit:

  cd "${_TMP_DIR}/Local Notebook" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${lines[0]}" =~ \
Imported\ .*[.*1.*].*\ .*example.md.*\ \"Example\ Title\"             ]]
  [[ "${lines[0]}" =~ \
\"Example\ Title\"\ from\ .*${NB_TEST_BASE_PATH}/fixtures/example.md  ]]
}

# no argument #################################################################

@test "'import' with no arguments exits with status 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
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

# destination #################################################################

@test "'import <path> <notebook>:' imports file into <notebook>:." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Notebook:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/Example Notebook/example.md" ]]

  diff                                          \
    <(cat "${_TMP_DIR}/fixtures/example.md")    \
    <(cat "${NB_DIR}/Example Notebook/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/.index"     ]]

  diff                                          \
    <(ls "${NB_DIR}/Example Notebook/")         \
    <(cat "${NB_DIR}/Example Notebook/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Notebook:1.*].*\ .*example.md.*\ \"Example\ Title\" ]]
  [[ "${output}" =~ \
example.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md   ]]
}

@test "'import ./* <notebook>:' with valid * (glob) argument copies multiple files and directories into <notebook>:." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./* "Example Notebook:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/Example Notebook/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}"  -eq 13 ]]

  grep -q '# Example Title' "${NB_DIR}/Example Notebook/Example Folder"/*

  [[ -d "${_TMP_DIR}/fixtures/Example Folder"                         ]]
  [[ -d "${NB_DIR}/Example Notebook/Example Folder"                   ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Folder/example.md"        ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Folder/example.com.html"  ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Folder            ]]

  [[ -d "${_TMP_DIR}/fixtures/bin"                                    ]]
  [[ -d "${NB_DIR}/Example Notebook/bin"                              ]]
  [[ -f "${NB_DIR}/Example Notebook/bin/bookmark"                     ]]
  [[ -f "${NB_DIR}/Example Notebook/bin/mock_editor"                  ]]
  [[    "${lines[1]}" =~ Imported                                     ]]
  [[    "${output}"   =~ Example\ Notebook:bin                        ]]

  [[ -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"              ]]
  [[ -f "${NB_DIR}/Example Notebook/copy-deprecated.nb-plugin"        ]]
  [[    "${lines[2]}" =~ Imported                                     ]]
  [[    "${output}"   =~ Example\ Notebook:copy-deprecated.nb-plugin  ]]

  [[ -e "${_TMP_DIR}/fixtures/example.com-og.html"                    ]]
  [[ -f "${NB_DIR}/Example Notebook/example.com-og.html"              ]]
  [[    "${lines[3]}" =~ Imported                                     ]]
  [[    "${output}"   =~ Example\ Notebook:example.com-og.html        ]]

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Import'

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/.index" ]]

  diff                                      \
    <(ls "${NB_DIR}/Example Notebook/")     \
    <(cat "${NB_DIR}/Example Notebook/.index")
}

@test "'import ./* <notebook>:<folder>' (no slash) with valid * (glob) argument copies multiple files and directories into <notebook>:<folder>/." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Destination" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./* "Example Notebook:Example Destination"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/Example Notebook/Example Destination/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}"  -eq 13 ]]

  grep -q '# Example Title' "${NB_DIR}/Example Notebook/Example Destination/Example Folder"/*

  [[ -d "${_TMP_DIR}/fixtures/Example Folder"                                             ]]
  [[ -d "${NB_DIR}/Example Notebook/Example Destination/Example Folder"                   ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/Example Folder/example.md"        ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/Example Folder/example.com.html"  ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/Example\ Folder           ]]

  [[ -d "${_TMP_DIR}/fixtures/bin"                                                        ]]
  [[ -d "${NB_DIR}/Example Notebook/Example Destination/bin"                              ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/bin/bookmark"                     ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/bin/mock_editor"                  ]]
  [[    "${lines[1]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/bin                       ]]

  [[ -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"                                  ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/copy-deprecated.nb-plugin"        ]]
  [[    "${lines[2]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/copy-deprecated.nb-plugin ]]

  [[ -e "${_TMP_DIR}/fixtures/example.com-og.html"                                        ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/example.com-og.html"              ]]
  [[    "${lines[3]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/example.com-og.html       ]]

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Import'

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/Example Destination/.index" ]]

  diff                                                      \
    <(ls "${NB_DIR}/Example Notebook/Example Destination/") \
    <(cat "${NB_DIR}/Example Notebook/Example Destination/.index")
}

@test "'import ./* <notebook>:<folder>/' (slash) with valid * (glob) argument copies multiple files and directories into <notebook>:<folder>/." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Destination" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./* "Example Notebook:Example Destination/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/Example Notebook/Example Destination/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}"  -eq 13 ]]

  grep -q '# Example Title' "${NB_DIR}/Example Notebook/Example Destination/Example Folder"/*

  [[ -d "${_TMP_DIR}/fixtures/Example Folder"                                             ]]
  [[ -d "${NB_DIR}/Example Notebook/Example Destination/Example Folder"                   ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/Example Folder/example.md"        ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/Example Folder/example.com.html"  ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/Example\ Folder           ]]

  [[ -d "${_TMP_DIR}/fixtures/bin"                                                        ]]
  [[ -d "${NB_DIR}/Example Notebook/Example Destination/bin"                              ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/bin/bookmark"                     ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/bin/mock_editor"                  ]]
  [[    "${lines[1]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/bin                       ]]

  [[ -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"                                  ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/copy-deprecated.nb-plugin"        ]]
  [[    "${lines[2]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/copy-deprecated.nb-plugin ]]

  [[ -e "${_TMP_DIR}/fixtures/example.com-og.html"                                        ]]
  [[ -f "${NB_DIR}/Example Notebook/Example Destination/example.com-og.html"              ]]
  [[    "${lines[3]}" =~ Imported                                                         ]]
  [[    "${output}"   =~ Example\ Notebook:Example\ Destination/example.com-og.html       ]]

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Import'

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/Example Destination/.index" ]]

  diff                                                      \
    <(ls "${NB_DIR}/Example Notebook/Example Destination/") \
    <(cat "${NB_DIR}/Example Notebook/Example Destination/.index")
}

@test "'import <file-path> <notebook>:<filename>' imports file to <notebook>:<filename>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import                 \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Notebook:Example Destination.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/Example Notebook/Example Destination.md" ]]

  diff                                          \
    <(cat "${_TMP_DIR}/fixtures/example.md")    \
    <(cat "${NB_DIR}/Example Notebook/Example Destination.md")

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/.index" ]]

  diff                                  \
    <(ls "${NB_DIR}/Example Notebook/") \
    <(cat "${NB_DIR}/Example Notebook/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*Example\ Destination.md.*\ \"Example\ Title\"  ]]
  [[ "${output}" =~ \
Example\ Destination.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md  ]]
}

@test "'import <file-path> <notebook>:<folder>/<filename>' imports file to <notebook>:<folder>/<filename>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import                 \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Notebook:Example Folder/Example Destination.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/Example Notebook/Example Folder/Example Destination.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/Example Destination.md")

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/Example Folder/.index"      ]]

  diff                                                  \
    <(ls "${NB_DIR}/Example Notebook/Example Folder/")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*Example\ Folder/Example\ Destination.md.*\ \"Example\ Title\"  ]]
  [[ "${output}" =~ \
Folder/Example\ Destination.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md           ]]
}

@test "'import <path> <notebook>:<folder>/' (slash) imports file to <notebook>:<folder>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Notebook:Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/Example Notebook/Example Folder/example.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/Example Folder/.index"      ]]

  diff                                                  \
    <(ls "${NB_DIR}/Example Notebook/Example Folder/")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*Example\ Folder/example.md.*\ \"Example\ Title\" ]]
  [[ "${output}" =~ \
Folder/example.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md          ]]
}

@test "'import <path> <notebook>:<folder>' (no slash) imports file to <notebook>:<folder>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Notebook:Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/Example Notebook/Example Folder/example.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/Example Notebook/Example Folder/.index"      ]]

  diff                                                  \
    <(ls "${NB_DIR}/Example Notebook/Example Folder/")  \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*Example\ Folder/example.md.*\ \"Example\ Title\" ]]
  [[ "${output}" =~ \
Folder/example.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md          ]]
}

@test "'import ./* <folder>' (no slash) with valid * (glob) argument copies multiple files and directories into <folder>/." {
  {
    "${_NB}" init

    "${_NB}" add "Example Destination" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./* "Example Destination"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/Example Destination/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}"  -eq 13 ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Destination/Example Folder"/*

  [[ -d "${_TMP_DIR}/fixtures/Example Folder"                                   ]]
  [[ -d "${NB_DIR}/home/Example Destination/Example Folder"                     ]]
  [[ -f "${NB_DIR}/home/Example Destination/Example Folder/example.md"          ]]
  [[ -f "${NB_DIR}/home/Example Destination/Example Folder/example.com.html"    ]]
  [[    "${output}"   =~ Example\ Destination/Example\ Folder                   ]]

  [[ -d "${_TMP_DIR}/fixtures/bin"                                              ]]
  [[ -d "${NB_DIR}/home/Example Destination/bin"                                ]]
  [[ -f "${NB_DIR}/home/Example Destination/bin/bookmark"                       ]]
  [[ -f "${NB_DIR}/home/Example Destination/bin/mock_editor"                    ]]
  [[    "${lines[1]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/bin                               ]]

  [[ -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"                        ]]
  [[ -f "${NB_DIR}/home/Example Destination/copy-deprecated.nb-plugin"          ]]
  [[    "${lines[2]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/copy-deprecated.nb-plugin         ]]

  [[ -e "${_TMP_DIR}/fixtures/example.com-og.html"                              ]]
  [[ -f "${NB_DIR}/home/Example Destination/example.com-og.html"                ]]
  [[    "${lines[3]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/example.com-og.html               ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Import'

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Destination/.index" ]]

  diff                                          \
    <(ls "${NB_DIR}/home/Example Destination/") \
    <(cat "${NB_DIR}/home/Example Destination/.index")
}

@test "'import ./* <folder>/' (slash) with valid * (glob) argument copies multiple files and directories into <folder>/." {
  {
    "${_NB}" init

    "${_NB}" add "Example Destination" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]

    cd "${_TMP_DIR}/fixtures"

    [[ "$(pwd)" == "${_TMP_DIR}/fixtures" ]]
    [[ -d "${NB_DIR}/home"                ]]
  }

  run "${_NB}" import ./* "Example Destination/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  IFS=$'\n' _files=($(ls -1 "${NB_DIR}/home/Example Destination/"))

  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  printf "\${#_files[@]}: '%s'\\n" "${#_files[@]}"

  [[ "${#_files[@]}"  -eq 13 ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Destination/Example Folder"/*

  [[ -d "${_TMP_DIR}/fixtures/Example Folder"                                   ]]
  [[ -d "${NB_DIR}/home/Example Destination/Example Folder"                     ]]
  [[ -f "${NB_DIR}/home/Example Destination/Example Folder/example.md"          ]]
  [[ -f "${NB_DIR}/home/Example Destination/Example Folder/example.com.html"    ]]
  [[    "${output}"   =~ Example\ Destination/Example\ Folder                   ]]

  [[ -d "${_TMP_DIR}/fixtures/bin"                                              ]]
  [[ -d "${NB_DIR}/home/Example Destination/bin"                                ]]
  [[ -f "${NB_DIR}/home/Example Destination/bin/bookmark"                       ]]
  [[ -f "${NB_DIR}/home/Example Destination/bin/mock_editor"                    ]]
  [[    "${lines[1]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/bin                               ]]

  [[ -e "${_TMP_DIR}/fixtures/copy-deprecated.nb-plugin"                        ]]
  [[ -f "${NB_DIR}/home/Example Destination/copy-deprecated.nb-plugin"          ]]
  [[    "${lines[2]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/copy-deprecated.nb-plugin         ]]

  [[ -e "${_TMP_DIR}/fixtures/example.com-og.html"                              ]]
  [[ -f "${NB_DIR}/home/Example Destination/example.com-og.html"                ]]
  [[    "${lines[3]}" =~ Imported                                               ]]
  [[    "${output}"   =~ Example\ Destination/example.com-og.html               ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Import'

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Destination/.index" ]]

  diff                                          \
    <(ls "${NB_DIR}/home/Example Destination/") \
    <(cat "${NB_DIR}/home/Example Destination/.index")
}

@test "'import <file-path> <filename>' imports file to <filename>." {
  {
    "${_NB}" init

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Destination.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/home/Example Destination.md" ]]

  diff                                          \
    <(cat "${_TMP_DIR}/fixtures/example.md")    \
    <(cat "${NB_DIR}/home/Example Destination.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                          \
    <(ls "${NB_DIR}/home/")     \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Folder/1.*].*\ .*Example\ Destination.md.*\ \"Example\ Title\"  ]]
  [[ "${output}" =~ \
Example\ Destination.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md  ]]
}

@test "'import <file-path> <folder>/<filename>' imports file to <folder>/<filename>." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Folder/Example Destination.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/home/Example Folder/Example Destination.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/home/Example Folder/Example Destination.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/.index"      ]]

  diff                                        \
    <(ls "${NB_DIR}/home/Example Folder/")    \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Folder/1.*].*\ .*Example\ Folder/Example\ Destination.md.*\ \"Example\ Title\"  ]]
  [[ "${output}" =~ \
Folder/Example\ Destination.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md           ]]
}

@test "'import <path> <folder>/' (slash) imports file to <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/home/Example Folder/example.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/home/Example Folder/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/.index"      ]]

  diff                                        \
    <(ls "${NB_DIR}/home/Example Folder/")    \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Folder/1.*].*\ .*Example\ Folder/example.md.*\ \"Example\ Title\" ]]
  [[ "${output}" =~ \
Folder/example.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md          ]]
}

@test "'import <path> <folder>' (no slash) imports file to <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}"

    [[ -e "${_TMP_DIR}/fixtures" ]]
  }

  run "${_NB}" import "${_TMP_DIR}/fixtures/example.md" "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Adds file:

  [[ -f "${NB_DIR}/home/Example Folder/example.md"  ]]

  diff                                        \
    <(cat "${_TMP_DIR}/fixtures/example.md")  \
    <(cat "${NB_DIR}/home/Example Folder/example.md")

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/.index"      ]]

  diff                                        \
    <(ls "${NB_DIR}/home/Example Folder/")    \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ \
Imported\ .*[.*Example\ Folder/1.*].*\ .*Example\ Folder/example.md.*\ \"Example\ Title\" ]]
  [[ "${output}" =~ \
Folder/example.md.*\ \"Example\ Title\"\ from\ .*${_TMP_DIR}/fixtures/example.md          ]]
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

  [[ "${#_files[@]}" -eq 13                                   ]]

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

  [[ "${#_files[@]}" -eq 13                                 ]]

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
  [[ "${lines[0]}" =~ Usage.*\:       ]]
  [[ "${lines[1]}" =~ \ \ nb\ import  ]]
}
