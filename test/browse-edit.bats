#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# GET #########################################################################

@test "GET to --edit URL updates the note and prints form." {
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

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                     ]]
  [[ "${lines[1]}"  =~  Date:\ .*                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                           ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html              ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1  ]]
  [[ "${output}"    =~  \<form\ action=\"/home:1\?--edit      ]]
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

  run curl -sS -D - --data "content=Updated" "http://localhost:6789/home:1?--edit"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Updates file:

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(printf "Updated\\n")

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                     ]]
  [[ "${lines[1]}"  =~  Date:\ .*                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                           ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html              ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1  ]]
  [[ "${output}"    =~  \<form\ action=\"/home:1\?--edit      ]]
}

# CLI #########################################################################

@test "'browse --edit <selector>' opens the edit page in the browser." {
  {
    "${_NB}" init

    "${_NB}" add --title "Example Title" --content "Example content."
  }

  run "${_NB}" browse 1 --edit --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]
  [[    "${output}"  =~  \<form\ action=\"/home:1\?--edit     ]]
}

