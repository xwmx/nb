#!/usr/bin/env bats

load test_helper

# conflicting id / name #######################################################

@test "'_selector_resolve_path()' favors id with conflicting id and folder name." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]
  }

  run "${_NB}" helpers selector_resolve_path 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]

  run "${_NB}" helpers selector_resolve_path 1/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1              ]]
  [[ -z "${output}"                     ]]

  run "${_NB}" helpers selector_resolve_path 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "1"               ]]
}

# edge cases ##################################################################

@test "'_selector_resolve_path()' returns message with pattern that only matches notebook name." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    "${_NB}" notebooks add "example"
  }

  run "${_NB}" helpers selector_resolve_path example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0  ]]
  [[ -z "${output:-}"       ]]
}

# resolve paths ###############################################################

@test "'_selector_resolve_path()' resolves selector with root-level id file path." {
  {
    "${_NB}" init
    "${_NB}" add "A Folder" --type folder
    "${_NB}" add "Example File.md" \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example File.md"  ]]

    [[ -d "${NB_DIR}/home/A Folder"         ]]
  }

  run "${_NB}" helpers selector_resolve_path 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                     ]]
  [[ "${output}"  ==  "Example File.md"     ]]

  run "${_NB}" helpers selector_resolve_path 2 --full

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                 ]]
  [[ "${output}"  ==  "${NB_DIR}/home/Example File.md"  ]]
}

@test "'_selector_resolve_path()' resolves selector with first-level folder id file path." {
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

  run "${_NB}" helpers selector_resolve_path "2/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                 ]]
  [[ "${output}"  ==  "Example Folder/Example File.md"  ]]


  run "${_NB}" helpers selector_resolve_path "2/Example File.md" --full

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                               ]]
  [[ "${output}"  ==  "${NB_DIR}/home/Example Folder/Example File.md" ]]
}
