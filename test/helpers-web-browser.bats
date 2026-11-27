#!/usr/bin/env bats

load test_helper

# checks ######################################################################

@test "'_web_browser --check' returns 1 without exiting when no browser is available." {
  {
    "${_NB}" init
  }

  BASH_ENV="${NB_TEST_BASE_PATH}/fixtures/no_browser_env.sh" \
    run "${_NB}" helpers _web_browser --check

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]

  # The warning is only printed when `_web_browser` is asked to open a browser.
  # In probe mode the function must return 1 without exiting the process.
  [[ -z "${output}"         ]]
}

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
