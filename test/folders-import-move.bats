#!/usr/bin/env bats

load test_helper

# import move <path> <folder>/ ################################################

@test "'import move <path> <folder>' (no slash) with existing folder imports file." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder

    [[ ! -e "${NB_DIR}/home/example.md"                 ]]
    [[   -e "${NB_DIR}/home/Example Folder"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"  ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md"           ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folder:

  [[ ! -e "${NB_DIR}/home/sample.md"                  ]]
  [[   -e "${NB_DIR}/home/Example Folder"             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/example.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md"           ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:
  [[ "${output}" =~ Imported                    ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'import move <path> <folder>/<folder>' (no slash) with existing folder imports file." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder" --type folder

    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[   -e "${NB_DIR}/home/Example Folder"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"  ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md" ]]
}

  run "${_NB}" import move                      \
    "${_TMP_DIR}/fixtures/example.md"  \
    "Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folders:

    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[   -e "${NB_DIR}/home/Example Folder"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder"             ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"  ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/example.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md" ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  diff                                                  \
    <(ls "${NB_DIR}/home/Example Folder/Sample Folder") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md ]]
}

@test "'import move <path> <folder>/' (slash) imports file." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/example.md"                 ]]
    [[ ! -e "${NB_DIR}/home/Example Folder"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"  ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md"           ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folder:

  [[ ! -e "${NB_DIR}/home/sample.md"                  ]]
  [[   -e "${NB_DIR}/home/Example Folder"             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/example.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md"           ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported                    ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'import move <path> <folder>/<folder>/' (slash) imports file." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"  ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md" ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Folder/Sample Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folders:

    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[   -e "${NB_DIR}/home/Example Folder"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder"             ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"  ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/example.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md" ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  diff                                                  \
    <(ls "${NB_DIR}/home/Example Folder/Sample Folder") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md ]]
}

# # import move <path> <folder>/<filename> ####################################

@test "'import move' with valid <path> and <filename> imports file." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/sample.md"        ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md" ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "sample.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file:

  [[   -e "${NB_DIR}/home/sample.md"  ]]
  [[ ! -e "${NB_DIR}/home/sample.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/sample.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md" ]]

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported  ]]
  [[ "${output}" =~ sample.md ]]
}

@test "'import move' with valid <path> and <folder>/<filename> imports file." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/sample.md"                ]]
    [[ ! -e "${NB_DIR}/home/Example Folder"           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/sample.md" ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md"         ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Folder/sample.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folder:

  [[ ! -e "${NB_DIR}/home/sample.md"                  ]]
  [[   -e "${NB_DIR}/home/Example Folder"             ]]
  [[   -e "${NB_DIR}/home/Example Folder/sample.md"   ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.pdf" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/sample.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md"           ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported                  ]]
  [[ "${output}" =~ Example\ Folder/sample.md ]]
}

@test "'import move' with valid <path> and <folder>/<folder>/<filename> imports file." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/sample.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/sample.md"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/sample.md" ]]

    cp -R "${NB_TEST_BASE_PATH}/fixtures" "${_TMP_DIR}/fixtures"

    [[   -f "${_TMP_DIR}/fixtures/example.md" ]]
  }

  run "${_NB}" import move            \
    "${_TMP_DIR}/fixtures/example.md" \
    "Example Folder/Sample Folder/sample.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Creates file and folders:

    [[ ! -e "${NB_DIR}/home/sample.md"                              ]]
    [[   -e "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/sample.md"               ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder"           ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/sample.md" ]]

  diff                                                \
    <(cat "${NB_TEST_BASE_PATH}/fixtures/example.md") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/sample.md")

  # Moves from original location:

  [[ ! -f "${_TMP_DIR}/fixtures/example.md" ]]

  # Adds to indexes:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  diff                                                  \
    <(ls "${NB_DIR}/home/Example Folder/Sample Folder") \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Import'

  # Prints output:

  [[ "${output}" =~ Imported                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/sample.md  ]]
}
