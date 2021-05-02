#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# local notebook ##############################################################

@test "'browse --query <query>' serves the search results from the local notebooks as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add  "File One.md"       \
      --title     "Title One"         \
      --content   "Example content."

    "${_NB}" add  "File Two.md"       \
      --title     "Title Two"         \
      --content   "Example abcd efgh content."

    "${_NB}" add  "Example Folder"    \
      --type      "folder"

    declare _expected_param_pattern="--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook\&--per-page=.*"

    sleep 1
  }

  run "${_NB}" browse --print --query "abcd efgh"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                                             ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\>                           ]]

  # header crumbs

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?${_expected_param_pattern}\"\> ]]
  [[ "${output}"  =~  \
href=\"http://localhost:6789/\?${_expected_param_pattern}\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>   ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/local:\?${_expected_param_pattern}\"\>local\</a\>.*\</h1\>    ]]

  # form

  [[ "${output}"  =~  \
action=\"/local:\?--per-page=.*\&--columns=.*\&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook\" ]]

  [[ "${output}"  =~  value=\"abcd\ efgh\"\>                                                ]]

  [[ "${output}"  =~  \
\<input\ type=\"hidden\"\ name=\"--local\"\ \ \ \ \ value=\"${_TMP_DIR}/Local\ Notebook\"\> ]]

  # list

  [[ !  "${output}" =~  \
\<a.*\ href=\"http://localhost:6789/local:3\?--per-page=.*\&--local=.*\"\ class=\"list-item\"\> ]]
  [[ !  "${output}" =~  .*\[.*local:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\>           ]]

  [[    "${output}" =~  \
\<a.*\ href=\"http://localhost:6789/local:2\?--per-page=.*\"\ class=\"list-item\"\>         ]]
  [[    "${output}" =~  .*\[.*local:2.*\].*${_S}Title${_S}Two\</a\>\<br\>                   ]]

  [[ !  "${output}" =~  \
\<a.*\ href=\"http://localhost:6789/local:1\?--per-page=.*\"\ class=\"list-item\"\>         ]]
  [[ !  "${output}" =~  .*\[.*local:1.*\].*${_S}Title${_S}One\</a\>\<br\>                   ]]
}

# normalization ###############################################################

@test "'browse --container --query' with spaces performs search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcd efgh two."

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -s "http://localhost:6789/home:?--query=abcd%20efgh"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  [[ !  "${output}"   =~ Title\ One ]]

  [[    "${output}"   =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\>    ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\> ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\>    ]]

  {
    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -s "http://localhost:6789/home:?--query=abcd+efgh"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  [[ !  "${output}"   =~ Title\ One ]]

  [[    "${output}"   =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\>    ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\> ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\>    ]]
}

# no matches ##################################################################

@test "'browse --container --query' with no match displays page with message." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content abcde two."
  }

  run "${_NB}" browse --container --query "non-matching-query"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0 ]]

  printf "%s\\n" "${output}" | grep   -q \
    "Not found: non-matching-query"

  printf "%s\\n" "${output}" | grep   -q \
    "placeholder=\"search\"${_NEWLINE}type=\"text\"${_NEWLINE}value=\"non-matching-query\">"
}

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

  [[    "${status}"  -eq  0                       ]]

  [[    "${output}"  =~   placeholder=\"search\"  ]]
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

  [[    "${status}"  -eq  0                       ]]

  [[ !  "${output}"  =~   placeholder=\"search\"  ]]
}

# query #######################################################################

@test "'browse --container --query' with tag performs search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content #abcde two."
  }

  run "${_NB}" browse --container --query "#abcde"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  [[ !  "${output}"   =~ Title\ One ]]

  [[    "${output}"   =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\>    ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\> ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\>    ]]
}

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
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\>    ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\> ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\>    ]]
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

  printf "%s\\n" "${output}" | grep -v  -q \
    "Title One"

  printf "%s\\n" "${output}" | grep     -q \
    "placeholder=\"search\"${_NEWLINE}type=\"text\"${_NEWLINE}value=\"abcde\">"

  printf "%s\\n" "${output}" | grep     -q \
    "<a.* href=\"http://localhost:6789/home:2?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep     -q \
    "class=\"list-item\"><span class=\"dim\">\[</span><span class=\"identifier\">"

  printf "%s\\n" "${output}" | grep     -q \
    "identifier\">2</span><span class=\"dim\">\]</span> Title Two</a><br>"
}

@test "'browse --query \"<#hashtag>|<#hashtag>\"' performs OR search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --title "Title One"   --content "Content one."
    "${_NB}" add "File Two.md"    --title "Title Two"   --content "Content #xyz two."
    "${_NB}" add "File Three.md"  --title "Title Three" --content "Content #abcde three. #xyz"
    "${_NB}" add "File Four.md"   --title "Title Four"  --content "Content #abcde four."
    "${_NB}" add "File Five.md"   --title "Title Five"  --content "Content #xyz five. #abcde"
  }


  run "${_NB}" browse --query "#xyz|#abcde" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0                               ]]

  [[    "${output}" =~ value=\"\&#35\;xyz\|\&#35\;abcde\" ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[ !  "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

}

@test "'browse --query <#hashtag> <#hashtag>' performs AND search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --title "Title One"   --content "Content one."
    "${_NB}" add "File Two.md"    --title "Title Two"   --content "Content #xyz two."
    "${_NB}" add "File Three.md"  --title "Title Three" --content "Content #abcde three. #xyz"
    "${_NB}" add "File Four.md"   --title "Title Four"  --content "Content #abcde four."
    "${_NB}" add "File Five.md"   --title "Title Five"  --content "Content #xyz five. #abcde"
  }

  run "${_NB}" browse --query "#xyz #abcde" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0                               ]]

  [[    "${output}" =~ value=\"\&#35\;xyz\ \&#35\;abcde\" ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:5\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[ !  "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:4\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[    "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[ !  "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]

  [[ !  "${output}" =~ \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=.*\&--columns=.*\"\ class=\"list-item\"\>\<span\  ]]
}

@test "'browse --query <#hashtag>' performs search." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md" --title "Title One" --content "Content one."
    "${_NB}" add "File Two.md" --title "Title Two" --content "Content #abcde two."
  }

  run "${_NB}" browse --query "#abcde" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0         ]]

  printf "%s\\n" "${output}" | grep -v  -q \
    "Title One"

  printf "%s\\n" "${output}" | grep     -q \
    "placeholder=\"search\"${_NEWLINE}type=\"text\"${_NEWLINE}value=\"#abcde\">"

  printf "%s\\n" "${output}" | grep     -q \
    "<a.* href=\"http://localhost:6789/home:2?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep     -q \
    "class=\"list-item\"><span class=\"dim\">\[</span><span class=\"identifier\">"

  printf "%s\\n" "${output}" | grep     -q \
    "identifier\">2</span><span class=\"dim\">\]</span> Title Two</a><br>"
}

@test "'browse --query' performs paginated search." {
  {
    "${_NB}" init

    local _counter=0
    local __number=
    for   __number in One Two Three Four Five Six Seven Eight Nine Ten
    do
      _counter="$((_counter+1))"

      if (($((_counter % 2))))
      then
        "${_NB}" add "File ${__number}.md" --title "Title ${__number}"
      else
        "${_NB}" add "File ${__number}.md" --title "Title ${__number}" \
          --content "abcde${_NEWLINE}${_NEWLINE}abcde"
      fi
    done
  }

  run "${_NB}" browse --query "abcde" --print --per-page 2 --page 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0               ]]

  [[    "${output}"   =~ Title${_S}Eight  ]]
  [[    "${output}"   =~ Title${_S}Four   ]]

  [[ !  "${output}"   =~ Title${_S}Six    ]]
  [[ !  "${output}"   =~ Title${_S}Ten    ]]

  [[ !  "${output}"   =~ Title${_S}Two    ]]

  run "${_NB}" browse --query "abcde" --print --per-page 2 --page 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0               ]]

  [[ !  "${output}"   =~ Title${_S}Eight  ]]
  [[ !  "${output}"   =~ Title${_S}Four   ]]

  [[    "${output}"   =~ Title${_S}Six    ]]
  [[    "${output}"   =~ Title${_S}Ten    ]]

  [[ !  "${output}"   =~ Title${_S}Two    ]]

  run "${_NB}" browse --query "abcde" --print --per-page 2 --page 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0               ]]

  [[ !  "${output}"   =~ Title${_S}Eight  ]]
  [[ !  "${output}"   =~ Title${_S}Four   ]]

  [[ !  "${output}"   =~ Title${_S}Six    ]]
  [[ !  "${output}"   =~ Title${_S}Ten    ]]

  [[    "${output}"   =~ Title${_S}Two    ]]
}
