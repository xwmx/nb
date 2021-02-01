#!/usr/bin/env bats

load test_helper

export NB_BROWSE_PER_PAGE=4

@test "'browse' paginates lists." {
  {
    "${_NB}" init

    local __number=
    for   __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>\</h1\>       ]]

  # 10-7

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\>    ]]
  [[    "${output}"  =~  \[home:10\]\ Title\ Ten\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\>          ]]
  [[    "${output}"  =~  \[home:9\]\ Title\ Nine\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\>          ]]
  [[    "${output}"  =~  \[home:8\]\ Title\ Eight\</a\>\<br/\>  ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:7\"\>           ]]
  [[    "${output}"  =~  \[home:7\]\ Title\ Seven\</a\>\<br/\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:6\"\>      ]]
  [[ !  "${output}"  =~  \[home:6\]\ Title\ Six\</a\>\<br/\>    ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:5\"\>           ]]
  [[ !  "${output}"  =~  \[home:5\]\ Title\ Five\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:4\"\>           ]]
  [[ !  "${output}"  =~  \[home:4\]\ Title\ Four\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:3\"\>           ]]
  [[ !  "${output}"  =~  \[home:3\]\ Title\ Three\</a\>\<br/\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:2\"\>      ]]
  [[ !  "${output}"  =~  \[home:2\]\ Title\ Two\</a\>\<br/\>    ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:1\"\>           ]]
  [[ !  "${output}"  =~  \[home:1\]\ Title\ One\</a\>\<br/\>    ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=2\"\>Next\ Page\ ❯\</a\>\</p\> ]]
  [[ !  "${output}"  =~ ❮\ Prev\ Page                                                         ]]

  # page 2

  run "${_NB}" browse --print --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>\</h1\>       ]]

  # 10-7

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\>    ]]
  [[ !  "${output}"  =~  \[home:10\]\ Title\ Ten\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\>          ]]
  [[ !  "${output}"  =~  \[home:9\]\ Title\ Nine\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\>          ]]
  [[ !  "${output}"  =~  \[home:8\]\ Title\ Eight\</a\>\<br/\>  ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:7\"\>           ]]
  [[ !  "${output}"  =~  \[home:7\]\ Title\ Seven\</a\>\<br/\>  ]]

  # 6-3

  [[    "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:6\"\>      ]]
  [[    "${output}"  =~  \[home:6\]\ Title\ Six\</a\>\<br/\>    ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:5\"\>           ]]
  [[    "${output}"  =~  \[home:5\]\ Title\ Five\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:4\"\>           ]]
  [[    "${output}"  =~  \[home:4\]\ Title\ Four\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:3\"\>           ]]
  [[    "${output}"  =~  \[home:3\]\ Title\ Three\</a\>\<br/\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:2\"\>      ]]
  [[ !  "${output}"  =~  \[home:2\]\ Title\ Two\</a\>\<br/\>    ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:1\"\>           ]]
  [[ !  "${output}"  =~  \[home:1\]\ Title\ One\</a\>\<br/\>    ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=1\"\>❮\ Prev\ Page\</a\>\ \·\  ]]
  [[    "${output}"  =~ \
          \<a\ href=\"http://localhost:6789/home:\?--page=3\"\>Next\ Page\ ❯\</a\>\</p\>      ]]

  # page 3

  run "${_NB}" browse --print --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>\</h1\>       ]]

  # 10-7

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\>    ]]
  [[ !  "${output}"  =~  \[home:10\]\ Title\ Ten\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\>          ]]
  [[ !  "${output}"  =~  \[home:9\]\ Title\ Nine\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\>          ]]
  [[ !  "${output}"  =~  \[home:8\]\ Title\ Eight\</a\>\<br/\>  ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:7\"\>           ]]
  [[ !  "${output}"  =~  \[home:7\]\ Title\ Seven\</a\>\<br/\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:6\"\>      ]]
  [[ !  "${output}"  =~  \[home:6\]\ Title\ Six\</a\>\<br/\>    ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:5\"\>           ]]
  [[ !  "${output}"  =~  \[home:5\]\ Title\ Five\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:4\"\>           ]]
  [[ !  "${output}"  =~  \[home:4\]\ Title\ Four\</a\>\<br/\>   ]]

  [[ !  "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:3\"\>           ]]
  [[ !  "${output}"  =~  \[home:3\]\ Title\ Three\</a\>\<br/\>  ]]

  # 2-1

  [[    "${output}"  =~  \
         \<p\>\<a\ href=\"http://localhost:6789/home:2\"\>      ]]
  [[    "${output}"  =~  \[home:2\]\ Title\ Two\</a\>\<br/\>    ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:1\"\>           ]]
  [[    "${output}"  =~  \[home:1\]\ Title\ One\</a\>\<br/\>    ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=2\"\>❮\ Prev\ Page\</a\>\</p\> ]]
  [[ !  "${output}"  =~ Next\ Page\ ❯                                                         ]]

  # page 3

  NB_BROWSE_PER_PAGE=11 run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>\</h1\>       ]]

  # 10-7

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\>    ]]
  [[    "${output}"  =~  \[home:10\]\ Title\ Ten\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\>          ]]
  [[    "${output}"  =~  \[home:9\]\ Title\ Nine\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\>          ]]
  [[    "${output}"  =~  \[home:8\]\ Title\ Eight\</a\>\<br/\>  ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:7\"\>           ]]
  [[    "${output}"  =~  \[home:7\]\ Title\ Seven\</a\>\<br/\>  ]]

  # 6-3

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:6\"\>           ]]
  [[    "${output}"  =~  \[home:6\]\ Title\ Six\</a\>\<br/\>    ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:5\"\>           ]]
  [[    "${output}"  =~  \[home:5\]\ Title\ Five\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:4\"\>           ]]
  [[    "${output}"  =~  \[home:4\]\ Title\ Four\</a\>\<br/\>   ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:3\"\>           ]]
  [[    "${output}"  =~  \[home:3\]\ Title\ Three\</a\>\<br/\>  ]]

  # 2-1

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:2\"\>           ]]
  [[    "${output}"  =~  \[home:2\]\ Title\ Two\</a\>\<br/\>    ]]

  [[    "${output}"  =~  \
         \<a\ href=\"http://localhost:6789/home:1\"\>           ]]
  [[    "${output}"  =~  \[home:1\]\ Title\ One\</a\>\<br/\>    ]]

  # pagination links

  [[ !  "${output}"  =~ ❮\ Prev\ Page                           ]]
  [[ !  "${output}"  =~ Next\ Page\ ❯                           ]]
}
