#!/usr/bin/env bats

load test_helper

# non-breaking space
export _S=" "

@test "'browse' paginates lists." {
  {
    "${_NB}" init

    local __number=
    for   __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done
  }

  run "${_NB}" browse --print --per-page 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~ \
        \<h1\ class=\"header-crumbs\"\ id=\"nb-home\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
        .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>.*\</h1\>     ]]

  # 10-7

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\ class=\"list-item\"\> ]]
  [[    "${output}"  =~  \
          .*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\ /\>                    ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\ /\>              ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:7\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\ /\>              ]]

  # 6-3

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:6\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\ /\>                ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:5\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:3\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\ /\>              ]]

  # 2-1

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:2\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\ /\>                ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:1\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\ /\>                ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=2\&amp\;--per-page=4\"\>next\ ❯\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ ❮\ prev                                                                             ]]

  # page 2

  run "${_NB}" browse --print --per-page 4 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~ \
        \<h1\ class=\"header-crumbs\"\ id=\"nb-home\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
        .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>.*\</h1\>     ]]

  # 10-7

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\ class=\"list-item\"\> ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\ /\>                    ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\ /\>              ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:7\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\ /\>              ]]

  # 6-3

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:6\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
          .*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\ /\>                ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:5\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:3\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\ /\>              ]]

  # 2-1

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:2\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\ /\>                ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:1\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\ /\>                ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=1\&amp\;--per-page=4\"\>❮\ prev\</a\>\ .*\·.*\   ]]
  [[    "${output}"  =~ \
          \<a\ href=\"http://localhost:6789/home:\?--page=3\&amp\;--per-page=4\"\>next\ ❯\</a\>\</p\>           ]]

  # page 3

  run "${_NB}" browse --print --per-page 4 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~ \
        \<h1\ class=\"header-crumbs\"\ id=\"nb-home\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
        .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>.*\</h1\>     ]]

  # 10-7

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\ class=\"list-item\"\> ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\ /\>                    ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\ /\>              ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:7\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\ /\>              ]]

  # 6-3

  [[ !  "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:6\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\ /\>                ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:5\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\ /\>               ]]

  [[ !  "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:3\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
          .*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\ /\>              ]]

  # 2-1

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:2\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
          .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\ /\>                ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:1\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\ /\>                ]]

  # pagination links

  [[    "${output}"  =~ \
          \<p\>\<a\ href=\"http://localhost:6789/home:\?--page=2\&amp\;--per-page=4\"\>❮\ prev\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ next\ ❯ ]]

  # page with list of items under pagination limit

  run "${_NB}" browse --print --per-page 11

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                          ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                        ]]

  [[ "${output}"  =~ \
        \<h1\ class=\"header-crumbs\"\ id=\"nb-home\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
        .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>.*\</h1\>     ]]

  # 10-7

  [[    "${output}"  =~  \
          \<p\>\<a\ href=\"http://localhost:6789/home:10\"\ class=\"list-item\"\> ]]
  [[    "${output}"  =~  \
          .*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\ /\>                    ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:9\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:8\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\ /\>              ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:7\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\ /\>              ]]

  # 6-3

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:6\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\ /\>                ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:5\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\ /\>               ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:3\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
          .*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\ /\>              ]]

  # 2-1

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:2\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\ /\> ]]

  [[    "${output}"  =~  \
          \<a\ href=\"http://localhost:6789/home:1\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\ /\> ]]

  # pagination links

  [[ !  "${output}"  =~ ❮\ prev ]]
  [[ !  "${output}"  =~ next\ ❯ ]]
}
