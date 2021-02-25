#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# browse --notebooks ##########################################################

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


  printf "%s\\n" "${output}" | grep   -q \
"<h1 class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> <span class=\"dim\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"</h1>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"http://localhost:6789/Demo%20Notebook:?--per-page=.*\">Demo${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Example%20Notebook:?--per-page=.*\">Example${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Sample%20Notebook:?--per-page=.*\">Sample${_S}Notebook</a> .*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"http://localhost:6789/Test%20Notebook:?--per-page=.*\">Test${_S}Notebook</a></p>"
}

