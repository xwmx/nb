#!/usr/bin/env bats

load test_helper

# `unset` #####################################################################

@test "'unset' with no argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1     ]]
  [[ "${output}"  =~  Usage ]]
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
