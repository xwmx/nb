#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# local notebook ##############################################################

# @test "'browse' with no arguments serves the current notebook contents as a rendered HTML page with links to internal web server URLs." {
#   {
#     "${_NB}" init

#     mkdir -p "${_TMP_DIR}/Local Notebook"
#     cd "${_TMP_DIR}/Local Notebook"

#     "${_NB}" notebooks init

#     "${_NB}" add  "File One.md"       \
#       --title     "Title One"         \
#       --content   "Example content."

#     "${_NB}" add  "File Two.md"       \
#       --title     "Title Two"         \
#       --content   "Example content."

#     "${_NB}" add  "Example Folder"    \
#       --type      "folder"

#     sleep 1
#   }

#   run "${_NB}" browse --print

#   printf "\${status}: '%s'\\n" "${status}"
#   printf "\${output}: '%s'\\n" "${output}"

#   [[ "${status}"  ==  0                                             ]]
#   [[ "${output}"  =~  \<\!DOCTYPE\ html\>                           ]]

#   [[ "${output}"  =~  \
# \<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>  ]]
#   [[ "${output}"  =~  \
# href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
#   [[ "${output}"  =~  \
# .*·.*\ \<a.*\ href=\"http://localhost:6789/local:\?--per-page=.*\"\>local\</a\>.*\</h1\>  ]]

#   [[ "${output}"  =~  \
# \<a.*\ href=\"http://localhost:6789/local:3\?--per-page=.*\"\ class=\"list-item\"\>        ]]
#   [[ "${output}"  =~  .*\[.*local:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\>        ]]

#   [[ "${output}"  =~  \
# \<a.*\ href=\"http://localhost:6789/local:2\?--per-page=.*\"\ class=\"list-item\"\>        ]]
#   [[ "${output}"  =~  .*\[.*local:2.*\].*${_S}Title${_S}Two\</a\>\<br\>                    ]]

#   [[ "${output}"  =~  \
# \<a.*\ href=\"http://localhost:6789/local:1\?--per-page=.*\"\ class=\"list-item\"\>        ]]
#   [[ "${output}"  =~  .*\[.*local:1.*\].*${_S}Title${_S}One\</a\>\<br\>                    ]]
# }
