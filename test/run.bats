#!/usr/bin/env bats

load test_helper

@test "\`run\` exits with status 0 and prints output." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"

    _files="$(ls "${_NOTEBOOK_PATH}/")"
  }

  run "${_NB}" run ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}  -eq 0           ]]
  [[ "${output}" == "${_files}" ]]
}

@test "\`run\` with no command exits with status 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
  }

  run "${_NB}" run

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}  -eq 1                   ]]
  [[ "${output}" =~ Command\ required\. ]]
}
