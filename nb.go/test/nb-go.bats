#!/usr/bin/env bats

load test_helper

@test "'nb.go' with no arguments exits with status 0 and prints ls output." {
  run "${_NBGO}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0       ]]
  [[ "${output}"  =~  nb\ add ]]
}
