#!/usr/bin/env bats

load test_helper

# empty #######################################################################

@test "'ls <folder>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"
  }

  run "${_NB}" ls Example\ Folder/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[4]}"  =~  0\ audio\ files\.     ]]
}

@test "'ls <id>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"
  }

  run "${_NB}" ls 1/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[4]}"  =~  0\ audio\ files\.     ]]
}

@test "'ls <folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[4]}"  =~  0\ items\.            ]]
}

@test "'ls <id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[4]}"  =~  0\ items\.            ]]
}

@test "'ls <folder>/<folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/"
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~  Sample\ Folder        ]]
  [[   "${lines[4]}"  =~  0\ items\.            ]]
}

@test "'ls <id>/<id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]
  [[   "${lines[2]}"  =~  ^📂\ Example\ Folder  ]]
  [[   "${lines[4]}"  =~  0\ items\.            ]]
}

# ls <id>/ ####################################################################

@test "'ls folder/folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ ----                 ]]
  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~ Sample\ Folder       ]]
  [[   "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]
  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]
  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}

@test "'ls folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]
  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]
  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[   "${lines[7]}"  =~ Demo                 ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]
  [[   "${lines[8]}"  =~ ----                 ]]
  [[   "${lines[9]}"  =~ add                  ]]
}

@test "'ls <id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]
  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]
  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]
  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}

@test "'<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "example-1.md"
    "${_NB}" add "example-2.md"
    "${_NB}" add "example-3.md"

    "${_NB}" add "Example Folder/"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" 4/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]
  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]
  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]
  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}

# ls folder ###################################################################

@test "'ls folder/folder/folder' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"

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

  run "${_NB}" ls Example\ Folder/Sample\ Folder/Demo\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                                 ]]

  [[   "${lines[0]}"  =~ home                                               ]]
  [[   "${lines[1]}"  =~ -----                                              ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder                                ]]
  [[   "${lines[2]}"  =~ Sample\ Folder                                     ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder                                       ]]
  [[   "${lines[3]}"  =~ ----                                               ]]

  [[   "${lines[4]}"  =~  Example\\\ Folder/Sample\\\ Folder/3              ]]
  [[ ! "${lines[4]}"  =~  Example\\\ Folder/Sample\\\ Folder/Demo\\\ Folder ]]
  [[   "${lines[4]}"  =~  📂                                                ]]

  [[ ! "${lines[4]}"  =~  Sample\ Folder/Demo\ Folder                       ]]
  [[   "${lines[4]}"  =~  Demo\ Folder                                      ]]

  [[   "${lines[5]}"  =~ ----                                               ]]
  [[   "${lines[6]}"  =~ add                                                ]]
}

@test "'ls folder/folder' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder"

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                   ]]

  [[   "${lines[0]}"  =~ home                                 ]]
  [[   "${lines[1]}"  =~ -----                                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder                  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
  [[   "${lines[3]}"  =~ ----                                 ]]

  [[   "${lines[4]}"  =~  Example\\\ Folder/3                 ]]
  [[ ! "${lines[4]}"  =~  Example\\\ Folder/Sample\\\ Folder  ]]
  [[   "${lines[4]}"  =~  📂                                  ]]

  [[ ! "${lines[4]}"  =~  Example\ Folder/Sample\ Folder      ]]
  [[   "${lines[4]}"  =~  Sample\ Folder                      ]]

  [[   "${lines[5]}"  =~ ----                                 ]]
  [[   "${lines[6]}"  =~ add                                  ]]
}

@test "'ls folder' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder

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

# ls folder/ ##################################################################

@test "'ls folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]

  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}

@test "'ls folder/folder/' exits with 0 and lists files in folder/folder in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder"

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

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[ ! "${lines[4]}"  =~ three                ]]
  [[ ! "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[ ! "${lines[5]}"  =~ two                  ]]
  [[ ! "${lines[5]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]

  [[   "${lines[4]}"  =~ Sample\ Folder       ]]
  [[   "${lines[5]}"  =~ file\ 3              ]]
  [[   "${lines[6]}"  =~ file\ 2              ]]
  [[   "${lines[7]}"  =~ file\ 1              ]]

  [[   "${lines[8]}"  =~ ----                 ]]
  [[   "${lines[9]}"  =~ add                  ]]

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[   "${lines[4]}"  =~ three                ]]
  [[   "${lines[4]}"  =~ 🔖\ 🔒               ]]
  [[   "${lines[5]}"  =~ two                  ]]
  [[   "${lines[5]}"  =~ 🔖                   ]]
  [[   "${lines[6]}"  =~ one                  ]]
  [[ ! "${lines[6]}"  =~ 🔖                   ]]
  [[ ! "${lines[6]}"  =~ 🔒                   ]]

  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}

@test "'ls folder/folder/folder/' exits with 0 and lists files in folder/folder/folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"

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

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[ ! "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[ ! "${lines[4]}"  =~  three               ]]
  [[ ! "${lines[4]}"  =~  🔖\ 🔒              ]]
  [[ ! "${lines[5]}"  =~  two                 ]]
  [[ ! "${lines[5]}"  =~  🔖                  ]]
  [[ ! "${lines[6]}"  =~  one                 ]]
  [[ ! "${lines[6]}"  =~  🔖                  ]]
  [[ ! "${lines[6]}"  =~  🔒                  ]]

  [[   "${lines[4]}"  =~  Sample\ Folder      ]]
  [[   "${lines[5]}"  =~  file\ 3             ]]
  [[   "${lines[6]}"  =~  file\ 2             ]]
  [[   "${lines[7]}"  =~  file\ 1             ]]

  [[   "${lines[8]}"  =~ ----                 ]]
  [[   "${lines[9]}"  =~ add                  ]]

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~ Sample\ Folder       ]]
  [[ ! "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[   "${lines[4]}"  =~  Demo\ Folder        ]]
  [[   "${lines[5]}"  =~  three               ]]
  [[   "${lines[5]}"  =~  🔖\ 🔒              ]]
  [[   "${lines[6]}"  =~  two                 ]]
  [[   "${lines[6]}"  =~  🔖                  ]]
  [[   "${lines[7]}"  =~  one                 ]]
  [[ ! "${lines[7]}"  =~  🔖                  ]]
  [[ ! "${lines[7]}"  =~  🔒                  ]]

  [[   "${lines[8]}"  =~ ----                 ]]
  [[   "${lines[9]}"  =~ add                  ]]

  run "${_NB}" ls Example\ Folder/Sample\ Folder/Demo\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                   ]]

  [[   "${lines[0]}"  =~ home                 ]]
  [[   "${lines[1]}"  =~ -----                ]]

  [[   "${lines[2]}"  =~ 📂\ Example\ Folder  ]]
  [[   "${lines[2]}"  =~ Sample\ Folder       ]]
  [[   "${lines[2]}"  =~ Demo\ Folder         ]]
  [[   "${lines[3]}"  =~ ----                 ]]

  [[   "${lines[4]}"  =~  Document\ Three.md  ]]
  [[   "${lines[5]}"  =~  Document\ Two.md    ]]
  [[   "${lines[6]}"  =~  Document\ One.md    ]]

  [[   "${lines[7]}"  =~ ----                 ]]
  [[   "${lines[8]}"  =~ add                  ]]
}
