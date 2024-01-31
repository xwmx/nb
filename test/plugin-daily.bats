#!/usr/bin/env bats

load test_helper

# `daily` #####################################################################

@test "'nb daily' with no content exits with 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"
  }

  run "${_NB}" daily

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1               ]]
  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  nb\ daily       ]]
}

@test "'nb daily <content>' without existing note adds new note with content." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    declare _target_filename=
    _target_filename="$(date "+%Y%m%d").md"
  }

  run "${_NB}" daily "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0 ]]

  "${_NB}" show 1 --print

  [[ "${output}"    =~  Added:\ .*[.*1.*].*\ .*${_target_filename}    ]]
  [[ "$("${_NB}" show 1 --print | wc -l | awk '$1=$1')" == 1          ]]
  [[ "$("${_NB}" show 1 --print)" =~ \
\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]\ Example\ content\.              ]]

}

@test "'nb daily <content>' with existing note adds content to existing note." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    declare _target_filename=
    _target_filename="$(date "+%Y%m%d").md"

    "${_NB}" daily "Example initial content."
  }

  run "${_NB}" daily "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0 ]]

  "${_NB}" show 1 --print

  [[ "${output}"    =~  Updated:\ .*[.*1.*].*\ .*${_target_filename}  ]]
  [[ "$("${_NB}" show 1 --print | wc -l | awk '$1=$1')" == 2          ]]
  [[ "$("${_NB}" show 1 --print | sed -n '1p')" =~ \
\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]\ Example\ initial\ content\.     ]]
  [[ "$("${_NB}" show 1 --print | sed -n '2p')" =~ \
\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]\ Example\ new\ content\.         ]]
}

# help ########################################################################

@test "'help example' exits with status 0 and prints usage." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"
  }

  run "${_NB}" help daily

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  nb\ daily       ]]
}
