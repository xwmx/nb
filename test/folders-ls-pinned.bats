#!/usr/bin/env bats

load test_helper

export NB_PINNED_PATTERN="#pinned"

# search-based pinning ########################################################

@test "'NB_PINNED_PATTERN ls [<folder>/]' (slash) prints items tagged with #pinned in the current folder." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two."
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two. #pinned"

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]

  [[    "${lines[0]}"   =~  home                                  ]]
  [[    "${lines[1]}"   =~  ----                                  ]]
  [[    "${lines[2]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[3]}"   =~  \
          [.*4*].*\ 📂\ Example\ Folder                           ]]
  [[    "${lines[4]}"   =~  \
          [.*2*].*\ root\ two                                     ]]
  [[    "${lines[5]}"   =~  \
          [.*1*].*\ root\ one                                     ]]
  [[    "${lines[6]}"   =~  ----                                  ]]
  [[    "${lines[7]}"   =~  nb\ add                               ]]

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]

  [[    "${lines[0]}"   =~  home                                  ]]
  [[    "${lines[1]}"   =~  ----                                  ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/2.*].*\ 📌\ nested\ two              ]]
  [[    "${lines[3]}"   =~  \
          [.*Example\ Folder/3*].*\ 📂\ Sample\ Folder            ]]
  [[    "${lines[4]}"   =~  \
          [.*Example\ Folder/1*].*\ nested\ one                   ]]
  [[    "${lines[5]}"   =~  ----                                  ]]
  [[    "${lines[6]}"   =~  nb\ add\ 4/                           ]]


  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]

  [[    "${lines[0]}"   =~  home                                  ]]
  [[    "${lines[1]}"   =~  ----                                  ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[3]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/2.*].*\ deep\ two     ]]
  [[    "${lines[4]}"   =~  ----                                  ]]
  [[    "${lines[5]}"   =~  nb\ add\ 4/3/                         ]]
}
