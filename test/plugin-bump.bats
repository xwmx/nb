#!/usr/bin/env bats

load test_helper

# `bump` ###################################################################

@test "'nb bump' updates order of items in 'ls'." {
  {
    "${_NB}" init

    "${_NB}" set footer 0

    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/bump.nb-plugin"

    "${_NB}" add "File One.md"    --content "Example content one."
    "${_NB}" add "File Two.md"    --content "Example content two."
    "${_NB}" add "File Three.md"  --content "Example content three."
    "${_NB}" add "File Four.md"   --content "Example content four."
  }

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[3]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
  [[ "${lines[4]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[5]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]


  run "${_NB}" bump 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${#lines[@]}" -eq 1                                         ]]
  [[ "${lines[0]}"  =~  \
Bumped.*to\ top.*:.*\ .*\[.*2.*\].*\ .*File\ Two\.md              ]]

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[3]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[4]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
  [[ "${lines[5]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]

  run "${_NB}" bump 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${#lines[@]}" -eq 1                                         ]]
  [[ "${lines[0]}"  =~  \
Bumped.*to\ top.*:.*\ .*\[.*1.*\].*\ .*File\ One\.md              ]]

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]
  [[ "${lines[3]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[4]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[5]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
}

# `touch` alias ###############################################################

@test "'nb touch' updates order of items in 'ls'." {
  {
    "${_NB}" init

    "${_NB}" set footer 0

    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/bump.nb-plugin"

    "${_NB}" add "File One.md"    --content "Example content one."
    "${_NB}" add "File Two.md"    --content "Example content two."
    "${_NB}" add "File Three.md"  --content "Example content three."
    "${_NB}" add "File Four.md"   --content "Example content four."
  }

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[3]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
  [[ "${lines[4]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[5]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]


  run "${_NB}" touch 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${#lines[@]}" -eq 1                                         ]]
  [[ "${lines[0]}"  =~  \
Bumped.*\ to\ top.*:.*\ .*\[.*2.*\].*\ .*File\ Two\.md            ]]

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[3]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[4]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
  [[ "${lines[5]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]

  run "${_NB}" touch 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${#lines[@]}" -eq 1                                         ]]
  [[ "${lines[0]}"  =~  \
Bumped.*to\ top.*:.*\ .*\[.*1.*\].*\ .*File\ One\.md              ]]

  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${lines[0]}"  =~  home                                      ]]
  [[ "${lines[1]}"  =~  ----                                      ]]
  [[ "${lines[2]}"  =~  \
\[.*1.*\].*\ File\ One\.md\ ·\ \"Example\ content\ one\.\"        ]]
  [[ "${lines[3]}"  =~  \
\[.*2.*\].*\ File\ Two\.md\ ·\ \"Example\ content\ two\.\"        ]]
  [[ "${lines[4]}"  =~  \
\[.*4.*\].*\ File\ Four\.md\ ·\ \"Example\ content\ four\.\"      ]]
  [[ "${lines[5]}"  =~  \
\[.*3.*\].*\ File\ Three\.md\ ·\ \"Example\ content\ three\.\"    ]]
}

# help ########################################################################

@test "'help bump' exits with status 0 and prints usage." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/bump.nb-plugin"
  }

  run "${_NB}" help bump

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  nb\ bump        ]]
}
