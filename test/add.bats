#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# no argument #################################################################

@test "'add' with no arguments creates new note file created with \$EDITOR." {
  {
    "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# notebook: scoped ############################################################

@test "'add notebook:' creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/example"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/example/${_files[0]}")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+.md ]]
}

@test "'notebook:add' creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example

  }

  run "${_NB}" example:add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/example"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/example/${_files[0]}")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+.md ]]
}

# <filename> argument #########################################################

@test "'add' with filename argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" == 1                     ]]
  [[ "${_files[0]}" == "example-filename.md"  ]]

  grep -q '# Example Title' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:              ]]
  [[ "${output}" =~ example-filename.md ]]
}

@test "'add' with .org filename argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example-filename.org" --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0                          ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" == 1                     ]]
  [[ "${_files[0]}" == "example-filename.org" ]]

  grep -q 'Example content.' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:                ]]
  [[ "${output}" =~ example-filename.org  ]]
}

# <content> argument ##########################################################

@test "'add' with content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with scope and content argument creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add Example
  }

  run "${_NB}" Example:add "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/Example/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/Example"/*

  # Creates git commit:

  cd "${NB_DIR}/Example" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/Example/.index" ]]

  diff                        \
    <(ls "${NB_DIR}/Example") \
    <(cat "${NB_DIR}/Example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+.md ]]
}

@test "'add' with URL content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "${_BOOKMARK_URL}" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with scope and URL content argument creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add Example
  }

  run "${_NB}" Example:add "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/Example/"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/Example/${_files[0]}")" == "${_BOOKMARK_URL}" ]]

  # Creates git commit:

  cd "${NB_DIR}/Example" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/Example/.index" ]]

  diff                        \
    <(ls "${NB_DIR}/Example") \
    <(cat "${NB_DIR}/Example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+.md ]]
}

@test "'add' with email address content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example@example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "example@example.com" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with 'http:' non-URL content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "http: this is not a URL"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "http: this is not a URL" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with 'example.com' common TLD domain content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "example.com" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# --content option ############################################################

@test "'add' with --content option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/home"/*

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with URL --content option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  grep -q 'file' "${NB_DIR}/home"/*
  grep -q 'fixtures' "${NB_DIR}/home"/*

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --content option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --filename option ###########################################################

@test "'add' with --filename option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename example.org

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.org)" ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with --filename option overrides content or filename argument." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "sample.md" --filename example.org

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.org)" ]]
  ! grep -q '# mock_editor' "${NB_DIR}/home"/*
  grep -q 'sample.md' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with extensionless --filename option creates file without extension." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NB_DIR}/home" || return 1

  [[   -n "$(ls example)"             ]]
  [[   -e "${NB_DIR}/home/example"    ]]
  [[ ! -e "${NB_DIR}/home/example.md" ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --filename option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1        ]]

  cd "${NB_DIR}/home" || return 1

  ls "${NB_DIR}/home/"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --title option ##############################################################

@test "'add' with --title option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add \
    --title "Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(
    ls example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md
  )" ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" =~ \
        \#\ Example\ Title\:\ A\*string•with\/a\\bunch\|of\?invalid\<filename\"characters\> ]]

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --title option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --title

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1        ]]

  cd "${NB_DIR}/home" || return 1

  ls "${NB_DIR}/home/"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --type option ###############################################################

@test "'add --type org' with content argument creates a new .org note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --type org

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '* Content' "${NB_DIR}/home"/*

  [[ "${_files[0]}" =~ org$ ]]
}

@test "'add --type ''' without argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --type

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --encrypt option ############################################################

@test "'add --encrypt' with content argument creates a new .enc note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --encrypt --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ ${status} -eq 0                                                            ]]
  [[ "${#_files[@]}" -eq 1                                                      ]]
  [[ "${_files[0]}" =~ enc$                                                     ]]
  [[ "$(file "${NB_DIR}/home/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]
}

@test "'add --encrypt' with invalid encryption tool displays error message." {
  {
    "${_NB}" init
  }

  NB_ENCRYPTION_TOOL="not-valid" run "${_NB}" add  "* Content" --encrypt --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ ${status} -eq 1                              ]]
  [[ "${#_files[@]}" -eq 0                        ]]
  [[ "${output}" =~ Encryption\ tool\ not\ found: ]]
  [[ "${output}" =~ not-valid                     ]]
}

# --password option ###########################################################

@test "'add --password' without argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --encrypt --password

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# piped #######################################################################

@test "'add' with piped content creates new note without errors." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | \"${_NB}\" add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Piped' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add --type org' with piped content creates a new .org note file." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | \"${_NB}\" add --type org"

  [[ ${status} -eq 0        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Piped' "${NB_DIR}/home"/*

  [[ "${_files[0]}" =~ org$ ]]
}

@test "'add --type ''' with piped content exits with 1." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | \"${_NB}\" add --type"

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# aliases ####################################################################

@test "'a' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}


@test "'create' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}


@test "'new' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# help ########################################################################

@test "'help add' exits with status 0." {
  run "${_NB}" help add

  [[ ${status} -eq 0 ]]
}

@test "'help add' returns usage information." {
  run "${_NB}" help add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~  nb\ add ]]
}
