#!/usr/bin/env bats

load test_helper

# edge cases ##################################################################

@test "'move <notebook-1>:<id> <notebook-2>:<folder>/' with <notebook-1> as current moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" move "home:1" "Example Notebook:Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"                            ]]
  [[   -f "${NB_DIR}/Example Notebook/Sample Folder/Example File.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Example Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  Moving:\ \ \ .*\[.*1.*\].*\ .*Example\ File.md  ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Example\ Notebook:Sample\ Folder/Example\ File.md    ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Example\ Notebook:Sample\ Folder/Example\ File.md         ]]
}

@test "'move <notebook-1>:<filename> <notebook-2>:<folder>/' with <notebook-1> as current moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" move "home:Example File.md" "Example Notebook:Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"                            ]]
  [[   -f "${NB_DIR}/Example Notebook/Sample Folder/Example File.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Example Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  Moving:\ \ \ .*\[.*1.*\].*\ .*Example\ File.md  ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Example\ Notebook:Sample\ Folder/Example\ File.md    ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Example\ Notebook:Sample\ Folder/Example\ File.md         ]]
}

@test "'move <notebook-1>:<filename> <notebook-2>:<folder>/' without either as current moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"
  }

  run "${_NB}" move "home:Example File.md" "Example Notebook:Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"                            ]]
  [[   -f "${NB_DIR}/Example Notebook/Sample Folder/Example File.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Example Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  Moving:\ \ \ .*\[.*1.*\].*\ .*home:Example\ File.md ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Example\ Notebook:Sample\ Folder/Example\ File.md        ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Example\ Notebook:Sample\ Folder/Example\ File.md             ]]
}

# only extension ##############################################################

@test "'move .<extension>' with nested note changes the file extension while retaining the name and folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Example File.md" \
      --content   "Example content."
  }

  run "${_NB}" move Example\ Folder/Sample\ Folder/1 .js <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0                                                      ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"  ]]
  [[    -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.js"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*1.*].*\ .*Example\ Folder/Sample\ Folder/Example\ File\.md.* ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*Example\ Folder/Sample\ Folder/Example\ File\.js.*          ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*Example\ Folder/Sample\ Folder/Example\ File\.js.*  ]]
}

# --to-note ###############################################################

@test "'move --to-note' with nested <filename> argument renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add  "Example Folder/Sample Folder/Example File.bookmark.md" \
      --content   "Example content."

    [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  }

  run "${_NB}" rename                                       \
    "Example Folder/Sample Folder/Example File.bookmark.md" \
    --to-note <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"    -eq 0                   ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]
  [[    -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"          ]]


  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  declare _item_id=
  _item_id="$(
    "${_NB}" index get_id                   \
      "Example File.md"                     \
      "${NB_DIR}/home/Example Folder/Sample Folder"
  )"

  [[ "${_item_id}"  ==  "1"                 ]]

  # Prints output:

  [[ "${output}"    =~  Moved\ to                                       ]]
  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/Example\ File.md ]]
}

# --to-bookmark ###############################################################

@test "'move --to-bookmark' with nested <filename> argument renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add  "Example Folder/Sample Folder/Example File.md"      \
      --content   "Example content."

    [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" rename "Example Folder/Sample Folder/Example File.md"  \
    --to-bookmark <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"    -eq 0                   ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"          ]]
  [[    -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  declare _item_id=
  _item_id="$(
    "${_NB}" index get_id                   \
      "Example File.bookmark.md"            \
      "${NB_DIR}/home/Example Folder/Sample Folder"
  )"

  [[ "${_item_id}"  ==  "1"                 ]]

  # Prints output:

  [[ "${output}"    =~  Moved\ to                                                 ]]
  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
}

# --reset #####################################################################

@test "'move --reset' with nested <filename> argument renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add  "Example Folder/Sample Folder/Example File.md"      \
      --content   "Example content."

    [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" rename "Example Folder/Sample Folder/Example File.md"  \
    --reset <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"    -eq 0                   ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"  ]]

  _files=($(ls "${NB_DIR}/home/Example Folder/Sample Folder/"))
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  [[ "${_files[0]}" =~ [A-Za-z0-9]+.md      ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  declare _item_id=
  _item_id="$(
    "${_NB}" index get_id \
      "${_files[0]}"      \
      "${NB_DIR}/home/Example Folder/Sample Folder"
  )"

  [[ "${_item_id}"  ==  "1"                 ]]

  # Prints output:

  [[ "${output}"    =~  Moved\ to                                       ]]
  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/[A-Za-z0-9]+.md  ]]
}

# --to-title ##################################################################

@test "'move --to-title' with title and nested note renames to title." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Example File.md"  \
      --content   "Example content."                              \
      --title                                                     \
"Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"     ]]

    declare _target_filename="example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md"
  }

  run "${_NB}" move 1/1/1 --to-title <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0                        ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"      ]]
  [[    -f "${NB_DIR}/home/Example Folder/Sample Folder/${_target_filename}"  ]]


  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*1.*].*\ .*Example\ File\.md.*\ \"Example\ Title:\     ]]
  [[ "${lines[0]}" =~ \
Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"  ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*${_target_filename}            ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*${_target_filename}.*  ]]
  [[ "${lines[2]}" =~ \
 \"Example\ Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"  ]]
}

@test "'move --to-title' with title and root-level note renames to title." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"   \
      --content   "Example content."  \
      --title                         \
"Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"
  }

  run "${_NB}" move 1 --to-title <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0                            ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"     ]]
  [[    -f \
"${NB_DIR}/home/example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md"    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*1.*].*\ .*Example\ File\.md.*\ \"Example\ Title:\     ]]
  [[ "${lines[0]}" =~ \
Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"  ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md  ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*${_target_filename}.*  ]]
  [[ "${lines[2]}" =~ \
 \"Example\ Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"  ]]
}

# intermediate folders ########################################################

@test "'move notebook:folder/<id>' moves across notebooks and creates intermediate folders." {
  {
    "${_NB}" init
    "${_NB}" add "Test Folder/Sample File.bookmark.md"  \
      --title   "Sample Title"                          \
      --content "<https://1.example.test>"

    "${_NB}" notebooks add "one"

    [[   -d "${NB_DIR}/home/Test Folder"                                              ]]
    [[   -f "${NB_DIR}/home/Test Folder/Sample File.bookmark.md"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ ! -e "${NB_DIR}/one/Example Folder"                                            ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder"                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder"                  ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder/Example File.md"  ]]
  }

  run "${_NB}" move                                                 \
    "Test Folder/1"                                                 \
    "one:Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -d "${NB_DIR}/home/Test Folder"                                              ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
  [[   -d "${NB_DIR}/one/Example Folder"                                            ]]
  [[   -d "${NB_DIR}/one/Example Folder/Sample Folder"                              ]]
  [[   -d "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder"                  ]]
  [[   -f "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder/Example File.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/one" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                        ]]
  [[ "${output}" =~ one:Example\ Folder/Sample\ Folder/Demo\ Folder/1                 ]]
  [[ "${output}" =~ one:Example\ Folder/Sample\ Folder/Demo\ Folder/Example\ File.md  ]]
}

@test "'move folder/<id>' moves and creates intermediate folders." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample File.bookmark.md"   \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"


    [[   -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[   -f "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]
  }

  run "${_NB}" move                                             \
    "Example Folder/1"                                          \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -d "${NB_DIR}/home/Example Folder"                                           ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
  [[   -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
  [[   -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
  [[   -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                    ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/1                 ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/Example\ File.md  ]]
}

# error handling ##############################################################

@test "'move folder/<filename>' with invalid filename returns with error and message." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move             \
    "Example Folder/not-valid"  \
    "Example Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not move file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Not\ found:               ]]
  [[ "${output}" =~ Example\ Folder/not-valid ]]
}

# into folder/ ################################################################

@test "'move <notebook>:<selector> <notebook>:folder/' with existing folder moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder" --type folder

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[   -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]
  }

  run "${_NB}" move           \
    "Sample File.bookmark.md" \
    "Example Folder/"         \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[   -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                ]]
  [[ "${output}" =~ Example\ Folder/1                         ]]
  [[ "${output}" =~ Example\ Folder/Sample\ File.bookmark.md  ]]
}

@test "'move <selector> folder/' creates folder and moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]
  }

  run "${_NB}" move           \
    "Sample File.bookmark.md" \
    "Example Folder/"         \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[   -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                ]]
  [[ "${output}" =~ Example\ Folder/1                         ]]
  [[ "${output}" =~ Example\ Folder/Sample\ File.bookmark.md  ]]
}

@test "'move <notebook>:<selector> <notebook>:folder/' moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    "${_NB}" notebooks add "two"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -d "${NB_DIR}/two/Example Folder"                          ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/Sample File.bookmark.md"  ]]
  }

  run "${_NB}" move                 \
    "home:Sample File.bookmark.md"  \
    "two:Example Folder/"           \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -d "${NB_DIR}/two/Example Folder"                          ]]
  [[   -e "${NB_DIR}/two/Example Folder/Sample File.bookmark.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                    ]]
  [[ "${output}" =~ two:Example\ Folder/1                         ]]
  [[ "${output}" =~ two:Example\ Folder/Sample\ File.bookmark.md  ]]
}

# <filename> ##################################################################

@test "'move notebook:folder/folder/<filename>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder"                                          ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "two:Example Folder/example.md"                               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]
  [[   -e "${NB_DIR}/two/Example Folder/.index"                                   ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ two:Example\ Folder/1           ]]
  [[ "${output}" =~ two:Example\ Folder/example.md  ]]
}

@test "'move folder/<filename>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                           \
    "Example Folder/Example File.bookmark.md" \
    "Example Folder/example.md"               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<filename>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                         \
    "Example Folder/Sample Folder/Example File.bookmark.md" \
    "Example Folder/Sample Folder/example.md"               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<filename>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                                         \
    "Example Folder/Sample Folder/Example File.bookmark.md" \
    "Example Folder/example.md"                             \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<filename>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                                 \
    "home:Example Folder/Example File.bookmark.md"  \
    "home:Example Folder/example.md"                \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<filename>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "home:Example Folder/Sample Folder/example.md"                \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<filename>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "home:Example Folder/example.md"                              \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

# <id> ########################################################################

@test "'move notebook:folder/folder/<id>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                       \
    "home:Example Folder/Sample Folder/1" \
    "two:Example Folder/example.md"       \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ two:Example\ Folder/1           ]]
  [[ "${output}" =~ two:Example\ Folder/example.md  ]]
}

@test "'move folder/<id>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move             \
    "Example Folder/1"          \
    "Example Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<id>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                           \
    "Example Folder/Sample Folder/1"          \
    "Example Folder/Sample Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<id>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                   \
    "Example Folder/Sample Folder/1"  \
    "Example Folder/example.md"       \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<id>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                   \
    "home:Example Folder/1"           \
    "home:Example Folder/example.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<id>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                 \
    "home:Example Folder/Sample Folder/1"           \
    "home:Example Folder/Sample Folder/example.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<id>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                       \
    "home:Example Folder/Sample Folder/1" \
    "home:Example Folder/example.md"      \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

# <title> #####################################################################

@test "'move notebook:folder/folder/<title>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "two:Example Folder/example.md"                   \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/<title>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                 \
    "Example Folder/Example Title"  \
    "Example Folder/example.md"     \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<title>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                               \
    "Example Folder/Sample Folder/Example Title"  \
    "Example Folder/Sample Folder/example.md"     \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<title>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                               \
    "Example Folder/Sample Folder/Example Title"  \
    "Example Folder/example.md"                   \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<title>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                     \
    "home:Example Folder/Example Title" \
    "home:Example Folder/example.md"    \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<title>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "home:Example Folder/Sample Folder/example.md"    \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<title>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "home:Example Folder/example.md"                  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}
