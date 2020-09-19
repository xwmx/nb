#!/usr/bin/env bats

load test_helper

@test "\`env\` exits with status 0 and prints output." {
  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(tput colors): '%s'\\n" "$(tput colors)"

  [[ ${status}  -eq 0       ]]
  [[ "${output}" =~ EDITOR  ]]
}

# EDITOR ######################################################################

@test "\`env\` with EDITOR sets editor." {
  EDITOR='example-editor' run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[3]}" =~ EDITOR=example-editor ]]
}

@test "\`env\` with VISUAL sets editor." {
  EDITOR='' VISUAL='example-visual' run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[3]}" =~ EDITOR=example-visual ]]
}
