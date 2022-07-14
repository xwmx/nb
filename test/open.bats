#!/usr/bin/env bats

load test_helper

# open <selector> #############################################################

@test "'open <id>'." {
  {
    "${_NB}" init

    "${_NB}" bookmark "${_BOOKMARK_URL}" --filename "example.bookmark.md"
  }

  run "${_NB}" peek 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR}/home/example.bookmark.md"

  [[    "${status}"    -eq  1         ]]

  [[    "${lines[0]}"   =~  Usage     ]]
  [[    "${lines[1]}"   =~  nb\ open  ]]
}

# error handling ##############################################################

@test "'open' with no selector with exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" open

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq  1         ]]

  [[    "${lines[0]}"   =~  Usage     ]]
  [[    "${lines[1]}"   =~  nb\ open  ]]
}
