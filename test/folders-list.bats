#!/usr/bin/env bats

load test_helper

# list folder ################################################################

@test "'list folder/folder/folder' exits with 0 and prints the folder/folder/folder list item." {
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

    "${_NB}" add "Example Folder/"

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

    "${_NB}" add "Example Folder/"

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
