#!/usr/bin/env bats

load test_helper

# `_get_unique_basename()` ####################################################

@test "\`_get_unique_basename()\` prints one-level path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/example.txt"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"              ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/example.txt"  ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" helpers get_unique_basename "Example Folder/example.txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  # [[ "${lines[0]}" =~ example-1.txt ]]
  # TODO: Output path
  [[ "${lines[0]}" =~ Example\ Folder/example.txt ]]
}

@test "\`_get_unique_basename()\` prints two-level path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/.TODO-placeholder"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    # TODO: Must create folder with first document, since git doesn't
    # recognize empty folders.
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.txt"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                            ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"              ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.txt"  ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" helpers get_unique_basename  \
    "Example Folder/Sample Folder/example.txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  # [[ "${lines[0]}" =~ example-1.txt ]]
  # TODO: Output path
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/example.txt ]]
}

@test "\`_get_unique_basename()\` works for notes" {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" add "example.md" --content "Example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" add "example.md" --content "Example"


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-2.md  ]]
}

@test "\`_get_unique_basename()\` works for encrypted notes" {
  {
    run "${_NB}" init
  }

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ example.md.enc  ]]

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ example-2.md.enc  ]]
}

@test "\`_get_unique_basename()\` works for bookmarks" {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" --content "<https://example.com>"
  }

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ example-1.bookmark.md ]]

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ example-2.bookmark.md ]]
}

@test "\`_get_unique_basename()\` works for encrypted bookmarks" {
  {
    run "${_NB}" init
  }

  run  "${_NB}" add "example.bookmark.md"   \
      --content "<https://example.com>"     \
      --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ example.bookmark.md.enc ]]

  run "${_NB}" add "example.bookmark.md"  \
    --content "<https://example.com>"     \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ example-1.bookmark.md.enc ]]

  run "${_NB}" add "example.bookmark.md"  \
    --content "<https://example.com>"     \
    --encrypt --password password

  [[ ${status} -eq 0 ]]

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-2.bookmark.md.enc ]]
}

@test "\`_get_unique_basename()\` works for encrypted conflicted bookmarks" {
  {
    local _filename="example.bookmark.md"

    run "${_NB}" init
  }

  run  "${_NB}" add "${_filename%%.*}--conflicted-copy.${_filename#*.}"   \
      --content "<https://example.com>"                                   \
      --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                            ]]
  [[ "${lines[0]}" =~ example--conflicted-copy.bookmark.md.enc  ]]

  run "${_NB}" add "example--conflicted-copy.bookmark.md"   \
    --content "<https://example.com>"                       \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                              ]]
  [[ "${lines[0]}" =~ example--conflicted-copy-1.bookmark.md.enc  ]]

  run "${_NB}" add "example--conflicted-copy.bookmark.md"   \
    --content "<https://example.com>"                       \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                              ]]
  [[ "${lines[0]}" =~ example--conflicted-copy-2.bookmark.md.enc  ]]
}
