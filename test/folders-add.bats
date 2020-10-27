#!/usr/bin/env bats

load test_helper

@test "'add folder/folder --type folder' creates new folder without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder"        ]]
    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder" --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(ls -a "${_NOTEBOOK_PATH}/"))

  echo "${_files[@]}"

  [[ -d "${_NOTEBOOK_PATH}/Example Folder"                    ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder"))

  [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"      ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 3                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]

  # Commits to git:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git -C "${_NOTEBOOK_PATH}" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${_NOTEBOOK_PATH}/.index"                                        ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")"   ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/.index"                         ]]
  [[ "$(ls "${_NOTEBOOK_PATH}/Example Folder")" == \
       "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"           ]]
  [[ -z "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"  ]]

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder  ]]
}

@test "'add folder/folder/example.md' creates new note without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(ls -a "${_NOTEBOOK_PATH}/"))

  echo "${_files[@]}"

  [[ -d "${_NOTEBOOK_PATH}/Example Folder"                    ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder"))

  [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"      ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 4                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]
  [[ "${_folder_folder_files[3]}"   == "example-filename.md"  ]]

  [[ -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md" ]]

  grep -q '# Example Title' "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"/*

  # Commits to git:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git -C "${_NOTEBOOK_PATH}" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/.index"                       ]]
  [[ "$(ls "${_NOTEBOOK_PATH}/Example Folder")" == \
       "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"         ]]
  [[ "$(ls "${_NOTEBOOK_PATH}/Example Folder/Sample Folder")" == \
       "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")" ]]

  # Prints output:

  [[ "${output}" =~ Added:                                                  ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/example-filename.md  ]]
}

@test "'add folder/folder/example.md' with no created note deletes empty ancestor folders." {
  {
    run "${_NB}" init

    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md" ]]
  }

  EDITOR=mock_editor_no_op \
    run "${_NB}" add "Example Folder/Sample Folder/example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Does not create path:

  _files=($(ls -a "${_NOTEBOOK_PATH}/"))

  echo "${_files[@]}"

  [[   "${#_files[@]}"  == 4                                    ]]
  [[   "${_files[3]}"   == ".index"                             ]]
  [[ ! "${_files[*]}"   =~ "Example Folder"                     ]]

  [[ ! -d "${_NOTEBOOK_PATH}/Example Folder"                                      ]]
  [[ ! -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"                        ]]
  [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md"  ]]

  # Does not commit to git:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git -C "${_NOTEBOOK_PATH}" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Does not add to .indexes:

  [[ -e "${_NOTEBOOK_PATH}/.index"                                ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ Example             ]]
  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/.index"               ]]
  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index" ]]

  # Does not print output:

  [[ -z "${output}" ]]
}

@test "'add folder/folder/example.md --encrypt' creates new encrypted note without errors." {
  {
    run "${_NB}" init

    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" \
    --content "# Example Title"                                       \
    --encrypt --password=password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(ls -a "${_NOTEBOOK_PATH}/"))

  echo "${_files[@]}"

  [[ -d "${_NOTEBOOK_PATH}/Example Folder"                    ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder"))

  [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"      ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(ls -a "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 4                          ]]
  [[ "${_folder_folder_files[2]}"   == ".index"                   ]]
  [[ "${_folder_folder_files[3]}"   == "example-filename.md.enc"  ]]

  [[ -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/example-filename.md.enc" ]]

  # Commits to git:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git -C "${_NOTEBOOK_PATH}" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/.index"                       ]]
  [[ "$(ls "${_NOTEBOOK_PATH}/Example Folder")" == \
       "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" ]]

  [[ -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"         ]]
  [[ "$(ls "${_NOTEBOOK_PATH}/Example Folder/Sample Folder")" == \
       "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")" ]]
  # Prints output:

  [[ "${output}" =~ Added:                                                  ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/example-filename.md  ]]
}

@test "'add folder/folder/example.md' with no created note deletes only empty ancestor folders." {
  {
    run "${_NB}" init

    run "${_NB}" add "Example Folder/one.md" --content "# Example Title One"

    [[   -e "${_NOTEBOOK_PATH:-}/Example Folder/one.md"                                         ]]
    [[   -e "${_NOTEBOOK_PATH:-}/Example Folder/.index"                                         ]]
    [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/Demo Folder/example-filename.md"  ]]
  }

  EDITOR=mock_editor_no_op \
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Removes only empty directories:

  _files=($(ls -a "${_NOTEBOOK_PATH}/"))

  echo "${_files[@]}"

  [[   "${#_files[@]}"  == 5                        ]]
  [[   "${_files[3]}"   == ".index"                 ]]
  [[   "${_files[*]}"   =~ "Example Folder"         ]]

  [[   -d "${_NOTEBOOK_PATH}/Example Folder"        ]]
  [[   -e "${_NOTEBOOK_PATH}/Example Folder/.index" ]]
  [[   -e "${_NOTEBOOK_PATH}/Example Folder/one.md" ]]


  [[ ! -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"                                    ]]
  [[ ! -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder"                        ]]
  [[ ! -e "${_NOTEBOOK_PATH:-}/Example Folder/Sample Folder/Demo Folder/example-filename.md"  ]]

  # Does not commit to git:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git -C "${_NOTEBOOK_PATH}" status --porcelain)" ]]
  do
    sleep 1
  done
  git log -n 1 | grep -v -q '\[nb\] Add'

  # Retains .index in populated directories:

  [[   -e "${_NOTEBOOK_PATH}/.index"                                          ]]
  [[   "$(cat "${_NOTEBOOK_PATH}/.index")" =~ Example                         ]]
  [[   -e "${_NOTEBOOK_PATH}/Example Folder/.index"                           ]]
  [[   "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" =~ one.md           ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" =~ Sample           ]]
  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"             ]]
  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/.index" ]]

  # Does not print output:

  [[ -z "${output}" ]]
}
