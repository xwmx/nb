#!/usr/bin/env bats

load test_helper

# `notes init` ################################################################

@test "\`init\` exits with status 0." {
  run "${_NOTES}" init
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`init\` exits with status 1 when \`\$NOTES_DIR\` exists as a file." {
  touch "${NOTES_DIR}"
  [[ -e "${NOTES_DIR}" ]]
  run "${_NOTES}" init
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
}

@test "\`init\` exits with status 1 when \`\$NOTES_DATA_DIR\` exists." {
  mkdir -p "${NOTES_DATA_DIR}"
  [[ -e "${NOTES_DATA_DIR}" ]]
  run "$_NOTES" init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 1 ]]
}

@test "\`init\` creates \`\$NOTES_DIR\` and \`\$NOTES_DATA_DIR\` directories." {
  run "$_NOTES" init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ -d "${NOTES_DIR}" ]]
  [[ -d "${NOTES_DATA_DIR}" ]]
}

@test "\`init\` creates a git directory in \`\$NOTES_DATA_DIR\`." {
  run "$_NOTES" init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ -d "${NOTES_DATA_DIR}/.git" ]]
}

@test "\`init\` exits with status 0 when \$NOTESRC_PATH\` exists." {
  touch "${NOTESRC_PATH}"
  [[ -e "${NOTESRC_PATH}" ]]
  run "$_NOTES" init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
}

@test "\`init\` creates a .notesrc file at \`\$NOTESRC_PATH\`." {
  [[ ! -e "${NOTESRC_PATH}" ]]
  run "$_NOTES" init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ -e "${NOTESRC_PATH}" ]]
  cat "${NOTESRC_PATH}" | grep -q 'Configuration file for notes'
  printf "%s\n" "$(cat "${NOTESRC_PATH}")"
  cat "${NOTESRC_PATH}" | grep -q '\$NOTES_AUTO_SYNC'
}

# `notes init <remote-url>` ###################################################

@test "\`init <remote-url>\` creates a clone in \`\$NOTES_DATA_DIR\`." {
  _setup_remote_repo
  run "$_NOTES" init "$_GIT_REMOTE_URL"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ -d "${NOTES_DATA_DIR}/.git" ]]
  _origin="$(cd "${NOTES_DATA_DIR}" && git config --get remote.origin.url)"
  _compare "$_GIT_REMOTE_URL" "$_origin"
  [[ "$_origin" =~  "$_GIT_REMOTE_URL" ]]
}

# help ########################################################################

@test "\`help init\` exits with status 0." {
  run "$_NOTES" help init
  [[ $status -eq 0 ]]
}

@test "\`help init\` prints help information." {
  run "$_NOTES" help init
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes init [<remote-url>]" ]]
}
