#!/usr/bin/env bats

load test_helper

_setup_data() {
  "$_NOTES" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes data add <name>` #####################################################

@test "\`data add\` exits with 1 and prints error message." {
  {
    _setup_data
  }

  run "$_NOTES" data add
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[1]}" == "  notes data add <name> [<remote-url>]" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`data add <existing>\` exits with 1 and prints error message." {
  {
    _setup_data
  }

  run "$_NOTES" data add one
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ Already\ exists ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`data add <name>\` exits with 0 and adds a respository." {
  {
    _setup_data
  }

  run "$_NOTES" data add example
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'Added: example'" "'$output'"

  [[ "$output" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
}

# `notes data current` ########################################################

@test "\`data current\` exits with 0 and lists current default repository." {
  {
    _setup_data
  }

  run "$_NOTES" data current
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "data" ]]
}

@test "\`data current\` exits with 0 and lists current repository." {
  {
    _setup_data
    printf "%s\n" "one" > "${NOTES_DIR}/.current"
  }

  run "$_NOTES" data current
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "one" ]]
}

# `notes data list` ###########################################################

@test "\`data list\` exits with 0 and lists repositories." {
  {
    _setup_data
  }

  run "$_NOTES" data list
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="data
one"
  [[ "$output" == "$_expected" ]]
}

# `notes data use <name>` #####################################################

@test "\`data use\` exits with 1 and prints error message." {
  {
    _setup_data
  }

  run "$_NOTES" data use
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf ".current: %s\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[1]}" == "  notes data add <name> [<remote-url>]" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "data" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/data'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/data" ]]
}

@test "\`data add <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_data
  }

  run "$_NOTES" data use one
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
  run "$_NOTES" help data
  [[ $status -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "$_NOTES" help data
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes data add <name> [<remote-url>]" ]]
}
