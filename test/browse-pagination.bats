#!/usr/bin/env bats

load test_helper

# non-breaking space
export _S=" "

# configurable as escaped &amp; or &
export _AMP="&"

@test "'browse' includes pagination on links on listing page." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      declare _content="Example content."

      case "${__number}" in
        One)
          _content+=" [[Title Two]] • #example"
          ;;
        Two|Three|Six|Seven|Nine)
          _content+=" #example"
          ;;
      esac

      "${_NB}" add  "File ${__number}.md" \
        --title     "Title ${__number}"   \
        --content   "${_content}"
    done

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]

    sleep 1
  }

  run "${_NB}" browse --print --per-page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\</title\>   ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\"><h1><a.* href=\"http://localhost:6789/?--per-page=2&--columns=.*\">"
  printf "%s\\n" "${output}" | grep       -q  \
"><a.* href=\"http://localhost:6789/?--per-page=2&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"dim\">·</span> <a.* href=\"http://localhost:6789/Demo%20Notebook:?--per-page=2&--columns=.*\">"

  printf "%s\\n" "${output}" | grep       -q  \
"Demo Notebook</a> <span class=\"dim\">:</span> <a rel=\"noopener noreferrer\" href=\"http://local"

  printf "%s\\n" "${output}" | grep       -q  \
"host:6789/Demo Notebook:?--per-page=2&--columns=.*&--add\">+</a></h1>"

  printf "%s\\n" "${output}" | grep       -q  \
"http://localhost:6789/Demo%20Notebook:10?--per-page=2&--columns=.*\" class=\"list-item\">"
  printf "%s\\n" "${output}" | grep       -q  \
"http://localhost:6789/Demo%20Notebook:9?--per-page=2&--columns=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep   -v  -q  \
"http://localhost:6789/Demo%20Notebook:8?--per-page=2&--columns=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
"http://localhost:6789/Demo%20Notebook:?--per-page=2&--columns=.*&--page=2\">next ❯"
}

@test "'browse' includes pagination on links on item page." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      declare _content="Example content."

      case "${__number}" in
        One)
          _content+=" [[Title Two]] • #example"
          ;;
        Two|Three|Six|Seven|Nine)
          _content+=" #example"
          ;;
      esac

      "${_NB}" add  "File ${__number}.md" \
        --title     "Title ${__number}"   \
        --content   "${_content}"
    done

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]

    sleep 1
  }

  run "${_NB}" browse 1 --print --per-page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:1\</title\>  ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\"><h1>"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/?--per-page=2&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"dim\">·</span> <a.* href=\"http://localhost:6789/Demo%20Notebook:?--per-page=2&--columns=.*\">Demo Notebook</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"Demo Notebook</a> <span class=\"dim\">:</span> <span class=\"dim\">1</span>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/Demo Notebook:Title Two?--per-page=2&--columns=.*\">\[\[Title Two\]\]</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/Demo%20Notebook:?--per-page=2&--columns=.*&--query=%23example\">#example</a></p>"
}

@test "'browse' includes pagination on links on notebooks page." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      declare _content="Example content."

      case "${__number}" in
        One)
          _content+=" [[Title Two]] • #example"
          ;;
        Two|Three|Six|Seven|Nine)
          _content+=" #example"
          ;;
      esac

      "${_NB}" add  "File ${__number}.md" \
        --title     "Title ${__number}"   \
        --content   "${_content}"
    done

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]

    sleep 1
  }

  run "${_NB}" browse --notebooks --print --per-page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                            ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                          ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ \-\-notebooks\</title\> ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\"><h1>"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/?--per-page=2&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"dim\">·</span> <span class=\"dim\">notebooks</span>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.*href=\"http://localhost:6789/Demo%20Notebook:?--per-page=2&--columns=.*\">Demo${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"http://localhost:6789/Example%20Notebook:?--per-page=2&--columns=.*\">Example${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"http://localhost:6789/Sample%20Notebook:?--per-page=2&--columns=.*\">Sample${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"http://localhost:6789/Test%20Notebook:?--per-page=2&--columns=.*\">Test${_S}Notebook</a>"
}

@test "'browse' paginates lists." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done

    sleep 1
  }

  run "${_NB}" browse --print --per-page 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  printf "%s\\n" "${output}" | grep -q \
'<nav class="header-crumbs"><h1><a.* href="http://localhost:6789/?--per-page=4&--columns=.*"><span class="dim">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
"<span class=\"dim\">·</span> <a.* href=\"http://localhost:6789/home:?--per-page=4&--columns=.*\">home</a> <span "

  printf "%s\\n" "${output}" | grep -q \
"class=\"dim\">:</span> <a rel=\"noopener noreferrer\" href=\"http://localhost:6789/home:?--per-page=4&--columns=.*&--add\">+</a></h1>"

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:10\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>     ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:9\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:8\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:7\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:6\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*${_AMP}--page=2\"\>next\ ❯\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ ❮\ prev ]]

  # page 2

  sleep 1

  run "${_NB}" browse --print --per-page 4 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 2\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=4${_AMP}--columns=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*\"\>home\</a\>.*\</h1\>    ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/home:10\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:9\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:8\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:7\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:6\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*\"\>❮\ prev\</a\>\ .*\·.*\        ]]
  [[ !  "${output}"  =~ --page=1.*\"\>❮\ prev\</a\>\ .*\·.*\   ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*${_AMP}--page=3\"\>next\ ❯\</a\>\</p\>      ]]

  # page 3

  sleep 1

  run "${_NB}" browse --print --per-page 4 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 3\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=4${_AMP}--columns=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*\"\>home\</a\>.*\</h1\>    ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:10\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\> ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:9\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:8\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:7\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:6\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=4${_AMP}--columns=.*\"\ class=\"list-item\"\>        ]]
  [[    "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"http://localhost:6789/home:\?--per-page=4${_AMP}--columns=.*${_AMP}--page=2\"\>❮\ prev\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ next\ ❯ ]]

  # page with list of items under pagination limit

  sleep 1

  run "${_NB}" browse --print --per-page 11

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>\<h1\>\<a.*\ href=\"http://localhost:6789/\?--per-page=11${_AMP}--columns=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=11${_AMP}--columns=.*\"\>home\</a\>.*\</h1\>   ]]

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:10\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:9\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:8\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:7\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:6\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>         ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=11${_AMP}--columns=.*\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>         ]]

  # pagination links

  [[ !  "${output}"  =~ \<p\ class=\"pagination\"\> ]]
  [[ !  "${output}"  =~ ❮\ prev                     ]]
  [[ !  "${output}"  =~ next\ ❯                     ]]
}
