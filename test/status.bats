#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'status <not-valid>' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" status "Sample Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                                     ]]
  [[ "${#lines[@]}" -eq 1                                                     ]]

  [[ "${lines[0]}"  =~  ^.*!.*\ Notebook\ not\ found:\ .*Sample\ Notebook.*$  ]]
}

# aliases #####################################################################

@test "'st' exits with 0 and prints current notebook status information." {
  {
    "${_NB}" init
  }

  run "${_NB}" st

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]

  [[ "${lines[0]}"  ==  "$(_color_primary "home")"  ]]
  [[ "${lines[1]}"  =~  [^-]----[^-]                ]]
  [[ "${lines[2]}"  ==  "status: unarchived"        ]]
  [[ "${lines[3]}"  ==  "remote: none"              ]]
  [[ "${lines[4]}"  ==  "git:    clean"             ]]
}

@test "'stat' exits with 0 and prints current notebook status information." {
  {
    "${_NB}" init
  }

  run "${_NB}" stat

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]

  [[ "${lines[0]}"  ==  "$(_color_primary "home")"  ]]
  [[ "${lines[1]}"  =~  [^-]----[^-]                ]]
  [[ "${lines[2]}"  ==  "status: unarchived"        ]]
  [[ "${lines[3]}"  ==  "remote: none"              ]]
  [[ "${lines[4]}"  ==  "git:    clean"             ]]
}

# status ######################################################################

@test "'status' exits with 0 and prints changes." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" archive

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    touch "${NB_DIR}/home/Example New File.md"

    printf "\\nNew content.\\n" >> "${NB_DIR}/home/Example File.md"
  }

  run "${_NB}" status

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                       ]]

  [[ "${lines[0]}"  ==  "$(_color_primary "home")"              ]]
  [[ "${lines[1]}"  =~  [^-]----[^-]                            ]]
  [[ "${lines[2]}"  ==  "status: archived"                      ]]
  [[ "${lines[3]}"  ==  "remote: ${_GIT_REMOTE_URL} (master)"   ]]
  [[ "${lines[4]}"  ==  "git:    dirty"                         ]]
  [[ "${lines[5]}"  ==  "changes"                               ]]
  [[ "${lines[6]}"  =~  [^-]-------[^-]                         ]]
  [[ "${lines[7]}"  =~  \ M\ \"Example\ File\.md\"              ]]
  [[ "${lines[8]}"  =~  \?\?\ \"Example\ New\ File\.md\"        ]]
}

@test "'status <notebook>' exits with 0 and prints status information for <notebook>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" status "Example Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                       ]]

  [[ "${lines[0]}"  ==  "$(_color_primary "Example Notebook")"  ]]
  [[ "${lines[1]}"  =~  [^-]----------------[^-]                ]]
  [[ "${lines[2]}"  ==  "status: unarchived"                    ]]
  [[ "${lines[3]}"  ==  "remote: none"                          ]]
  [[ "${lines[4]}"  ==  "git:    clean"                         ]]
}

@test "'status' exits with 0 and prints current notebook status information." {
  {
    "${_NB}" init
  }

  run "${_NB}" status

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]

  [[ "${lines[0]}"  ==  "$(_color_primary "home")"  ]]
  [[ "${lines[1]}"  =~  [^-]----[^-]                ]]
  [[ "${lines[2]}"  ==  "status: unarchived"        ]]
  [[ "${lines[3]}"  ==  "remote: none"              ]]
  [[ "${lines[4]}"  ==  "git:    clean"             ]]
}

# help ########################################################################

@test "'help status' exits with 0 and prints help information." {
  run "${_NB}" help status

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]

  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  \ \ nb\ status  ]]
}
