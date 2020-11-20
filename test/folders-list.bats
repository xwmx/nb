#!/usr/bin/env bats

load test_helper

# empty #######################################################################

@test "'list <folder>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list Example\ Folder/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                 ]]
  [[   "${lines[0]}"  =~  0\ audio\ files\.                 ]]
  [[   "${lines[2]}"  =~  import\ \(\<path\>\ \|\ \<url\>\) ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/                ]]
}

@test "'list <id>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list 1/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                 ]]
  [[   "${lines[0]}"  =~  0\ audio\ files\.                 ]]
  [[   "${lines[2]}"  =~  import\ \(\<path\>\ \|\ \<url\>\) ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/                ]]
}

@test "'list <folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"
  }

  run "${_NB}" list Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                 ]]
  [[   "${lines[0]}"  =~  0\ items\.                        ]]
  [[   "${lines[2]}"  =~  add                               ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/                ]]
  [[   "${lines[3]}"  =~  bookmark                          ]]
  [[   "${lines[4]}"  =~  Example\\\ Folder/\ \<url\>       ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\) ]]
  [[   "${lines[6]}"  =~  Example\\\ Folder/                ]]
}

@test "'list <id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" list 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                 ]]
  [[   "${lines[0]}"  =~  0\ items\.                        ]]
  [[   "${lines[2]}"  =~  add                               ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/                ]]
  [[   "${lines[3]}"  =~  bookmark                          ]]
  [[   "${lines[4]}"  =~  Example\\\ Folder/\ \<url\>       ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\) ]]
  [[   "${lines[6]}"  =~  Example\\\ Folder/                ]]
}

@test "'list <folder>/<folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type folder
  }

  run "${_NB}" list Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                             ]]
  [[   "${lines[0]}"  =~  0\ items\.                                    ]]
  [[   "${lines[2]}"  =~  add                                           ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/Sample\\\ Folder/           ]]
  [[   "${lines[3]}"  =~  bookmark                                      ]]
  [[   "${lines[4]}"  =~  Example\\\ Folder/Sample\\\ Folder/\ \<url\>  ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)             ]]
  [[   "${lines[6]}"  =~  Example\\\ Folder/Sample\\\ Folder            ]]
}

@test "'list <id>/<id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type folder
  }

  run "${_NB}" list 1/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                             ]]
  [[   "${lines[0]}"  =~  0\ items\.                                    ]]
  [[   "${lines[2]}"  =~  add                                           ]]
  [[   "${lines[2]}"  =~  Example\\\ Folder/Sample\\\ Folder/           ]]
  [[   "${lines[3]}"  =~  bookmark                                      ]]
  [[   "${lines[4]}"  =~  Example\\\ Folder/Sample\\\ Folder/\ \<url\>  ]]
  [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)             ]]
  [[   "${lines[6]}"  =~  Example\\\ Folder/Sample\\\ Folder            ]]
}

# error handling ##############################################################

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

  [[   "${status}"    -eq 1                         ]]

  [[   "${lines[0]}"  =~ Not\ found:                ]]
  [[   "${lines[0]}"  =~ Example\ Folder/not-valid  ]]

  [[ ! "${output}"  =~ three                        ]]
  [[ ! "${output}"  =~ 🔖\ 🔒                       ]]
  [[ ! "${output}"  =~ two                          ]]
  [[ ! "${output}"  =~ 🔖                           ]]
  [[ ! "${output}"  =~ one                          ]]
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

  [[   "${status}"    -eq 1                         ]]

  [[   "${lines[0]}"  =~ Not\ found:                ]]
  [[   "${lines[0]}"  =~ Example\ Folder/not-valid  ]]
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

  [[   "${status}"    -eq 0                                   ]]

  [[   "${lines[0]}"  =~  [^/]home:Example\\\ Folder/3        ]]
  [[ ! "${lines[0]}"  =~  Example\\\ Folder/Sample\\\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                                  ]]

  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder      ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                      ]]
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

  [[   "${status}"    -eq 0                                   ]]

  [[   "${lines[0]}"  =~  Example\\\ Folder/3                 ]]
  [[ ! "${lines[0]}"  =~  Example\\\ Folder/Sample\\\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                                  ]]

  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder      ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                      ]]
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

  [[   "${status}"    -eq 0                                                 ]]

  [[   "${lines[0]}"  =~  Example\\\ Folder/Sample\\\ Folder/3              ]]
  [[ ! "${lines[0]}"  =~  Example\\\ Folder/Sample\\\ Folder/Demo\\\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                                ]]

  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                       ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                      ]]
  [[   "${#lines[@]}" -eq 1                                                 ]]
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

  [[   "${lines[0]}"  =~  Example\\\ Folder/3                 ]]
  [[ ! "${lines[0]}"  =~  Example\\\ Folder/Sample\\\ Folder  ]]
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

  [[ ! "${lines[0]}"  =~  Example\\\ Folder ]]
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
