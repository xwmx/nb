#!/usr/bin/env bats

load test_helper

# `_get_unique_relative_path()` ###############################################

@test "'_get_unique_relative_path()' with no arguments prints generated filename without extension." {
  {
    run "${_NB}" init
  }

  run "${_NB}" helpers get_unique_relative_path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0            ]]
  [[ "${lines[0]}" =~ ^[0-9]+$  ]]
}

@test "'_get_unique_relative_path()' prints generated filename without extension with one-level relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ Example\ Folder/[0-9]+$ ]]
}

@test "'_get_unique_relative_path()' prints generated filename without extension with two-level relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder/Sample Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                          ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/[0-9]+$  ]]
}

# file extension ##############################################################

@test "'_get_unique_relative_path()' prints generated filename for extension." {
  {
    run "${_NB}" init
  }

  run "${_NB}" helpers get_unique_relative_path ".rst"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0             ]]
  [[ "${lines[0]}" =~ [0-9]+.rst ]]
}

@test "'_get_unique_relative_path()' prints generated filename for extension with nested notebook path." {
  {
    run "${_NB}" init

    mkdir -p "${_NOTEBOOK_PATH}/${_NOTEBOOK_PATH}"
    touch "${_NOTEBOOK_PATH}/${_NOTEBOOK_PATH}/.index"
  }

  run "${_NB}" helpers get_unique_relative_path "${_NOTEBOOK_PATH}/.rst"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ ${_NOTEBOOK_PATH}/[0-9]+.rst  ]]
}

@test "'_get_unique_relative_path()' prints generated filename for extension with one-level relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder/.rst"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                              ]]
  [[ "${lines[0]}" =~ Example\ Folder/[0-9]+.rst  ]]
}

@test "'_get_unique_relative_path()' prints generated filename for extension with two-level relative path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder/Sample Folder/.rst"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                            ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/[0-9]+.rst ]]
}

# file path ###################################################################

@test "'_get_unique_relative_path()' prints one-level file path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
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

  run "${_NB}" helpers get_unique_relative_path "Example Folder/example.txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ Example\ Folder/example-1.txt ]]
}

@test "'_get_unique_relative_path()' prints one-level folder path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder" ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ Example\ Folder-1 ]]
}

@test "'_get_unique_relative_path()' prints two-level file path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
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

  run "${_NB}" helpers get_unique_relative_path  \
    "Example Folder/Sample Folder/example.txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                                ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/example-1.txt  ]]
}

@test "'_get_unique_relative_path()' prints two-level folder path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/example.txt"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                            ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"              ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"       ]]
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

  run "${_NB}" helpers get_unique_relative_path "Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                    ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder-1  ]]
}

@test "'_get_unique_relative_path()' prints three-level file path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/example.txt"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                                        ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"                          ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder"              ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/example.txt"  ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" helpers get_unique_relative_path  \
    "Example Folder/Sample Folder/Demo Folder/example.txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                                            ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/example-1.txt ]]
}

@test "'_get_unique_relative_path()' prints three-level folder path." {
  {
    run "${_NB}" init

    mkdir "${_NOTEBOOK_PATH}/Example Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"

    mkdir "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/.index"
    touch "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/example.txt"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                                        ]]

    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"                          ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"                   ]]

    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder"              ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/.index"       ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Demo Folder/example.txt"  ]]

    run "${_NB}" list

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    "${_NB}" git log

    [[ "${status}" -eq 0              ]]
    [[ "${output}" =~ 1               ]]
    [[ "${output}" =~ 📂              ]]
    [[ "${output}" =~ Example\ Folder ]]
  }

  run "${_NB}" helpers get_unique_relative_path "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                                ]]
  [[ "${lines[0]}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder-1 ]]
}

# types #######################################################################

@test "'_get_unique_relative_path()' works for notes." {
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

@test "'_get_unique_relative_path()' works for encrypted notes." {
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

@test "'_get_unique_relative_path()' works for bookmarks." {
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

@test "'_get_unique_relative_path()' works for encrypted bookmarks." {
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

@test "'_get_unique_relative_path()' works for encrypted conflicted bookmarks." {
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
