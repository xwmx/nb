#!/usr/bin/env bats

load test_helper

@test "'_build_related_list()' builds a Markdown-formatted list of related URLs and selectors." {
  {
    "${_NB}" init
  }

  run "${_NB}" helpers build_related_list \
    "http://example.com"                  \
    "example:123"                         \
    "http://example.org"                  \
    "[[sample:456]]"                      \
    "Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  diff                            \
    <(printf "%s\\n" "${output}") \
    <(cat <<HEREDOC
- <http://example.com>
- [[example:123]]
- <http://example.org>
- [[sample:456]]
- [[Example Title]]
HEREDOC
    )
}

@test "'_build_related_list()' prints nothing with no input." {
  {
    "${_NB}" init
  }

  run "${_NB}" helpers build_related_list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}
