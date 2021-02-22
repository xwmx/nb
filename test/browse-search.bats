#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

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
    "placeholder=\"search\" type=\"text\" value=\"non-matching-query\">"
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
\<p\>\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\> ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\>   ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\ /\>   ]]
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
\<p\>\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\> ]]
  [[    "${output}"   =~   \
class=\"list-item\"\>\<span\ class=\"dim\"\>\[\</span\>\<span\ class=\"identifier\"\>   ]]
  [[    "${output}"   =~   \
identifier\"\>2\</span\>\<span\ class=\"dim\"\>\]\</span\>\ Title\ Two\</a\>\<br\ /\>   ]]
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
    "placeholder=\"search\" type=\"text\" value=\"abcde\">"

  printf "%s\\n" "${output}" | grep     -q \
    "<p><a.* href=\"http://localhost:6789/home:2?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep     -q \
    "class=\"list-item\"><span class=\"dim\">\[</span><span class=\"identifier\">"

  printf "%s\\n" "${output}" | grep     -q \
    "identifier\">2</span><span class=\"dim\">\]</span> Title Two</a><br />"
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
    "placeholder=\"search\" type=\"text\" value=\"#abcde\">"

  printf "%s\\n" "${output}" | grep     -q \
    "<p><a.* href=\"http://localhost:6789/home:2?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep     -q \
    "class=\"list-item\"><span class=\"dim\">\[</span><span class=\"identifier\">"

  printf "%s\\n" "${output}" | grep     -q \
    "identifier\">2</span><span class=\"dim\">\]</span> Title Two</a><br />"
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
