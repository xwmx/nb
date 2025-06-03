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

    "${_NB}" add                    \
      --filename  "43210101.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-01-01

## 01:01:01

Example content one.
HEREDOC
      )"

    "${_NB}" add                    \
      --filename  "43210202.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-02-02

## 02:02:02

Example content two.
HEREDOC
      )"


    "${_NB}" add                    \
      --filename  "43210303.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-03-03

## 03:03:03

Example content three.
HEREDOC
      )"
    }

  run "${_NB}" daily --prev

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  .*[.*0.*].*\ \[3\]\ Daily\ 4321-03-03 ]]
  [[ "${lines[1]}"  =~  .*[.*1.*].*\ \[2\]\ Daily\ 4321-02-02 ]]
  [[ "${lines[2]}"  =~  .*[.*2.*].*\ \[1\]\ Daily\ 4321-01-01 ]]
}

@test "'nb daily --prev <number>' shows notes." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    "${_NB}" add                    \
      --filename  "43210101.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-01-01

## 01:01:01

Example content one.
HEREDOC
      )"

    "${_NB}" add                    \
      --filename  "43210202.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-02-02

## 02:02:02

Example content two.
HEREDOC
      )"


    "${_NB}" add                    \
      --filename  "43210303.md"     \
      --content   "$(cat <<HEREDOC
# Daily 4321-03-03

## 03:03:03

Example content three.
HEREDOC
      )"
  }

  run "${_NB}" daily --prev 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ "${lines[0]}"  =~  \
.*\[.*2.*\].*43210202\.md.*:  ]]
  [[ "${lines[1]}"  =~  \
.*\#.*Daily\ 4321-02-02       ]]
  [[ "${lines[2]}"  =~  \
.*\#\#.*02:02:02              ]]
  [[ "${lines[3]}"  =~  \
Example\ content\ two\.       ]]

  run "${_NB}" daily --prev 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ "${lines[0]}"  =~  \
.*\[.*3.*\].*43210303\.md.*:  ]]
  [[ "${lines[1]}"  =~  \
.*\#.*Daily\ 4321-03-03       ]]
  [[ "${lines[2]}"  =~  \
.*\#\#.*03:03:03              ]]
  [[ "${lines[3]}"  =~  \
Example\ content\ three\.     ]]

  run "${_NB}" daily --prev 42

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1     ]]

  [[ "${lines[0]}"  =~  \
.*!.*\ Not\ found\.           ]]
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

  [[ "${lines[0]}"  =~  \
.*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.md.*:     ]]
  [[ "${lines[1]}"  =~  \
\#.*Daily.*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ]]
  [[ "${lines[2]}"  =~  \
\#\#.*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]                ]]
  [[ "${lines[3]}"  =~  \
Example\ content\ one\.                               ]]
  [[ "${lines[4]}"  =~  \
\#\#.*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]                ]]
  [[ "${lines[5]}"  =~  \
Example\ content\ two\.                               ]]
}

@test "'nb daily \"<content>\"' (with quotes) without existing note adds new note with content." {
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

  [[ "${output}"    =~  Added:\ .*[.*1.*].*\ .*${_target_filename}  ]]
  [[ "$("${_NB}" show 1 --print | wc -l | awk '$1=$1')" == 5        ]]
  [[ "$("${_NB}" show 1 --print)" =~ \
\#\#.*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]                              ]]
  [[ "$("${_NB}" show 1 --print)" =~ Example\ content\.             ]]
}

@test "'nb daily <content>' (without quotes) without existing note adds new note with content." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    declare _target_filename=
    _target_filename="$(date "+%Y%m%d").md"
  }

  run "${_NB}" daily Example note content.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0 ]]

  "${_NB}" show 1 --print

  [[ "${output}"    =~  Added:\ .*[.*1.*].*\ .*${_target_filename}  ]]
  [[ "$("${_NB}" show 1 --print | wc -l | awk '$1=$1')" == 5        ]]
  [[ "$("${_NB}" show 1 --print)" =~ \
\#\#.*[0-9][0-9]:[0-9][0-9]:[0-9][0-9]                              ]]
  [[ "$("${_NB}" show 1 --print)" =~ Example\ note\ content\.       ]]
}

@test "'nb daily \"<content>\"' (with quotes) with existing note adds content to existing note." {
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

  "${_NB}" show 1 --print --no-color | grep -q \
"# Daily \d\d\d\d-\d\d-\d\d

## \d\d:\d\d:\d\d

Example initial content.

## \d\d:\d\d:\d\d

Example new content."
}

@test "'nb daily <content>' (without quotes) with existing note adds content to existing note." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/daily.nb-plugin"

    declare _target_filename=
    _target_filename="$(date "+%Y%m%d").md"

    "${_NB}" daily "Example initial content."
  }

  run "${_NB}" daily Example new content.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0 ]]

  "${_NB}" show 1 --print

  [[ "${output}"    =~  Updated:\ .*[.*1.*].*\ .*${_target_filename}  ]]

  "${_NB}" show 1 --print --no-color | grep -q \
"# Daily \d\d\d\d-\d\d-\d\d

## \d\d:\d\d:\d\d

Example initial content.

## \d\d:\d\d:\d\d

Example new content."
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
