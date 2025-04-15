#!/usr/bin/env bats

load test_helper

@test "'run' exits with status 0 and prints output." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"

    _files="$(ls "${NB_DIR}/home/")"
  }

  run "${_NB}" run ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0           ]]
  [[ "${output}"  ==  "${_files}" ]]
}

@test "'run' with no command exits with status 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" run

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                   ]]
  [[ "${output}"  =~  Command\ required\. ]]
}

@test "'run' with non-existent command exits with status 1 and prints message." {
  {
    "${_NB}" init
  }

  run -127 "${_NB}" run not-a-valid-command

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 127 ]]
  [[ "${output}"  =~  Command\ not\ found:\ .*not-a-valid-command ]] ||
    [[ "${output}"  =~  bash:\ line\ 1:\ not-a-valid-command:\ command\ not\ found ]]
}
