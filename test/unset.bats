#!/usr/bin/env bats

load test_helper

# help ########################################################################

@test "'help unset' exits with 0 and prints help information." {
  run "${_NB}" help unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]

  [[ "${lines[0]}"  =~  Usage.*\:     ]]
  [[ "${lines[1]}"  =~  \ \ nb\ unset ]]
}

# `reset` #####################################################################

@test "'reset' with argument unsets, prints, and exits." {
  {
    "${_NB}" init

    run "${_NB}" settings set EDITOR sample

    [[ "$(EDITOR='' "${_NB}" settings get EDITOR)" == 'sample'  ]]
    [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="sample"'             ]]
  }

  run "${_NB}" reset EDITOR

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc:\\n'%s'\\n" "$(cat "${NBRC_PATH}")"

  [[    "${status}"             -eq 0                           ]]
  [[ !  "$(cat "${NBRC_PATH}")" =~  'EDITOR="sample"'           ]]
  [[ !  "$(cat "${NBRC_PATH}")" =~  'EDITOR="sample"'           ]]
  [[    "${output}"             =~  EDITOR                      ]]
  [[    "${output}"             =~  restored\ to\ the\ default  ]]
  [[ !  "${output}"             =~  sample                      ]]
}

# `unset` #####################################################################

@test "'unset' with no argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1             ]]
  [[ "${lines[0]}"  =~  Usage.*\:     ]]
  [[ "${lines[1]}"  =~  \ \ nb\ unset ]]
}

@test "'unset' with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" unset EXAMPLE

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                     ]]
  [[ "${output}"  =~ Setting\ not\ found\:  ]]
  [[ "${output}"  =~ EXAMPLE                ]]
}

@test "'unset' with argument unsets, prints, and exits." {
  {
    "${_NB}" init

    run "${_NB}" settings set EDITOR sample

    [[ "$(EDITOR='' "${_NB}" settings get EDITOR)" == 'sample'  ]]
    [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="sample"'             ]]
  }

  run "${_NB}" unset EDITOR

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc:\\n'%s'\\n" "$(cat "${NBRC_PATH}")"

  [[    "${status}"             -eq 0                           ]]
  [[ !  "$(cat "${NBRC_PATH}")" =~  'EDITOR="sample"'           ]]
  [[ !  "$(cat "${NBRC_PATH}")" =~  'EDITOR="sample"'           ]]
  [[    "${output}"             =~  EDITOR                      ]]
  [[    "${output}"             =~  restored\ to\ the\ default  ]]
  [[ !  "${output}"             =~  sample                      ]]
}
