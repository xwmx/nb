#!/usr/bin/env bats

load test_helper

# `init` ######################################################################

@test "\`init\` exits with status 0." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
}

@test "\`init\` exits with status 1 when \`\$NB_DIR\` exists as a file." {
  {
    touch "${NB_DIR}"
    [[ -e "${NB_DIR}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

@test "\`init\` exits with status 0 when \`\$_NOTEBOOK_PATH\` exists." {
  {
    mkdir -p "${_NOTEBOOK_PATH}"
    [[ -e "${_NOTEBOOK_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ already\ exists ]]
  [[ ${status} -eq 0                ]]
}

@test "\`init\` creates \`\$NB_DIR\` and \`\$_NOTEBOOK_PATH\` directories." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${NB_DIR}"         ]]
  [[ -d "${_NOTEBOOK_PATH}" ]]
}

@test "\`init\` creates a git directory in \`\$_NOTEBOOK_PATH\`." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${_NOTEBOOK_PATH}/.git" ]]
}

@test "\`init\` creates an .index \`\$_NOTEBOOK_PATH\`." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
}

@test "\`init\` exits with status 0 when \$NBRC_PATH\` exists." {
  {
    touch "${NBRC_PATH}"
    [[ -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
}

@test "\`init\` creates a .nbrc file at \`\$NBRC_PATH\`." {
  {
    [[ ! -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "%s\\n" "$(cat "${NBRC_PATH}")"

  [[ -e "${NBRC_PATH}" ]]
  cat "${NBRC_PATH}" | grep -q "Configuration file for \`nb\`"
  cat "${NBRC_PATH}" | grep -q "NB_ENCRYPTION_TOOL"
}

@test "\`init\` creates git commit." {
  run "${_NB}" init

  cd "${_NOTEBOOK_PATH}" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Initialize'
}

# `init <remote-url>` #########################################################

@test "\`init <remote-url>\` creates a clone in \`\$_NOTEBOOK_PATH\`." {
  {
    _setup_remote_repo
  }

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _origin="$(cd "${_NOTEBOOK_PATH}" && git config --get remote.origin.url)"
  _compare "${_GIT_REMOTE_URL}" "${_origin}"

  [[ -d "${_NOTEBOOK_PATH}/.git"          ]]
  [[ "${_origin}" =~  ${_GIT_REMOTE_URL}  ]]
}

# help ########################################################################

@test "\`help init\` exits with status 0." {
  run "${_NB}" help init

  [[ ${status} -eq 0 ]]
}

@test "\`help init\` prints help information." {
  run "${_NB}" help init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:"                    ]]
  [[ "${lines[1]}" == "  nb init [<remote-url>]"  ]]
}
