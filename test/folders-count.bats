#!/usr/bin/env bats

load test_helper

# default #####################################################################

@test "'count' with no argument exits with 0 and prints count in root folder." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 2 ]]
}

# notebooks ###################################################################

@test "'count notebook:' exits with 0 and prints count in notebook root folder." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" count home:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 2 ]]
}

@test "'count notebook:<folder>' (no slash) exits with 0 and prints count in <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" count home:Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count notebook:<folder>/' (slash) exits with 0 and prints count in <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" count home:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

# error handling ##############################################################

@test "'count <not-valid>' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]
  [[ "${lines[0]}"  =~  Not\ found:.*not-valid  ]]
}

@test "'count <not-valid> --skip-unmatched-selector' exits with 0 and prints root-level count." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count not-valid --skip-unmatched-selector

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  =~  2 ]]
}

# file paths ##################################################################

@test "'count <file>' exits with 0 and prints count of <file> (1)." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count one.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 1 ]]
}

@test "'count <folder>/<file>' exits with 0 and prints count of <folder>/<file> (1)." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/two.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 1 ]]
}

# <folder> paths ##############################################################

@test "'count <folder>' (no slash) exits with 0 and prints count in <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count <folder>/' (slash) exits with 0 and prints count in <folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count <folder>/<folder>' (no slash) exits with 0 and prints count in <folder>/<folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 4 ]]
}

@test "'count <folder>/<folder>/' (slash) exits with 0 and prints count in <folder>/<folder>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 4 ]]
}

# <id> paths ##################################################################

@test "'count <folder-id>' (no slash) exits with 0 and prints count in <folder-id>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count <folder-id>/' (slash) exits with 0 and prints count in <folder-id>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count <folder>/<folder-id>' (no slash) exits with 0 and prints count in <folder>/<folder-id>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 4 ]]
}

@test "'count <folder>/<folder-id>/' (slash) exits with 0 and prints count in <folder>/<folder-id>." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"
    "${_NB}" add "Example Folder/one.md"
    "${_NB}" add "Example Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/one.md"
    "${_NB}" add "Example Folder/Sample Folder/two.md"
    "${_NB}" add "Example Folder/Sample Folder/three.md"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder"
  }

  run "${_NB}" count Example\ Folder/3/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 4 ]]
}
