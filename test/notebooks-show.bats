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

@test "\`notebooks show <selector>\` exits with 0 and prints the notebook name." {
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

# `notebooks show --escaped` ##################################################

@test "\`notebooks show --escaped\` with exits with 0 and prints display name." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "long example"
  }

  run "${_NB}" notebooks show "long example" --escaped

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${output}" == "long\ example" ]]
}

# `notebooks show --filename` #################################################

@test "\`notebooks show --filename\` prints a unique filename." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" notebooks show "home" --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]

  run "${_NB}" add "example.md" --content "Example"

  run "${_NB}" notebooks show "home" --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]
}

@test "\`notebooks show --filename <filename>\` prints a unique filename." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" notebooks show "home" --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" add "example.md" --content "Example"

  run "${_NB}" notebooks show "home" --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-2.md  ]]
}
