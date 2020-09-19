#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"
  mkdir -p "${NB_DIR}/two"
  cd "${NB_DIR}" || return 1
}

@test "\`notebooks export\` with no arguments exits with status 1 and prints help." {
  {
    run "${_NB}" init
  }

  run "${_NB}" notebooks export

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "\`notebooks export\` with valid <name> exports to current directory." {
  {
    run "${_NB}" init
  }

  run "${_NB}" notebooks add "example"

  [[ -d "${NB_DIR}/example"     ]]
  [[ ! -d "${_TMP_DIR}/example" ]]

  cd "${_TMP_DIR}"

  run "${_NB}" notebooks export "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                ]]
  [[ -d "${_TMP_DIR}/example"       ]]
  [[ -d "${_TMP_DIR}/example/.git"  ]]
  [[ "${lines[0]}" =~ "Exported"    ]]
}

@test "\`notebooks export\` with valid <name> exports to current directory uniquely." {
  {
    run "${_NB}" init

    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example"     ]]

    mkdir -p "${_TMP_DIR}/example"
    [[ -d "${_TMP_DIR}/example"   ]]

    cd "${_TMP_DIR}"
  }

  run "${_NB}" notebooks export "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                  ]]
  [[ -d "${_TMP_DIR}/example-1"       ]]
  [[ -d "${_TMP_DIR}/example-1/.git"  ]]
  [[ "${lines[0]}" =~ "Exported"      ]]
}

@test "\`notebooks export\` with invalid <name> exits with 1." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example" ]]
    cd "${_TMP_DIR}"
  }

  run "${_NB}" notebooks export "not valid"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 1                  ]]
  [[ ! -d "${_TMP_DIR}/example"       ]]
  [[ ! -d "${_TMP_DIR}/example/.git"  ]]
  [[ "${lines[0]}" =~ "not found"     ]]
}

@test "\`notebooks export\` with valid <name> and <path> exports." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example"     ]]
    [[ ! -d "${_TMP_DIR}/example" ]]
  }

  run "${_NB}" notebooks export "example" "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                ]]
  [[ -d "${_TMP_DIR}/example"       ]]
  [[ -d "${_TMP_DIR}/example/.git"  ]]
  [[ "${lines[0]}" =~ "Exported"    ]]
}

@test "\`notebooks export\` with valid <name> and <path> exports uniquely." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example"     ]]
    mkdir -p "${_TMP_DIR}/example"
    [[ -d "${_TMP_DIR}/example"   ]]
  }

  run "${_NB}" notebooks export "example" "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                  ]]
  [[ -d "${_TMP_DIR}/example-1"       ]]
  [[ -d "${_TMP_DIR}/example-1/.git"  ]]
  [[ "${lines[0]}" =~ "Exported"      ]]
}

@test "\`notebooks export\` with valid <name> and <path> ending in existing name exports." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example"     ]]
    mkdir -p "${_TMP_DIR}/example"
    [[ -d "${_TMP_DIR}/example"   ]]
  }

  run "${_NB}" notebooks export "example" "${_TMP_DIR}/sample-example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                      ]]
  [[ -d "${_TMP_DIR}/sample-example"      ]]
  [[ -d "${_TMP_DIR}/sample-example/.git" ]]
  [[ "${lines[0]}" =~ "Exported"          ]]
}

@test "\`notebooks export\` with valid <name> and relative <path> exports." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example"       ]]
    mkdir -p "${_TMP_DIR}/subfolder"
    [[ -d "${_TMP_DIR}/subfolder"   ]]
    cd "${_TMP_DIR}"
  }

  run "${_NB}" notebooks export "example" "subfolder/local-notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                                ]]
  [[ -d "${_TMP_DIR}/subfolder/local-notebook"      ]]
  [[ -d "${_TMP_DIR}/subfolder/local-notebook/.git" ]]
  [[ "${lines[0]}" =~ "Exported"                    ]]
}
