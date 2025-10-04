#!/usr/bin/env bats

load test_helper

@test "'env' exits with status 0 and prints output." {
  run "${_NB}" env

  printf "\${status}:       '%s'\\n" "${status}"
  printf "\${output}:       '%s'\\n" "${output}"
  printf "\$(tput colors):  '%s'\\n" "$(tput colors)"

  [[ "${status}"  -eq 0         ]]
  [[ "${output}"  =~  NB_EDITOR ]]
}

# EDITOR ######################################################################

@test "'env' with EDITOR sets editor." {
  EDITOR='example-editor' run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[29]}" =~ NB_EDITOR=example-editor     ]]
}

@test "'env' with NB_EDITOR sets editor." {
  EDITOR='' NB_EDITOR='example-nb-editor' VISUAL='' run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[29]}" =~ NB_EDITOR=example-nb-editor  ]]
}

@test "'env' with VISUAL sets editor." {
  EDITOR='' VISUAL='example-visual' run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[29]}" =~ NB_EDITOR=example-visual     ]]
}
