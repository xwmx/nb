#!/usr/bin/env bats

load test_helper

# terminal formatting #########################################################

@test "'browse --notebooks' breaks lines and omits separator at column limit." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]
  }

  run "${_NB}" browse --notebooks --columns 35 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep   -q \
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/?--per-page=.*&--columns=.*\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:?--per-page=.*&--columns=.*\">Demo${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:?--per-page=.*&--columns=.*\">Example${_S}Notebook</a><br>"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:?--per-page=.*&--columns=.*\">Sample${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:?--per-page=.*&--columns=.*\">Test${_S}Notebook</a></p>"

  run "${_NB}" browse --notebooks --columns 10 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep   -q \
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/?--per-page=.*&--columns=.*\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:?--per-page=.*&--columns=.*\">Demo${_S}Notebook</a><br>"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:?--per-page=.*&--columns=.*\">Example${_S}Notebook</a><br>"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:?--per-page=.*&--columns=.*\">Sample${_S}Notebook</a><br>"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:?--per-page=.*&--columns=.*\">Test${_S}Notebook</a></p>"
}

# HTML <title> ################################################################

@test "'browse --notebooks' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    sleep 1
  }

  run "${_NB}" browse --notebooks --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                              ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ \-\-notebooks\</title\> ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                            ]]
}

# local #######################################################################

@test "'browse --notebooks'  with local notebook serves the list of unarchived notebooks with local notebook as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init <<< "y${_NEWLINE}"

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]

    declare _local_notebook_param="--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
    declare _expected_param_pattern="${_local_notebook_param}&--per-page=.*&--columns=.*"
  }

  run "${_NB}" browse --notebooks --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep     -q \
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"//localhost:6789/?${_expected_param_pattern}\"><span "

  printf "%s\\n" "${output}" | grep     -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep -v  -q \
"<p><a.* href=\"//localhost:6789/local:?.*<a.* href=\"//localhost:6789/local:?"

  printf "%s\\n" "${output}" | grep     -q \
"<p><a.* href=\"//localhost:6789/local:?${_expected_param_pattern}\">local</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep     -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:?${_expected_param_pattern}\">Demo${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:?${_expected_param_pattern}\">Example${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:?${_expected_param_pattern}\">Sample${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:?${_expected_param_pattern}\">Test${_S}Notebook</a></p>"
}

# browse -n ###################################################################

@test "'browse -n'  serves the list of unarchived notebooks as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]
  }

  run "${_NB}" browse -n --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep   -q \
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/?--per-page=.*&--columns=.*\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:?--per-page=.*&--columns=.*\">Demo${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:?--per-page=.*&--columns=.*\">Example${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:?--per-page=.*&--columns=.*\">Sample${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:?--per-page=.*&--columns=.*\">Test${_S}Notebook</a></p>"
}

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
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/?--per-page=.*&--columns=.*\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:?--per-page=.*&--columns=.*\">Demo${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:?--per-page=.*&--columns=.*\">Example${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:?--per-page=.*&--columns=.*\">Sample${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:?--per-page=.*&--columns=.*\">Test${_S}Notebook</a></p>"
}

@test "GET to 'browse --notebooks' URL serves the list of unarchived notebooks as a rendered HTML page with links to internal web server URLs without mutedensional parameters." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" notebooks rename "home" "Demo Notebook"

    [[    -d "${NB_DIR}/Demo Notebook"  ]]
    [[ !  -e "${NB_DIR}/home"           ]]

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/?--gui"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep   -q \
"<nav class=\"header-crumbs\">"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/\"><span "

  printf "%s\\n" "${output}" | grep   -q \
"<span class=\"muted\">❯</span>nb</a> <span class=\"muted\">·</span> <span class=\"muted\">notebooks</span>"

  printf "%s\\n" "${output}" | grep   -q \
"<p><a.* href=\"//localhost:6789/Demo%20Notebook:\">Demo${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Example%20Notebook:\">Example${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Sample%20Notebook:\">Sample${_S}Notebook</a>${_S}.*·.*"

  printf "%s\\n" "${output}" | grep   -q \
"<a.* href=\"//localhost:6789/Test%20Notebook:\">Test${_S}Notebook</a></p>"
}
