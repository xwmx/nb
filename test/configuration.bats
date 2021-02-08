#!/usr/bin/env bats

load test_helper

@test "'nb' recognizes setting in .nbrc." {
  {
    "${_NB}" init

    printf "export NB_COLOR_PRIMARY=123\\n" >> "${NBRC_PATH}"
  }

  run "${_NB}" set get color_primary

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NBRC_PATH}"


  [[ "${status}"    -eq 0   ]]

  [[ "${lines[0]}"  =~  123 ]]
}

@test "'nb' resolves .nbrc with symlinked relative path." {
  {
    "${_NB}" init

    printf "export NB_COLOR_PRIMARY=123\\n" >> "${NBRC_PATH}"

    [[ "$("${_NB}" set get color_primary)" == 123 ]]

    _pwd="${PWD}"

    mkdir "${_TMP_DIR}/Symlink Test"

    cd "${_TMP_DIR}/Symlink Test"

    ln -s ../.nbrc .nbrc

    cd "${_pwd}"

    export NBRC_PATH="${_TMP_DIR}/Symlink Test/.nbrc"
  }

  NBRC_PATH="${_TMP_DIR}/Symlink Test/.nbrc" run "${_NB}" set get color_primary

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]

  [[ "${lines[0]}"  =~  123 ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                           ]]

  [[ "${output}"  =~  NBRC_PATH=.*${_TMP_DIR}/.nbrc ]]
}
