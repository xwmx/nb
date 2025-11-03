#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

# current notebook resolution #################################################

@test "'nb' resolves current notebook." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Notebook One"
    "${_NB}" notebooks add "Notebook Two"

    [[ -d "${NB_DIR}/home"          ]]
    [[ -d "${NB_DIR}/Notebook One"  ]]
    [[ -d "${NB_DIR}/Notebook Two"  ]]
  }

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep "^NB_NOTEBOOK_PATH=${NB_DIR}/home$"
  printf "%s\\n" "${output}" | grep "^_LOCAL_NOTEBOOK_PATH=$"
  printf "%s\\n" "${output}" | grep "^_GLOBAL_NOTEBOOK_PATH=${NB_DIR}/home$"
}

@test "'nb' resolves current notebook to value in NB_DIR/.current." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Notebook One"
    "${_NB}" notebooks add "Notebook Two"

    [[ -d "${NB_DIR}/home"          ]]
    [[ -d "${NB_DIR}/Notebook One"  ]]
    [[ -d "${NB_DIR}/Notebook Two"  ]]

    printf "Notebook One" > "${NB_DIR}/.current"
  }

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep "^NB_NOTEBOOK_PATH=${NB_DIR}/Notebook One$"
  printf "%s\\n" "${output}" | grep "^_LOCAL_NOTEBOOK_PATH=$"
  printf "%s\\n" "${output}" | grep "^_GLOBAL_NOTEBOOK_PATH=${NB_DIR}/Notebook One$"
}

@test "'NB_NOTEBOOK_DIR=<notebook> nb' overrides value in NB_DIR/.current." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Notebook One"
    "${_NB}" notebooks add "Notebook Two"

    [[ -d "${NB_DIR}/home"          ]]
    [[ -d "${NB_DIR}/Notebook One"  ]]
    [[ -d "${NB_DIR}/Notebook Two"  ]]

    printf "Notebook One" > "${NB_DIR}/.current"
  }

  NB_NOTEBOOK_PATH="${NB_DIR}/Notebook Two" run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep "^NB_NOTEBOOK_PATH=${NB_DIR}/Notebook Two$"
  printf "%s\\n" "${output}" | grep "^_LOCAL_NOTEBOOK_PATH=$"
  printf "%s\\n" "${output}" | grep "^_GLOBAL_NOTEBOOK_PATH=${NB_DIR}/Notebook Two$"
}

@test "'nb' resolves to local notebook when present." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Notebook One"
    "${_NB}" notebooks add "Notebook Two"

    [[ -d "${NB_DIR}/home"          ]]
    [[ -d "${NB_DIR}/Notebook One"  ]]
    [[ -d "${NB_DIR}/Notebook Two"  ]]

    printf "Notebook One" > "${NB_DIR}/.current"

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init <<< "y${_NEWLINE}"

    "${_NB}" env | grep "^_CURRENT_WORKING_DIR=${_TMP_DIR}/Local Notebook$"
  }

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep "^NB_NOTEBOOK_PATH=${_TMP_DIR}/Local Notebook$"
  printf "%s\\n" "${output}" | grep "^_LOCAL_NOTEBOOK_PATH=${_TMP_DIR}/Local Notebook$"
  printf "%s\\n" "${output}" | grep "^_GLOBAL_NOTEBOOK_PATH=${NB_DIR}/Notebook One"
}
