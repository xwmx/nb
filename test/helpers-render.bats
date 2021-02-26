#!/usr/bin/env bats

load test_helper

# with pandoc #################################################################

@test "'_render --pandoc' prints complete HTML document with piped input." {
  echo "<span class=\"sample-class\">Example content.</span>" | {
    run "${_NB}" helpers render --pandoc

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"  -eq 0 ]]

    printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
    printf "%s\\n" "${output}" | grep -q "<head>"
    printf "%s\\n" "${output}" | grep -q "<body>"
    printf "%s\\n" "${output}" | grep -q "</body>"
    printf "%s\\n" "${output}" | grep -q "</body>"

    printf "%s\\n" "${output}" | grep -q \
      "<span class=\"sample-class\">Example content.</span>"
  }
}

@test "'_render --pandoc' prints complete HTML document with string input." {
  run "${_NB}" helpers render  --pandoc \
    "<span class=\"sample-class\">Example content.</span>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<span class=\"sample-class\">Example content.</span>"
}

@test "'_render --pandoc' prints markdown document converted to HTML with file input." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --title     "Example Title" \
      --content   "Example content with *formatting* and [a link](https://example.test)"
  }

  run "${_NB}" helpers render  --pandoc "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<h1 id=\"example-title\">Example Title</h1>"
  printf "%s\\n" "${output}" | grep -q \
    "Example content with <em>formatting</em> and <a href=\"https://example.test\">a link</a>"
}

# without pandoc ##############################################################

@test "'_render' prints complete HTML document with piped input." {
  echo "<span class=\"sample-class\">Example content.</span>" | {
    run "${_NB}" helpers render

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"  -eq 0 ]]

    printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
    printf "%s\\n" "${output}" | grep -q "<head>"
    printf "%s\\n" "${output}" | grep -q "<body>"
    printf "%s\\n" "${output}" | grep -q "</body>"
    printf "%s\\n" "${output}" | grep -q "</body>"

    printf "%s\\n" "${output}" | grep -q \
      "<span class=\"sample-class\">Example content.</span>"
  }
}

@test "'_render' prints complete HTML document with string input." {
  run "${_NB}" helpers render \
    "<span class=\"sample-class\">Example content.</span>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<span class=\"sample-class\">Example content.</span>"
}

@test "'_render' prints raw markdown document with file input." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --title     "Example Title" \
      --content   "Example content with *formatting* and [a link](https://example.test)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "# Example Title"
  printf "%s\\n" "${output}" | grep -q \
    "Example content with \*formatting\* and \[a link\](https://example.test)"
}
