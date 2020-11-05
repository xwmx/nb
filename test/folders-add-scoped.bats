#!/usr/bin/env bats

load test_helper

# notebook:folder/ #####################################################################

@test "'add folder notebook:<folder>/' (trailing slash) creates new nested folder without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/Sample Folder/.index" ]]

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" add folder "home:Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home"))

  echo "_files: ${_files[*]}"

  [[ -d "${NB_DIR}/home/Example Folder"   ]]
  [[ "${#_files[@]}"  == 5                ]]
  [[ "${_files[3]}"   == ".index"         ]]
  [[ "${_files[4]}"   == "Example Folder" ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  echo "_folder_files: ${_folder_files[*]}"

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  [[ "${#_folder_files[@]}" == 4                        ]]
  [[ "${_folder_files[2]}"  == ".index"                 ]]
  [[ "${_folder_files[3]}"  != "Sample Folder"          ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  # Prints output:

  [[    "${output}" =~ Added:                                     ]]
  [[    "${output}" =~ 📂                                         ]]
  [[    "${output}" =~ home:Example\\\ Folder/1                   ]]
  [[    "${output}" =~ home:Example\\\ Folder/[0-9][0-9][0-9]+    ]]
  [[ !  "${output}" =~ \.                                         ]]
  [[ !  "${output}" =~ folder                                     ]]
}

@test "'add notebook:<folder>/ --filename' creates new note without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" add home:Example\ Folder/ --content "# Example Title" \
    --filename "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ example-filename.md          ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                                        ]]
  [[ "${output}" =~ home:Example\\\ Folder/1                      ]]
  [[ "${output}" =~ home:Example\\\ Folder/example-filename.md    ]]
}

@test "'add notebook:<folder>/' creates new note without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" add home:Example\ Folder/ --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ [0-9]+.md                    ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/1          ]]
  [[ "${output}" =~ home:Example\\\ Folder/[0-9]+.md  ]]
}
