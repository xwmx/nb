#!/usr/bin/env bats

load test_helper

# show <path-with-folder> --relative-path ###################################o##

@test "\`show folder/folder/example.md --relative-path\` displays relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.bookmark.md" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

@test "\`show folder/folder/1 --relative-path\` displays relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _example_selector="Example Folder/Sample Folder/1"
  printf "'%s'\\n" "${_example_selector%\/*}"
  printf "'%s'\\n" "${_example_selector##*\/}"
  _INDEX_FOLDER_PATH="${_NOTEBOOK_PATH}/${_example_selector%\/*}" \
    "${_NB}" index get_basename "${_example_selector##*\/}"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

@test "\`show demo:folder/folder/1 --relative-path\` displays relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "demo:Example Folder/Sample Folder/1" --relative-path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                                   ]]
  [[ "${output}"  =~ ^Example\ Folder/Sample\ Folder/example.bookmark.md  ]]
}

# show <path-with-folder> --info-line #########################################

@test "\`show folder/folder/example.md --info-line\` displays info line." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/"

  [[   ${status}      -eq 0                                                       ]]
  [[   "${output}"    =~  1                                                       ]]
  [[   "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/example.bookmark.md  ]]
  [[   "${output}"    =~  Example\ Title                                          ]]
  [[   "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/1                    ]]
  [[ ! "${output}"    =~ home                                                     ]]
  [[   "${output}"    =~  🔖                                                      ]]
}

@test "\`show notebook:folder/folder/example.md --info-line\` displays info line." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]

    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" show "home:Example Folder/Sample Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/"

  [[ ${status}      -eq 0                                                       ]]
  [[ "${output}"    =~  1                                                       ]]
  [[ "${output}"    =~  Example\\\ Folder/Sample\\\ Folder/example.bookmark.md  ]]
  [[ "${output}"    =~  Example\ Title                                          ]]
  [[ "${output}"    =~  home:Example\\\ Folder/Sample\\\ Folder/1               ]]
  [[ "${output}"    =~  🔖                                                      ]]
}

# show <path-with-folder> --selector-id #######################################

@test "\`show folder/folder/example.md --selector-id\` displays selector id." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                         ]]
  [[ "${output}"  =~ Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "\`show demo:folder/folder/example.md --selector-id\` displays selector id." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md"
# Example Title

<https://example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.bookmark.md" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" show "demo:Example Folder/Sample Folder/example.md" --selector-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                         ]]
  [[ "${output}"  =~ Example\ Folder/Sample\ Folder/example.md  ]]
}
