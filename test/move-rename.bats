#!/usr/bin/env bats

load test_helper

_setup_rename() {
  "${_NB}" init
  "${_NB}" add "initial example name.md"
}

# only extension ##############################################################

@test "'move .<extension>' with root-level note changes the file extension while retaining the name." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" --content   "Example content."
  }

  run "${_NB}" move 1 .js <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0                            ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"     ]]
  [[    -f "${NB_DIR}/home/Example File.js"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*1.*].*\ .*Example\ File\.md.* ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*Example\ File\.js.*          ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*Example\ File\.js.*  ]]
}

# --to-title ##################################################################

@test "'move --to-title' with title and root-level bookmark renames to title." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.bookmark.md"                                                \
      --title     "Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"  \
      --content   "<https://example.test>"
  }

  run "${_NB}" move 1 --to-title <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0                                  ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.bookmark.md"  ]]
  [[    -f \
"${NB_DIR}/home/example_title__a_string•with_a_bunch_of_invalid_filename_characters_.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"             ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*1.*].*\ .*Example\ File\.bookmark.md.*\ \"Example\ Title:\  ]]
  [[ "${lines[0]}" =~ \
Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"        ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*example_title__a_string•with_a_bunch_of_invalid_filename_characters_.bookmark.md           ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*example_title__a_string•with_a_bunch_of_invalid_filename_characters_.bookmark.md.* ]]
  [[ "${lines[2]}" =~ \
 \"Example\ Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"          ]]
}

@test "'move --to-title' with title and root-level note renames to title." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"                                                         \
      --title     "Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"  \
      --content   "Example content."
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
To:\ \ \ \ \ \ \ .*example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md            ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*1.*].*\ .*example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md.*  ]]
  [[ "${lines[2]}" =~ \
 \"Example\ Title:\ A\*string•with/a\\bunch\|of\?invalid\<filename\"characters\>\"                    ]]
}

@test "'move --to-title' prints message with file with no title." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" move 1 --to-title

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1                            ]]

  # Does not move file:

  [[ -e "${NB_DIR}/home/Example File.md"        ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Move'
  ! git log | grep -q '\[nb\] Add'
  ! git log | grep -q '\[nb\] Delete'

  # Prints message:

  [[ "${lines[0]}" =~ Title\ not\ found\.       ]]
}

@test "'move --to-title' prints message with non-text file." {
  {
    "${_NB}" init
    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.pdf"

    [[ -e "${NB_DIR}/home/example.pdf"          ]]
  }

  run "${_NB}" move 1 --to-title

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1                            ]]

  # Does not move file:

  [[ -e "${NB_DIR}/home/example.pdf"            ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Move'
  ! git log | grep -q '\[nb\] Add'
  ! git log | grep -q '\[nb\] Delete'

  # Prints message:

  [[ "${lines[0]}" =~ Must\ be\ a\ text\ file\. ]]
}

# <filename> --to-bookmark ####################################################

@test "'move --to-bookmark' with note renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"          ]]
  [[    -e "${NB_DIR}/home/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  "${_NB}" index get_id "Example File.bookmark.md"

  [[ "$("${_NB}" index get_id "Example File.bookmark.md")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                 ]]
  [[ "${output}" =~ Example\ File.bookmark.md ]]
}

@test "'move 1 <name> --to-bookmark' with note renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" "New Name" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"      ]]
  [[    -e "${NB_DIR}/home/New Name.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  "${_NB}" index get_id "New Name.bookmark.md"

  [[ "$("${_NB}" index get_id "New Name.bookmark.md")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ New\ Name.bookmark.md ]]
}

@test "'move 1 New\ Name.demo --to-bookmark' discards extension and renames." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" "New Name.demo" --to-bookmark --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"      ]]
  [[    -e "${NB_DIR}/home/New Name.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  "${_NB}" index get_id "New Name.bookmark.md"

  [[ "$("${_NB}" index get_id "New Name.bookmark.md")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ New\ Name.bookmark.md ]]
}

# <filename> --to-note ########################################################

@test "'rename --to-note' with bookmark renames to updated default extension without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.bookmark.md"

    [[ -e "${NB_DIR}/home/Example File.bookmark.md" ]]

    "${_NB}" set default_extension "org"
  }

  run "${_NB}" move "Example File.bookmark.md" --to-note --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  [[    -e "${NB_DIR}/home/Example File.org"          ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  "${_NB}" index get_id "Example File.org"

  [[ "$("${_NB}" index get_id "Example File.org")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to         ]]
  [[ "${output}" =~ Example\ File.org ]]
}

@test "'rename --to-note' with bookmark renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.bookmark.md"

    [[ -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  }

  run "${_NB}" move "Example File.bookmark.md" --to-note --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  [[    -e "${NB_DIR}/home/Example File.md"          ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  cat "${NB_DIR}/home/.index"

  "${_NB}" index get_id "Example File.md"

  [[ "$("${_NB}" index get_id "Example File.md")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to         ]]
  [[ "${output}" =~ Example\ File.md  ]]
}

# no argument #################################################################

@test "'move' with no arguments exits with 1, does nothing, and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not move file:

  [[ -e "${NB_DIR}/home/Example File.md"    ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Move'
  ! git log | grep -q '\[nb\] Add'
  ! git log | grep -q '\[nb\] Delete'

  # Prints help:

  [[ "${lines[0]}" =~ Usage.*:  ]]
  [[ "${lines[1]}" =~ nb\ move  ]]
}

# <filename> ##################################################################

@test "'move' with <filename> argument moves without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" "EXAMPLE NEW NAME.org" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"       ]]
  [[   -e "${NB_DIR}/home/EXAMPLE NEW NAME.org"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  "${_NB}" index show

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.org')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.org  ]]
}

@test "'move' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"     ]]
  [[ ! -e "${NB_DIR}/home/EXAMPLE"             ]]
  [[   -e "${NB_DIR}/home/EXAMPLE NEW NAME.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.md ]]
}

@test "'move' bookmark with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.bookmark.md"

    [[ -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  }

  run "${_NB}" move "Example File.bookmark.md" "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Renames file:

  [[ ! -e "${NB_DIR}/home/Example File.bookmark.md"      ]]
  [[   -e "${NB_DIR}/home/EXAMPLE NEW NAME.bookmark.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.bookmark.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                       ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.bookmark.md  ]]
}

@test "'move' bookmark with extension <filename> argument uses target extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.bookmark.md"

    [[ -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  }

  run "${_NB}" move "Example File.bookmark.md" "EXAMPLE NEW NAME.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.bookmark.md" ]]
  [[    -e "${NB_DIR}/home/EXAMPLE NEW NAME.md"      ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.md ]]
}

@test "'move' note with bookmark extension <filename> argument uses target extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" move "Example File.md" "EXAMPLE NEW NAME.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Renames file:

  [[ !  -e "${NB_DIR}/home/Example File.md"              ]]
  [[    -e "${NB_DIR}/home/EXAMPLE NEW NAME.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.bookmark.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                       ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.bookmark.md  ]]
}

@test "'move' with existing <filename> exits with status 1." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"          ]]

    "${_NB}" add "EXAMPLE NEW NAME.org"

    [[ -e "${NB_DIR}/home/EXAMPLE NEW NAME.org"     ]]
  }

  run "${_NB}" move "Example File.md" "EXAMPLE NEW NAME.org" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 1                     ]]
  [[    "${output}" =~  'File already exists' ]]
  [[ -e "${NB_DIR}/home/EXAMPLE NEW NAME.org" ]]
}

# <id> ########################################################################

@test "'move <id>' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md" ]]
  }

  run "${_NB}" move 1 "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"      ]]
  [[    -e "${NB_DIR}/home/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.md ]]
}

@test "'<id> move' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" 1 move "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File.md"      ]]
  [[    -e "${NB_DIR}/home/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ EXAMPLE\ NEW\ NAME.md ]]
}

# <filename> --reset ##########################################################

@test "'move --reset' with <filename> argument renames without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md"

    [[ -e "${NB_DIR}/home/Example File.md"  ]]
  }

  run "${_NB}" rename "Example File.md" --reset --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example File.md"  ]]

  _files=($(ls "${NB_DIR}/home/"))
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

  "${_NB}" index get_id "${_files[0]}"

  [[ "$("${_NB}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to       ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <scope> #####################################################################

@test "'move <scope>:<id>' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example File.md"

    [[ -e "${NB_DIR}/one/Example File.md" ]]
  }

  run "${_NB}" move one:1 "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/one/Example File"         ]]
  [[    -e "${NB_DIR}/one/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                 ]]
  [[ "${output}" =~ one:1                     ]]
  [[ "${output}" =~ one:EXAMPLE\ NEW\ NAME.md ]]
}

@test "'<scope>:move <id>' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example File.md"

    [[ -e "${NB_DIR}/one/Example File.md" ]]
  }

  run "${_NB}" one:move 1 "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/one/Example File"         ]]
  [[    -e "${NB_DIR}/one/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                 ]]
  [[ "${output}" =~ one:EXAMPLE\ NEW\ NAME.md ]]
}

@test "'<scope>:<id> move' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example File.md"

    [[ -e "${NB_DIR}/one/Example File.md" ]]
  }

  run "${_NB}" one:1 move "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/one/Example File"         ]]
  [[    -e "${NB_DIR}/one/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                 ]]
  [[ "${output}" =~ one:EXAMPLE\ NEW\ NAME.md ]]
}

@test "'<id> <scope>:move' with extension-less <filename> argument uses source extension." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example File.md"

    [[ -e "${NB_DIR}/one/Example File.md" ]]
  }

  run "${_NB}" 1 one:move "EXAMPLE NEW NAME" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/one/Example File"         ]]
  [[    -e "${NB_DIR}/one/EXAMPLE NEW NAME.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/one/" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates index:

  [[ "$("${_NB}" index get_id 'EXAMPLE NEW NAME.md')" == '1' ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to                 ]]
  [[ "${output}" =~ one:EXAMPLE\ NEW\ NAME.md ]]
}

# help ########################################################################

@test "'help move' exits with status 0." {
  run "${_NB}" help move

  [[ ${status} -eq 0 ]]
}

@test "'help move' prints help information." {
  run "${_NB}" help move

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*:  ]]
  [[ "${lines[1]}" =~ nb\ move  ]]
}
