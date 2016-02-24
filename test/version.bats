#!/usr/bin/env bats

load test_helper

@test "\`notes version\` returns with 0 status." {
  run "${_NOTES}" --version
  [[ "${status}" -eq 0 ]]
}

@test "\`notes version\` prints a version number." {
  run "${_NOTES}" --version
  printf "'%s'" "${output}"
  echo "${output}" \
    | grep -q '[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+'
}

@test "\`notes --version\` returns with 0 status." {
  run "${_NOTES}" --version
  [[ "${status}" -eq 0 ]]
}

@test "\`notes --version\` prints a version number." {
  run "${_NOTES}" --version
  printf "'%s'" "${output}"
  echo "${output}" \
    | grep -q '[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+'
}
