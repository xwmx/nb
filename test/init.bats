#!/usr/bin/env bats

load test_helper

# `init` ######################################################################

@test "'init' exits with status 0." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
}

@test "'init' exits with status 1 when '\$NB_DIR' exists as a file." {
  {
    touch "${NB_DIR}"

    [[ -e "${NB_DIR}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1 ]]
}

@test "'init' exits with status 0 when '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home' exists." {
  {
    mkdir -p "${NB_DIR}/home"

    [[ -e "${NB_DIR}/home" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ !  "${output}" =~  exists  ]]
  [[    "${status}" -eq 0       ]]
}

@test "'init' creates '\$NB_DIR' and '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home' directories." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${NB_DIR}"       ]]
  [[ -d "${NB_DIR}/home"  ]]
}

@test "'init' creates a git directory in '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${NB_DIR}/home/.git" ]]
}

@test "'init' creates an .index '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -e "${NB_DIR}/home/.index" ]]
}

@test "'init' exits with status 0 when '\$NBRC_PATH' exists." {
  {
    touch "${NBRC_PATH}"

    [[ -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
}

@test "'init' creates a .nbrc file at '\$NBRC_PATH'." {
  {
    [[ ! -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "%s\\n" "$(cat "${NBRC_PATH}")"

  [[ -e "${NBRC_PATH}" ]]

  grep -q "Configuration file for \`nb\`"  "${NBRC_PATH}"
  grep -q "NB_ENCRYPTION_TOOL"             "${NBRC_PATH}"
}

@test "'init' creates git commit." {
  run "${_NB}" init

  cd "${NB_DIR}/home" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Initialize'
}

# `init <remote-url>` #########################################################

@test "'init <remote-url>' creates a clone in '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  {
    _setup_remote_repo
  }

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  diff                                      \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")  \
    <(git -C "${NB_DIR}/home" config --get remote.origin.url)

  [[ -d "${NB_DIR}/home/.git" ]]
}

# help ########################################################################

@test "'help init' exits with status 0." {
  run "${_NB}" help init

  [[ "${status}" -eq 0 ]]
}

@test "'help init' prints help information." {
  run "${_NB}" help init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:"                    ]]
  [[ "${lines[1]}" == "  nb init [<remote-url>]"  ]]
}
