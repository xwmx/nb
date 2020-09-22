#!/usr/bin/env bats

load test_helper

# `notebooks show` ############################################################

@test "\`notebooks show\` with no id exits with 1 and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1      ]]
  [[ "${output}" =~ Usage ]]
}

@test "\`notebooks show example\` with exits with 1 and prints message." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                      ]]
  [[ "${output}" =~ Notebook\ not\ found  ]]
  [[ "${output}" =~ example               ]]
}

@test "\`notebooks show <id>\` exits with 0 and prints the notebook name." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" == "one" ]]
}

@test "\`notebooks show <path>\` exits with 0 and prints the notebook name." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show "${NB_DIR}/one"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" == "one" ]]
}

@test "\`notebooks show <selection>\` exits with 0 and prints the notebook name." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show one:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]

  run "${_NB}" notebooks show one:example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]
}

# `notebooks show --path` #####################################################

@test "\`notebooks show --path\` with exits with 0 and prints path." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
  }

  run "${_NB}" notebooks show one --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${output}" == "${NB_DIR}/one" ]]
}

# `notebooks show --display-name` #############################################

@test "\`notebooks show --display-name\` with exits with 0 and prints display name." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "long example"
  }

  run "${_NB}" notebooks show "long example" --display-name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${output}" == "long\ example" ]]
}
