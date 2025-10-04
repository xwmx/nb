#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"
  mkdir -p "${NB_DIR}/two"
  cd "${NB_DIR}" || return 1
}

# <name> validation ###########################################################

@test "'notebooks use <reserved>' exits with 1 and prints error message." {
  {
    "${_NB}" init

    cd "${_TMP_DIR}"

    _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  for __name in "${_names[@]}"
  do
    run "${_NB}" notebooks use "${__name}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ ${status} -eq 1                  ]]
    [[ "${lines[0]}" =~ Name\ reserved  ]]
    [[ "${lines[0]}" =~ ${__name}       ]]
  done
}

# `notebooks use <name>` ######################################################

@test "'notebooks use' exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks use

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NB_DIR}/.current")"

  [[ ${status} -eq 1                                  ]]
  [[ "${lines[1]}" =~ \ \ nb\ notebooks               ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"          ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/home'" "'${lines[2]}'"

  [[ "${output}" =~ NB_NOTEBOOK_PATH=${NB_DIR}/home   ]]
}

@test "'notebooks use <invalid>' exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks use not-a-notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NB_DIR}/.current")"

  [[ ${status} -eq 1                          ]]
  [[ "${lines[0]}" =~ Not\ found              ]]
  [[ "${lines[0]}" =~ not-a-notebook          ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/home'" "'${lines[2]}'"

  [[ "${output}" =~ NB_NOTEBOOK_PATH=${NB_DIR}/home ]]
}

@test "'notebooks use <name>' exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks use one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using: $(_color_primary 'one')'" "'${output}'"

  [[ ${status} -eq 0                                      ]]
  [[ "${output}" == "Now using: $(_color_primary 'one')"  ]]
  [[ "$(cat "${NB_DIR}/.current")" == "one"               ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/one'" "'${lines[2]}'"

  [[ "${output}" =~ NB_NOTEBOOK_PATH=${NB_DIR}/one ]]
}

@test "'notebooks use <name>:' exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks use one:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using: $(_color_primary 'one')'" "'${output}'"

  [[ ${status} -eq 0                        ]]
  [[ "${output}" =~ Now\ using:             ]]
  [[ "${output}" =~ one                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "one" ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/one'" "'${lines[2]}'"

  [[ "${output}" =~ NB_NOTEBOOK_PATH=${NB_DIR}/one ]]
}

@test "'notebooks use <name>:' exits with 0, sets the current notebook, and loads local .nbrc." {
  {
    _setup_notebooks

    touch "${NB_DIR}/one/.nbrc"

    cat <<HEREDOC > "${NB_DIR}/one/.nbrc"
NB_DEFAULT_EXTENSION="adoc"
HEREDOC
  }

  run "${_NB}" notebooks use one:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using: $(_color_primary 'one')'" "'${output}'"

  [[ ${status} -eq 0                        ]]
  [[ "${output}" =~ Now\ using:             ]]
  [[ "${output}" =~ one                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "one" ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/one'" "'${lines[2]}'"
  _compare "'NB_DEFAULT_EXTENSION=adoc'"      "'${lines[8]}'"

  [[ "${output}" =~ "NB_NOTEBOOK_PATH=${NB_DIR}/one" ]]
  [[ "${output}" =~ "NB_DEFAULT_EXTENSION=adoc"      ]]
}

@test "'notebooks use' in local exits with 1 and prints error message." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

  }

  run "${_NB}" notebooks use one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NB_DIR}/.current")"

  [[ ${status} -eq 1                          ]]
  [[ "${lines[0]}" =~ in\ a\ local\ notebook  ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${_TMP_DIR}/example'" "'${lines[2]}'"
  [[ "$(cat "${NB_DIR}/.current")" == "home" ]]

  [[ "${output}" =~ "NB_NOTEBOOK_PATH=${_TMP_DIR}/example" ]]
}
