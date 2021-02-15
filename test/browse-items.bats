#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# items #######################################################################

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
