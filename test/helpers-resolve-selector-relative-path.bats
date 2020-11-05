#!/usr/bin/env bats

load test_helper

# _resolve_selector_folders() (notebooks, folder and file ids) ################

@test "'_resolve_selector_folders()' resolves selector with notebook and root-level file id path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"       ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers resolve_selector_folders home:2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_selector_folders()' resolves selector with notebook and first-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"

    run "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "home:2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with notebook and second-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
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

  run "${_NB}" helpers resolve_selector_folders "home:2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with notebook and third-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md"

    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
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

  run "${_NB}" helpers resolve_selector_folders "home:2/2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

# _resolve_selector_folders() (folder and file ids) ####################################

@test "'_resolve_selector_folders()' resolves selector with root-level id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"       ]]
  }

  run "${_NB}" helpers resolve_selector_folders 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"

    run "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level folder id file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md"

    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
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

  run "${_NB}" helpers resolve_selector_folders "2/2/2/Example file.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

# _resolve_selector_folders() (folder ids) ####################################

@test "'_resolve_selector_folders()' resolves selector with root-level folder id path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/"

    [[ -d "${NB_DIR}/home/A Folder"       ]]
    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_selector_folders()' resolves selector with root-level folder id path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/"

    [[ -d "${NB_DIR}/home/A Folder"       ]]
    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level folder id path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"   ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level folder id path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                       ]]
    [[ -d "${NB_DIR}/home/Example Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"   ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level folder id path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"     ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level folder id path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                                     ]]
    [[ -d "${NB_DIR}/home/Example Folder"                               ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"               ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"     ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level folder id path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder"     ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/2/2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level folder id path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "A Folder/"
    run "${_NB}" add "Example Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/A Nested Folder/"
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder/"

    [[ -d "${NB_DIR}/home/A Folder"                                                 ]]
    [[ -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/A Nested Folder"                           ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/A Nested Folder"             ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/A Nested Folder" ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder"     ]]
  }

  run "${_NB}" helpers resolve_selector_folders "2/2/2/2/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                       ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder/Test Folder"  ]]
}

# _resolve_selector_folders() (folder) ########################################

@test "'_resolve_selector_folders()' resolves selector with root-level folder path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/"

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_selector_folders()' resolves selector with root-level folder path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/"

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level folder path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level folder path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder/Sample Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level folder path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders \
    "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level folder path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders \
    "Example Folder/Sample Folder/Demo Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level folder path, no slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders \
    "Example Folder/Sample Folder/Demo Folder/Test Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level folder path, yes slash." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Test Folder/"

    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Test Folder" ]]
  }

  run "${_NB}" helpers resolve_selector_folders \
    "Example Folder/Sample Folder/Demo Folder/Test Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                       ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder/Test Folder"  ]]
}

# _resolve_selector_folders() (file) ##########################################

@test "'_resolve_selector_folders()' resolves selector with root-level file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md" ]]
 }

  run "${_NB}" helpers resolve_selector_folders "Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_selector_folders()' resolves selector with first-level file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Example File.md" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with second-level file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" helpers resolve_selector_folders "Example Folder/Sample Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder"  ]]
}

@test "'_resolve_selector_folders()' resolves selector with third-level file path." {
  {
    run "${_NB}" init
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]
  }

  run "${_NB}" helpers resolve_selector_folders \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]
  [[ "${output}"  ==  "Example Folder/Sample Folder/Demo Folder"  ]]
}
