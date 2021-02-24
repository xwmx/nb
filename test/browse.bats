#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# title #######################################################################

@test "'browse' sets HTML title." {
  {
    "${_NB}" init
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                    ]]

  [[    "${output}"  =~  '<title>nb</title>'  ]]
  [[ !  "${output}"  =~  'h1 class="title"'   ]]
  [[ !  "${output}"  =~  'title-block-header' ]]
}

# css / styles ################################################################

@test "'browse' includes application styles." {
  {
    "${_NB}" init
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0         ]]

  [[ "${output}"  =~  'html {'  ]]
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
href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>         ]]
  [[ "${output}"  =~  \
\<h1\ class=\"header-crumbs\"\ id=\"nb-home-example-folder\"\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\             ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/\?--per-page=.*\"\>Example\ Folder\</a\>\ .*/.*\</h1\> ]]

  [[ "${output}"  =~  0\ items. ]]

  run "${_NB}" browse 2/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
\<h1\ class=\"header-crumbs\"\ id=\"nb-home-1\"\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\   ]]
  [[ "${output}"  =~  \
\<span\ class=\"dim\"\>❯\</span\>nb\</a\>                               ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\   ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2/\?--per-page=.*\"\>1\</a\>\ .*/.*\</h1\>     ]]

  [[ "${output}"  =~  \
\<p\>\<a.*\ href=\"http://localhost:6789/home:2/1\?--per-page=.*\"\ class=\"list-item\"\>.*\[.*1/1.*\].*  ]]
  [[ "${output}"  =~  \
class=\"list-item\"\>.*\[.*1/1.*\].*${_S}File${_S}One.md\</a\>\<br\ /\> ]]
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
