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

  printf "\${status}: '%s'\\n" "${status}"
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

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md.enc")" ]]

  [[ "$(
        "${_NB}" show example.md.enc --password password --print --no-color
      )" =~ Example\ content\. ]]
  [[ "$(
        "${_NB}" show example-1.md.enc --password password --print --no-color
      )" =~ Example\ content\. ]]
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

  printf "\${status}: '%s'\\n" "${status}"
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

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md.enc")" ]]

  [[ "$(
        "${_NB}" show example.md.enc --password password --print --no-color
      )" =~ Example\ content\. ]]
  [[ "$(
        "${_NB}" show example-1.md.enc --password password --print --no-color
      )" =~ Example\ content\. ]]
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

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md")" ]]
}

# `copy <invalid>` ###############################################################

@test "\`copy <invalid>\` exits with error message." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "not-valid"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1             ]]
  [[ "${lines[0]}" =~ Not\ found  ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" == 1 ]]
}

# `copy <directory>` ##########################################################

@test "\`copy <directory>\` exits with error message." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"

    cp -R "${BATS_TEST_DIRNAME}/fixtures/Example Folder" "${_NOTEBOOK_PATH}/example"

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1               ]]
  [[ "${lines[0]}" =~ Not\ a\ file  ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))

  [[ "${#_files[@]}" == 1 ]]
}

# `copy <selector>` filenames #################################################

@test "\`copy <name>\` with text file copies the note with sequential names." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" copy "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-2.md  ]]

  run "${_NB}" copy "example-1.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-1-1.md  ]]

  run "${_NB}" copy "example-1.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-1-2.md  ]]

  run "${_NB}" copy "example-2.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Added           ]]
  [[ "${lines[0]}" =~ example-2-1.md  ]]

  run "${_NB}" copy "example-2.md"

  printf "\${status}: '%s'\\n" "${status}"
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

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  run "${_NB}" copy "example.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ Added             ]]
  [[ "${lines[0]}" =~ example-2.md.enc  ]]

  run "${_NB}" copy "example-1.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-1-1.md.enc  ]]

  run "${_NB}" copy "example-1.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-1-2.md.enc  ]]

  run "${_NB}" copy "example-2.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-2-1.md.enc  ]]

  run "${_NB}" copy "example-2.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ Added               ]]
  [[ "${lines[0]}" =~ example-2-2.md.enc  ]]
}

# `<selector>` copy alternative ###############################################

@test "\`<id> copy\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" 1 copy

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR}/home/example.md")" == \
     "$(_get_hash "${NB_DIR}/home/example-1.md")" ]]
}

# `copy <scope:selector>` #####################################################

@test "\`copy <scope>:<id>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0               ]]
    [[ -e "${NB_DIR}/one/example.md"  ]]
  }; _setup

  run "${_NB}" copy one:1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR}/one/example.md")" == \
     "$(_get_hash "${NB_DIR}/one/example-1.md")" ]]
}

@test "\`<scope>:<id> copy\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0               ]]
    [[ -e "${NB_DIR}/one/example.md"  ]]
  }; _setup

  run "${_NB}" one:1 copy

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR}/one/example.md")" == \
     "$(_get_hash "${NB_DIR}/one/example-1.md")" ]]
}

# `<scope>:copy <selector>` ###################################################

@test "\`<scope>:copy <id>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0               ]]
    [[ -e "${NB_DIR}/one/example.md"  ]]
  }; _setup

  run "${_NB}" one:copy 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR}/one/example.md")" == \
     "$(_get_hash "${NB_DIR}/one/example-1.md")" ]]
}

@test "\`<id> <scope>:copy\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0               ]]
    [[ -e "${NB_DIR}/one/example.md"  ]]
  }; _setup

  run "${_NB}" 1 one:copy

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR}/one/example.md")" == \
     "$(_get_hash "${NB_DIR}/one/example-1.md")" ]]
}

# duplicate ###################################################################

@test "\`duplicate <id>\` with text file copies file." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" duplicate 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${lines[0]}" =~ Added         ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/example.md")" == \
     "$(_get_hash "${NB_DIR_2}/home/example-1.md")" ]]
}

# help ########################################################################

@test "\`copy\` with no argument exits with status 1 and prints usage." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" copy

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage\:   ]]
  [[ "${lines[1]}" =~ nb\ copy  ]]
}


@test "\`help copy\` exits with status 0 and prints usage." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/copy.nb-plugin"
    run "${_NB}" add "example.md" --title "Example" --content "Example content."

    [[ "${status}" == 0 ]]
  }; _setup

  run "${_NB}" help copy

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  [[ "${lines[0]}" =~ Usage\:   ]]
  [[ "${lines[1]}" =~ nb\ copy  ]]
}
