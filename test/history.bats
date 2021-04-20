#!/usr/bin/env bats

load test_helper

@test "'history' exits with status 0 and prints notebook history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                        ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ one.md     ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ two.md     ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ two.md    ]]
  [[    "${output}"  =~  \[nb\]\ Delete:\ one.md  ]]
}

@test "'history <filename>' with existing filename exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history two.md --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                        ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md     ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ two.md     ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ two.md    ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md  ]]
}

@test "'history <id>' with existing file exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history 2 --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                        ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md     ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ two.md     ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ two.md    ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md  ]]
}

@test "'history <title>' with existing file exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history second --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                        ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md     ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ two.md     ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ two.md    ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md  ]]
}

@test "'history <filename>' with deleted filename exits with status 0 and prints file history." {
  skip "TODO"
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history one.md --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                        ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ one.md     ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md     ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md    ]]
  [[    "${output}"  =~  \[nb\]\ Delete:\ one.md  ]]
}

@test "'history <filename>' with invalid filename exits with status 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force
  }

  run "${_NB}" history not-valid --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                     ]]
  [[    "${#lines[@]}"  -eq 1                     ]]
  [[    "${lines[0]}"   =~  Not\ found:           ]]
  [[    "${lines[0]}"   =~  not-valid             ]]
}
