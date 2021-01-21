#!/usr/bin/env bats

load test_helper

# --render, --print, and --raw ################################################

@test "'show --print' prints the un-rendered file contents with highlighting." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "\
# Example Title

Example content with [a link](https://example.test) and *formatting*."
  }

  run "${_NB}" show "Example File.md" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                   ]]
  [[ "${lines[0]}"  =~  \.*#.*\ .*Example\ Title.*                          ]]
  [[ "${lines[1]}"  =~  \
       Example\ content\ with\ .*\[.*a\ link.*\](.*https://example.test.*)  ]]
  [[ "${lines[1]}"  =~  \ and\ .*\*.*formatting.*\*.*\.                     ]]
}

@test "'show --print --raw' prints the un-rendered file contents without highlighting." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "\
# Example Title

Example content with [a link](https://example.test) and *formatting*."
  }

  run "${_NB}" show "Example File.md" --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                     ]]
  [[ "${lines[0]}"  ==  "# Example Title"                                     ]]
  [[ "${lines[1]}"  ==  \
      "Example content with [a link](https://example.test) and *formatting*." ]]
}

@test "'show --render --print' prints the rendered file as dump from browser." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "\
# Example Title

Example content with [a link](https://example.test) and *formatting*."
  }

  run "${_NB}" show "Example File.md" --render --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                               ]]
  [[ "${lines[0]}"  ==  "Example Title"                                 ]]
  [[ "${lines[1]}"  ==  "Example content with a link and formatting."   ]]
}

@test "'show --render --print --raw' prints the rendered file as raw HTML." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "\
# Example Title

Example content with [a link](https://example.test) and *formatting*."
  }

  run "${_NB}" show "Example File.md" --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                 ]]
  [[ "${lines[0]}"  =~  \<h1\ id=\"example-title\"\>Example\ Title\</h1\> ]]
  [[ "${lines[1]}"  =~  \<p\>Example\ content\ with\                      ]]
  [[ "${lines[1]}"  =~  \<a\ href=\"https://example.test\"\>a\ link\</a\> ]]
  [[ "${lines[1]}"  =~  and\ \<em\>formatting\</em\>.\</p\>               ]]
}
