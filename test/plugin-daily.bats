#!/usr/bin/env bats

load test_helper

# `daily --prev` ##############################################################

@test "'nb daily --prev' with no content and no existing note prints message." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"
  }

  run "${_NB}" daily --prev

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${output}"    ==  "Add the first daily note: nb daily <content>" ]]
}

@test "'nb daily --prev' with existing notes lists notes." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    "${_NB}" add                                      \
      --content   "[01:01:01] Example content one."   \
      --filename  "43210101.md"

    "${_NB}" add                                      \
      --content   "[02:02:02] Example content two."   \
      --filename  "43210202.md"

    "${_NB}" add                                      \
      --content   "[03:03:03] Example content three." \
      --filename  "43210303.md"
  }

  run "${_NB}" daily --prev

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  \
.*[.*2.*].*\ \[1\]\ 43210101.md\ ·\ \"\[01:01:01\]\ Example\ content\ one\.\"   ]]
  [[ "${lines[1]}"  =~  \
.*[.*1.*].*\ \[2\]\ 43210202.md\ ·\ \"\[02:02:02\]\ Example\ content\ two\.\"   ]]
  [[ "${lines[2]}"  =~  \
.*[.*0.*].*\ \[3\]\ 43210303.md\ ·\ \"\[03:03:03\]\ Example\ content\ three\.\" ]]
}

@test "'nb daily --prev <number>' shows notes." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    "${_NB}" add                                      \
      --content   "[01:01:01] Example content one."   \
      --filename  "43210101.md"

    "${_NB}" add                                      \
      --content   "[02:02:02] Example content two."   \
      --filename  "43210202.md"

    "${_NB}" add                                      \
      --content   "[03:03:03] Example content three." \
      --filename  "43210303.md"
  }

  run "${_NB}" daily --prev 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  \
.*43210202\.md.*:                       ]]
  [[ "${lines[1]}"  =~  \
\[02:02:02\]\ Example\ content\ two\.   ]]

  run "${_NB}" daily --prev 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  \
.*43210303\.md.*:                       ]]
  [[ "${lines[1]}"  =~  \
\[03:03:03\]\ Example\ content\ three\. ]]

  run "${_NB}" daily --prev 42

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1 ]]

  [[ "${lines[0]}"  =~  \
.*!.*\ Not\ found\.                     ]]
}

# `daily` #####################################################################

@test "'nb daily' with no content and no existing note prints message." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"
  }

  run "${_NB}" daily

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${output}"    ==  "Add the first note of the day: nb daily <content>" ]]
}

@test "'nb daily' with no content and existing note prints note contents." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    "${_NB}" daily "Example content one."
    "${_NB}" daily "Example content two."
  }

  run "${_NB}" daily

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  "${_NB}" show 1 --print

  [[ "${lines[0]}"  =~  \
.*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.md.*:             ]]
  [[ "${lines[1]}"  =~  \
\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]\ Example\ content\ one\. ]]
  [[ "${lines[2]}"  =~  \
\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]\ Example\ content\ two\. ]]
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
