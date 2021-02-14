#!/usr/bin/env bats

load test_helper

# links #######################################################################

@test "'show --for-browse' properly resolves titled wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Root Title Two]]

More example [[Example Notebook:Example Folder/1]] content.
HEREDOC
)"

    "${_NB}" add  "File Two.md"       \
      --title     "Root Title Two"    \
      --content   "Example content."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Nested Title One"                            \
      --content   "Nested content one."

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" use "Sample Notebook"
  }

  run "${_NB}" show home:1 --for-browse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    '<a href="http://localhost:6789/home:2">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    '<a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

@test "'show --for-browse' properly resolves duplicated wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Example Notebook:Example Folder/1]]

More example [[Example Notebook:Example Folder/1]] content.
HEREDOC
)"

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Nested Title One"                            \
      --content   "Nested content one."
  }

  run "${_NB}" show 1 --for-browse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'link one: <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a>'


  printf "%s\\n" "${output}" | grep -q -v\
    'example <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

@test "'show --for-browse' resolves wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example content one [[Sample Folder/Nested Title One]] with more [[Example Notebook:File Two.md]].

More example [[Example Notebook:Example Folder/1]] content.
HEREDOC
)"

    "${_NB}" add  "File Two.md"                   \
      --title     "Root Title Two"                \
      --content   "Root content two."

    "${_NB}" add  "Sample Folder/File One.md"     \
      --title     "Nested Title One"              \
      --content   "Nested content one."

    "${_NB}" add  "Sample Folder/File Two.md"     \
      --title     "Nested Title Two"              \
      --content   "Nested content two."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:File One.md"  \
      --title     "Root Title One"                \
      --content   "Root content one."

    "${_NB}" add  "Example Notebook:File Two.md"  \
      --title     "Root Title Two"                \
      --content   "Root content two."

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Nested Title One"                            \
      --content   "Nested content one."

    "${_NB}" add  "Example Notebook:Example Folder/File Two.md" \
      --title     "Nested Title Two"                            \
      --content   "Nested content two."
  }

  run "${_NB}" show 1 --for-browse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    '<a href="http://localhost:6789/home:3/1">\[\[Sample Folder/Nested Title One\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    '<a href="http://localhost:6789/Example Notebook:2">\[\[Example Notebook:File Two.md\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    '<a href="http://localhost:6789/Example Notebook:3/1">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

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
