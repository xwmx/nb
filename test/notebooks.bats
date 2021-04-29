#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init

  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"

  cd "${NB_DIR}" || return 1
}

# --archived / --unarchived ###################################################

@test "'notebooks --archived' works with filtering." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Query Notebook"
    "${_NB}" notebooks add "Demo Query Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" archive "Sample Query Notebook"
    "${_NB}" archive "Demo Query Notebook"
    "${_NB}" archive "Test Notebook"
  }

  run "${_NB}" notebooks --archived query

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                      ]]
  [[    "${#lines[@]}" -eq 2                                      ]]

  [[ !  "${output}"    =~  home                                   ]]
  [[ !  "${output}"    =~  Example\ Notebook                      ]]
  [[    "${output}"    =~  Sample\ Query\ Notebook\ \(archived\)  ]]
  [[    "${output}"    =~  Demo\ Query\ Notebook\ \(archived\)    ]]
  [[ !  "${output}"    =~  Test\ Notebook                         ]]
}

@test "'notebooks --ar' exits with 0 and prints archived notebooks." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" archive "Sample Notebook"
    "${_NB}" archive "Test Notebook"
  }

  run "${_NB}" notebooks --ar

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                              ]]
  [[    "${#lines[@]}" -eq 2                              ]]

  [[ !  "${output}"    =~  home                           ]]
  [[ !  "${output}"    =~  Example\ Notebook              ]]
  [[    "${output}"    =~  Sample\ Notebook\ \(archived\) ]]
  [[ !  "${output}"    =~  Demo\ Notebook                 ]]
  [[    "${output}"    =~  Test\ Notebook\ \(archived\)   ]]
}

@test "'notebooks --archived' exits with 0 and prints archived notebooks." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" archive "Sample Notebook"
    "${_NB}" archive "Test Notebook"
  }

  run "${_NB}" notebooks --archived

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                              ]]
  [[    "${#lines[@]}" -eq 2                              ]]

  [[ !  "${output}"    =~  home                           ]]
  [[ !  "${output}"    =~  Example\ Notebook              ]]
  [[    "${output}"    =~  Sample\ Notebook\ \(archived\) ]]
  [[ !  "${output}"    =~  Demo\ Notebook                 ]]
  [[    "${output}"    =~  Test\ Notebook\ \(archived\)   ]]
}

@test "'notebooks --unarchived' exits with 0 and prints unarchived notebooks." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" archive "Sample Notebook"
    "${_NB}" archive "Test Notebook"
  }

  run "${_NB}" notebooks --unarchived

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                  ]]
  [[    "${#lines[@]}" -eq 3                  ]]

  [[    "${output}"    =~  home               ]]
  [[    "${output}"    =~  Example\ Notebook  ]]
  [[ !  "${output}"    =~  Sample\ Notebook   ]]
  [[    "${output}"    =~  Demo\ Notebook     ]]
  [[ !  "${output}"    =~  Test\ Notebook     ]]
}

@test "'notebooks --unar' exits with 0 and prints unarchived notebooks." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks add "Test Notebook"

    "${_NB}" archive "Sample Notebook"
    "${_NB}" archive "Test Notebook"
  }

  run "${_NB}" notebooks --unar

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                  ]]
  [[    "${#lines[@]}" -eq 3                  ]]

  [[    "${output}"    =~  home               ]]
  [[    "${output}"    =~  Example\ Notebook  ]]
  [[ !  "${output}"    =~  Sample\ Notebook   ]]
  [[    "${output}"    =~  Demo\ Notebook     ]]
  [[ !  "${output}"    =~  Test\ Notebook     ]]
}

# notebook name filtering #####################################################

@test "'notebooks --not-valid-option-or-query' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example One"
    "${_NB}" notebooks add "Example Two"
    "${_NB}" notebooks add "Example Three"

    "${_NB}" notebooks add "Sample One"
    "${_NB}" notebooks add "Sample Two"

    "${_NB}" notebooks add "Demo One"
    "${_NB}" notebooks add "Demo Two"
  }

  run "${_NB}" notebooks --not-valid-option-or-query

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                         ]]
  [[ "${#lines[@]}" -eq 1                         ]]

  [[ "${output}"    =~  \
\!.*\ Notebook\ not\ found:\ .*--not-valid-option-or-query ]]
}

@test "'notebooks <query> --path' exits with 0 and prints matching notebook paths." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example One"
    "${_NB}" notebooks add "Example Two"
    "${_NB}" notebooks add "Example Three"

    "${_NB}" notebooks add "Sample One"
    "${_NB}" notebooks add "Sample Two"

    "${_NB}" notebooks add "Demo One"
    "${_NB}" notebooks add "Demo Two"
  }

  run "${_NB}" notebooks example --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${output}"    =~  ${NB_DIR}/Example\ Three  ]]
  [[ "${output}"    =~  ${NB_DIR}/Example\ Two    ]]
  [[ "${output}"    =~  ${NB_DIR}/Example\ One    ]]

  run "${_NB}" notebooks two --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]
  [[ "${#lines[@]}" -eq 3                         ]]

  [[ "${output}"    =~  ${NB_DIR}/Example\ Two    ]]
  [[ "${output}"    =~  ${NB_DIR}/Sample\ Two     ]]
  [[ "${output}"    =~  ${NB_DIR}/Demo\ Two       ]]

  run "${_NB}" notebooks no-match --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                         ]]
  [[ "${#lines[@]}" -eq 1                         ]]

  [[ "${output}"    =~  \!.*\ Notebook\ not\ found:\ .*no-match ]]
}

@test "'notebooks <query> --name' exits with 0 and prints matching notebook names." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example One"
    "${_NB}" notebooks add "Example Two"
    "${_NB}" notebooks add "Example Three"

    "${_NB}" notebooks add "Sample One"
    "${_NB}" notebooks add "Sample Two"

    "${_NB}" notebooks add "Demo One"
    "${_NB}" notebooks add "Demo Two"
  }

  run "${_NB}" notebooks example --name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${#lines[@]}" -eq 3               ]]

  [[ "${output}"    =~  Example\ Three  ]]
  [[ "${output}"    =~  Example\ Two    ]]
  [[ "${output}"    =~  Example\ One    ]]

  run "${_NB}" notebooks two --name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${#lines[@]}" -eq 3               ]]

  [[ "${output}"    =~  Example\ Two    ]]
  [[ "${output}"    =~  Sample\ Two     ]]
  [[ "${output}"    =~  Demo\ Two       ]]

  run "${_NB}" notebooks no-match --name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1               ]]
  [[ "${#lines[@]}" -eq 1               ]]

  [[ "${output}"    =~  \!.*\ Notebook\ not\ found:\ .*no-match ]]
}

@test "'notebooks <query>' exits with 0 and prints matching notebook names." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example One"
    "${_NB}" notebooks add "Example Two"
    "${_NB}" notebooks add "Example Three"

    "${_NB}" notebooks add "Sample One"
    "${_NB}" notebooks add "Sample Two"

    "${_NB}" notebooks add "Demo One"
    "${_NB}" notebooks add "Demo Two"
  }

  run "${_NB}" notebooks example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${#lines[@]}" -eq 3               ]]

  [[ "${output}"    =~  Example\ Three  ]]
  [[ "${output}"    =~  Example\ Two    ]]
  [[ "${output}"    =~  Example\ One    ]]

  run "${_NB}" notebooks two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${#lines[@]}" -eq 3               ]]

  [[ "${output}"    =~  Example\ Two    ]]
  [[ "${output}"    =~  Sample\ Two     ]]
  [[ "${output}"    =~  Demo\ Two       ]]

  run "${_NB}" notebooks no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1               ]]
  [[ "${#lines[@]}" -eq 1               ]]

  [[ "${output}"    =~  \!.*\ Notebook\ not\ found:\ .*no-match ]]
}

# `notebooks` #################################################################

@test "'notebooks' exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
    _expected="$(_color_primary 'home' --underline)
one (${_GIT_REMOTE_URL})"
  }

  NB_COLOR_HIGHLIGHT=3 run "${_NB}" notebooks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks <name>' exits with 0 and prints the given notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="one (${_GIT_REMOTE_URL})"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks <name> <name>' exits with 0 and prints the given notebooks." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks one home

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="one (${_GIT_REMOTE_URL})
$(_color_primary 'home' --underline)"
  _compare "${_expected}" "${output}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks <invalid>' exits with 1 and prints the given notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                     ]]
  [[ "${output}"  =~  Notebook\ not\ found  ]]
}

@test "'notebooks <name> --names' exits with 0 and prints the given notebook name." {
  {
    _setup_notebooks

    _expected="$(_color_primary 'home')"
  }

  run "${_NB}" notebooks home --names

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks --names' exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
    _expected="$(_color_primary 'home' --underline)
one"
  }

  run "${_NB}" notebooks --names

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks --no-color' exits with 0 and prints all notebook names with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one (${_GIT_REMOTE_URL})"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks <name> --no-color' exits with 0 and prints the given notebook name with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks home --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "${_expected}"  ]]
}

@test "'notebooks --names --no-color' exits with 0 and prints all notebook names with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks --names --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --names --no-color --archived' exits with 0 and prints archived." {
  {
    _setup_notebooks
    "${_NB}" one:notebook archive
  }

  run "${_NB}" notebooks --names --no-color --archived

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --names --no-color --unarchived' exits with 0 and prints unarchived." {
  {
    _setup_notebooks
    "${_NB}" one:notebook archive
  }

  run "${_NB}" notebooks --names --no-color --unarchived

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --names --no-color' prints local and global." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)"   ==  "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" notebooks --names --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="local
home
one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --names --no-color --local' exits with 0 and prints local." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)"   ==  "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" notebooks --names --no-color --local

  printf "\${PWD}: %s\\n" "${PWD}"
  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="local"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --names --no-color --local' with no local exits with 1." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}"

    [[ "$(pwd)"   ==  "${_TMP_DIR}"   ]]
  }

  run "${_NB}" notebooks --names --no-color --local

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -z "${output}"       ]]
  [[    "${status}" -eq 1 ]]
}

@test "'notebooks --names --no-color --global' exits with 0 and prints global." {
  {
    _setup_notebooks
    "${_NB}" notebooks init "${_TMP_DIR}/example-local"
  }

  run "${_NB}" notebooks --names --no-color --global

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

# `notebooks --paths` #########################################################

@test "'notebooks --paths' prints local and global." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)"   ==  "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" notebooks --paths

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="${_TMP_DIR}/example-local
${NB_DIR}/home
${NB_DIR}/one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --paths --local' exits with 0 and prints local." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)"   ==  "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" notebooks --paths --local

  printf "\${PWD}: %s\\n" "${PWD}"
  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="${_TMP_DIR}/example-local"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

@test "'notebooks --paths --local' with no local exits with 1." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}"

    [[ "$(pwd)"     ==  "${_TMP_DIR}" ]]
  }

  run "${_NB}" notebooks --paths --local

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -z "${output}"                   ]]
  [[    "${status}" -eq 1             ]]
}

@test "'notebooks --paths --global' exits with 0 and prints global." {
  {
    _setup_notebooks
    "${_NB}" notebooks init "${_TMP_DIR}/example-local"
  }

  run "${_NB}" notebooks --paths --global

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="${NB_DIR}/home
${NB_DIR}/one"

  [[ "${output}"  ==  "${_expected}"  ]]
  [[ "${status}"  -eq 0               ]]
}

# help ########################################################################

@test "'help notebooks' exits with status 0." {
  run "${_NB}" help notebooks

  [[ "${status}"    -eq 0                 ]]
}

@test "'help notebooks' prints help information." {
  run "${_NB}" help notebooks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}"  =~  Usage.*:          ]]
  [[ "${lines[1]}"  =~  \ \ nb\ notebooks ]]
}
