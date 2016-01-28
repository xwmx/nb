#!/usr/bin/env bats

load test_helper

_setup_repos() {
  "$_NOTES" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes repos` ###########################################################

@test "\`repos\` exits with 0 and lists repositories." {
  {
    _setup_repos
  }

  run "$_NOTES" repos
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="data
one"
  [[ "$output" == "$_expected" ]]
}

# help ########################################################################

@test "\`help repos\` exits with status 0." {
  run "$_NOTES" help repos
  [[ $status -eq 0 ]]
}

@test "\`help repos\` prints help information." {
  run "$_NOTES" help repos
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes repos" ]]
}
