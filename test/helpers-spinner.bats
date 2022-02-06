#!/usr/bin/env bats

load test_helper

@test "'_spinner()' displays color spinner for the duration of the specified process." {
  {
    (sleep 3) &
  }

  run "${_NB}" helpers spinner $!

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                   ]]
  [[    "${#lines[@]}"  -eq 1                   ]]
  [[ !  "${lines[0]}"   =~  \[\|\]              ]]
  [[    "${lines[0]}"   =~  \[.*\|.*\]          ]]
  [[    "${lines[0]}"   =~  \
.*\[.*\-.*\].*\ .*\[.*\/.*\].*\ .*\[.*\|.*\].*  ]]
}

@test "'_spinner() --no-color' displays nothing and waits for the duration of the specified process." {
  {
    (sleep 3) &
  }

  run "${_NB}" helpers spinner $! --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                   ]]
  [[ -z "${output}"                             ]]
}
