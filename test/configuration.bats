#!/usr/bin/env bats

load test_helper

# configuration validation ####################################################

@test "'nb' with Bash 4 on macOS does not display prompt." {
  if [[ "${OSTYPE}" =~ ^darwin ]]
  then
    if [[ "${BASH_VERSINFO[0]:-}" == 3  ]]
    then
      NB_TEST_MOCK_TTY=1 NB_BASH_UPDATE_PROMPT_ENABLED=0 run "${_NB}"
    else
      NB_TEST_MOCK_TTY=1 run "${_NB}"
    fi

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[    "${status}"  -eq 0                            ]]

    [[ !  "${output}"  =~  !.*\ Update\ Bash.*          ]]
    [[ !  "${output}"   =~ Bash\ 3.2\ support\ enabled. ]]
    [[ !  "${output}"  =~  !.*\ Updating\ Bash.*\.\.\.  ]]
    [[ !  "${output}"  =~  Updated.*\ to\ .*Bash\ 5     ]]

    [[ ! -e "${NB_DIR}/.nb-bash-3-enabled"              ]]
  fi
}

@test "'nb' with Bash 3 on macOS displays prompt and updates Bash with affirmative response." {
  if [[ "${OSTYPE}" =~ ^darwin ]]
  then
    if [[ "${BASH_VERSINFO[0]:-}" == 3  ]]
    then
      NB_TEST_MOCK_TTY=1 run "${_NB}" <<< "y${_NEWLINE}"
    else
      NB_TEST_MOCK_TTY=1 NB_BASH_UPDATE_PROMPT_ENABLED=1 run "${_NB}" <<< "y${_NEWLINE}"
    fi

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"


    [[ "${status}"  -eq 0                               ]]

    [[    "${output}"  =~  !.*\ Update\ Bash.*          ]]
    [[ !  "${output}"   =~ Bash\ 3.2\ support\ enabled. ]]
    [[    "${output}"  =~  !.*\ Updating\ Bash.*\.\.\.  ]]
    [[    "${output}"  =~  Updated.*\ to\ .*Bash\ 5     ]]

    [[ ! -e "${NB_DIR}/.nb-bash-3-enabled"              ]]
  fi
}

@test "'nb' with Bash 3 on macOS displays prompt and does not update Bash with disaffirmative response." {
  if [[ "${OSTYPE}" =~ ^darwin ]]
  then
    if [[ "${BASH_VERSINFO[0]:-}" == 3  ]]
    then
      NB_TEST_MOCK_TTY=1 run "${_NB}" <<< "n${_NEWLINE}"
    else
      NB_TEST_MOCK_TTY=1 NB_BASH_UPDATE_PROMPT_ENABLED=1 run "${_NB}" <<< "n${_NEWLINE}"
    fi

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"


    [[ "${status}"  -eq 0                               ]]

    [[    "${output}"  =~  !.*\ Update\ Bash.*          ]]
    [[    "${output}"   =~ Bash\ 3.2\ support\ enabled. ]]
    [[ !  "${output}"  =~  !.*\ Updating\ Bash.*\.\.\.  ]]
    [[ !  "${output}"  =~  Updated.*\ to\ .*Bash\ 5     ]]

    [[   -e "${NB_DIR}/.nb-bash-3-enabled"              ]]
  fi
}

# .nbrc #######################################################################

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
