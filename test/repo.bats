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

# `notes repo` ################################################################

@test "\`repo\` exits with 0 and lists current default repository." {
  {
    _setup_repos
  }

  run "$_NOTES" repo
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "data" ]]
}

@test "\`repo current\` exits with 0 and lists current repository." {
  {
    _setup_repos
    printf "%s\n" "one" > "${NOTES_DIR}/.current"
  }

  run "$_NOTES" repo
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "one" ]]
}

# `notes repo add <name>` #####################################################

@test "\`repo add\` exits with 1 and prints error message." {
  {
    _setup_repos
  }

  run "$_NOTES" repo add
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[1]}" == "  notes repo add <name> [<remote-url>]" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`repo add <existing>\` exits with 1 and prints error message." {
  {
    _setup_repos
  }

  run "$_NOTES" repo add one
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ Already\ exists ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`repo add <name>\` exits with 0 and adds a respository." {
  {
    _setup_repos
  }

  run "$_NOTES" repo add example
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'Added: example'" "'$output'"

  [[ "$output" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
}

# `notes repo list` ###########################################################

@test "\`repo list\` exits with 0 and lists repositories." {
  {
    _setup_repos
  }

  run "$_NOTES" repo list
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="data
one"
  [[ "$output" == "$_expected" ]]
}

# `notes repo use <name>` #####################################################

@test "\`repo use\` exits with 1 and prints error message." {
  {
    _setup_repos
  }

  run "$_NOTES" repo use
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf ".current: %s\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[1]}" == "  notes repo add <name> [<remote-url>]" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "data" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/data'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/data" ]]
}

@test "\`repo add <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_repos
  }

  run "$_NOTES" repo use one
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'Added: example'" "'$output'"

  [[ "$output" == "Now using one" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/one'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/one" ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "$_NOTES" help repo
  [[ $status -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "$_NOTES" help repo
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes repo add <name> [<remote-url>]" ]]
}
