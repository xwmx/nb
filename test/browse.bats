#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# header crumbs ###############################################################

@test "'browse <notebook-path>:<folder-id>/<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                                        ]]

  [[ "${output}"    =~ \#\ \[nb\]\(http://localhost:6789/\)\ ·\                 ]]
  [[ "${output}"    =~ \ ·\ \[home\]\(http://localhost:6789/home:\)\ :\         ]]
  [[ "${output}"    =~ \ :\ \[Example\ Folder\]\(http://localhost:6789/1/\)\ /  ]]
  [[ "${output}"    =~ \ /\ \[Sample\ Folder\]\(http://localhost:6789/1/1/\)\ / ]]
}

@test "'browse <notebook-path>:<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                                        ]]

  [[ "${output}"    =~ \#\ \[nb\]\(http://localhost:6789/\)\ ·\                 ]]
  [[ "${output}"    =~ \ ·\ \[home\]\(http://localhost:6789/home:\)\ :\         ]]
  [[ "${output}"    =~ \ :\ \[Example\ Folder\]\(http://localhost:6789/1/\)\ /  ]]
}

@test "'browse <notebook-path>/<folder>/file>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder/Folder One.md" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                                        ]]

  [[ "${output}"    =~ \#\ \[nb\]\(http://localhost:6789/\)\ ·\                 ]]
  [[ "${output}"    =~ \ ·\ \[home\]\(http://localhost:6789/home:\)\ :\         ]]
  [[ "${output}"    =~ \ :\ \[Example\ Folder\]\(http://localhost:6789/1/\)\ /  ]]
}

@test "'browse <notebook-path>/<folder>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                                        ]]

  [[ "${output}"    =~ \#\ \[nb\]\(http://localhost:6789/\)\ ·\                 ]]
  [[ "${output}"    =~ \ ·\ \[home\]\(http://localhost:6789/home:\)\ :\         ]]
  [[ "${output}"    =~ \ :\ \[Example\ Folder\]\(http://localhost:6789/1/\)\ /  ]]
}

# conflicting folder id / name ################################################

@test "'browse <folder>/' with conflicting id / folder name renders links to ids and labels to names." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]
  }

  run "${_NB}" browse 1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\> ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ :\                        ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/\"\>Example\ Folder\</a\>\ /\</h1\>             ]]

  [[ "${output}"  =~  0\ items. ]]

  run "${_NB}" browse 2/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-home-1\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ :\            ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/2/\"\>1\</a\>\ /\</h1\>               ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/2/1\"\>\[1/1\]${_S}File${_S}One.md\</a\>\<br/\>\</p\>  ]]
}

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

  [[ "${status}"    ==  0                                                           ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                         ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                   ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/Example%20Title\"\> ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                          ]]
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

  [[ "${status}"    ==  0                                                           ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                         ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                   ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/Example%20Title\"\> ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                          ]]
}

# empty #######################################################################

@test "'browse <folder-selector>/' (slash) with empty folder prints message and header." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder" --type "folder"
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>   ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ :\                          ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/\"\>Example\ Folder\</a\>\ /\</h1\>               ]]

  [[ "${output}"  =~  0\ items. ]]
}

@test "'browse <notebook>:' with empty notebook prints message and header." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ id=\"nb-example-notebook\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>            ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/Example%20Notebook:\"\>Example\ Notebook\</a\>\</h1\>  ]]

  [[ "${output}"  =~  0\ items. ]]
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
      \<p\>\<a\ href=\"http://localhost:6789/One:\"\>One\</a\>\<br/\> ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Two:\"\>Two\</a\>\<br/\>      ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Three:\"\>Three\</a\>\<br/\>  ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\<br/\>    ]]
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

  [[ "${status}"  == 0                                              ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                            ]]

  [[ "${output}"  =~  \<h1\ id=\"nb-home\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>  ]]
  [[ "${output}"  =~ ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\</h1\>        ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/home:3\"\>                     ]]
  [[ "${output}"  =~  \[home:3\]${_S}📂${_S}Example${_S}Folder\</a\>\<br/\> ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:2\"\>                          ]]
  [[ "${output}"  =~  \[home:2\]${_S}Title${_S}Two\</a\>\<br/\>             ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1\"\>                          ]]
  [[ "${output}"  =~  \[home:1\]${_S}Title${_S}One\</a\>\<br/\>             ]]
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
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\> ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ :\                        ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/\"\>Example\ Folder\</a\>\ /\</h1\>   ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/1/2\"\>                            ]]
  [[ "${output}"  =~  \[Example${_S}Folder/2\]${_S}Title${_S}Two\</a\>\<br/\>   ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/1\"\>                                 ]]
  [[ "${output}"  =~  \[Example${_S}Folder/1\]${_S}Title${_S}One\</a\>\<br/\>   ]]
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
      \<h1\ id=\"nb-home-example-folder\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>   ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ :\                          ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/\"\>Example\ Folder\</a\>\ /\</h1\> ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/1/2\"\>                          ]]
  [[ "${output}"  =~  \[Example${_S}Folder/2\]${_S}Title${_S}Two\</a\>\<br/\> ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/1/1\"\>                               ]]
  [[ "${output}"  =~  \[Example${_S}Folder/1\]${_S}Title${_S}One\</a\>\<br/\> ]]
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
      \<h1\ id=\"nb-example-notebook\"\>\<a\ href=\"http://localhost:6789/\"\>nb\</a\>            ]]
  [[ "${output}"  =~  \
      ·\ \<a\ href=\"http://localhost:6789/Example%20Notebook:\"\>Example\ Notebook\</a\>\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/Example%20Notebook:2\"\>   ]]
  [[ "${output}"  =~  \[Example${_S}Notebook:2\]${_S}Title${_S}Two\</a\>\<br/\>  ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Example%20Notebook:1\"\>        ]]
  [[ "${output}"  =~  \[Example${_S}Notebook:1\]${_S}Title${_S}One\</a\>\<br/\>  ]]
}
