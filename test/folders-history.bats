#!/usr/bin/env bats

load test_helper

@test "'history <folder>/' (slash) exits with status 0 and prints folder history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder/ --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                    ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md                                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md                              ]]

  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/Sample\ Folder/one.md  ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/one.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/two.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ Example\ Folder/one.md                ]]
  [[    "${output}"  =~  \[nb\]\ Delete:\ Example\ Folder/two.md              ]]
}

@test "'history <folder>' (no slash) exits with status 0 and prints folder history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                    ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md                                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md                              ]]

  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/Sample\ Folder/one.md  ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/one.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/two.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ Example\ Folder/one.md                ]]
  [[    "${output}"  =~  \[nb\]\ Delete:\ Example\ Folder/two.md              ]]
}

@test "'history <folder>/<filename>' exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder/one.md --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                    ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md                                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md                              ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/Sample\ Folder/one.md  ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/one.md                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/two.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ Example\ Folder/one.md                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ Example\ Folder/two.md              ]]
}

@test "'history <folder>/<id>' exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder/1 --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                    ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md                                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md                              ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/Sample\ Folder/one.md  ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/one.md                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/two.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ Example\ Folder/one.md                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ Example\ Folder/two.md              ]]
}

@test "'history <folder>/<title>' exits with status 0 and prints file history." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder/first\ nested --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                    ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ one.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ two.md                                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Edit:\ two.md                                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ one.md                              ]]

  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/Sample\ Folder/one.md  ]]
  [[    "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/one.md                 ]]
  [[ !  "${output}"  =~  \[nb\]\ Add:\ Example\ Folder/two.md                 ]]
  [[    "${output}"  =~  \[nb\]\ Edit:\ Example\ Folder/one.md                ]]
  [[ !  "${output}"  =~  \[nb\]\ Delete:\ Example\ Folder/two.md              ]]
}

@test "'history <folder>/<not-valid>' exits with status 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add    "one.md" --title "first"
    "${_NB}" add    "two.md" --title "second"
    "${_NB}" edit   "two.md" --content "Edited content."
    "${_NB}" delete "one.md" --force

    "${_NB}" add    "Example Folder/one.md" --title "first nested"
    "${_NB}" add    "Example Folder/two.md" --title "second nested"
    "${_NB}" edit   "Example Folder/one.md" --content "Edited content."
    "${_NB}" delete "Example Folder/two.md" --force

    "${_NB}" add    "Example Folder/Sample Folder/one.md" --title "first deeply nested"
  }

  run "${_NB}" history Example\ Folder/not-valid --git-log

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                                                 ]]
  [[    "${#lines[@]}"  -eq 1                                                 ]]

  [[    "${lines[0]}"   =~  Not\ found:\ .*Example\ Folder/not-valid          ]]
}
