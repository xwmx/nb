#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# HTML <title> ################################################################

@test "'browse edit <folder>/<folder>/<file>' with local notebook sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse edit Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ edit\ local:1/1/1\</title\>    ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse edit <folder>/<folder>/<file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse edit Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ edit\ home:1/1/1\</title\>     ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse edit <file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse edit 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ edit\ home:1\</title\>         ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse edit <notebook>:<file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse edit Example\ Notebook:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                    ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                  ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ edit\ Example\\\ Notebook:1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                ]]
}

@test "'browse edit <folder>/<file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse edit Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                  ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ edit\ home:1/1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                              ]]
}

# POST ########################################################################

@test "POST to --edit URL updates the note and prints form."  {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --title "Example Title" --content "Example content."

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D -                                                 \
    --data "content=Line%20one.%0D%0A%0D%0ALine%20%2F%26%3F%20two." \
    "http://localhost:6789/home:1?--edit"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Updates file:

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(printf "Line one.\\n\\nLine /&? two.\\n")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:1?--edit"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"
}

# local notebook ##############################################################

@test "POST to --edit URL with local notebook updates the note and prints form."  {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add "Example File.md" --title "Example Title" --content "Example content."

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data  \
    "content=Updated"       \
    "http://localhost:6789/local:1?--edit&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Updates file:

  diff                                                  \
    <(cat "${_TMP_DIR}/Local Notebook/Example File.md") \
    <(printf "Updated\\n")

  # Creates git commit:

  cd "${_TMP_DIR}/Local Notebook" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*local.*\ .*:.*\ .*1     ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/local:1?--edit&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"
}

@test "GET to --edit URL with local notebook renders form." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add  "Example Folder/File One.js"  \
      --content   "console.log('example');"

    # shellcheck disable=2129
    printf "export NB_TESTING=1\\n"               >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/local:1/1?--edit&--example&-x&abcdefg&--sample=demo-value&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                              ]]
  [[    "${lines[1]}"  =~  Date:\ .*                                      ]]
  [[    "${lines[2]}"  =~  Expires:\ .*                                   ]]
  [[    "${lines[3]}"  =~  Server:\ nb                                    ]]
  [[    "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8      ]]

  [[    "${output}"    =~ \
action=\"/local:1/1\?--edit\&--per-page=.*\&--columns=.*\&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook ]]

  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"--example\"\>  ]]
  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"-x\"\>         ]]
  [[    "${output}"    =~ \
\<input\ type=\"hidden\"\ name=\"--sample\"\ value=\"demo-value\"\>       ]]

  [[ !  "${output}"    =~ \<input\ type=\"hidden\"\ name=\"abcdefg\"\>    ]]
}

# option parameters ###########################################################

@test "GET to --edit URL with option parameters adds hidden form fields." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.js"  \
      --content   "console.log('example');"

    # shellcheck disable=2129
    printf "export NB_TESTING=1\\n"               >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/1?--edit&--example&-x&abcdefg&--sample=demo-value"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                              ]]
  [[    "${lines[1]}"  =~  Date:\ .*                                      ]]
  [[    "${lines[2]}"  =~  Expires:\ .*                                   ]]
  [[    "${lines[3]}"  =~  Server:\ nb                                    ]]
  [[    "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8      ]]

  [[    "${output}"    =~ action=\"/home:1/1\?--edit                      ]]

  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"--example\"\>  ]]
  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"-x\"\>         ]]
  [[    "${output}"    =~ \
\<input\ type=\"hidden\"\ name=\"--sample\"\ value=\"demo-value\"\>       ]]

  [[ !  "${output}"    =~ \<input\ type=\"hidden\"\ name=\"abcdefg\"\>    ]]
}

# ace editor ##################################################################

@test "GET to --edit URL with Ace enabled sets the theme with \$NB_ACE_THEME." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.js"  \
      --content   "console.log('example');"

    # shellcheck disable=2129
    printf "export NB_ACE_ENABLED=1\\n"           >> "${NBRC_PATH}"
    printf "export NB_ACE_THEME=\"ambiance\"\\n"  >> "${NBRC_PATH}"
    printf "export NB_TESTING=1\\n"               >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/1?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                              ]]
  [[    "${lines[1]}"  =~  Date:\ .*                                      ]]
  [[    "${lines[2]}"  =~  Expires:\ .*                                   ]]
  [[    "${lines[3]}"  =~  Server:\ nb                                    ]]
  [[    "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8      ]]

  [[    "${output}"    =~ action=\"/home:1/1\?--edit                      ]]

  [[    "${output}"    =~ initializeAceEditor                             ]]
  [[    "${output}"    =~ editor\.setTheme\(\'ace\/theme\/ambiance\'\)\;  ]]
}

@test "GET to --edit URL with Ace enabled and non-default extension includes initialization with updated mode." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.js"  \
      --content   "console.log('example');"

    printf "export NB_ACE_ENABLED=1\\n" >> "${NBRC_PATH}"
    printf "export NB_TESTING=1\\n"     >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/1?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                                  ]]
  [[    "${lines[1]}"  =~  Date:\ .*                                          ]]
  [[    "${lines[2]}"  =~  Expires:\ .*                                       ]]
  [[    "${lines[3]}"  =~  Server:\ nb                                        ]]
  [[    "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8          ]]

  [[    "${output}"    =~ action=\"/home:1/1\?--edit                          ]]

  [[    "${output}"    =~ initializeAceEditor                                 ]]
  [[    "${output}"    =~ aceModeList\.getModeForPath\(\'example.js\'\)\.mode ]]
}

@test "GET to --edit URL with Ace un-enabled does not include initialization." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    printf "export NB_ACE_ENABLED=0\\n" >> "${NBRC_PATH}"
    printf "export NB_TESTING=1\\n"     >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/1?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                                  ]]
  [[    "${lines[1]}"  =~  Date:\ .*                                          ]]
  [[    "${lines[2]}"  =~  Expires:\ .*                                       ]]
  [[    "${lines[3]}"  =~  Server:\ nb                                        ]]
  [[    "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8          ]]

  [[    "${output}"    =~ action=\"/home:1/1\?--edit                          ]]


  [[ !  "${output}"    =~ initializeAceEditor                                 ]]
  [[ !  "${output}"    =~ aceModeList\.getModeForPath\(\'example.md\'\)\.mode ]]
}

@test "GET to --edit URL with Ace enabled includes initialization with default mode and theme." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    printf "export NB_ACE_ENABLED=1\\n" >> "${NBRC_PATH}"
    printf "export NB_TESTING=1\\n"     >> "${NBRC_PATH}"

    (ncat                                       \
      --exec "${_NB} browse --respond"          \
      --listen                                  \
      --source-port "6789"                      \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/1?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~ HTTP/1.0\ 200\ OK                                   ]]
  [[    "${lines[1]}"  =~ Date:\ .*                                           ]]
  [[    "${lines[2]}"  =~ Expires:\ .*                                        ]]
  [[    "${lines[3]}"  =~ Server:\ nb                                         ]]
  [[    "${lines[4]}"  =~ Content-Type:\ text/html\;\ charset=UTF-8           ]]

  [[    "${output}"    =~ action=\"/home:1/1\?--edit                          ]]

  [[    "${output}"    =~ initializeAceEditor                                 ]]
  [[    "${output}"    =~ aceModeList\.getModeForPath\(\'example.md\'\)\.mode ]]
  [[    "${output}"    =~ editor\.setTheme\(\'ace\/theme\/twilight\'\)\;      ]]
}

# GET #########################################################################

@test "GET to --edit URL with .odt file renders item without form." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"      \
      --title     "Title One"                       \
      --content   "Example content. [[Example Title]]"

    cat "${NB_DIR}/home/Example Folder/File One.md" \
      | pandoc --from markdown --to odt             \
      | "${_NB}" add "Example Folder/File One.odt"

    [[ -f "${NB_DIR}/home/Example Folder/File One.odt" ]]

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1/2?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0    ]]

  printf "%s\\n" "${output}"  | grep -v -q \
    "<p>Example content. <a"

  printf "%s\\n" "${output}"  | grep -v -q \
    "<form${_NEWLINE}action=\"/home:1?--edit&--per-page=30--columns=20"
}

@test "GET to --edit URL with --columns parameter uses value for textarea, form URL parameters, and header links and retains leading tab." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --title "Example Title" --content "	Example content."

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1?--edit&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not update file:

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(printf "# Example Title\\n\\n	Example content.\\n")

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]

  printf "%s\\n" "${output}" | grep -q \
    "href=\"http://localhost:6789/?--per-page=30&--columns=20\"><span class=\"dim\">❯</span>nb</a> "

  printf "%s\\n" "${output}" | grep -q "cols=\"17\"># Example Title"
  printf "%s\\n" "${output}" | grep -q \
    "<form${_NEWLINE}action=\"/home:1?--edit&--per-page=30--columns=20"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"
}

@test "GET to --edit URL without --columns parameter uses default value for textarea and retains leading tab." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --title "Example Title" --content "	Example content."

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1?--edit"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not update file:

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(printf "# Example Title\\n\\n	Example content.\\n")

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\""

  printf "%s\\n" "${output}" | grep -q \
">:</span> <a rel=\"noopener noreferrer\" href=\"http://localhost:6789/home:"

  printf "%s\\n" "${output}" | grep -q \
"1?--per-page=.*&--columns=.*\">1</a> <span class=\"dim\">·</span> <a.* "

  printf "%s\\n" "${output}" | grep -q \
"rel=\"noopener noreferrer\" href=\"http://localhost:6789/--original/home/Example File.md\">↓</a> <span class=\"dim\">·</span> <span cl"

  printf "%s\\n" "${output}" | grep -q \
"ss=\"dim\">editing</span> <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" "

  printf "%s\\n" "${output}" | grep -q \
"href=\"http://localhost:6789/home:1?--per-page=30&--columns=.*&--delete\">-</a> <span class=\"dim\">|</span> <a "

  printf "%s\\n" "${output}" | grep -q \
"rel=\"noopener noreferrer\" href=\"http://localhost:6789/home:?--per-page=30&--columns=.*&--add\">+</a></h1>"

  printf "%s\\n" "${output}" | grep -q "cols=\"67\"># Example Title"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"

  [[ !  "${output}"    =~ \<input\ type=\"hidden\"\ name=\"home%3A1\"\>    ]]

}

@test "GET to --edit URL prints form without updating note." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --title "Example Title" --content "Example content."

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:1?--edit"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not update file:

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(printf "# Example Title\\n\\nExample content.\\n")

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:1?--edit"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"
}

# CLI #########################################################################

@test "'browse --edit <selector>' opens the edit page in the browser." {
  {
    "${_NB}" init

    "${_NB}" add --title "Example Title" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse 1 --edit --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:1?--edit"

  printf "%s\\n" "${output}" | grep -q \
"value=\"save\"> <span class=\"dim\">·</span> <span class=\"dim last-saved\">last: .*</span>"
}
