#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"
  cd "${NB_DIR}" || return 1
}

# <name> validation ###########################################################

@test "'notebooks export <reserved>' exits with 1 and prints error message." {
  {
    "${_NB}" init

    cd "${_TMP_DIR}"

    _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  for __name in "${_names[@]}"
  do
    run "${_NB}" notebooks import                     \
      "${NB_TEST_BASE_PATH}/fixtures/Example Folder"  \
      "${__name}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    ls "${NB_DIR}"

    [[ ${status} -eq 1                  ]]
    [[ "${lines[0]}" =~ Name\ reserved  ]]
    [[ "${lines[0]}" =~ ${__name}       ]]

    [[ ! "${output}" =~ "Imported"      ]]
    "${_NB}" notebooks | grep -q -v 'example'
  done
}

# no argument #################################################################

@test "'notebooks import' with no arguments exits with status 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks import

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

@test "'notebooks import' with valid directory <path> imports." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks import "${NB_TEST_BASE_PATH}/fixtures/Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls "${NB_DIR}"

  [[ ${status} -eq 0                            ]]
  [[ -d "${NB_DIR}/Example Folder"              ]]
  [[ "${lines[0]}" =~ "Imported"                ]]
  "${_NB}" notebooks | grep -q 'Example Folder'
}

@test "'notebooks import' with relative <path> imports." {
  {
    "${_NB}" init

    mkdir "${_TMP_DIR}/example"

    touch "${_TMP_DIR}/example/file.md"

    cd "${_TMP_DIR}"
  }

  run "${_NB}" notebooks import example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls "${NB_DIR}"

  [[ ${status} -eq 0                      ]]
  [[ -d "${NB_DIR}/example"               ]]
  [[ "${lines[0]}" =~ "Imported"          ]]
  "${_NB}" notebooks | grep -q 'example'
}

@test "'notebooks import' with existing notebook imports with unique name." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Example Folder"

    [[ -d "${NB_DIR}/Example Folder" ]]
  }

  run "${_NB}" notebooks import "${NB_TEST_BASE_PATH}/fixtures/Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls "${NB_DIR}"

  [[ ${status} -eq 0                              ]]
  [[ -d "${NB_DIR}/Example Folder-1"              ]]
  [[ "${lines[0]}" =~ "Imported"                  ]]
  "${_NB}" notebooks | grep -q 'Example Folder-1'
}

@test "'notebooks import' with invalid file <path> argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks import "${NB_TEST_BASE_PATH}/fixtures/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}
  "
  ls "${NB_DIR}"

  [[ ${status} -eq 1                    ]]
  [[ ! -e "${NB_DIR}/Example Folder"    ]]
  [[ "${lines[0]}" =~ "Not a directory" ]]
}

@test "'notebooks import' with valid <name> argument imports." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks import                     \
    "${NB_TEST_BASE_PATH}/fixtures/Example Folder"  \
    "example-notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls "${NB_DIR}"

  [[ ${status} -eq 0                        ]]
  [[ -d "${NB_DIR}/example-notebook"        ]]
  [[ -d "${NB_DIR}/example-notebook/.git"   ]]
  [[ -f "${NB_DIR}/example-notebook/.index" ]]
  [[ "${lines[0]}" =~ "Imported"            ]]
  "${_NB}" notebooks | grep -q 'example'
}

@test "'notebooks import' with existing notebook <name> imports with unique name." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "example"

    [[ -d "${NB_DIR}/example" ]]
  }

  run "${_NB}" notebooks import                     \
    "${NB_TEST_BASE_PATH}/fixtures/Example Folder"  \
    "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls "${NB_DIR}"

  [[ ${status} -eq 0                        ]]
  [[ -d "${NB_DIR}/example-1"               ]]
  [[ "${lines[0]}" =~ "Imported"            ]]
  "${_NB}" notebooks | grep -q 'example-1'
}
