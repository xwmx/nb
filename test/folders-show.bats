#!/usr/bin/env bats

load test_helper

# show error handling #########################################################

@test "'show filename/<id>' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "one.md"     --title "one"     --content "Content one."
    "${_NB}" add "example.md" --title "example" --content "Content example."
  }

  run "${_NB}" show one.md/example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1             ]]

  [[   "${lines[0]}"  =~ Not\ found:    ]]
  [[   "${lines[0]}"  =~ one.md/example ]]
  [[   "${#lines[@]}" == 1              ]]
}

# show --id ###################################################################

@test "'show <folder>/<filename> --id' exits with status 0 and prints note id." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Example File.md"
  }

  run "${_NB}" show "Example Folder/Example File.md" --id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0   ]]
  [[ "${output}" ==   "1" ]]
}

# show --relative-path ########################################################

@test "'show <selector> --relative-path' with numeric folder name gives precedence to ids." {
  {
    "${_NB}" init

    "${_NB}" add                        \
      --content   "Example content 2."  \
      --filename  "2"

    "${_NB}" add                        \
      --filename  "1"                   \
      --type      "folder"


    [[ -d "${NB_DIR}/home/1" ]]
    [[ -f "${NB_DIR}/home/2" ]]
  }

  run "${_NB}" show 1 --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]
  [[ "${output}" ==  "2"    ]]

  run "${_NB}" show 2 --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]
  [[ "${output}" ==  "1"    ]]
}

@test "'show <id> --relative-path' with filename matching notebook name prints filename." {
  {
    "${_NB}" init

    "${_NB}" add --filename "one:" --content "Example content one."
    "${_NB}" add --filename "two:" --content "Example content two."

    "${_NB}" notebooks add "one"

    [[ -d "${NB_DIR}/one"       ]]
    [[ -f "${NB_DIR}/home/one:" ]]
    [[ -f "${NB_DIR}/home/two:" ]]
  }

  run "${_NB}" show 1 --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0          ]]
  [[ "${output}" ==  "one:"     ]]

  run "${_NB}" show 2 --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0          ]]
  [[ "${output}" ==  "two:"     ]]
}

@test "'show folder/folder/<title> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/Example Title" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ "${status}"  -eq 0                                                     ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder/example.bookmark.md   ]]
}

@test "'show folder/folder/<filename> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.bookmark.md" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ "${status}"  -eq 0                                                     ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder/example.bookmark.md   ]]
}

@test "'show folder/folder/<id> --relative-path' displays relative path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
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

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder/example.bookmark.md ]]
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

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder/example.bookmark.md ]]
}

@test "'show notebook: --relative-path' prints empty string." {
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

  run "${_NB}" show "one:" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0 ]]
  [[ -z "${output}"       ]]
}

# show --folder-path ########################################################

@test "'show <id> --folder-path' with filename matching notebook name prints nothing." {
  {
    "${_NB}" init

    "${_NB}" add --filename "one:" --content "Example content one."
    "${_NB}" add --filename "two:" --content "Example content two."

    "${_NB}" notebooks add "one"

    [[ -d "${NB_DIR}/one"       ]]
    [[ -f "${NB_DIR}/home/one:" ]]
    [[ -f "${NB_DIR}/home/two:" ]]
  }

  run "${_NB}" show 1 --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0 ]]
  [[ -z "${output:-}"     ]]

  run "${_NB}" show 2 --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0 ]]
  [[ -z "${output:-}"     ]]
}

@test "'show folder/folder --folder-path' (no slash) displays folder path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "Example Folder"  ]]
}

@test "'show folder/folder/ --folder-path' (slash) displays folder path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder ]]
}

@test "'show folder/folder/<title> --folder-path' displays folder path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/Example Title" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder ]]
}

@test "'show folder/folder/<filename> --folder-path' displays folder path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.bookmark.md" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder ]]
}

@test "'show folder/folder/<id> --folder-path' displays folder path." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _example_selector="Example Folder/Sample Folder/1"
  printf "'%s'\\n" "${_example_selector%\/*}"
  printf "'%s'\\n" "${_example_selector##*\/}"
  "${_NB}" index get_basename   \
    "${_example_selector##*\/}" \
    "${NB_DIR}/home/${_example_selector%\/*}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder ]]
}

@test "'show notebook:folder/folder/<id> --folder-path' displays folder path." {
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

  run "${_NB}" show "one:Example Folder/Sample Folder/1" --folder-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                               ]]
  [[ "${output}"  =~  ^Example\ Folder/Sample\ Folder ]]
}

@test "'show notebook: --folder-path' prints empty string." {
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

  run "${_NB}" show "one:" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0 ]]
  [[ -z "${output}"       ]]
}

# show <path-with-folder> --info-line #########################################

@test "'show folder/folder/<filename> --info-line' displays info line." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[   "${status}"    -eq 0                                                   ]]
  [[   "${output}"    =~  1                                                   ]]
  [[   "${output}"    =~  Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
  [[   "${output}"    =~  Example\ Title                                      ]]
  [[   "${output}"    =~  Example\ Folder/Sample\ Folder/1                    ]]
  [[ ! "${output}"    =~  home                                                ]]
  [[   "${output}"    =~  🔖                                                  ]]
}

@test "'show notebook:folder/folder/<filename> --info-line' displays info line." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" show "home:Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${NB_DIR}/home/Example Folder/Sample Folder/"

  [[ "${status}"    -eq 0                                                   ]]
  [[ "${output}"    =~  1                                                   ]]
  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
  [[ "${output}"    =~  Example\ Title                                      ]]
  [[ "${output}"    =~  home:Example\ Folder/Sample\ Folder/1               ]]
  [[ "${output}"    =~  🔖                                                  ]]
}

# show <path-with-folder> --selector-id #######################################

@test "'show folder/folder/<filename> --selector-id' displays selector id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                         ]]
  [[ "${output}"  =~  Example\ Folder/Sample\ Folder/example.md ]]
}

@test "'show demo:folder/folder/<filename> --selector-id' displays selector id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/example.bookmark.md" \
      --content "<https://example.test>"                            \
      --title   "Example Title"

    [[ -d "${NB_DIR}/home/Example Folder"                                   ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/example.bookmark.md" ]]
  }

  run "${_NB}" show "demo:Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                         ]]
  [[ "${output}"  =~  Example\ Folder/Sample\ Folder/example.md ]]
}
