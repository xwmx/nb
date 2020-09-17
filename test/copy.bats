#!/usr/bin/env bats

load test_helper

# `copy <name>` ###############################################################

@test "\`copy <name>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md")" ]]
}

@test "\`copy <name>\` with binary file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md"   \
      --title "Example"             \
      --content "Example content."  \
      --encrypt                     \
      --password password

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md.enc")" ]]

  [[ "$("${_NB}" show example.md.enc --password password --print --no-color)" =~ \
     Example\ content\. ]]
  [[ "$("${_NB}" show example-1.md.enc --password password --print --no-color)" =~ \
     Example\ content\. ]]
}

# `copy <id>` #################################################################

@test "\`copy <id>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy 1

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md")" ]]
}

@test "\`copy <id>\` with binary file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md"   \
      --title "Example"             \
      --content "Example content."  \
      --encrypt                     \
      --password password

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy 1

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md.enc")" ]]

  [[ "$("${_NB}" show example.md.enc --password password --print --no-color)" =~ \
     Example\ content\. ]]
  [[ "$("${_NB}" show example-1.md.enc --password password --print --no-color)" =~ \
     Example\ content\. ]]
}

# `copy <title>` ##############################################################

@test "\`copy <title>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy Example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md")" ]]
}

# `copy <invalid>` ###############################################################

@test "\`copy <invalid>\` exits with error." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "not-valid"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1             ]]
  [[ "${lines[0]}" =~ Not\ found  ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" == 1 ]]
}

# `copy <selection>` filenames ################################################

@test "\`copy <name>\` with text file copies the note with sequential names." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" copy "example.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-2.md  ]]

  run "${_NB}" copy "example-1.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-1-1.md  ]]

  run "${_NB}" copy "example-1.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-1-2.md  ]]

  run "${_NB}" copy "example-2.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-2-1.md  ]]

  run "${_NB}" copy "example-2.md"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-2-2.md  ]]
}

@test "\`copy <name>\` with binary file copies the file with sequential names." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md"   \
      --title "Example"             \
      --content "Example content."  \
      --encrypt                     \
      --password password

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  run "${_NB}" copy "example.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-2.md.enc  ]]

  run "${_NB}" copy "example-1.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-1-1.md.enc  ]]

  run "${_NB}" copy "example-1.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-1-2.md.enc  ]]

  run "${_NB}" copy "example-2.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-2-1.md.enc  ]]

  run "${_NB}" copy "example-2.md.enc"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-2-2.md.enc  ]]
}
