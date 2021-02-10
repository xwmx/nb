#!/usr/bin/env bats

load test_helper

@test "'list --per-page <limit> [--page <number>]' paginates list." {
  {
    "${_NB}" init

    local __number=
    for   __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done
  }

  # --per-page 3, first page

  run "${_NB}" search "title" --list --per-page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${lines[0]}"  =~  .*[.*8.*].*\ Title\ Eight ]]
  [[ "${lines[1]}"  =~  .*[.*5.*].*\ Title\ Five  ]]
  [[ "${lines[2]}"  =~  .*[.*4.*].*\ Title\ Four  ]]

  run "${_NB}" search "title" --list --per-page 3 --page 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${lines[0]}"  =~  .*[.*8.*].*\ Title\ Eight ]]
  [[ "${lines[1]}"  =~  .*[.*5.*].*\ Title\ Five  ]]
  [[ "${lines[2]}"  =~  .*[.*4.*].*\ Title\ Four  ]]

  run "${_NB}" search "title" --list --per-page 3 --page 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${lines[0]}"  =~  .*[.*8.*].*\ Title\ Eight ]]
  [[ "${lines[1]}"  =~  .*[.*5.*].*\ Title\ Five  ]]
  [[ "${lines[2]}"  =~  .*[.*4.*].*\ Title\ Four  ]]

  # --per-page 3 --page 2+

  run "${_NB}" search "title" --list --per-page 3 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  .*[.*9.*].*\ Title\ Nine    ]]
  [[ "${lines[1]}"  =~  .*[.*1.*].*\ Title\ One     ]]
  [[ "${lines[2]}"  =~  .*[.*7.*].*\ Title\ Seven   ]]

  run "${_NB}" search "title" --list --per-page 3 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${lines[0]}"  =~  .*[.*6.*].*\ Title\ Six   ]]
  [[ "${lines[1]}"  =~  .*[.*10.*].*\ Title\ Ten  ]]
  [[ "${lines[2]}"  =~  .*[.*3.*].*\ Title\ Three ]]

  run "${_NB}" search "title" --list --per-page 3 --page 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 1                         ]]

  [[ "${lines[0]}"  =~  .*[.*2.*].*\ Title\ Two   ]]

  # --per-page 5

  run "${_NB}" search "title" --list --per-page 5

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 5                         ]]

  [[ "${lines[0]}"  =~  .*[.*8.*].*\ Title\ Eight ]]
  [[ "${lines[1]}"  =~  .*[.*5.*].*\ Title\ Five  ]]
  [[ "${lines[2]}"  =~  .*[.*4.*].*\ Title\ Four  ]]
  [[ "${lines[3]}"  =~  .*[.*9.*].*\ Title\ Nine  ]]
  [[ "${lines[4]}"  =~  .*[.*1.*].*\ Title\ One   ]]

  run "${_NB}" search "title" --list --per-page 5 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 5                         ]]

  [[ "${lines[0]}"  =~  .*[.*7.*].*\ Title\ Seven ]]
  [[ "${lines[1]}"  =~  .*[.*6.*].*\ Title\ Six   ]]
  [[ "${lines[2]}"  =~  .*[.*10.*].*\ Title\ Ten  ]]
  [[ "${lines[3]}"  =~  .*[.*3.*].*\ Title\ Three ]]
  [[ "${lines[4]}"  =~  .*[.*2.*].*\ Title\ Two   ]]

  run "${_NB}" search "title" --list --per-page 5 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 0                         ]]
}
