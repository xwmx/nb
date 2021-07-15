#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# browse --serve ##############################################################

@test "'browse --serve' displays message with selector and --local parameter with local notebook and notebook selector." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook: --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/Example%20Notebook:\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook$ ]]
}

@test "'browse --serve' displays message with selector and --local parameter with local notebook and folder." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/local:Example%20Folder/\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook$ ]]
}

@test "'browse --serve' displays message with selector and --local parameter with local notebook." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/local:\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook$ ]]
}

@test "'browse --serve' displays message without selector or params with current notebook." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*$      ]]
  [[ !  "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}/home:$  ]]
}

@test "'browse --serve' displays message with selector when notebook selector is specified." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook: --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/Example%20Notebook:$  ]]
}

@test "'browse --serve' displays message with selector when folder selector is specified." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                  ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/home:Example%20Folder/$ ]]
}

@test "'browse --serve' displays message with selector when notebook and folder selector is specified." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook:Example\ Folder/ --serve <<< "x"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                                ]]

  [[    "${output}"  =~  \
^Listening:\ .*http://localhost:${NB_SERVER_PORT}.*/Example%20Notebook:Example%20Folder/$ ]]
}
