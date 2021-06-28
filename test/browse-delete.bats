#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# HTML <title> ################################################################

@test "'browse delete <folder>/<folder>/<file>' with local notebook sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse delete Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ delete\ local:1/1/1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse delete <folder>/<folder>/<file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse delete Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ delete\ home:1/1/1\</title\>   ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse delete <id>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse delete 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>          ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ delete\ home:1\</title\>       ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>        ]]
}

@test "'browse delete <notebook>:<id>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse delete Example\ Notebook:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                    ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ delete\ Example\\\ Notebook:1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                  ]]
}

@test "'browse <folder>/<id>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:1/1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                        ]]
}

# POST ########################################################################

@test "POST to --delete URL with local notebook deletes the note and redirects."  {
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
    ""                      \
    "http://localhost:6789/local:1?--delete&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                    ]]

  # Deletes file:

  [[ -z "$(ls "${_TMP_DIR}/Local Notebook")"  ]]

  # Creates git commit:

  cd "${_TMP_DIR}/Local Notebook" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"     ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  declare _expected_param_pattern="--per-page=30\&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                            ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                       ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                    ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                     ]]
  [[ "${lines[4]}"  =~  \
Location:\ http:\/\/localhost:6789\/local:\?${_expected_param_pattern}  ]]
}

@test "POST to --delete URL deletes the note and redirects."  {
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

  run curl -sS -D - --data "" "http://localhost:6789/home:1?--delete"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Deletes file:

  [[ -z "$(ls "${NB_DIR}/home")" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                      ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                               ]]
  [[ "${lines[4]}"  =~  Location:\ http:\/\/localhost:6789\/home:\?--per-page=.*  ]]
}

# GET #########################################################################

@test "GET to --delete URL with --local parameter renders form to delete local item." {
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

    declare _local_notebook_param="--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
    declare _expected_param_pattern="${_local_notebook_param}&--per-page=30&--columns=.*"
  }

  run curl -sS -D - "http://localhost:6789/local:1?--delete&${_local_notebook_param}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not delete file:

  diff                                      \
    <(cat "${_TMP_DIR}/Local Notebook/Example File.md") \
    <(printf "# Example Title\\n\\nExample content.\\n")

  # Does not create git commit:

  cd "${_TMP_DIR}/Local Notebook" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Delete'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*local.*\ .*:.*\ .*1     ]]
  [[ "${output}"    =~  header-crumbs.*↓                          ]]

  printf "%s\\n" "${output}" | grep -q \
"href=\"http://localhost:6789/?${_expected_param_pattern}\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
"❯</span>nb</a>.*<span class=\"dim\">·</span> <span class=\"dim\">-</span> <span class=\"dim\">|</span>"

  printf "%s\\n" "${output}" | grep -q \
"<h2 align=\"center\">deleting</h2>"

  printf "%s\\n" "${output}" | grep -q \
"<p align=\"center\">${_NEWLINE}  <a rel=\"noopener noreferrer\" href=\"http://localhost:6789/local:1?${_expected_param_pattern}\">\[1\] Example\ File.md \"Example Title\"</a>${_NEWLINE}</p>"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/local:1?--delete&${_expected_param_pattern}\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"delete\">"
}

@test "GET to --delete URL with --columns parameter uses value for form URL parameters, and header links." {
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

  run curl -sS -D - "http://localhost:6789/home:1?--delete&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not delete file:

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
  git log | grep -v -q '\[nb\] Delete'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]
  [[ "${output}"    =~  header-crumbs.*↓                          ]]

  printf "%s\\n" "${output}" | grep -q \
"href=\"http://localhost:6789/?--per-page=30&--columns=20\"><span class=\"dim\">❯</span>nb</a> "

  printf "%s\\n" "${output}" | grep -q \
"❯</span>nb</a>.*<span class=\"dim\">·</span> <span class=\"dim\">-</span> <span class=\"dim\">|</span>"

  printf "%s\\n" "${output}" | grep -q \
"<h2 align=\"center\">deleting</h2>"

  printf "%s\\n" "${output}" | grep -q \
"<p align=\"center\">${_NEWLINE}  <a rel=\"noopener noreferrer\" href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">\[1\] Example\ File.md \"Example Title\"</a>${_NEWLINE}</p>"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:1?--delete&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"delete\">"
}

@test "GET to --delete URL prints form without deleting note." {
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

  run curl -sS -D - "http://localhost:6789/home:1?--delete"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Does not delete file:

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
  git log | grep -v -q '\[nb\] Delete'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]
  [[ "${output}"    =~  header-crumbs.*↓                          ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:1?--delete"

  printf "%s\\n" "${output}" | grep -q \
"value=\"delete\">"
}

# CLI #########################################################################

@test "'browse --delete <selector>' opens the delete page in the browser." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --title "Example Title" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse 1 --delete --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                        ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1     ]]
  [[ "${output}"    =~  header-crumbs.*↓                          ]]

  printf "%s\\n" "${output}" | grep -q \
"href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> "

  printf "%s\\n" "${output}" | grep -q \
"<h2 align=\"center\">deleting</h2>"

  printf "%s\\n" "${output}" | grep -q \
"<p align=\"center\">${_NEWLINE}<a rel=\"noopener noreferrer\" href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">\[1\] Example\ File.md \"Example Title\"</a>${_NEWLINE}</p>"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:1?--delete&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"delete\">"
}

