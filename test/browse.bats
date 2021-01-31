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

# headers #######################################################################

@test "'browse <selector> --print --headers' prints response headers." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse 1 --print --headers

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                         ]]
  [[ "${#lines[@]}" ==  5                         ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*              ]]
  [[ "${lines[3]}"  =~  Server:\ nb               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html  ]]
}

# items #######################################################################

@test "'browse <selector>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
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

  [[ "${status}"    ==  0                                                           ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                         ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                   ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/Example%20Title\"\> ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                          ]]
}

# notebooks and folder (containers) ###########################################

@test "'browse --notebooks'  serves the list of unarchived notebooks as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "One"
    "${_NB}" notebooks add "Two"
    "${_NB}" notebooks add "Three"
  }

  run "${_NB}" browse --notebooks --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-notebooks\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>\ ·\ notebooks\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/One:\"\>One\</a\>\<br/\> ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Two:\"\>Two\</a\>\<br/\>      ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Three:\"\>Three\</a\>\<br/\>  ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/home:\"\>home\</a\>\<br/\>    ]]
}

@test "'browse' with no arguments serves the current notebook contents as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Title One"         \
      --content   "Example content."

    "${_NB}" add  "File Two.md"       \
      --title     "Title Two"         \
      --content   "Example content."

    "${_NB}" add  "Example Folder"    \
      --type      "folder"
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                                  ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                                ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>\</h1\>       ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/home:3/\"\>  ]]
  [[ "${output}"  =~  \[home:3\]\ 📂\ Example\ Folder\</a\>\<br/\>      ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/home:2\"\>        ]]
  [[ "${output}"  =~  \[home:2\]\ Title\ Two\</a\>\<br/\>               ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/home:1\"\>        ]]
  [[ "${output}"  =~  \[home:1\]\ Title\ One\</a\>\<br/\>               ]]
}

@test "'browse <folder-selector>/' (slash) serves the list as rendered HTML with links to internal web server URLs." {
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

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>     ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>                               ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Example%20Folder/\"\>Example\ Folder\</a\>\ /\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/2\"\> ]]
  [[ "${output}"  =~  \[Example\ Folder/2\]\ Title\ Two\</a\>\<br/\>              ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/1\"\>      ]]
  [[ "${output}"  =~  \[Example\ Folder/1\]\ Title\ One\</a\>\<br/\>              ]]
}

@test "'browse <folder-selector>' (no slash) serves the list as rendered HTML with links to internal web server URLs." {
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

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>     ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home:\</a\>                               ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Example%20Folder/\"\>Example\ Folder\</a\>\ /\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/2\"\> ]]
  [[ "${output}"  =~  \[Example\ Folder/2\]\ Title\ Two\</a\>\<br/\>              ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Folder/1\"\>      ]]
  [[ "${output}"  =~  \[Example\ Folder/1\]\ Title\ One\</a\>\<br/\>              ]]
}

@test "'browse <notebook>:' serves the notebook contents as rendered HTML with links to internal web server URLs." {
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

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-example-notebook\"\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/\"\>nb\</a\>            ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Notebook:\"\>Example\ Notebook:\</a\>\</h1\> ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Notebook:2\"\>   ]]
  [[ "${output}"  =~  \[Example\ Notebook:2\]\ Title\ Two\</a\>\<br/\>                ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:${_NB_SERVER_PORT}/Example%20Notebook:1\"\>        ]]
  [[ "${output}"  =~  \[Example\ Notebook:1\]\ Title\ One\</a\>\<br/\>                ]]
}
