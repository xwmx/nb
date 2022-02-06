#!/usr/bin/env bats

load test_helper

# --build #####################################################################

@test "'_selector_resolve_folders <existing-folder> --build' (no slash) resolves existing folder name." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md"         \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    [[ "$("${_NB}" notebooks current)" == "home"          ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder" --build

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders <new-segment> --build' (no slash) returns 1 and prints nothing." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md"         \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    [[ "$("${_NB}" notebooks current)" == "home"          ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Sample Folder" --build

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders <new-segment>/ --build' (slash) prints new segment." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md"         \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    [[ "$("${_NB}" notebooks current)" == "home"          ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Sample Folder/" --build

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "Sample Folder" ]]
}

@test "'_selector_resolve_folders <new-segment>/<filename> --build' prints new segment." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md"         \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    [[ "$("${_NB}" notebooks current)" == "home"          ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Sample Folder/Example file.md" --build

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0               ]]
  [[ "${output}"  ==  "Sample Folder" ]]
}

@test "'_selector_resolve_folders <notebook>:<folder-id>/<new-segment>/<filename> --build' resolves folders with new segment." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md"         \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one"           ]]
  }

  run "${_NB}" helpers selector_resolve_folders "home:2/Sample Folder/Example file.md" --build

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

# conflicting id / name #######################################################

@test "'_selector_resolve_folders()' favors id with conflicting id and folder name." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder"  --type folder

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -d "${NB_DIR}/home/1"              ]]
  }

  run "${_NB}" helpers selector_resolve_folders 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]

  run "${_NB}" helpers selector_resolve_folders 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "1"               ]]
}

# _selector_resolve_folders() (error handling) ################################

@test "'_selector_resolve_folders()' returns error with not-valid path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md"  ]]

    [[ -d "${NB_DIR}/home/A Folder"         ]]
  }

  run "${_NB}" helpers selector_resolve_folders not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1               ]]
  [[ -z "${output}"                       ]]
  # [[    "${lines[0]}" =~  Not\ a\ folder: ]]
  # [[    "${lines[0]}" =~  not-valid       ]]
}

@test "'_selector_resolve_folders()' returns error with double not-valid two-level path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md"  ]]

    [[ -d "${NB_DIR}/home/A Folder"         ]]
  }

  run "${_NB}" helpers selector_resolve_folders not-valid/also-not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1               ]]
  [[ -z "${output}"                       ]]
  # [[    "${lines[0]}" =~  Not\ a\ folder: ]]
  # [[    "${lines[0]}" =~  not-valid       ]]
}

@test "'_selector_resolve_folders()' returns error with second-level not-valid two-level path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md"  ]]

    [[ -d "${NB_DIR}/home/A Folder"         ]]
  }

  run "${_NB}" helpers selector_resolve_folders A\ Folder/not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1               ]]
  [[ -z "${output}"                       ]]
  # [[    "${lines[0]}" =~  Not\ a\ folder: ]]
  # [[    "${lines[0]}" =~  not-valid       ]]
}

@test "'_selector_resolve_folders()' returns error with second-level not-valid id two-level path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md"  ]]

    [[ -d "${NB_DIR}/home/A Folder"         ]]
  }

  run "${_NB}" helpers selector_resolve_folders A\ Folder/99/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1               ]]
  [[ -z "${output}"                       ]]
  # [[    "${lines[0]}" =~  Not\ a\ folder: ]]
  # [[    "${lines[0]}" =~  99              ]]
}

# _selector_resolve_folders() (notebooks, folder and file ids) ################

@test "'_selector_resolve_folders()' resolves selector with notebook and root-level file id path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"       ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers selector_resolve_folders home:2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders()' resolves selector with notebook and first-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "home:2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with notebook and second-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "home:2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with notebook and third-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "home:2/2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

# _selector_resolve_folders() (folder and file ids) ####################################

@test "'_selector_resolve_folders()' resolves selector with root-level id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"       ]]
  }

  run "${_NB}" helpers selector_resolve_folders 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level folder id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

# _selector_resolve_folders() (folder ids) ####################################

@test "'_selector_resolve_folders()' resolves selector with root-level folder id path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"       ]]
    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders()' resolves selector with root-level folder id path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"       ]]
    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level folder id path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"   ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level folder id path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"   ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level folder id path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"     ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level folder id path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"     ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level folder id path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder"     ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level folder id path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder" --type folder
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder" --type folder

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder"     ]]
  }

  run "${_NB}" helpers selector_resolve_folders "2/2/2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                       ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder/Test Folder"  ]]
}

# _selector_resolve_folders() (folder) ########################################

@test "'_selector_resolve_folders()' resolves selector with root-level folder path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders()' resolves selector with root-level folder path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level folder path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level folder path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder/Sample Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level folder path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders \
    "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level folder path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders \
    "Example Folder/Sample Folder/Demo Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level folder path, no slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders \
    "Example Folder/Sample Folder/Demo Folder/Test Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level folder path, yes slash." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder" --type folder

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder" ]]
  }

  run "${_NB}" helpers selector_resolve_folders \
    "Example Folder/Sample Folder/Demo Folder/Test Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                       ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder/Test Folder"  ]]
}

# _selector_resolve_folders() (file) ##########################################

@test "'_selector_resolve_folders()' resolves selector with root-level file path." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]
 }

  run "${_NB}" helpers selector_resolve_folders "Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_selector_resolve_folders()' resolves selector with first-level file path." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with second-level file path." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" helpers selector_resolve_folders "Example Folder/Sample Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_selector_resolve_folders()' resolves selector with third-level file path." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]
  }

  run "${_NB}" helpers selector_resolve_folders \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

