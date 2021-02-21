#!/usr/bin/env bats

load test_helper

@test "'_get_uri()' with unencoded URLs encodes them." {
  run "${_NB}" helpers get-uri http://example.com

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                             ]]
  [[ "${output}"  ==  "http%3A%2F%2Fexample.com"    ]]

  run "${_NB}" helpers get-uri https://example.com

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                             ]]
  [[ "${output}"  ==  "https%3A%2F%2Fexample.com"   ]]
}

@test "'_get_uri()' with encoded URLs decodes them." {
  run "${_NB}" helpers get-uri http%3A%2F%2Fexample.com

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                           ]]
  [[ "${output}"  ==  "http://example.com"        ]]

  run "${_NB}" helpers get-uri https%3A%2F%2Fexample.com

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                           ]]
  [[ "${output}"  ==  "https://example.com"       ]]
}
