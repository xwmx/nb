#!/usr/bin/env bats

load test_helper

@test "'_string_is_url()' matches URLs." {
  run "${_NB}" helpers string_is_url "file:///home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ftp://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "https://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sftp://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]
}

@test "'_string_is_url()' doesn't match non-URLs." {
  run "${_NB}" helpers string_is_url "Not a URL."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "not-a-url"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notaurl:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:example/123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]
}
