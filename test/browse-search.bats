#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# search form #################################################################

@test "'browse' with container displays search form." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcde two."
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0             ]]

  [[    "${output}"  =~   search-input  ]]
}

@test "'browse' with item does not display search form." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcde two."
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0             ]]

  [[ !  "${output}"  =~   search-input  ]]
}

# query #######################################################################

@test "'browse --container --query' performs search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcde two."
  }

  run "${_NB}" browse --container --query "abcde"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  [[ !  "${output}"   =~ Title\ One ]]

  [[    "${output}"   =~  \
    \<p\>\<br/\>\ \<a\ href=\"http://localhost:6789/2\"\ class=\"list-item\"\>                ]]
  [[    "${output}"   =~   \
    class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\>     ]]
  [[    "${output}"   =~   \
    identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br/\>\</p\> ]]
}

@test "'browse --query' performs search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcde two."
  }

  run "${_NB}" browse --query "abcde" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  [[ !  "${output}"   =~ Title\ One ]]

  [[    "${output}"  =~   \
    \<p\>\<br/\>\ \<a\ href=\"http://localhost:6789/2\"\ class=\"list-item\"\>                ]]
  [[    "${output}"  =~   \
    class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\>     ]]
  [[    "${output}"  =~   \
    identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br/\>\</p\> ]]
}
