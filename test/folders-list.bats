#!/usr/bin/env bats

load test_helper

# full path ###################################################################

@test "'list /not/valid/full/path/to/folder/' (slash) with existing notebook exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/one.md"             \
      --title     "Title One"
    "${_NB}" add  "Example Folder/two.bookmark.md"    \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Folder/three.bookmark.md"  \
      --content   "<https://example.test>"            \
      --encrypt   --password=password
  }

  # full path (slash)

  run "${_NB}" list "${NB_DIR}/home/not-valid/does-not-match"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1     ]]
  [[   "${#lines[@]}" -eq 1     ]]

  [[   "${lines[0]}"  =~  Not\ found:\ .*${NB_DIR}/home/not-valid/does-not-match  ]]
}

@test "'list /not/valid/full/path/to/folder/' (slash) without existing notebook treats exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/one.md"             \
      --title     "Title One"
    "${_NB}" add  "Example Folder/two.bookmark.md"    \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Folder/three.bookmark.md"  \
      --content   "<https://example.test>"            \
      --encrypt   --password=password
  }

  # full path (slash)

  run "${_NB}" list "${NB_DIR}/example/not-valid/does-not-match"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1     ]]
  [[   "${#lines[@]}" -eq 1     ]]

  [[   "${lines[0]}"  =~  Not\ found:\ .*${NB_DIR}/example/not-valid/does-not-match  ]]
}

@test "'list /full/path/to/folder/' (slash) exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/one.md"             \
      --title     "Title One"
    "${_NB}" add  "Example Folder/two.bookmark.md"    \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Folder/three.bookmark.md"  \
      --content   "<https://example.test>"            \
      --encrypt   --password=password
  }

  # relative path

  run "${_NB}" list "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]
  [[   "${#lines[@]}" -eq 3     ]]

  [[   "${lines[0]}"  =~  [.*Example\ Folder/3.*].*\ 🔖\ 🔒\ three.bookmark.md  ]]
  [[   "${lines[1]}"  =~  [.*Example\ Folder/2.*].*\ 🔖\ two.bookmark.md        ]]
  [[   "${lines[2]}"  =~  [.*Example\ Folder/1.*].*\ Title\ One                 ]]

  # full path (slash)

  run "${_NB}" list "${NB_DIR}/home/Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]
  [[   "${#lines[@]}" -eq 3     ]]

  [[   "${lines[0]}"  =~  \
          [.*Example\ Folder/3.*].*\ 🔖\ 🔒\ three.bookmark.md  ]]
  [[   "${lines[1]}"  =~  \
          [.*Example\ Folder/2.*].*\ 🔖\ two.bookmark.md        ]]
  [[   "${lines[2]}"  =~  \
          [.*Example\ Folder/1.*].*\ Title\ One                 ]]
}

@test "'list /full/path/to/folder' (no slash) exits with 0 and lists folder item only." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/one.md"             \
      --title     "Title One"
    "${_NB}" add  "Example Folder/two.bookmark.md"    \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Folder/three.bookmark.md"  \
      --content   "<https://example.test>"            \
      --encrypt   --password=password
  }

  # relative path

  run "${_NB}" list "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]
  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  [.*1.*].*\ 📂\ Example\ Folder  ]]

  # full path (no slash)

  run "${_NB}" list "${NB_DIR}/home/Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]
  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  [.*1.*].*\ 📂\ Example\ Folder  ]]
}

@test "'list /full/path/to/folder/' (slash) in different notebook exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/one.md"            \
      --title     "Title One"
    "${_NB}" add  "Example Notebook:Example Folder/two.bookmark.md"   \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Notebook:Example Folder/three.bookmark.md" \
      --content   "<https://example.test>"                            \
      --encrypt   --password=password
  }

  # relative path

  run "${_NB}" list "Example Notebook:Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]
  [[   "${#lines[@]}" -eq 3     ]]

  [[   "${lines[0]}"  =~  [.*Example\ Folder/3.*].*\ 🔖\ 🔒\ three.bookmark.md  ]]
  [[   "${lines[1]}"  =~  [.*Example\ Folder/2.*].*\ 🔖\ two.bookmark.md        ]]
  [[   "${lines[2]}"  =~  [.*Example\ Folder/1.*].*\ Title\ One                 ]]

  # full path (slash)

  run "${_NB}" list "${NB_DIR}/Example Notebook/Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]
  [[   "${#lines[@]}" -eq 3     ]]

  [[   "${lines[0]}"  =~  \
          [.*Example\ Notebook:Example\ Folder/3.*].*\ 🔖\ 🔒\ three.bookmark.md  ]]
  [[   "${lines[1]}"  =~  \
          [.*Example\ Notebook:Example\ Folder/2.*].*\ 🔖\ two.bookmark.md        ]]
  [[   "${lines[2]}"  =~  \
          [.*Example\ Notebook:Example\ Folder/1.*].*\ Title\ One                 ]]
}

@test "'list /full/path/to/folder' (no slash) in diferrent notebook exits with 0 and lists folder item only." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/one.md"            \
      --title     "Title One"
    "${_NB}" add  "Example Notebook:Example Folder/two.bookmark.md"   \
      --content   "<https://example.test>"
    "${_NB}" add  "Example Notebook:Example Folder/three.bookmark.md" \
      --content   "<https://example.test>"                            \
      --encrypt   --password=password
  }

  # relative path

  run "${_NB}" list "Example Notebook:Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                                 ]]
  [[   "${#lines[@]}" -eq 1                                                 ]]

  [[   "${lines[0]}"  =~  [.*Example\ Notebook:1.*].*\ 📂\ Example\ Folder  ]]

  # full path (no slash)

  run "${_NB}" list "${NB_DIR}/Example Notebook/Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                                 ]]
  [[   "${#lines[@]}" -eq 1                                                 ]]

  [[   "${lines[0]}"  =~  [.*Example\ Notebook:1.*].*\ 📂\ Example\ Folder  ]]
}

# empty #######################################################################

@test "'list <folder>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list Example\ Folder/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  0\ audio\ files\.                     ]]
  [[   "${lines[2]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
}

@test "'list <id>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list 1/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  0\ audio\ files\.                     ]]
  [[   "${lines[2]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
}

@test "'list <folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"
  }

  run "${_NB}" list Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  0\ items\.                            ]]
  [[   "${lines[2]}"  =~  add\ 1/                               ]]
  [[   "${lines[3]}"  =~  bookmark                              ]]
  [[   "${lines[4]}"  =~  1/\ \<url\>                           ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
}

@test "'list <id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  0\ items\.                            ]]
  [[   "${lines[2]}"  =~  add\ 1/                               ]]
  [[   "${lines[3]}"  =~  bookmark                              ]]
  [[   "${lines[4]}"  =~  1/\ \<url\>                           ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
}

@test "'list <folder>/<folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type folder
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  0\ items\.                              ]]
  [[   "${lines[2]}"  =~  add\ 1/1/                               ]]
  [[   "${lines[3]}"  =~  bookmark                                ]]
  [[   "${lines[4]}"  =~  1/1/\ \<url\>                           ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/1/ ]]
}

@test "'list <id>/<id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type folder
  }

  run "${_NB}" list 1/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  0\ items\.                              ]]
  [[   "${lines[2]}"  =~  add\ 1/1/                               ]]
  [[   "${lines[3]}"  =~  bookmark                                ]]
  [[   "${lines[4]}"  =~  1/1/\ \<url\>                           ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/1/ ]]
}

@test "'list <notebook>:<id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" list home:1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]
  [[   "${lines[0]}"  =~  0\ items\.                                  ]]
  [[   "${lines[2]}"  =~  add\ home:1/                                ]]
  [[   "${lines[3]}"  =~  bookmark                                    ]]
  [[   "${lines[4]}"  =~  home:1/\ \<url\>                            ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ home:1/  ]]
}

# index #######################################################################

@test "'list <folder>/<folder>/' reconciles ancestor indexes." {
  {
    "${_NB}" init

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[    -d "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ !  -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                       ]]
  [[    "${lines[0]}" =~  0\ items\.                              ]]

  [[    -e "${NB_DIR}/home/Example Folder/.index"                 ]]
  [[    -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"   ]]

  diff                                                            \
    <(cat "${NB_DIR}/home/Example Folder/.index")                 \
    <(printf "Sample Folder\\n")

  diff                                                            \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")   \
    <(printf "")
}

@test "'list <folder>/<folder>/<filename>' reconciles ancestor indexes." {
  {
    "${_NB}" init

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"
    touch "${NB_DIR}/home/Example Folder/Sample Folder/example.md"

    [[    -d "${NB_DIR}/home/Example Folder/Sample Folder"            ]]
    [[ !  -e "${NB_DIR}/home/Example Folder/.index"                   ]]
    [[ !  -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"     ]]
    [[    -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md" ]]
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                           ]]
  [[    "${lines[0]}" =~  example.md                                  ]]

  [[    -e "${NB_DIR}/home/Example Folder/.index"                     ]]
  [[    -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"       ]]
  [[    -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"   ]]

  diff                                                                \
    <(cat "${NB_DIR}/home/Example Folder/.index")                     \
    <(printf "Sample Folder\\n")

  diff                                                                \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")       \
    <(printf "example.md\\n")
}

# excerpt #####################################################################

@test "'list <folder>/<folder>/<id> -e' includes excerpt line." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "one"                                 \
      --content   "Content one."
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/one --excerpt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  echo "${#lines[1]}"

  [[    "${status}"     -eq 0                                             ]]
  [[    "${#lines[@]}"  -eq 4                                             ]]

  [[    "${lines[0]}"   =~  Example\ Folder/Sample\ Folder/1.*one         ]]
  [[    "${lines[1]}"   =~  [^-]------------------------------------[^-]  ]]
  [[    "${#lines[1]}"  =~  47                                            ]]
}

# filtering ###################################################################

@test "'list <folder>/ <pattern>...' (slash) exits with 0 and prints filtered list." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."
  }

  run "${_NB}" list one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  1.*root\ one                    ]]

  run "${_NB}" list Example\ Folder/ one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/1.*nested\ one  ]]

  run "${_NB}" list Example\ Folder/ nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 2                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one  ]]

  run "${_NB}" list Example\ Folder/ one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 2                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one  ]]
}

@test "'list <folder> <pattern>...' (no slash) exits with 0 and treats folder as selector and filter pattern." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."
  }

  run "${_NB}" list one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 1                       ]]

  [[    "${lines[0]}"   =~  1.*root\ one            ]]
  [[    "${output}"     =~  1.*root\ one            ]]

  run "${_NB}" list Example\ Folder one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 2                       ]]

  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]
  [[    "${lines[1]}"   =~  1.*root\ one            ]]

  run "${_NB}" list Example\ Folder nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 1                       ]]

  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]

  run "${_NB}" list Example\ Folder one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 3                       ]]

  [[    "${lines[2]}"   =~  1.*root\ one            ]]
  [[    "${lines[1]}"   =~  2.*root\ two            ]]
  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]
}

# error handling ##############################################################

@test "'list filename/<id>' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"     --title "one"     --content "Content one."
    "${_NB}" add "example.md" --title "example" --content "Content example."
  }

  run "${_NB}" list one.md/example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1             ]]

  [[   "${lines[0]}"  =~ Not\ found:    ]]
  [[   "${lines[0]}"  =~ one.md/example ]]
  [[   "${#lines[@]}" == 1              ]]
}

@test "'list <not-valid-id>/' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" list 10/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1           ]]

  [[   "${lines[0]}"  =~ Not\ found:  ]]
  [[   "${lines[0]}"  =~ 10           ]]

  [[ ! "${output}"  =~ three          ]]
  [[ ! "${output}"  =~ 🔖\ 🔒         ]]
  [[ ! "${output}"  =~ two            ]]
  [[ ! "${output}"  =~ 🔖             ]]
  [[ ! "${output}"  =~ one            ]]
}

@test "'list not-valid/' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" list not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1           ]]

  [[   "${lines[0]}"  =~ Not\ found:  ]]
  [[   "${lines[0]}"  =~ not-valid    ]]

  [[ ! "${output}"  =~ three          ]]
  [[ ! "${output}"  =~ 🔖\ 🔒         ]]
  [[ ! "${output}"  =~ two            ]]
  [[ ! "${output}"  =~ 🔖             ]]
  [[ ! "${output}"  =~ one            ]]
}

@test "'list valid/<not-valid-id>/' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
    "${_NB}" add "Example Folder/Sample 2 Folder 2" --type folder
  }

  run "${_NB}" list Example\ Folder/10/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1                         ]]

  [[   "${lines[0]}"  =~ Not\ found:                ]]
  [[   "${lines[0]}"  =~ Example\ Folder/10         ]]

  [[ ! "${output}"  =~ three                        ]]
  [[ ! "${output}"  =~ 🔖\ 🔒                       ]]
  [[ ! "${output}"  =~ two                          ]]
  [[ ! "${output}"  =~ 🔖                           ]]
  [[ ! "${output}"  =~ one                          ]]
}

@test "'list valid/not-valid/' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1                                         ]]

  [[   "${lines[0]}"  =~ Not\ found:.*Example\ Folder/not-valid/    ]]

  [[ ! "${output}"  =~ three                                        ]]
  [[ ! "${output}"  =~ 🔖\ 🔒                                       ]]
  [[ ! "${output}"  =~ two                                          ]]
  [[ ! "${output}"  =~ 🔖                                           ]]
  [[ ! "${output}"  =~ one                                          ]]
}

@test "'list not-valid/not-valid/' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list not-valid/not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1                   ]]

  [[   "${lines[0]}"  =~ Not\ found:          ]]
  [[   "${lines[0]}"  =~ not-valid/not-valid  ]]

  [[ ! "${output}"  =~ three                  ]]
  [[ ! "${output}"  =~ 🔖\ 🔒                 ]]
  [[ ! "${output}"  =~ two                    ]]
  [[ ! "${output}"  =~ 🔖                     ]]
  [[ ! "${output}"  =~ one                    ]]
}

@test "'list not-valid' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" list not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1           ]]

  [[   "${lines[0]}"  =~ Not\ found:  ]]
  [[   "${lines[0]}"  =~ not-valid    ]]
}

@test "'list valid/not-valid' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1                                           ]]

  [[   "${lines[0]}"  =~ Not\ found:.*Example\ Folder/.*\ .*not-valid ]]
}

@test "'list not-valid/not-valid' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list not-valid/not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1                   ]]

  [[   "${lines[0]}"  =~ Not\ found:          ]]
  [[   "${lines[0]}"  =~ not-valid/not-valid  ]]
}

# list folder files ###########################################################

@test "'list folder/folder/<id>/' (slash) with file lists file." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/1/3/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                            ]]

  [[   "${lines[0]}"  =~ Example\ Folder/Sample\ Folder/Demo\ Folder/3 ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒                                        ]]
  [[   "${lines[0]}"  =~ three.bookmark.md.enc                         ]]
}

# list notebook:<id> ##########################################################

@test "'list notebook:<id>/<folder>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" list home:1/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${lines[0]}"  =~  [^/]home:Example\ Folder/3      ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]

  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'list <id>/<folder>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"
}

  run "${_NB}" list 1/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${lines[0]}"  =~  Example\ Folder/3               ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]

  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

# list <id>/ ##################################################################

@test "'list folder/folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]

  [[   "${lines[0]}"  =~ three  ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒 ]]
  [[   "${lines[1]}"  =~ two    ]]
  [[   "${lines[1]}"  =~ 🔖     ]]
  [[   "${lines[2]}"  =~ one    ]]
  [[ ! "${lines[2]}"  =~ 🔖     ]]
  [[ ! "${lines[2]}"  =~ 🔒     ]]
}

@test "'list folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[   "${status}"    -eq 0     ]]

  [[   "${lines[0]}"  =~ three  ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒 ]]
  [[   "${lines[1]}"  =~ two    ]]
  [[   "${lines[1]}"  =~ 🔖     ]]
  [[   "${lines[2]}"  =~ one    ]]
  [[ ! "${lines[2]}"  =~ 🔖     ]]
  [[ ! "${lines[2]}"  =~ 🔒     ]]
}

@test "'list <id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" list 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]

  [[   "${lines[0]}"  =~ three  ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒 ]]
  [[   "${lines[1]}"  =~ two    ]]
  [[   "${lines[1]}"  =~ 🔖     ]]
  [[   "${lines[2]}"  =~ one    ]]
  [[ ! "${lines[2]}"  =~ 🔖     ]]
  [[ ! "${lines[2]}"  =~ 🔒     ]]
}

# list folder ################################################################

@test "'list folder/folder/folder' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                   \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"     \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"              \
      --title "Two"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.txt" \
      --content "Content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.txt" \
      --content "Content two."
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/Demo\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]

  [[   "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/3            ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                          ]]

  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                 ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                ]]
  [[   "${#lines[@]}" -eq 1                                           ]]
}

@test "'list folder/folder' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                   ]]

  [[   "${lines[0]}"  =~  Example\ Folder/3                   ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder      ]]
  [[   "${lines[0]}"  =~  📂                                  ]]

  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder      ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                      ]]
  [[   "${#lines[@]}" -eq 1                                   ]]
}

@test "'list folder' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                 ]]

  [[ ! "${lines[0]}"  =~  3\.bookmark\.md   ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒            ]]
  [[ ! "${lines[1]}"  =~  2\.bookmark\.md   ]]
  [[ ! "${lines[1]}"  =~  🔖                ]]
  [[ ! "${lines[2]}"  =~  one               ]]
  [[ ! "${lines[2]}"  =~  🔖                ]]
  [[ ! "${lines[2]}"  =~  🔒                ]]

  [[   "${lines[0]}"  =~  3                 ]]
  [[   "${lines[0]}"  =~  📂                ]]
  [[   "${lines[0]}"  =~  Example\ Folder   ]]
  [[   "${#lines[@]}" -eq 1                 ]]
}

# list folder/ ################################################################

@test "'list folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]

  [[   "${lines[0]}"  =~ three  ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒 ]]
  [[   "${lines[1]}"  =~ two    ]]
  [[   "${lines[1]}"  =~ 🔖     ]]
  [[   "${lines[2]}"  =~ one    ]]
  [[ ! "${lines[2]}"  =~ 🔖     ]]
  [[ ! "${lines[2]}"  =~ 🔒     ]]
}

@test "'list folder/folder/' exits with 0 and lists files in folder/folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/file 1.md"  --content "Example content one."
    "${_NB}" add "Example Folder/file 2.md"  --content "Example content two."
    "${_NB}" add "Example Folder/file 3.md"  --content "Example content three."

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" list Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]

  [[ ! "${lines[0]}"  =~ three            ]]
  [[ ! "${lines[0]}"  =~ 🔖\ 🔒           ]]
  [[ ! "${lines[1]}"  =~ two              ]]
  [[ ! "${lines[1]}"  =~ 🔖               ]]
  [[ ! "${lines[2]}"  =~ one              ]]
  [[ ! "${lines[2]}"  =~ 🔖               ]]
  [[ ! "${lines[2]}"  =~ 🔒               ]]

  [[   "${lines[0]}"  =~ Sample\ Folder   ]]
  [[   "${lines[1]}"  =~ file\ 3          ]]
  [[   "${lines[2]}"  =~ file\ 2          ]]
  [[   "${lines[3]}"  =~ file\ 1          ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0     ]]

  [[   "${lines[0]}"  =~ three  ]]
  [[   "${lines[0]}"  =~ 🔖\ 🔒 ]]
  [[   "${lines[1]}"  =~ two    ]]
  [[   "${lines[1]}"  =~ 🔖     ]]
  [[   "${lines[2]}"  =~ one    ]]
  [[ ! "${lines[2]}"  =~ 🔖     ]]
  [[ ! "${lines[2]}"  =~ 🔒     ]]
}

@test "'list folder/folder/folder/' exits with 0 and lists files in folder/folder/folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/file 1.md" --content "Example content one."
    "${_NB}" add "Example Folder/file 2.md" --content "Example content two."
    "${_NB}" add "Example Folder/file 3.md" --content "Example content three."

    "${_NB}" add "Example Folder/Sample Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"               \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md"             \
      --content "<https://example.test>"                                      \
      --encrypt --password=password

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document One.md"   \
      --content "Example content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document Two.md"   \
      --content "Example content two."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document Three.md" \
      --content "Example content three."
  }

  run "${_NB}" list Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]

  [[ ! "${lines[0]}"  =~  three           ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒          ]]
  [[ ! "${lines[1]}"  =~  two             ]]
  [[ ! "${lines[1]}"  =~  🔖              ]]
  [[ ! "${lines[2]}"  =~  one             ]]
  [[ ! "${lines[2]}"  =~  🔖              ]]
  [[ ! "${lines[2]}"  =~  🔒              ]]

  [[   "${lines[0]}"  =~  Sample\ Folder  ]]
  [[   "${lines[1]}"  =~  file\ 3         ]]
  [[   "${lines[2]}"  =~  file\ 2         ]]
  [[   "${lines[3]}"  =~  file\ 1         ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0             ]]

  [[   "${lines[0]}"  =~  Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  three         ]]
  [[   "${lines[1]}"  =~  🔖\ 🔒        ]]
  [[   "${lines[2]}"  =~  two           ]]
  [[   "${lines[2]}"  =~  🔖            ]]
  [[   "${lines[3]}"  =~  one           ]]
  [[ ! "${lines[3]}"  =~  🔖            ]]
  [[ ! "${lines[3]}"  =~  🔒            ]]

  run "${_NB}" list Example\ Folder/Sample\ Folder/Demo\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~  Document\ Three.md  ]]
  [[   "${lines[1]}"  =~  Document\ Two.md    ]]
  [[   "${lines[2]}"  =~  Document\ One.md    ]]
}
