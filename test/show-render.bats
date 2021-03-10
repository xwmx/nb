#!/usr/bin/env bats

load test_helper

# syntax highlighting #########################################################

@test "'show <item>' includes syntax highlighting." {
  {
    "${_NB}" init

    "${_NB}" add "example.rb" --content  "puts \"Hello World\""

    sleep 1
  }

  run "${_NB}" show 1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[ !  "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>       ]]

  [[    "${output}"    =~  pre\ \>\ code.sourceCode                     ]]

  [[    "${output}"    =~  \
\<div\ class=\"sourceCode\"\ id=\"cb1\"\>\<pre\ class=\"sourceCode\ rb\"\>\<code\  ]]

  [[    "${output}"    =~  \<code\ class=\"sourceCode\ ruby\"\>         ]]

  [[    "${output}"    =~  \
\<span\ class=\"fu\"\>puts\</span\>\ \<span\ class=\"st\"\>\&quot\;Hello\ World\&quot\;\</span\> ]]
}

# .org ########################################################################

@test "'show' with .org file renders an HTML page with wiki-style links resolved to file URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.org" \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" show 2/1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  # TODO: .org / org mode titles in pandoc HTML output?
  # [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                     ]]

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"file://${NB_DIR}/home/Example%20File.md\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# links #######################################################################

@test "'show --render' properly resolves titled wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Root Title Two]]

More example [[Example Notebook:Example Folder/1]] content [[3/1]] here.
HEREDOC
)"

    "${_NB}" add  "File Two.md"       \
      --title     "Root Title Two"    \
      --content   "Example content."

    "${_NB}" add  "Sample Folder/File One.md"                   \
      --title     "Sample Nested Title Two"                     \
      --content   "Sample nested content one."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Example Nested Title One"                    \
      --content   "Example nested content one."

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" use "Sample Notebook"
  }

  run "${_NB}" show home:1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    "one: <a.* href=\"file://${NB_DIR}/home/File%20Two.md\">\[\[Root Title Two\]\]</a>"

  printf "%s\\n" "${output}" | grep -q \
    "example <a.* href=\"file://${NB_DIR}/Example%20Notebook/Example%20Folder/File%20One.md\">\[\[Example\ Notebook:Example\ Folder/1\]\]</a> content"

  printf "%s\\n" "${output}" | grep -q \
    "content <a.* href=\"file://${NB_DIR}/home/Sample%20Folder/File%20One.md\">\[\[3/1\]\]</a> here"
}

@test "'show --render' properly resolves titled wiki-style links and skips links with non-resolving selectors." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Root Title Two]]

More example [[Example Notebook:Example Folder/1]] content [[2/1]] here.
HEREDOC
)"

    "${_NB}" add  "File Two.md"       \
      --title     "Root Title Two"    \
      --content   "Example content."

    "${_NB}" add  "Sample Folder/File One.md"                   \
      --title     "Sample Nested Title Two"                     \
      --content   "Sample nested content one."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Example Nested Title One"                    \
      --content   "Example nested content one."

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" use "Sample Notebook"
  }

  run "${_NB}" show home:1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    "one: <a.* href=\"file://${NB_DIR}/home/File%20Two.md\">\[\[Root Title Two\]\]</a>"

  printf "%s\\n" "${output}" | grep -q \
    "example <a.* href=\"file://${NB_DIR}/Example%20Notebook/Example%20Folder/File%20One.md\">\[\[Example\ Notebook:Example\ Folder/1\]\]</a> content"

  printf "%s\\n" "${output}" | grep -q 'content \[\[2/1\]\] here'
}

@test "'show --render' properly resolves duplicated wiki-style links." {
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

  run "${_NB}" show 1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
   "link one: <a.* href=\"file://${NB_DIR}/Example%20Notebook/Example%20Folder/File%20One.md\">\[\[Example\ Notebook:Example\ Folder/1\]\]</a>"

  printf "%s\\n" "${output}" | grep -q -v\
    "example <a.* href=\"file://${NB_DIR}/Example%20Notebook/Example%20Folder/File%20One.md\">\[\[Example\ Notebook:Example\ Folder/1\]\]</a>"
}

@test "'show --render' resolves wiki-style links." {
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

  run "${_NB}" show 1 --render --print --raw

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    "<a.* href=\"file://${NB_DIR}/home/Sample%20Folder/File%20One.md\">\[\[Sample\ Folder/Nested\ Title\ One\]\]</a>"

  printf "%s\\n" "${output}" | grep -q \
    "<a.* href=\"file://${NB_DIR}/Example%20Notebook/File%20Two.md\">\[\[Example\ Notebook:File\ Two.md\]\]</a>"

  printf "%s\\n" "${output}" | grep -q \
    "<a.* href=\"file://${NB_DIR}/Example%20Notebook/Example%20Folder/File%20One.md\">\[\[Example\ Notebook:Example\ Folder/1\]\]</a>"
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

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  =~  \<!DOCTYPE\ html\>                                  ]]
  [[ "${output}"  =~  \<h1\ id=\"example-title\"\>Example\ Title\</h1\>   ]]
  [[ "${output}"  =~  \<p\>Example\ content\ with\                        ]]
  [[ "${output}"  =~  \<a.*\ href=\"https://example.test\"\>a\ link\</a\> ]]
  [[ "${output}"  =~  and\ \<em\>formatting\</em\>.\</p\>                 ]]
}
