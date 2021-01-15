#!/usr/bin/env bats

load test_helper

export NB_PINNED_PATTERN="#pinned"

# search-based pinning ########################################################

@test "'NB_PINNED_PATTERN list [<folder>/]' (slash) prints items tagged with #pinned, recursively." {
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

  run bash -c "${_NB} list"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 6                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/2.*].*\ 📌\ nested\ two              ]]
  [[    "${lines[2]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[3]}"   =~  \
          [.*4*].*\ 📂\ Example\ Folder                           ]]
  [[    "${lines[4]}"   =~  \
          [.*2*].*\ root\ two                                     ]]
  [[    "${lines[5]}"   =~  \
          [.*1*].*\ root\ one                                     ]]

  run bash -c "${_NB} list Example\ Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 4                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/2.*].*\ 📌\ nested\ two              ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/3*].*\ 📂\ Sample\ Folder            ]]
  [[    "${lines[3]}"   =~  \
          [.*Example\ Folder/1*].*\ nested\ one                   ]]

  run bash -c "${_NB} list Example\ Folder/Sample\ Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 2                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/2.*].*\ deep\ two     ]]
}
