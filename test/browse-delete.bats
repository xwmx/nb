#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# GET #########################################################################

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

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                     ]]
  [[ "${lines[1]}"  =~  Date:\ .*                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                           ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html              ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1  ]]

  printf "%s\\n" "${output}" | grep -q \
"href=\"http://localhost:6789/?--per-page=30&--columns=20\"><span class=\"dim\">❯</span>nb</a> "

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
  [[ "${lines[4]}"  =~  Content-Type:\ text/html                  ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:1?--delete"

  printf "%s\\n" "${output}" | grep -q \
"value=\"delete\">"
}

# POST ########################################################################

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

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

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

