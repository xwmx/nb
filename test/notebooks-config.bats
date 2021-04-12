#!/usr/bin/env bats

load test_helper

# notebooks config --unset ####################################################

@test "'notebooks config --unset' with local email unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email  "local@example.test"
  }

  run "${_NB}" notebooks config --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}

@test "'notebooks config --unset' with local name unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks config --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}

@test "'notebooks config --unset' with full local configuration unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks config --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}

@test "'notebooks config --unset' with no local configuration prints global values." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks config --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}

# notebooks config ############################################################

@test "'notebooks config' with local email prints local value with global name." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email  "local@example.test"
  }

  run "${_NB}" notebooks config

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (local):  local@example.test" ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}

@test "'notebooks config' with local name prints local value with global email." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks config

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (local):  Example Local Name" ]]
}

@test "'notebooks config' with full local configuration prints local values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks config

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  [[ "${lines[0]}"  == "email (local):  local@example.test" ]]
  [[ "${lines[1]}"  == "name  (local):  Example Local Name" ]]
}

@test "'notebooks config' with no local configuration prints global values." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks config

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 2 ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  == "email (global): ${_global_email}"   ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"    ]]
}
