#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# items #######################################################################

# @test "'browse' with .org file serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
#   {
#     "${_NB}" init

#     "${_NB}" add  "Example File.md"             \
#       --title     "Example Title"               \
#       --content   "Example content."

#     "${_NB}" add  "Example Folder/File One.org"  \
#       --title     "Title One"                   \
#       --content   "Example content. [[Example Title]]"
#   }

#   run "${_NB}" browse 2/1 --print

#   printf "\${status}: '%s'\\n" "${status}"
#   printf "\${output}: '%s'\\n" "${output}"

#   [[ "${status}"    ==  0                                                   ]]
#   [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                 ]]

#   [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>           ]]

#   [[ "${output}"    =~  \
#       \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/home:1\"\>  ]]
#   [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                  ]]
# }

@test "'browse <folder-id>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                 ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>           ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/home:1\"\>  ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                  ]]
}

@test "'browse <folder-name>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                 ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>           ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/home:1\"\>  ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                  ]]
}

@test "'browse <item-selector>' properly resolves titled wiki-style links." {
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

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'one: <a href="http://localhost:6789/home:2">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    'example <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q \
    'content <a href="http://localhost:6789/home:3/1">\[\[3/1\]\]</a> here'
}

@test "'browse <item-selector>' properly resolves titled wiki-style links and skips links with non-resolving selectors." {
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

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'one: <a href="http://localhost:6789/home:2">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    'example <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q 'content \[\[2/1\]\] here'
}

@test "'browse <selector>' properly resolves duplicated wiki-style links." {
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

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'link one: <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a>'


  printf "%s\\n" "${output}" | grep -q -v\
    'example <a href="http://localhost:6789/Example Notebook:1/1">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

@test "'browse <selector>' resolves wiki-style links in a different arrangement." {
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

  run "${_NB}" browse 1 --print

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
