#!/usr/bin/env bats

load test_helper

export NB_PINNED_PATTERN="#pinned"

# --pinned ####################################################################

@test "'NB_PINNED_PATTERN list --pinned --type' filters by type." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"     \
      --title     "Title One"       \
      --content   "Content one."

    "${_NB}" add  "File Two.md"     \
      --title     "Title Two"       \
      --content   "Content two."

    "${_NB}" add  "Example Folder" --type "folder"

    "${_NB}" add  "File Three.md"   \
      --title     "Title Three"     \
      --content   "Content Three."

    "${_NB}" add  "Sample Folder" --type "folder"

    "${_NB}" add  "File Four.md"    \
      --title     "Title Four"      \
      --content   "Content Four."

    "${_NB}" add  "Demo Folder" --type "folder"


    "${_NB}" pin 2
    "${_NB}" pin 3
    "${_NB}" pin 5
    "${_NB}" pin 6
  }

  run "${_NB}" list --pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 4                                 ]]

  [[    "${lines[0]}"   =~  [.*2*].*\ 📌\ Title\ Two          ]]
  [[    "${lines[1]}"   =~  [.*3*].*\ 📌\ 📂\ Example\ Folder ]]
  [[    "${lines[2]}"   =~  [.*5*].*\ 📌\ 📂\ Sample\ Folder  ]]
  [[    "${lines[3]}"   =~  [.*6*].*\ 📌\ Title\ Four         ]]

  run "${_NB}" list --pinned --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 2                                 ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ 📂\ Example\ Folder ]]
  [[    "${lines[1]}"   =~  [.*5*].*\ 📌\ 📂\ Sample\ Folder  ]]

  run "${_NB}" list --pinned --type md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 2                                 ]]

  [[    "${lines[0]}"   =~  [.*2*].*\ 📌\ Title\ Two          ]]
  [[    "${lines[1]}"   =~  [.*6*].*\ 📌\ Title\ Four         ]]

  run "${_NB}" list --pinned --type example-type

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 5                                 ]]

  [[    "${lines[0]}"   =~  0\ pinned\ example-type\ items.   ]]
  [[    "${lines[1]}"   =~  Pin\ an\ item:                    ]]
  [[    "${lines[2]}"   =~  nb\ pin\ \<id\>                   ]]
  [[    "${lines[3]}"   =~  Help\ information:                ]]
  [[    "${lines[4]}"   =~  nb\ help                          ]]
}

@test "'NB_PINNED_PATTERN list --pinned' only shows pins." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two. #pinned"
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/three.md" \
      --title     "nested three"            \
      --content   "Content three."

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."
  }

  run "${_NB}" list --pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 2                             ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ root\ three     ]]
  [[    "${lines[1]}"   =~  [.*2*].*\ 📌\ root\ two       ]]

  run "${_NB}" list Example\ Folder/ --pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 5                             ]]

  [[    "${lines[0]}"   =~  0\ pinned\ items.             ]]
  [[    "${lines[1]}"   =~  Pin\ an\ item:                ]]
  [[    "${lines[2]}"   =~  nb\ pin\ 4/\<id\>             ]]
  [[    "${lines[3]}"   =~  Help\ information:            ]]
  [[    "${lines[4]}"   =~  nb\ help                      ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/ --pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 2                             ]]

  [[    "${lines[0]}"   =~  [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  [.*Example\ Folder/Sample\ Folder/2.*].*\ 📌\ deep\ two ]]
}

# --with-pinned ###############################################################

@test "'NB_PINNED_PATTERN list --with-pinned' only shows pins when type is blank." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two. #pinned"
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/three.md" \
      --title     "nested three"            \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."
  }

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 4                             ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ root\ three     ]]
  [[    "${lines[1]}"   =~  [.*2*].*\ 📌\ root\ two       ]]
  [[    "${lines[2]}"   =~  [.*4*].*\ 📂\ Example\ Folder ]]
  [[    "${lines[3]}"   =~  [.*1*].*\ root\ one           ]]

  run "${_NB}" list --with-pinned --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 1                             ]]

  [[    "${lines[0]}"   =~  [.*4*].*\ 📂\ Example\ Folder ]]
}

@test "'NB_PINNED_PATTERN list --with-pinned' doesn't show pins when single selector match is present." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two. #pinned"
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/three.md" \
      --title     "nested three"            \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."
  }

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 4                             ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ root\ three     ]]
  [[    "${lines[1]}"   =~  [.*2*].*\ 📌\ root\ two       ]]
  [[    "${lines[2]}"   =~  [.*4*].*\ 📂\ Example\ Folder ]]
  [[    "${lines[3]}"   =~  [.*1*].*\ root\ one           ]]

  run "${_NB}" list "4" --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 1                             ]]

  [[    "${lines[0]}"   =~  [.*4*].*\ 📂\ Example\ Folder ]]

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 4                             ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one    ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3.*].*\ 📌\ nested\ three  ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/4*].*\ 📂\ Sample\ Folder  ]]
  [[    "${lines[3]}"   =~  \
          [.*Example\ Folder/2.*].*\ nested\ two        ]]

  run "${_NB}" list Example\ Folder/4 --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 1                           ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/4*].*\ 📂\ Sample\ Folder  ]]

  # switch notebooks

  "${_NB}" notebooks add "Example Notebook"
  "${_NB}" use "Example Notebook"

  run "${_NB}" list home: --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 4                                   ]]

  [[    "${lines[0]}"   =~  [.*home:3*].*\ 📌\ root\ three      ]]
  [[    "${lines[1]}"   =~  [.*home:2*].*\ 📌\ root\ two        ]]
  [[    "${lines[2]}"   =~  [.*home:4*].*\ 📂\ Example\ Folder  ]]
  [[    "${lines[3]}"   =~  [.*home:1*].*\ root\ one            ]]

  run "${_NB}" list home:4 --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 1                                   ]]

  [[    "${lines[0]}"   =~  [.*home:4*].*\ 📂\ Example\ Folder  ]]

  run "${_NB}" list home:Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 4                                 ]]

  [[    "${lines[0]}"   =~  \
          [.*home:Example\ Folder/1.*].*\ 📌\ nested\ one     ]]
  [[    "${lines[1]}"   =~  \
          [.*home:Example\ Folder/3.*].*\ 📌\ nested\ three   ]]
  [[    "${lines[2]}"   =~  \
          [.*home:Example\ Folder/4*].*\ 📂\ Sample\ Folder   ]]
  [[    "${lines[3]}"   =~  \
          [.*home:Example\ Folder/2.*].*\ nested\ two         ]]

  run "${_NB}" list home:Example\ Folder/4 --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 1                                 ]]

  [[    "${lines[0]}"   =~  \
          [.*home:Example\ Folder/4*].*\ 📂\ Sample\ Folder   ]]
}

@test "'NB_PINNED_PATTERN list --with-pinned' filters pinned and unpinned items by filter pattern." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two. #pinned"
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/three.md" \
      --title     "nested three"            \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."
  }

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 4                             ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ root\ three     ]]
  [[    "${lines[1]}"   =~  [.*2*].*\ 📌\ root\ two       ]]
  [[    "${lines[2]}"   =~  [.*4*].*\ 📂\ Example\ Folder ]]
  [[    "${lines[3]}"   =~  [.*1*].*\ root\ one           ]]

  run "${_NB}" list "root" --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 3                             ]]

  [[    "${lines[0]}"   =~  [.*3*].*\ 📌\ root\ three     ]]
  [[    "${lines[1]}"   =~  [.*2*].*\ 📌\ root\ two       ]]
  [[    "${lines[2]}"   =~  [.*1*].*\ root\ one           ]]

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 4                           ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one    ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3.*].*\ 📌\ nested\ three  ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/4*].*\ 📂\ Sample\ Folder  ]]
  [[    "${lines[3]}"   =~  \
          [.*Example\ Folder/2.*].*\ nested\ two        ]]

  run "${_NB}" list Example\ Folder/ "nested" --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 3                           ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one    ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3.*].*\ 📌\ nested\ three  ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/2.*].*\ nested\ two        ]]

  # switch notebooks

  "${_NB}" notebooks add "Example Notebook"
  "${_NB}" use "Example Notebook"

  run "${_NB}" list home: --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 4                                   ]]

  [[    "${lines[0]}"   =~  [.*home:3*].*\ 📌\ root\ three      ]]
  [[    "${lines[1]}"   =~  [.*home:2*].*\ 📌\ root\ two        ]]
  [[    "${lines[2]}"   =~  [.*home:4*].*\ 📂\ Example\ Folder  ]]
  [[    "${lines[3]}"   =~  [.*home:1*].*\ root\ one            ]]

  run "${_NB}" list home: "root" --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 3                                   ]]

  [[    "${lines[0]}"   =~  [.*home:3*].*\ 📌\ root\ three      ]]
  [[    "${lines[1]}"   =~  [.*home:2*].*\ 📌\ root\ two        ]]
  [[    "${lines[2]}"   =~  [.*home:1*].*\ root\ one            ]]

  run "${_NB}" list home:Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 4                                 ]]

  [[    "${lines[0]}"   =~  \
          [.*home:Example\ Folder/1.*].*\ 📌\ nested\ one     ]]
  [[    "${lines[1]}"   =~  \
          [.*home:Example\ Folder/3.*].*\ 📌\ nested\ three   ]]
  [[    "${lines[2]}"   =~  \
          [.*home:Example\ Folder/4*].*\ 📂\ Sample\ Folder   ]]
  [[    "${lines[3]}"   =~  \
          [.*home:Example\ Folder/2.*].*\ nested\ two         ]]

  run "${_NB}" list home:Example\ Folder/ "nested" --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  \
          [.*home:Example\ Folder/1.*].*\ 📌\ nested\ one     ]]
  [[    "${lines[1]}"   =~  \
          [.*home:Example\ Folder/3.*].*\ 📌\ nested\ three   ]]
  [[    "${lines[2]}"   =~  \
          [.*home:Example\ Folder/2.*].*\ nested\ two         ]]
}

@test "'NB_PINNED_PATTERN list [<folder>/] --with-pinned --limit' (slash) respects limit." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two. #pinned"
    "${_NB}" add  "two.md"      \
      --title     "root three"  \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/three.md" \
      --title     "nested three"            \
      --content   "Content three. #pinned"

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two. #pinned"
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."
  }

  run "${_NB}" list --with-pinned --limit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 2                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[1]}"   =~  3\ omitted.\ 4\ total.                ]]

  run "${_NB}" list --with-pinned --limit 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[1]}"   =~  \
          [.*2*].*\ 📌\ root\ two                                 ]]
  [[    "${lines[2]}"   =~  2\ omitted.\ 4\ total.                ]]

  run "${_NB}" list --with-pinned --limit 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 4                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[1]}"   =~  \
          [.*2*].*\ 📌\ root\ two                                 ]]
  [[    "${lines[2]}"   =~  \
          [.*4*].*\ 📂\ Example\ Folder                           ]]
  [[    "${lines[3]}"   =~  1\ omitted.\ 4\ total.                ]]

  run "${_NB}" list Example\ Folder/ --with-pinned --limit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 2                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one              ]]
  [[    "${lines[1]}"   =~  3\ omitted.\ 4\ total.                ]]

  run "${_NB}" list Example\ Folder/ --with-pinned --limit 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one              ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3.*].*\ 📌\ nested\ three            ]]
  [[    "${lines[2]}"   =~  2\ omitted.\ 4\ total.                ]]

  run "${_NB}" list Example\ Folder/ --with-pinned --limit 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 4                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/1.*].*\ 📌\ nested\ one              ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3.*].*\ 📌\ nested\ three            ]]
  [[    "${lines[2]}"   =~  \
          [.*4*].*\ 📂\ Sample\ Folder                            ]]
  [[    "${lines[3]}"   =~  1\ omitted.\ 4\ total.                ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/ --with-pinned --limit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 2                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  2\ omitted.\ 3\ total.                ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/ --with-pinned --limit 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/2.*].*\ 📌\ deep\ two ]]
  [[    "${lines[2]}"   =~  1\ omitted.\ 3\ total.                ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/ --with-pinned --limit 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 4                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/2.*].*\ 📌\ deep\ two ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/3.*].*\ deep\ three   ]]
}

@test "'NB_PINNED_PATTERN list [<folder>/] --with-pinned' (slash) prints items tagged with #pinned in the current folder." {
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

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 4                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*3*].*\ 📌\ root\ three                               ]]
  [[    "${lines[1]}"   =~  \
          [.*4*].*\ 📂\ Example\ Folder                           ]]
  [[    "${lines[2]}"   =~  \
          [.*2*].*\ root\ two                                     ]]
  [[    "${lines[3]}"   =~  \
          [.*1*].*\ root\ one                                     ]]

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/2.*].*\ 📌\ nested\ two              ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/3*].*\ 📂\ Sample\ Folder            ]]
  [[    "${lines[2]}"   =~  \
          [.*Example\ Folder/1*].*\ nested\ one                   ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 2                                     ]]

  [[    "${lines[0]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/1.*].*\ 📌\ deep\ one ]]
  [[    "${lines[1]}"   =~  \
          [.*Example\ Folder/Sample\ Folder/2.*].*\ deep\ two     ]]
}
