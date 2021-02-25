#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

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
\<h1\ class=\"header-crumbs\"\ id=\"nb-home-example-folder\"\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\              ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/\?--per-page=.*\"\>Example\ Folder\</a\>\ .*/.*\</h1\>  ]]

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
\<h1\ class=\"header-crumbs\"\ id=\"nb-example-notebook\"\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/Example%20Notebook:\?--per-page=.*\"\>Example\ Notebook\</a\>.*\</h1\>  ]]

  [[ "${output}"  =~  0\ items. ]]
}

# notebooks and folder (containers) ###########################################

@test "'browse --notebooks'  serves the list of unarchived notebooks as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]
  }

  run "${_NB}" browse --notebooks --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"  =~  \
\<h1\ class=\"header-crumbs\"\>           ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\                      ]]
  [[ "${output}"  =~  \
\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ .*·.*\ \<span\ class=\"dim\"\>notebooks\</span\>.*\</h1\>  ]]

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"http://localhost:6789/Demo%20Notebook:?--per-page=.*\">Demo${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Example%20Notebook:?--per-page=.*\">Example${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Sample%20Notebook:?--per-page=.*\">Sample${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Test%20Notebook:?--per-page=.*\">Test${_S}Notebook</a></p>"
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

  [[ "${status}"  ==  0                                             ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\>                           ]]

  [[ "${output}"  =~  \
\<h1\ class=\"header-crumbs\"\ id=\"nb-home\"\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\> ]]
  [[ "${output}"  =~  \
href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>.*\</h1\>    ]]

  [[ "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/home:3\?--per-page=.*\"\ class=\"list-item\"\>   ]]
  [[ "${output}"  =~  .*\[.*home:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\ /\>     ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2\?--per-page=.*\"\ class=\"list-item\"\>        ]]
  [[ "${output}"  =~  .*\[.*home:2.*\].*${_S}Title${_S}Two\</a\>\<br\ /\>                 ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1\?--per-page=.*\"\ class=\"list-item\"\>        ]]
  [[ "${output}"  =~  .*\[.*home:1.*\].*${_S}Title${_S}One\</a\>\<br\ /\>                 ]]
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

  printf "%s\\n" "${output}" | grep       -q  \
"<h1 class=\"header-crumbs\" id=\"nb-home-example-folder\">.*<a.* href=\"http://localhost:6789/?--per-page=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep       -q  \
".*·.* <a.* href=\"http://localhost:6789/home:?--per-page=.*\">home</a> .*:.*"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/home:1/?--per-page=.*\">Example Folder</a> .*/.*</h1>"

  printf "%s\\n" "${output}" | grep       -q  \
"<p><a.* href=\"http://localhost:6789/home:1/2?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
".*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two</a><br />"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"http://localhost:6789/home:1/1?--per-page=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
".*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One</a><br />"
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
\<h1\ class=\"header-crumbs\"\ id=\"nb-home-example-folder\"\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\             ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/\?--per-page=.*\"\>Example\ Folder\</a\>\ .*/.*\</h1\> ]]

  [[ "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/home:1/2\?--per-page=.*\"\ class=\"list-item\"\>         ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two\</a\>\<br\ /\>           ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/1\?--per-page=.*\"\ class=\"list-item\"\>              ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One\</a\>\<br\ /\>           ]]
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
\<h1\ class=\"header-crumbs\"\ id=\"nb-example-notebook\"\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/Example%20Notebook:\?--per-page=.*\"\>Example\ Notebook\</a\>\</h1\> ]]

  [[ "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/Example%20Notebook:2\?--per-page=.*\"\ class=\"list-item\"\> ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:2.*\].*${_S}Title${_S}Two\</a\>\<br\ /\>             ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/Example%20Notebook:1\?--per-page=.*\"\ class=\"list-item\"\>      ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:1.*\].*${_S}Title${_S}One\</a\>\<br\ /\>             ]]
}
