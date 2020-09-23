#!/usr/bin/env bats

load test_helper

@test "\`git checkpoint\` with no message and clean repo does not create new commit." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${_NOTEBOOK_PATH}/${_filename}"
    [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q -v '\[nb\] Commit'
}

@test "\`git checkpoint\` with no message and dirty repo creates a new commit with the default message." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${_NOTEBOOK_PATH}/${_filename}"
    [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Commit'
}

@test "\`git checkpoint <message>\` with dirty repo creates a new commit with <message>." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${_NOTEBOOK_PATH}/${_filename}"
    [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint "Unique message."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  git log
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q 'Unique message.'
}
