#!/usr/bin/env bats

load test_helper

@test "'_file_is_text()' returns status 0 for text file." {
  run "${_NB}" helpers file_is_text "${NB_TEST_BASE_PATH}/example.asciidoc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_file_is_text()' returns status 1 for pdf file." {
  run "${_NB}" helpers file_is_text "${NB_TEST_BASE_PATH}/example.pdf"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

@test "'_file_is_text()' returns status 1 for nonexistent file." {
  run "${_NB}" helpers file_is_text "${NB_TEST_BASE_PATH}/nonexistent"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

@test "'_file_is_text()' returns status 1 for blank file path." {
  run "${_NB}" helpers file_is_text ""

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}
