#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# todo delete #################################################################

@test "'todo delete <notebook>:<folder>/<id>' with positive confirmation prompt exits with 0, deletes todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    "${_NB}" use "home"
  }

  run "${_NB}" todo delete Example\ Notebook:Example\ Folder/3 <<< "y${NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/Example Notebook/Example Folder/Three.todo.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/Example Notebook/Example Folder/.index"            ]]
  [[    "$(ls "${NB_DIR}/Example Notebook/Example Folder")"  == \
          "$(cat "${NB_DIR}/Example Notebook/Example Folder/.index")" ]]
  [[    "${_original_index}"                  != \
          "$(cat "${NB_DIR}/Example Notebook/Example Folder/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                                                   ]]
  [[ "${output}" =~   Deleted:                                            ]]
  [[ "${output}" =~   Example\ Notebook:.*Example\ Folder/Three.todo.md.* ]]
}

@test "'todo delete <id>' with postive confirmation prompt exits with 0, deletes todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" todo delete 3 <<< "y${NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Three.todo.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"             ]]
  [[    "$(ls "${NB_DIR}/home")"  == \
          "$(cat "${NB_DIR}/home/.index")"  ]]
  [[    "${_original_index}"      != \
          "$(cat "${NB_DIR}/home/.index")"  ]]

  # Prints output:

  [[ "${status}" -eq  0                 ]]
  [[ "${output}" =~   Deleted:          ]]
  [[ "${output}" =~   .*Three.todo.md.* ]]
}

@test "'todo delete <id>' with negative response exits with 0." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" todo delete 3 <<< "n${NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                       ]]
  [[ "${lines[0]}"    =~  Deleting.*Three.todo.md ]]
  [[ "${lines[1]}"    =~  Exiting\.\.\.           ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 3                       ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Deleted'
}

@test "'todo delete' with no selector exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 1               ]]
  [[ "${lines[0]}"    =~  Usage.*:        ]]
  [[ "${lines[1]}"    =~  ${_ME}\ todo    ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 0               ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Deleted'
}

# <title> #####################################################################

@test "'todo delete folder/<title>' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.todo.md"                  \
      --content "# [ ] Sample todo description."

    "${_NB}" add "Example Folder/Example File.todo.md"  \
      --content "# [ ] Example todo description."

    [[   -e "${NB_DIR}/home/Example Folder/Example File.todo.md" ]]
  }

  run "${_NB}" delete "Example Folder/Example todo description." --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes  file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.todo.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: .*Example Folder/Example File.todo.md'

  # Prints output:

  [[ "${output}" =~ Deleted:                              ]]
  [[ "${output}" =~ Example\ Folder/1                     ]]
  [[ "${output}" =~ ✔️                                     ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.todo.md ]]
}

@test "'todo delete folder/folder/<title>' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.todo.md"                                \
      --content "# [ ] Sample todo description."

    "${_NB}" add "Example Folder/Sample Folder/Example File.todo.md"  \
      --content "# [ ] Example todo description."

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.todo.md"  ]]
  }

  run "${_NB}" delete "Example Folder/Sample Folder/Example todo description." --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.todo.md"    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: .*Example Folder/Sample Folder/Example File.todo.md'

  # Prints output:

  [[ "${output}" =~ Deleted:                                              ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                      ]]
  [[ "${output}" =~ ✔️                                                     ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.todo.md  ]]
}

@test "'todo delete notebook:folder/<title>' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.tod.md"                  \
      --content "# [ ] Sample todo description."

    "${_NB}" add "Example Folder/Example File.todo.md"  \
      --content "# [ ] Example todo description."

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Example File.todo.md"  ]]
  }

  run "${_NB}" delete "home:Example Folder/Example todo description." --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.todo.md"    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: .*Example Folder/Example File.todo.md'

  # Prints output:

  [[ "${output}" =~ Deleted:                                    ]]
  [[ "${output}" =~ home:Example\ Folder/1                      ]]
  [[ "${output}" =~ ✔️                                           ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.todo.md  ]]
}

@test "'todo delete notebook:folder/folder/<title>' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.todo.md"                                \
      --content "# [ ] Sample todo description."

    "${_NB}" add "Example Folder/Sample Folder/Example File.todo.md"  \
      --content "# [ ] Example todo description."

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.todo.md"  ]]
  }

  run "${_NB}" delete "home:Example Folder/Sample Folder/Example todo description." --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.todo.md"    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: .*Example Folder/Sample Folder/Example File.todo.md'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                  ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                     ]]
  [[ "${output}" =~ ✔️                                                         ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.todo.md ]]
}
