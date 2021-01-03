#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'delete' with no argument exits with 1, prints help, and does not delete." {
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    [[ -e "${NB_DIR}/home/example.md" ]]
  }

  run "${_NB}" delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1:

  [[ "${status}" -eq 1                    ]]

  # Does not delete file:

  [[ -e "${NB_DIR}/home/example.md"       ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Delete'

  # Prints help information:

  [[ "${lines[0]}" =~ Usage\:             ]]
  [[ "${lines[1]}" =~ \ \ nb\ delete      ]]
}

# .gitignored #################################################################

@test "'delete <selector>' with gitignored file returns 0 and deletes file." {
  {
    "${_NB}" init

    "${_NB}" add "sample.md" --content "Sample content."

    printf "example.md\\n" > "${NB_DIR}/home/.gitignore"

    "${_NB}" git add --all
    "${_NB}" git checkpoint

    printf "Example content.\\n" > "${NB_DIR}/home/example.md"

    [[ -e "${NB_DIR}/home/example.md"  ]]

    "${_NB}" git check-ignore "example.md" > /dev/null
  }

  run "${_NB}" delete "example.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0                       ]]
  [[ ! -e "${NB_DIR}/home/example.md"             ]]
  [[      "${output}" =~ Deleted\:.*2.*example.md ]]
}

# <selector> ##################################################################

@test "'delete <selector>' with empty repo exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" delete 1 --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1             ]]
  [[ "${lines[0]}"  =~  Not\ found\:  ]]
  [[ "${lines[0]}"  =~  1             ]]
}

@test "'delete <selector> (no force)' returns 0 and deletes file." {
  skip "Determine how to test interactive prompt."
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    [[ -e "${NB_DIR}/home/example.md"  ]]
  }

  run "${_NB}" delete "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0           ]]
  [[ ! -e "${NB_DIR}/home/example.md" ]]
}

# <scope>:<selector> ##########################################################

@test "'delete <scope>:<selector>' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add "example.md"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list  --no-id --filenames

    "${_NB}" use "home"

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" delete one:example.md --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}" =~   Deleted:              ]]
  [[ "${output}" =~   one:1.*one:example.md ]]
}

@test "'<scope>:delete <selector>' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add "example.md"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list  --no-id --filenames

    "${_NB}" use "home"

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" one:delete "example.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}" =~   Deleted:              ]]
  [[ "${output}" =~   one:1.*one:example.md ]]
}

@test "'<scope>:<selector> delete' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add "example.md"


    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list  --no-id --filenames

    "${_NB}" use "home"

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" one:example.md delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}" =~   Deleted:              ]]
  [[ "${output}" =~   one:1.*one:example.md ]]
}

@test "'<selector> <scope>:delete' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add "example.md"

    printf "home:list\\n" && "${_NB}" home:list --no-id --filenames
    printf "one:list\\n"  && "${_NB}" one:list  --no-id --filenames

    "${_NB}" use "home"

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" example.md one:delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}" =~   Deleted:              ]]
  [[ "${output}" =~   one:1.*one:example.md ]]
}

# <filename> ##################################################################

@test "'delete' with <filename> argument deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/example.md"     ]]
  }

  run "${_NB}" delete example.md --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                             ]]
  [[ "${output}" =~   Deleted:                      ]]
  [[ "${output}" =~   1.*example.md.*\"mock_editor  ]]
}

# <id> ########################################################################

@test "'delete <id>' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/example.md"  ]]
  }

  run "${_NB}" delete 1 --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                             ]]
  [[ "${output}" =~   Deleted:                      ]]
  [[ "${output}" =~   1.*example.md.*\"mock_editor  ]]
}

@test "'<id> delete' with deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/example.md"     ]]
  }

  run "${_NB}" 1 delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                             ]]
  [[ "${output}" =~   Deleted:                      ]]
  [[ "${output}" =~   1.*example.md.*\"mock_editor  ]]
}

# <path> ######################################################################

@test "'delete' with <path> argument deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "example.md"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/example.md" ]]
  }

  run "${_NB}" delete "${NB_DIR}/home/example.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                             ]]
  [[ "${output}" =~   Deleted:                      ]]
  [[ "${output}" =~   1.*example.md.*\"mock_editor  ]]
}

# <title> #####################################################################

@test "'delete' with <title> argument deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --title "Example Title"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/example.md"     ]]
  }

  run "${_NB}" delete "Example Title" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes note file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                               ]]
  [[ "${output}" =~   Deleted:                        ]]
  [[ "${output}" =~   1.*example.md.*\"Example\ Title ]]
}

# <folder> #################################################################

@test "'delete' with <folder> argument deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/Example Folder"

    _original_index="$(cat "${NB_DIR}/home/.index")"

    [[ -e "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" delete "Example Folder" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/example.md"     ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[    "$(ls "${NB_DIR}/home")"  == "$(cat "${NB_DIR}/home/.index")" ]]
  [[    "${_original_index}"      != "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${status}" -eq  0                         ]]
  [[ "${output}" =~   Deleted:                  ]]
  [[ "${output}" =~   1.*📂.*Example\\\ Folder  ]]
}

# help ########################################################################

@test "'help delete' exits with status 0." {
  run "${_NB}" help delete

  [[ "${status}" -eq 0 ]]
}

@test "'help delete' prints help information." {
  run "${_NB}" help delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:"    ]]
  [[ "${lines[1]}" =~ nb\ delete  ]]
}
