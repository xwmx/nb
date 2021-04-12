#!/usr/bin/env bats

load test_helper

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

  [[ "${lines[0]}"  == "email (global): ${_global_email}" ]]
  [[ "${lines[1]}"  == "name  (global): ${_global_name}"  ]]
}
