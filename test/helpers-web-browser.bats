#!/usr/bin/env bats

load test_helper

# checks ######################################################################

@test "'_web_browser --gui' return 1 when \$BROWSER is set to 'w3m'." {
  {
    "${_NB}" init
  }

  BROWSER=w3m run "${_NB}" helpers _web_browser --gui

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]

  [[ -z "${output}"         ]]
}

@test "'_web_browser --gui' return 1 when \$BROWSER is set to 'lynx'." {
  {
    "${_NB}" init
  }

  BROWSER=lynx run "${_NB}" helpers _web_browser --gui

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]

  [[ -z "${output}"         ]]
}

@test "'_web_browser --gui' return 0 when \$BROWSER is set to 'firefox'." {
  {
    "${_NB}" init
  }

  BROWSER=firefox run "${_NB}" helpers _web_browser --gui

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]

  [[ -z "${output}"         ]]
}

@test "'_web_browser --gui' return 0 when \$BROWSER is set to '<full path>/Google Chrome'." {
  {
    "${_NB}" init
  }

  BROWSER="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    run "${_NB}" helpers _web_browser --gui

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]

  [[ -z "${output}"         ]]
}
