#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# --local #####################################################################

@test "'browse local:' with missing --local param responds with 400 Bad Request." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add  "Example File.md"     \
      --title     "Example Title"       \
      --content   "Example content."

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -I -s "http://localhost:6789/local:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                           ]]
  [[ "${#lines[@]}" ==  6                           ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 400\ Bad\ Request ]]
  [[ "${lines[1]}"  =~  Date:\ .*                   ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                ]]
  [[ "${lines[3]}"  =~  Server:\ nb                 ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html    ]]
}

# 302 #########################################################################

@test "'browse' with 'url=<url>' param responds with 302 redirect." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"     \
      --title     "Example Title"       \
      --content   "Example content."

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -I -s "http://localhost:6789/?url=http%3A%2F%2Fexample.test"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                               ]]
  [[ "${#lines[@]}" ==  5                               ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found            ]]
  [[ "${lines[1]}"  =~  Date:\ .*                       ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                    ]]
  [[ "${lines[3]}"  =~  Server:\ nb                     ]]
  [[ "${lines[4]}"  =~  Location:\ http://example.test  ]]
}

# 404 #########################################################################

@test "'browse' renders 404 when not found." {
  {
    "${_NB}" init

    sleep 1
  }

  run "${_NB}" browse no-matching-selector --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                      ]]

  [[    "${output}"  =~  html                   ]]
  [[    "${output}"  =~  \<title\>nb\</title\>  ]]
  [[    "${output}"  =~  \404\ Not\ Found       ]]
}

# 415 #########################################################################

@test "'browse <file>' renders 415 with message when file is encrypted." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md"                \
      --content "Example content."                \
      --encrypt                                   \
      --password password

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                   ]]

  [[ "${output}" =~  html                                                 ]]
  [[ "${output}" =~  header-crumbs                                        ]]
  [[ "${output}" =~  \<title\>${_ME}\ browse\ home:1\</title\>            ]]
  [[ "${output}" =~  415\ Unsupported\ Media\ Type:\ File\ is\ encrypted  ]]
  [[ "${output}" =~  ↓                                                    ]]
}

@test "'browse <folder>/<file>' renders 415 with message when file is encrypted." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."                \
      --encrypt                                   \
      --password password

    sleep 1
  }

  run "${_NB}" browse 1/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                                                    ]]

  [[ "${output}" =~  html                                                 ]]
  [[ "${output}" =~  header-crumbs                                        ]]
  [[ "${output}" =~  \<title\>${_ME}\ browse\ home:1/1\</title\>          ]]
  [[ "${output}" =~  415\ Unsupported\ Media\ Type:\ File\ is\ encrypted  ]]
  [[ "${output}" =~  ↓                                                    ]]
}
