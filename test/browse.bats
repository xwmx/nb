#!/usr/bin/env bats

load test_helper

export _NB_SERVER_PORT=6789


# error handling ##############################################################

@test "'browse <not-valid>' returns 404 Not Found." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse not-valid --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                ]]
  [[ "${output}"    =~ 404\ Not\ Found  ]]
}

# browse ######################################################################

@test "'browse <selector>' serves the rendered HTML page." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                    ]]
  [[ "${output}"    =~ \<\!DOCTYPE\ html\>  ]]
}

@test "'browse <folder-selector>/' (slash) serves the list as rendered HTML." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                                                             ]]

  [[ "${output}"  =~  \<h1\ id=\"example-folder\"\>Example\ Folder/\</h1\>          ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/2\"\>   ]]
  [[ "${output}"  =~  \[Example\ Folder/2\]\ Title\ Two\</a\>\</p\>                 ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/1\"\>   ]]
  [[ "${output}"  =~  \[Example\ Folder/1\]\ Title\ One\</a\>\</p\>                 ]]
}

@test "'browse <folder-selector>' (no slash) serves the list as rendered HTML." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                                                             ]]

  [[ "${output}"  =~  \<h1\ id=\"example-folder\"\>Example\ Folder/\</h1\>          ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/2\"\>   ]]
  [[ "${output}"  =~  \[Example\ Folder/2\]\ Title\ Two\</a\>\</p\>                 ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/1\"\>   ]]
  [[ "${output}"  =~  \[Example\ Folder/1\]\ Title\ One\</a\>\</p\>                 ]]
}

@test "'browse <notebook>:' serves the notebook contents as rendered HTML." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:File One.md"  \
      --title     "Title One"                     \
      --content   "Example content."

    "${_NB}" add  "Example Notebook:File Two.md"  \
      --title     "Title Two"                     \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                                                             ]]

  [[ "${output}"  =~  \<h1\ id=\"example-notebook\"\>Example\ Notebook:\</h1\>      ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Notebook:2\"\> ]]
  [[ "${output}"  =~  \[Example\ Notebook:2\]\ Title\ Two\</a\>\</p\>               ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Notebook:1\"\> ]]
  [[ "${output}"  =~  \[Example\ Notebook:1\]\ Title\ One\</a\>\</p\>               ]]
}
