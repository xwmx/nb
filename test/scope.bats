#!/usr/bin/env bats

load test_helper

_setup_scope() {
  "${_NB}" init
  "${_NB}" notebooks add one
  "${_NB}" use one
  "${_NB}" add "# first"
  "${_NB}" use home
  "${_NB}" notebooks add two
}

# `nb <name>:notebook` #####################################################

@test "\`nb one:notebook\` exits with 0 and scoped \`notebook\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:notebook
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ "one" ]]
}

@test "\`nb two:notebook\` exits with 0 and scoped \`notebook\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" two:notebook
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ "two" ]]
}

@test "\`nb one:invalid\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:invalid
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[2]}" =~ "first" ]]
}

# `nb <name>:` #########################################################

@test "\`nb one:\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one:
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[2]}" =~ "first" ]]
}

@test "\`nb one: --no-id\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" one: --no-id
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" = "first" ]]
}

@test "\`nb two:\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" two:
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[2]}" =~ 0\ notes\. ]]
}

@test "\`nb invalid:\` exits with 1 and prints error." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" invalid:
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ "Notebook not found: invalid" ]]
}

# `nb show <notebook>:<identifier>` ########################################

@test "\`nb show one:first --dump\` exits with 0 and prints scoped file content." {
  {
    _setup_scope &>/dev/null
  }

  run "${_NB}" show one:first --dump
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ "first" ]]
}
