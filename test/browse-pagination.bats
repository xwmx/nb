#!/usr/bin/env bats

load test_helper

@test "'browse' only includes next page link when there are remaining items." {
  {
    "${_NB}" init

    declare i=
    for   ((i=1; i < 11; i++))
    do
      declare _content="Example content ${i}."

      "${_NB}" add  "File ${i}.md"  \
        --title     "Title ${i}"    \
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

  run "${_NB}" browse --print --limit 10 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\</title\>   ]]

  printf "%s\\n" "${output}" | grep    -v -q  \
"//localhost:6789/Demo%20Notebook:?--limit=.*&--columns=.*&--page=2\">next ❯"

  run "${_NB}" browse --print --limit 5 --page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                            ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                          ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\ --page\ 2\</title\>  ]]

  printf "%s\\n" "${output}" | grep    -v -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=.*&--page=2\">next ❯"

  run "${_NB}" browse --print --limit 9 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\</title\>   ]]

  printf "%s\\n" "${output}" | grep    -v -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=.*&--page=2\">next ❯"

  {
    "${_NB}" add  "File 11.md"  \
      --title     "Title 11"    \
      --content   "Example content 11."
  }

  run "${_NB}" browse --print --limit 5 --page 2  --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                            ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                          ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\ --page\ 2\</title\>  ]]

  printf "%s\\n" "${output}" | grep    -v -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=.*&--page=3\">next ❯"
}

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

  run "${_NB}" browse --print --limit 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\</title\>   ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\"><strong><a.* href=\"//localhost:6789/?--columns=.*&--limit=2\">"
  printf "%s\\n" "${output}" | grep       -q  \
"><a.* href=\"//localhost:6789/?--columns=.*&--limit=2\"><span class=\"muted\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"muted\">·</span> <a.* href=\"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2\">"

  printf "%s\\n" "${output}" | grep       -q  \
"Demo Notebook</a> <span class=\"muted\">:</span> <a rel=\"noopener noreferrer\" href=\"//local"

  printf "%s\\n" "${output}" | grep       -q  \
"host:6789/Demo Notebook:?--columns=.*&--limit=2&--add\">+</a></strong></nav>"

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:10?--columns=.*&--limit=2\" class=\"list-item\">"
  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:9?--columns=.*&--limit=2\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep   -v  -q  \
"//localhost:6789/Demo%20Notebook:8?--columns=.*&--limit=2\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2&--page=2\">next ❯"
}


@test "'browse' encodes #hashtag queries in pagination links." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      declare _content="Example content. #example"

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

  run "${_NB}" browse --print --page 2 --limit 2 --terminal --query "#example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                    ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>  ]]

  [[ "${output}"  =~ \
\<title\>nb\ browse\ Demo\\\ Notebook:\ --query\ \"\&#35\;example\"\ --page\ 2\</title\>  ]]

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2&--query=%23example\">❮ prev"

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2&--query=%23example&--page=3\">next ❯"
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

  run "${_NB}" browse 1 --print --limit 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:1\</title\>  ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\">"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/?--columns=.*&--limit=2\"><span class=\"muted\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"muted\">·</span> <a.* href=\"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2\">Demo Notebook</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"Demo Notebook</a> <span class=\"muted\">:</span> <span class=\"muted\">1</span>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/Demo Notebook:Title Two?--columns=.*&--limit=2\">\[\[Title Two\]\]</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2&--query=%23example\">#example</a></p>"
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

  run "${_NB}" browse --notebooks --print --limit 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                            ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                          ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ \-\-notebooks\</title\> ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\">"
  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/?--columns=.*&--limit=2\"><span class=\"muted\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.*href=\"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2\">Demo${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"//localhost:6789/Example%20Notebook:?--columns=.*&--limit=2\">Example${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"//localhost:6789/Sample%20Notebook:?--columns=.*&--limit=2\">Sample${_S}Notebook</a>${_S}<span"
  printf "%s\\n" "${output}" | grep       -q  \
"span> <a.*href=\"//localhost:6789/Test%20Notebook:?--columns=.*&--limit=2\">Test${_S}Notebook</a>"
}

@test "'browse' paginates lists with --limit <limit>." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done

    sleep 1
  }

  run "${_NB}" browse --print --limit 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  printf "%s\\n" "${output}" | grep -q \
'<nav class="header-crumbs"><strong><a.* href="//localhost:6789/?--columns=.*&--limit=4"><span class="muted">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
"<span class=\"muted\">·</span> <a.* href=\"//localhost:6789/home:?--columns=.*&--limit=4\">home</a> <span "

  printf "%s\\n" "${output}" | grep -q \
"class=\"muted\">:</span> <a rel=\"noopener noreferrer\" href=\"//localhost:6789/home:?--columns=.*&--limit=4&--add\">+</a></strong></nav>"

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>     ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=2\"\>next\ ❯\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ ❮\ prev ]]

  # page 2

  sleep 1

  run "${_NB}" browse --print --limit 4 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 2\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>.*\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=4               ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=4\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>home\</a\>.*\</strong\>\</nav\>  ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\> ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>❮\ prev\</a\>\ .*\·.*\              ]]
  [[ !  "${output}"  =~ --page=1.*\"\>❮\ prev\</a\>\ .*\·.*\   ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=3\"\>next\ ❯\</a\>\</p\>  ]]

  # page 3

  sleep 1

  run "${_NB}" browse --print --limit 4 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 3\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>.*\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=4               ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=4\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>home\</a\>.*\</strong\>\</nav\>  ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=2\"\>❮\ prev\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ next\ ❯ ]]

  # page with list of items under pagination limit

  sleep 1

  run "${_NB}" browse --print --limit 11

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>\<strong\>\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=11      ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=11\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                 ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=11\"\>home\</a\>.*\</strong\>\</nav\> ]]

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\> ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>         ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>         ]]

  # pagination links

  [[ !  "${output}"  =~ \<p\ class=\"pagination\"\> ]]
  [[ !  "${output}"  =~ ❮\ prev                     ]]
  [[ !  "${output}"  =~ next\ ❯                     ]]
}

@test "'browse -<limit>' paginates list." {
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

  run "${_NB}" browse --print -2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ Demo\\\ Notebook:\</title\>   ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\"><strong><a.* href=\"//localhost:6789/?--columns=.*&--limit=2\">"
  printf "%s\\n" "${output}" | grep       -q  \
"><a.* href=\"//localhost:6789/?--columns=.*&--limit=2\"><span class=\"muted\">❯</span>nb</a>"
  printf "%s\\n" "${output}" | grep       -q  \
"<span class=\"muted\">·</span> <a.* href=\"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2\">"

  printf "%s\\n" "${output}" | grep       -q  \
"Demo Notebook</a> <span class=\"muted\">:</span> <a rel=\"noopener noreferrer\" href=\"//local"

  printf "%s\\n" "${output}" | grep       -q  \
"host:6789/Demo Notebook:?--columns=.*&--limit=2&--add\">+</a></strong></nav>"

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:10?--columns=.*&--limit=2\" class=\"list-item\">"
  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:9?--columns=.*&--limit=2\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep   -v  -q  \
"//localhost:6789/Demo%20Notebook:8?--columns=.*&--limit=2\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
"//localhost:6789/Demo%20Notebook:?--columns=.*&--limit=2&--page=2\">next ❯"
}

@test "'browse' paginates lists with -n <limit>." {
  {
    "${_NB}" init

    declare __number=
    for     __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
    done

    sleep 1
  }

  run "${_NB}" browse --print -n 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  printf "%s\\n" "${output}" | grep -q \
'<nav class="header-crumbs"><strong><a.* href="//localhost:6789/?--columns=.*&--limit=4"><span class="muted">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
"<span class=\"muted\">·</span> <a.* href=\"//localhost:6789/home:?--columns=.*&--limit=4\">home</a> <span "

  printf "%s\\n" "${output}" | grep -q \
"class=\"muted\">:</span> <a rel=\"noopener noreferrer\" href=\"//localhost:6789/home:?--columns=.*&--limit=4&--add\">+</a></strong></nav>"

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>     ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>      ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=2\"\>next\ ❯\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ ❮\ prev ]]

  # page 2

  sleep 1

  run "${_NB}" browse --print -n 4 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 2\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>.*\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=4               ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=4\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>home\</a\>.*\</strong\>\</nav\>  ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\> ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[ !  "${output}"  =~  \
\<p\>\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>       ]]
  [[ !  "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>❮\ prev\</a\>\ .*\·.*\       ]]
  [[ !  "${output}"  =~ --page=1.*\"\>❮\ prev\</a\>\ .*\·.*\   ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=3\"\>next\ ❯\</a\>\</p\> ]]

  # page 3

  sleep 1

  run "${_NB}" browse --print -n 4 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\ \-\-page\ 3\</title\>  ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>.*\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=4               ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=4\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                  ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4\"\>home\</a\>.*\</strong\>\</nav\>  ]]

  # 10-7

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>  ]]
  [[ !  "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[ !  "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[ !  "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=4\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>    ]]

  # pagination links

  [[    "${output}"  =~ \<p\ class=\"pagination\"\>      ]]
  [[    "${output}"  =~ \
\<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=4${_AMP}--page=2\"\>❮\ prev\</a\>\</p\>  ]]
  [[ !  "${output}"  =~ next\ ❯ ]]

  # page with list of items under pagination limit

  sleep 1

  run "${_NB}" browse --print -n 11

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                      ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                    ]]

  [[ "${output}"  =~ \<title\>nb\ browse\ home:\</title\>   ]]

  [[ "${output}"  =~ \
\<nav\ class=\"header-crumbs\"\>\<strong\>\<a.*\ href=\"//localhost:6789/\?--columns=.*${_AMP}--limit=11      ]]
  [[ "${output}"  =~ \
localhost:6789/\?--columns=.*${_AMP}--limit=11\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>                 ]]
  [[ "${output}"  =~ \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*${_AMP}--limit=11\"\>home\</a\>.*\</strong\>\</nav\> ]]

  # 10-7

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:10\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>  ]]
  [[    "${output}"  =~  \
.*\[.*home:10.*\].*${_S}Title${_S}Ten\</a\>\<br\>        ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:9\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:9.*\].*${_S}${_S}Title${_S}Nine\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:8\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:8.*\].*${_S}${_S}Title${_S}Eight\</a\>\<br\>  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:7\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:7.*\].*${_S}${_S}Title${_S}Seven\</a\>\<br\>  ]]

  # 6-3

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:6\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:6.*\].*${_S}${_S}Title${_S}Six\</a\>\<br\>    ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:5\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:5.*\].*${_S}${_S}Title${_S}Five\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:4\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:4.*\].*${_S}${_S}Title${_S}Four\</a\>\<br\>   ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  \
.*\[.*home:3.*\].*${_S}${_S}Title${_S}Three\</a\>\<br\>  ]]

  # 2-1

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  .*\[.*home:2.*\].*${_S}${_S}Title${_S}Two\</a\>\<br\>                  ]]

  [[    "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*${_AMP}--limit=11\"\ class=\"list-item\"\>   ]]
  [[    "${output}"  =~  .*\[.*home:1.*\].*${_S}${_S}Title${_S}One\</a\>\<br\>                  ]]

  # pagination links

  [[ !  "${output}"  =~ \<p\ class=\"pagination\"\> ]]
  [[ !  "${output}"  =~ ❮\ prev                     ]]
  [[ !  "${output}"  =~ next\ ❯                     ]]
}
