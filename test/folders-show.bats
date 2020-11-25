#!/usr/bin/env bats

load test_helper

# show <path-with-folder> --relative-path #####################################

@test "'show folder/folder/<title> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/Example Title" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

@test "'show folder/folder/<filename> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.bookmark.md" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

@test "'show folder/folder/<id> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _example_selector="Example Folder/Sample Folder/1"
  printf "'%s'\\n" "${_example_selector%\/*}"
  printf "'%s'\\n" "${_example_selector##*\/}"
  "${_NB}" index get_basename   \
    "${_example_selector##*\/}" \
    "${NB_DIR}/home/${_example_selector%\/*}"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

@test "'show notebook:folder/folder/<id> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "one"

    "${_NB}" one:add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                                \
      --title   "Example Title"

    [[ -d "${NB_DIR}/one/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/one/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/one/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "one:Example Folder/Sample Folder/1" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

# show <path-with-folder> --info-line #########################################

@test "'show folder/folder/<filename> --info-line' displays info line." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[   ${status}      -eq 0                                                       ]]
  [[   "${output}"    =~  1                                                       ]]
  [[   "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/example.bookmark.md  ]]
  [[   "${output}"    =~  Example\ Title                                          ]]
  [[   "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/1                    ]]
  [[ ! "${output}"    =~  home                                                    ]]
  [[   "${output}"    =~  🔖                                                      ]]
}

@test "'show notebook:folder/folder/<filename> --info-line' displays info line." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" show "home:Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ ${status}      -eq 0                                                       ]]
  [[ "${output}"    =~  1                                                       ]]
  [[ "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/example.bookmark.md  ]]
  [[ "${output}"    =~  Example\ Title                                          ]]
  [[ "${output}"    =~  home:Example\\\ Folder/Sample\\\ Folder/1               ]]
  [[ "${output}"    =~  🔖                                                      ]]
}

# show <path-with-folder> --selector-id #######################################

@test "'show folder/folder/<filename> --selector-id' displays selector id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                         ]]
  [[ "${output}"  =~ Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'show demo:folder/folder/<filename> --selector-id' displays selector id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                    ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md"  ]]
  }

  run "${_NB}" show "demo:Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                         ]]
  [[ "${output}"  =~ Example\ Folder/Sample\ Folder/example.md  ]]
}
