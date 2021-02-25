#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# columns #####################################################################

@test "GET to container URL with no --columns param and GUI request truncates using the default column value and omits --column param from links." {

  {
    "${_NB}" init

    "${_NB}" add                    \
      "Example File.md"             \
       --content "Example content." \
--title "\
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--gui"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                        ]]

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*              ]]
  [[ "${lines[3]}"  =~  Server:\ nb               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html  ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home    ]]

  [[ "${output}"    =~  abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefg…  ]]

  printf "%s\\n" "${output}" \
    | grep -q "href=\"http://localhost:6789/home:1\" class=\"list-item\""

}

@test "GET to container URL with --columns param truncates using the provided value." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      "Example File.md"             \
       --content "Example content." \
--title "\
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                        ]]

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*              ]]
  [[ "${lines[3]}"  =~  Server:\ nb               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html  ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home    ]]

  [[ "${output}"    =~  abcdefghi…                ]]

  printf "%s\\n" "${output}" \
    | grep -q "href=\"http://localhost:6789/home:1?--per-page=.*&amp;--columns=20\" class=\"list-item\""
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
