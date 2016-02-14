#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "$_NOTES" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes notebooks` ###########################################################

@test "\`notebooks\` exits with 0 and lists notebooks." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebooks
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="$(tput setaf 3)home$(tput sgr0)
one	(${_GIT_REMOTE_URL})"
  [[ "$output" == "$_expected" ]]
}

@test "\`notebooks --names\` exits with 0 and lists notebook names." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebooks --names
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="home
one"
  [[ "$output" == "$_expected" ]]
}

# help ########################################################################

@test "\`help notebooks\` exits with status 0." {
  run "$_NOTES" help notebooks
  [[ $status -eq 0 ]]
}

@test "\`help notebooks\` prints help information." {
  run "$_NOTES" help notebooks
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes notebooks [--names]" ]]
}
