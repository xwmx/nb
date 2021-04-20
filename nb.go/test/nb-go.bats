#!/usr/bin/env bats

load test_helper

@test "'nb.go' with no arguments exits with status 0 and prints ls output." {
  {
    "${_NB}" init
  }

  run "${_NBGO}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "%s\\n" "${_NBGO}"
  printf "%s\\n" "${_NB}"
  printf "%s\\n" "${NB_TEST_BASE_PATH}"
  printf "%s\\n" "${BATS_TEST_DIRNAME}"
  printf "%s\\n" "${NB_DIR}"

  [[ "${status}"  -eq 0       ]]
  [[ "${output}"  =~  nb\ add ]]
}
