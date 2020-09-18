#!/usr/bin/env bats

load test_helper

@test "\`version\` returns with 0 status." {
  run "${_NB}" --version

  [[ "${status}" -eq 0 ]]
}

@test "\`version\` prints a version number." {
  run "${_NB}" --version

  printf "'%s'" "${output}"

  echo "${output}" \
    | grep -q '[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+'
}

@test "\`--version\` returns with 0 status." {
  run "${_NB}" --version

  [[ "${status}" -eq 0 ]]
}

@test "\`--version\` prints a version number." {
  run "${_NB}" --version

  printf "'%s'" "${output}"

  echo "${output}" \
    | grep -q '[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+'
}
