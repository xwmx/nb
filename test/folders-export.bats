#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'export folder/<filename>' with invalid filename returns with error and message." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/not-valid" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not export file:

  [[ ! -e "${_TMP_DIR}/example.md"  ]]

  # Prints output:

  [[ "${output}" =~ Not\ found:               ]]
  [[ "${output}" =~ Example\ Folder/not-valid ]]
}

# <filename> ##################################################################

@test "'export folder/<filename>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/Example File.bookmark.md" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                         ]]
  [[ "${output}" =~ Example\ Folder/1                                 ]]
  [[ "${output}" =~ 🔖                                                ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md         ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                            ]]
}

@test "'export folder/folder/<filename>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/Sample Folder/Example File.bookmark.md" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]


  # Prints output:

  [[ "${output}" =~ Exported:                                                 ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                    ]]
}

@test "'export notebook:folder/<filename>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export "home:Example Folder/Example File.bookmark.md" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                       ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                          ]]
}

@test "'export notebook:folder/folder/<filename>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export                                             \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                                     ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                        ]]
}

# <id> ########################################################################

@test "'export folder/<id>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]

  }

  run "${_NB}" export "Example Folder/1" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                         ]]
  [[ "${output}" =~ Example\ Folder/1                                 ]]
  [[ "${output}" =~ 🔖                                                ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md         ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                            ]]
}

@test "'export folder/folder/<id>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/Sample Folder/1" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]


  # Prints output:

  [[ "${output}" =~ Exported:                                                 ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                    ]]
}

@test "'export notebook:folder/<id>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export "home:Example Folder/1" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                       ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                          ]]
}

@test "'export notebook:folder/folder/<id>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export "home:Example Folder/Sample Folder/1" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" == "<https://2.example.test>"  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                                     ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                        ]]
}

# <title> #####################################################################

@test "'export folder/<title>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/Example Title" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ Example\ Title              ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ \<https://2.example.test\>  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                         ]]
  [[ "${output}" =~ Example\ Folder/1                                 ]]
  [[ "${output}" =~ 🔖                                                ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md         ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                            ]]
}

@test "'export folder/folder/<title>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[ ! -e "${_TMP_DIR}/example.md"  ]]
  }

  run "${_NB}" export "Example Folder/Sample Folder/Example Title" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ Example\ Title              ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ \<https://2.example.test\>  ]]


  # Prints output:

  [[ "${output}" =~ Exported:                                                 ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                    ]]
}

@test "'export notebook:folder/<title>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export "home:Example Folder/Example Title" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ Example\ Title              ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ \<https://2.example.test\>  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                       ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                          ]]
}

@test "'export notebook:folder/folder/<title>' exports properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[ ! -e "${_TMP_DIR}/example.md"            ]]
  }

  run "${_NB}" export "home:Example Folder/Sample Folder/Example Title" "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Exports file:

  [[ -e "${_TMP_DIR}/example.md"                                      ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ Example\ Title              ]]
  [[ "$(cat "${_TMP_DIR}/example.md")" =~ \<https://2.example.test\>  ]]

  # Prints output:

  [[ "${output}" =~ Exported:                                                     ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
  [[ "${output}" =~ ${_TMP_DIR}/example.md                                        ]]
}
