#!/usr/bin/env bats

load test_helper

@test "'_string_is_email()' matches email addresses." {
  run "${_NB}" helpers string_is_email "example@example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_email "example+plusaddressing@example.text"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_email "example+plusaddressing@example.examplelongtld"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]
}

@test "'_string_is_email()' does not match non-email addresses." {
  run "${_NB}" helpers string_is_email "not-an-email-address"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]
}
