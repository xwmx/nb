#!/usr/bin/env bats

load test_helper

@test "\`env\` exits with status 0 and prints output." {
  run "${_NOTES}" env

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(tput colors): '%s'\\n" "$(tput colors)"

  [[ ${status}  -eq 0       ]]
  [[ "${output}" =~ EDITOR  ]]
}
