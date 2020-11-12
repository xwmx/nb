#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'bookmark <folder>/' with no argument exits with 0, prints message, and lists." {
  {
    run "${_NB}" init

    run "${_NB}" add "Example Folder" --type folder

    [[   -d "${_NOTEBOOK_PATH:-}/Example Folder"        ]]
    [[   -f "${_NOTEBOOK_PATH:-}/Example Folder/.index" ]]
  }

  run "${_NB}" bookmark Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0          ]]

  # Does not create note file:

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1    ]]

  # Does not create git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Add'

  # Prints help information:

  [[ "${lines[0]}" =~ ^Add\:  ]]
}
