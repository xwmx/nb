#!/usr/bin/env bats

load test_helper

# `plugins` ###################################################################

@test "\`plugins\` lists plugins." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"
  }; _setup

  run "${_NB}" plugins

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                     ]]
  [[ "${lines[0]}" =~ example.nb-plugin   ]]
  [[ "${lines[1]}" =~ turquoise.nb-theme  ]]
}

@test "\`plugins <name>\` lists plugins." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"
  }; _setup

  run "${_NB}" plugins example.nb-plugin

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                   ]]
  [[ "${lines[0]}" =~ example.nb-plugin ]]
  [[ -z "${lines[1]}"                   ]]
}

@test "\`plugins <name>\` with no matching exits with error." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"
  }; _setup

  run "${_NB}" plugins example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1                       ]]
  [[ "${lines[0]}" =~ No\ matching\ plugins ]]
  [[ -z "${lines[1]}"                       ]]
}

@test "\`plugins\` with no plugins exits with error." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1             ]]
  [[ "${lines[0]}" =~ No\ plugins ]]
  [[ -z "${lines[1]}"             ]]
}

# `plugins install` ###########################################################

@test "\`plugins install\` with valid <path> argument installs a plugin." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                           ]]
  [[ -e "${NB_DIR}/.plugins/example.nb-plugin"  ]]
  [[ "${lines[0]}" =~ Plugin\ installed         ]]
  [[ "${lines[1]}" =~ example.nb-plugin         ]]

  run "${_NB}" example

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Hello,\ World!  ]]
}

@test "\`plugins install\` with valid <path> argument installs a theme plugin." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                           ]]
  [[ -e "${NB_DIR}/.plugins/turquoise.nb-theme" ]]
  [[ "${lines[0]}" =~ Plugin\ installed         ]]
  [[ "${lines[1]}" =~ turquoise.nb-theme        ]]

  run "${_NB}" settings colors themes

  [[ "${status}" == 0         ]]
  [[ "${output}" =~ turquoise ]]
}

@test "\`plugins install\` with valid <url> argument installs a plugin." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins install file://"${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                           ]]
  [[ -e "${NB_DIR}/.plugins/example.nb-plugin"  ]]
  [[ "${lines[0]}" =~ Plugin\ installed         ]]
  [[ "${lines[1]}" =~ example.nb-plugin         ]]

  run "${_NB}" example

  [[ "${status}" == 0                 ]]
  [[ "${lines[0]}" =~ Hello,\ World!  ]]
}

@test "\`plugins install\` with valid <url> argument installs a theme plugin." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins install file://"${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                           ]]
  [[ -e "${NB_DIR}/.plugins/turquoise.nb-theme" ]]
  [[ "${lines[0]}" =~ Plugin\ installed         ]]
  [[ "${lines[1]}" =~ turquoise.nb-theme        ]]

  run "${_NB}" settings colors themes

  [[ "${status}" == 0         ]]
  [[ "${output}" =~ turquoise ]]
}

@test "\`plugins install\` with invalid argument exits with error." {
  _setup() {
    run "${_NB}" init
  }; _setup

  run "${_NB}" plugins install "invalid"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1               ]]
  [[ "${lines[0]}" =~ Not\ a\ valid ]]
}

@test "\`plugins install\` with existing plugin exits with error." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
  }; _setup

  run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1                     ]]
  [[ "${lines[0]}" =~ already\ installed  ]]
}

# `plugins uninstall` #########################################################

@test "\`plugins uninstall\` with valid <name> argument uninstalls a plugin." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
  }; _setup

  run "${_NB}" plugins uninstall "example.nb-plugin" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                                   ]]
  [[ ! -e "${NB_DIR}/.plugins/example.nb-plugin"        ]]
  [[ "${lines[0]}" =~ Plugin\ successfully\ uninstalled ]]
  [[ "${lines[1]}" =~ example.nb-plugin                 ]]
}

@test "\`plugins uninstall\` with valid <name> argument uninstalls a theme." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/turquoise.nb-theme"
  }; _setup

  run "${_NB}" plugins uninstall "turquoise.nb-theme" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                                   ]]
  [[ ! -e "${NB_DIR}/.plugins/turquoise.nb-theme"       ]]
  [[ "${lines[0]}" =~ Plugin\ successfully\ uninstalled ]]
  [[ "${lines[1]}" =~ turquoise.nb-theme                ]]
}

@test "\`plugins uninstall\` with invalid <name> argument exits with error." {
  _setup() {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"
  }; _setup

  run "${_NB}" plugins uninstall "example" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 1                           ]]
  [[ -e "${NB_DIR}/.plugins/example.nb-plugin"  ]]
  [[ "${lines[0]}" =~ Plugin\ not\ found        ]]
  [[ "${lines[0]}" =~ example                   ]]
  [[ -z "${lines[1]}"                           ]]
}
