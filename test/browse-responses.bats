#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# 404 #########################################################################

@test "'browse' renders 404 when not found." {
  {
    "${_NB}" init
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

@test "'browse <file>' renders 415 with message when file is pdf." {
  {
    "${_NB}" init

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.pdf"
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                              ]]

  [[    "${output}"   =~  html                          ]]
  [[    "${output}"   =~  \<title\>nb\</title\>         ]]
  [[    "${output}"   =~  415\ Unsupported\ Media\ Type ]]
  [[ !  "${output}"   =~  encrypted                     ]]
}

@test "'browse <file>' renders 415 with message when file is encrypted." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" \
      --content "Example content."                \
      --encrypt                                   \
      --password password
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                      ]]

  [[    "${output}"  =~  html                   ]]
  [[    "${output}"  =~  \<title\>nb\</title\>  ]]
  [[    "${output}"  =~  415\ Unsupported\ Media\ Type:\ File\ is\ encrypted\. ]]
}

@test "'browse <folder>/<file>' renders 415 with message when file is encrypted." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."                \
      --encrypt                                   \
      --password password
  }

  run "${_NB}" browse 1/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                      ]]

  [[    "${output}"  =~  html                   ]]
  [[    "${output}"  =~  \<title\>nb\</title\>  ]]
  [[    "${output}"  =~  415\ Unsupported\ Media\ Type:\ File\ is\ encrypted\. ]]
}
