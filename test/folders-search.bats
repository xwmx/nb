#!/usr/bin/env bats

load test_helper

_setup_folders_and_files() {
  local _title_prefix=

  if [[ "${1:-}" == "--local" ]]
  then
    _title_prefix="Local / "
  fi

  # notebook root

  "${_NB}" add  "File One.md"                 \
    --title     "${_title_prefix}Root One"    \
    --content   "example phrase"

  "${_NB}" add  "File Two.md"                 \
    --title     "${_title_prefix}Root Two"    \
    --content   "sample phrase"

  "${_NB}" add  "File Three.md"               \
    --title     "${_title_prefix}Root Three"  \
    --content   "example phrase"

  "${_NB}" add  "File Four.md"                \
    --title     "${_title_prefix}Root Four"   \
    --content   "demo phrase"

  # Example Folder /

  "${_NB}" add  "Example Folder/File One.md"              \
    --title     "${_title_prefix}Example Folder / One"    \
    --content   "demo phrase"

  "${_NB}" add  "Example Folder/File Two.md"              \
    --title     "${_title_prefix}Example Folder / Two"    \
    --content   "example phrase"

  "${_NB}" add  "Example Folder/File Three.md"            \
    --title     "${_title_prefix}Example Folder / Three"  \
    --content   "sample phrase"

  "${_NB}" add  "Example Folder/File Four.md"             \
    --title     "${_title_prefix}Example Folder / Four"   \
    --content   "example phrase"

  # Example Folder / Sample Folder /

  "${_NB}" add  "Example Folder/Sample Folder/File One.md"                \
    --title     "${_title_prefix}Example Folder / Sample Folder / One"    \
    --content   "example phrase"

  "${_NB}" add  "Example Folder/Sample Folder/File Two.md"                \
    --title     "${_title_prefix}Example Folder / Sample Folder / Two"    \
    --content   "demo phrase"

  "${_NB}" add  "Example Folder/Sample Folder/File Three.md"              \
    --title     "${_title_prefix}Example Folder / Sample Folder / Three"  \
    --content   "example phrase"

  "${_NB}" add  "Example Folder/Sample Folder/File Four.md"               \
    --title     "${_title_prefix}Example Folder / Sample Folder / Four"   \
    --content   "sample phrase"
}

# <path> selectors ############################################################

@test "'search /path/to/<filename>' (no slash, query) searches for <query> in <filename>." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "${NB_DIR}/home/File One.md" "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                       ]]

  [[ "${lines[0]}"  =~  .*[.*1.*].*\ Root\ One  ]]
  [[ "${lines[1]}"  =~  ---                     ]]
  [[ "${lines[2]}"  =~  3.*:.*example.*\ phrase ]]
}

@test "'search /path/to/<notebook>' (no slash, query) searches for <query> in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "${NB_DIR}/home" "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0                       ]]
  [[ "${#lines[@]}" -eq 37                      ]]

  [[ "${output}"    =~  .*[.*1.*].*\ Root\ One  ]]
  [[ "${output}"    =~  ---                     ]]
  [[ "${output}"    =~  3.*:.*example.*\ phrase ]]

  [[ "${output}"    =~  \
.*[.*Example\ Folder/Sample\ Folder/4.*].*\ Example\ Folder\ /\ Sample\ Folder\ /\ Four ]]
  [[ "${output}"    =~  ---                     ]]
  [[ "${output}"    =~  1.*:.*#\ .*Example.*\ Folder\ /\ Sample\ Folder\ /\ Four        ]]
}

@test "'search /path/to/<notebook>/' (slash, query) searches for <query> in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "${NB_DIR}/home/" "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0                       ]]
  [[ "${#lines[@]}" -eq 37                      ]]

  [[ "${output}"    =~  .*[.*1.*].*\ Root\ One  ]]
  [[ "${output}"    =~  ---                     ]]
  [[ "${output}"    =~  3.*:.*example.*\ phrase ]]

  [[ "${output}"    =~  \
.*[.*Example\ Folder/Sample\ Folder/4.*].*\ Example\ Folder\ /\ Sample\ Folder\ /\ Four ]]
  [[ "${output}"    =~  ---                     ]]
  [[ "${output}"    =~  1.*:.*#\ .*Example.*\ Folder\ /\ Sample\ Folder\ /\ Four        ]]
}

@test "'search /path/to/<folder>' (no slash, query) searches for <query> in <folder> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "${NB_DIR}/home/Example Folder" "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"    -eq 0                       ]]
  [[    "${#lines[@]}" -eq 28                      ]]

  [[ !  "${output}"    =~  .*[.*1.*].*\ Root\ One  ]]

  [[    "${output}"    =~  \
.*[.*Example\ Folder/Sample\ Folder/4.*].*\ Example\ Folder\ /\ Sample\ Folder\ /\ Four ]]
  [[    "${output}"    =~  ---                     ]]
  [[    "${output}"    =~  1.*:.*#\ .*Example.*\ Folder\ /\ Sample\ Folder\ /\ Four     ]]
}

@test "'search /path/to/<folder>/' (slash, query) searches for <query> in <folder> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "${NB_DIR}/home/Example Folder/" "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"    -eq 0                        ]]
  [[    "${#lines[@]}" -eq 28                       ]]

  [[ !  "${output}"    =~  .*[.*1.*].*\ Root\ One   ]]

  [[    "${output}"    =~  \
.*[.*Example\ Folder/Sample\ Folder/4.*].*\ Example\ Folder\ /\ Sample\ Folder\ /\ Four ]]
  [[    "${output}"    =~  ---                      ]]
  [[    "${output}"    =~  1.*:.*#\ .*Example.*\ Folder\ /\ Sample\ Folder\ /\ Four     ]]
}

# <filename> and <folder> selectors ###########################################

@test "'search <filename>' (no slash, no query) searches for <filename> in current notebook recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]

  [[ "${output}"    =~  1.*File\ One.md.*\ ·\ Root\ One   ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[2]}"  =~  Filename\ Match:\ .*File\ One.md  ]]

  [[ "${output}"    =~  \
Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ One ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[5]}"  =~  Filename\ Match:\ .*File\ One.md  ]]

  [[ "${output}"    =~  \
Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ Sample\ Folder\ /\ One ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[8]}"  =~  Filename\ Match:\ .*File\ One.md  ]]
}

@test "'search <filename>/' (slash, no query) searches for <filename> in current notebook recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search File\ One.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]

  [[ "${output}"    =~  1.*File\ One.md.*\ ·\ Root\ One   ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[2]}"  =~  Filename\ Match:\ .*File\ One.md  ]]

  [[ "${output}"    =~  \
Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ One ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[5]}"  =~  Filename\ Match:\ .*File\ One.md  ]]

  [[ "${output}"    =~  \
Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ Sample\ Folder\ /\ One ]]
  [[ "${output}"    =~  ----------------                  ]]
  [[ "${lines[8]}"  =~  Filename\ Match:\ .*File\ One.md  ]]
}

@test "'search <folder>' (no slash, no query) searches for <folder> in current notebook recursively with matching content." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                          ]]

  [[ !  "${output}"    =~  [^/]1[^/]*One                              ]]

  [[    "${output}"    =~  Example\ Folder/5.*\ 📂\ .*Sample\ Folder  ]]
  [[    "${output}"    =~  ------------------------------------       ]]
  [[    "${output}"    =~  Folder\ Name\ Match:\ .*Sample\ Folder     ]]

  [[    "${output}"    =~ \
          Example\ Folder/Sample\ Folder/1.*Example\ Folder\ /\ Sample\ Folder\ /\ One   ]]
  [[    "${output}"    =~ \
          Example\ Folder/Sample\ Folder/2.*Example\ Folder\ /\ Sample\ Folder\ /\ Two   ]]
  [[    "${output}"    =~ \
          Example\ Folder/Sample\ Folder/3.*Example\ Folder\ /\ Sample\ Folder\ /\ Three ]]
  [[    "${output}"    =~ \
          Example\ Folder/Sample\ Folder/4.*Example\ Folder\ /\ Sample\ Folder\ /\ Four  ]]
}

@test "'search <folder>' (no slash, no query) searches for <folder> in current notebook recursively with only matching folder names." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" rename                   \
      "Example Folder/Sample Folder"  \
      "Example Folder/Demo Folder"    \
      --force

    [[ -d "${NB_DIR}/home/Example Folder/Demo Folder" ]]
  }

  run "${_NB}" search "Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                          ]]

  [[    "${#lines[@]}" -eq 3                                          ]]

  [[    "${output}"    =~  Example\ Folder/5.*\ 📂\ .*Demo\ Folder    ]]
  [[    "${output}"    =~  [^-]---------------------------------[^-]  ]]
  [[    "${output}"    =~  Folder\ Name\ Match:\ .*Demo\ Folder       ]]
}

@test "'search <folder>/' (slash, no query) with matching folder name returns 1 and prints help." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq  1           ]]

  [[    "${lines[0]}"  =~   Usage:      ]]
  [[    "${lines[1]}"  =~   nb\ search  ]]
}

@test "'search <folder>/' (slash, no query) with no match searches for nested <folder> in current notebook recursively with only matching folder names." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" rename                   \
      "Example Folder/Sample Folder"  \
      "Example Folder/Demo Folder"    \
      --force

    [[ -d "${NB_DIR}/home/Example Folder/Demo Folder" ]]
  }

  run "${_NB}" search Demo\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                          ]]

  [[    "${#lines[@]}" -eq 3                                          ]]

  [[    "${output}"    =~  Example\ Folder/5.*\ 📂\ .*Demo\ Folder    ]]
  [[    "${output}"    =~  [^-]---------------------------------[^-]  ]]
  [[    "${output}"    =~  Folder\ Name\ Match:\ .*Demo\ Folder       ]]
}

@test "'search <folder-id>/' (slash, no query) with matching folder returns 1 and prints help." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search 5/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1            ]]

  [[    "${lines[0]}"    =~  Usage:     ]]
  [[    "${lines[1]}"    =~  nb\ search ]]
}

@test "'search <folder-id>/' (slash, no query) with no matching folder searches for <folder-id> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" edit "Example Folder/File Three.md"              \
      --content   "12345"
    "${_NB}" edit "Example Folder/Sample Folder/File Two.md"  \
      --content   "12345"
  }

  run "${_NB}" search 12345/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                                            ]]

  [[    "${#lines[@]}" -eq 6                                                            ]]

  [[    "${output}"    =~  Example\ Folder/3.*Example\ Folder\ /\ Three                 ]]
  [[    "${lines[1]}"  =~  ---------------                                              ]]
  [[    "${lines[2]}"  =~  12345                                                        ]]
  [[    "${output}"    =~  \
          Example\ Folder/Sample\ Folder/2.*Example\ Folder\ /\ Sample\ Folder\ /\ Two  ]]
  [[    "${lines[4]}"  =~  ---------------                                              ]]
  [[    "${lines[5]}"  =~  12345                                                        ]]
}

# <notebook> selectors ########################################################

@test "'search <notebook>:' (no query, colon) with matching notebook returns 1 and prints help." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "Example Notebook"

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" search Example\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1          ]]

  [[    "${lines[0]}" =~  Usage:     ]]
  [[    "${lines[1]}" =~  nb\ search ]]
}

@test "'search <notebook>:' (no query, colon) without matching notebook searches for the string in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "Example Notebook"

    [[ "$("${_NB}" notebooks current)" == "home" ]]

    "${_NB}" edit "Example Folder/File Two.md"                \
      --content   "Not a Notebook"
    "${_NB}" edit "Example Folder/File Three.md"              \
      --content   "Not a Notebook:"
    "${_NB}" edit "Example Folder/Sample Folder/File Two.md"  \
      --content   "Not a Notebook:"
  }

  run "${_NB}" search Not\ a\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                                            ]]

  [[    "${#lines[@]}" -eq 6                                                            ]]

  [[ !  "${output}"    =~  Example\ Folder/2.*Example\ Folder\ /\ Two                   ]]

  [[    "${output}"    =~  Example\ Folder/3.*Example\ Folder\ /\ Three                 ]]
  [[    "${lines[1]}"  =~  ---------------                                              ]]
  [[    "${lines[2]}"  =~  Not\ a\ Notebook                                             ]]
  [[    "${output}"    =~  \
          Example\ Folder/Sample\ Folder/2.*Example\ Folder\ /\ Sample\ Folder\ /\ Two  ]]
  [[    "${lines[4]}"  =~  ---------------                                              ]]
  [[    "${lines[5]}"  =~  Not\ a\ Notebook                                             ]]
}

@test "'search <notebook>' (no query, no colon) with matching notebook searches for the string in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "Example Notebook"

    [[ "$("${_NB}" notebooks current)" == "home" ]]

    "${_NB}" edit "Example Folder/File Two.md"                \
      --content   "Example Notebook"
    "${_NB}" edit "Example Folder/File Three.md"              \
      --content   "Example Notebook:"
    "${_NB}" edit "Example Folder/Sample Folder/File Two.md"  \
      --content   "Example Notebook:"
  }

  run "${_NB}" search Example\ Notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                                            ]]

  [[    "${#lines[@]}" -eq 9                                                            ]]

  [[    "${output}"    =~  Example\ Folder/3.*Example\ Folder\ /\ Three                 ]]
  [[    "${lines[1]}"  =~  ---------------                                              ]]
  [[    "${lines[2]}"  =~  Example\ Notebook                                            ]]

  [[    "${output}"    =~  Example\ Folder/2.*Example\ Folder\ /\ Two                   ]]
  [[    "${lines[4]}"  =~  ---------------                                              ]]
  [[    "${lines[5]}"  =~  Example\ Notebook                                            ]]

  [[    "${output}"    =~  \
          Example\ Folder/Sample\ Folder/2.*Example\ Folder\ /\ Sample\ Folder\ /\ Two  ]]
  [[    "${lines[7]}"  =~  ---------------                                              ]]
  [[    "${lines[8]}"  =~  Example\ Notebook                                            ]]
}

@test "'search <notebook>:<filename>' (no slash, no space) searches for <filename> in <notebook> root." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home:File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]

  [[    "${output}"   =~  home:1.*File\ One.md.*\ ·\ Root\ One  ]]
  [[    "${output}"   =~  ---------------------                 ]]
  [[    "${lines[2]}" =~  Filename\ Match:\ .*File\ One.md      ]]
  [[ -z "${lines[3]}"                                           ]]

  [[ !  "${output}"   =~  Example\ Folder                     ]]
  [[ !  "${output}"   =~  Sample\ Folder                      ]]
}

@test "'search <notebook>: <filename>' (no slash, space) searches for <filename> in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home: "File One.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]

  [[ "${output}"    =~  home:1.*File\ One.md.*\ ·\ Root\ One  ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[2]}"  =~  Filename\ Match:\ .*File\ One.md      ]]

  [[ "${output}"    =~  \
      home:Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ One ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[5]}"  =~  Filename\ Match:\ .*File\ One.md      ]]

  [[ "${output}"    =~  \
      home:Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ Sample\ Folder\ /\ One ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[8]}"  =~  Filename\ Match:\ .*File\ One.md      ]]
}

@test "'search <notebook>:<filename>/' (slash, no space) searches for <filename> in <notebook> root." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home:File\ One.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]

  [[    "${output}"   =~  home:1.*File\ One.md.*\ ·\ Root\ One  ]]
  [[    "${output}"   =~  ---------------------                 ]]
  [[    "${lines[2]}" =~  Filename\ Match:\ .*File\ One.md      ]]
  [[ -z "${lines[3]}"                                           ]]

  [[ !  "${output}"   =~  Example\ Folder                       ]]
  [[ !  "${output}"   =~  Sample\ Folder                        ]]
}

@test "'search <notebook>: <filename>/' (slash, space) searches for <filename> in <notebook> recursively." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home: File\ One.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]

  [[ "${output}"    =~  home:1.*File\ One.md.*\ ·\ Root\ One  ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[2]}"  =~  Filename\ Match:\ .*File\ One.md      ]]

  [[ "${output}"    =~  \
      home:Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ One ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[5]}"  =~  Filename\ Match:\ .*File\ One.md      ]]

  [[ "${output}"    =~  \
      home:Example\ Folder/1.*File\ One.md.*\ ·\ Example\ Folder\ /\ Sample\ Folder\ /\ One ]]
  [[ "${output}"    =~  ---------------------                 ]]
  [[ "${lines[8]}"  =~  Filename\ Match:\ .*File\ One.md      ]]
}

# <query> selectors ###########################################################

@test "'search <query> <filename>' searches <filename> in current notebook for <query>." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "example" File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                 ]]
  [[ "${#lines[@]}" -eq 3                 ]]

  [[ "${output}"    =~  [^:]1.*One        ]]
  [[ "${output}"    =~  -------           ]]
  [[ "${lines[2]}"  =~  example.*\ phrase ]]
}

@test "'search <query> <notebook>:<filename>' (no slash) searches <filename> in <notebook> for <query>." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "example" home:File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                         ]]

  [[ "${output}"    =~  home:1.*Root\ One         ]]
  [[ "${output}"    =~  [^-]-----------------[^-] ]]
  [[ "${lines[2]}"  =~  example.*\ phrase         ]]
}

@test "'search <query> <notebook>:' searches within <notebook> subfolders." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "example phrase" home:

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[6]}:  '%s'\\n" "${#lines[6]}"
  printf "\${#lines[7]}:  '%s'\\n" "${#lines[7]}"

  [[ "${status}"      -eq 0                         ]]

  [[ "${output}"      =~  home:1.*One               ]]

  [[ "${lines[1]}"    =~  ------------              ]]
  [[ "${#lines[1]}"   == "$((${#lines[0]} - 21))"   ]]
  [[ "${lines[2]}"    =~  3                         ]]
  [[ "${lines[2]}"    =~  example\ phrase           ]]

  [[ "${output}"      =~  home:3.*Three             ]]

  [[ "${lines[4]}"    =~  ------------              ]]
  [[ "${#lines[4]}"   == "$((${#lines[3]} - 21))"   ]]
  [[ "${lines[5]}"    =~  3                         ]]
  [[ "${lines[5]}"    =~  example\ phrase           ]]

  [[ "${output}"      =~  home:Example\ Folder/Sample\ Folder/3         ]]
  [[ "${output}"      =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[7]}"    =~  ------------              ]]
  [[ "${#lines[7]}"   == "$((${#lines[6]} - 21))"   ]]
  [[ "${lines[8]}"    =~  3                         ]]
  [[ "${lines[8]}"    =~  example\ phrase           ]]

  [[ "${output}"      =~  home:Example\ Folder/Sample\ Folder/1         ]]
  [[ "${output}"      =~  Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[10]}"   =~  ------------              ]]
  [[ "${#lines[10]}"  == "$((${#lines[9]} - 21))"   ]]
  [[ "${lines[11]}"   =~  3                         ]]
  [[ "${lines[11]}"   =~  example\ phrase           ]]

  [[ "${output}"      =~ home:Example\ Folder/2.*Example\ Folder\ /\ Two    ]]

  [[ "${lines[13]}"   =~  ------------              ]]
  [[ "${#lines[13]}"  == "$((${#lines[12]} - 21))"  ]]
  [[ "${lines[14]}"   =~  3                         ]]
  [[ "${lines[14]}"   =~  example\ phrase           ]]

  [[ "${output}"      =~  home:Example\ Folder/4.*Example\ Folder\ /\ Four  ]]

  [[ "${lines[16]}"   =~  ------------              ]]
  [[ "${#lines[16]}"  == "$((${#lines[15]} - 21))"  ]]
  [[ "${lines[17]}"   =~  3                         ]]
  [[ "${lines[17]}"   =~  example\ phrase           ]]
}

@test "'search <query> <notebook>:<folder>/' (slash) searches within <folder> and subfolders in <notebook>." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "example phrase" home:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                 ]]

  [[ "${output}"    =~  home:Example\ Folder/Sample\ Folder/3             ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three      ]]

  [[ "${lines[1]}"  =~  -----------------------------                     ]]
  [[ "${lines[2]}"  =~  3                                                 ]]
  [[ "${lines[2]}"  =~  example\ phrase                                   ]]

  [[ "${output}"    =~  home:Example\ Folder/Sample\ Folder/1             ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ One        ]]

  [[ "${lines[4]}"  =~  -----------------------------                     ]]
  [[ "${lines[5]}"  =~  3                                                 ]]
  [[ "${lines[5]}"  =~  example\ phrase                                   ]]

  [[ "${output}"    =~  home:Example\ Folder/2.*Example\ Folder\ /\ Two   ]]

  [[ "${lines[7]}"  =~  -----------------------------                     ]]
  [[ "${lines[8]}"  =~  3                                                 ]]
  [[ "${lines[8]}"  =~  example\ phrase                                   ]]

  [[ "${output}"    =~  home:Example\ Folder/4.*Example\ Folder\ /\ Four  ]]

  [[ "${lines[10]}" =~  -----------------------------                     ]]
  [[ "${lines[11]}" =~  3                                                 ]]
  [[ "${lines[11]}" =~  example\ phrase                                   ]]
}

@test "'search <query> <notebook>:<folder>' (no slash) searches within <folder> and subfolders in <notebook>." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "example phrase" home:Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                   ]]

  [[ "${output}"    =~  home:Example\ Folder/Sample\ Folder/3           ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three        ]]

  [[ "${lines[1]}"  =~  -----------------------------                       ]]
  [[ "${lines[2]}"  =~  3                                                   ]]
  [[ "${lines[2]}"  =~  example\ phrase                                     ]]

  [[ "${output}"    =~  home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ One          ]]

  [[ "${lines[4]}"  =~  -----------------------------                       ]]
  [[ "${lines[5]}"  =~  3                                                   ]]
  [[ "${lines[5]}"  =~  example\ phrase                                     ]]

  [[ "${output}"    =~  home:Example\ Folder/2.*Example\ Folder\ /\ Two   ]]

  [[ "${lines[7]}"  =~  -----------------------------                       ]]
  [[ "${lines[8]}"  =~  3                                                   ]]
  [[ "${lines[8]}"  =~  example\ phrase                                     ]]

  [[ "${output}"    =~  home:Example\ Folder/4.*Example\ Folder\ /\ Four  ]]

  [[ "${lines[10]}" =~  -----------------------------                       ]]
  [[ "${lines[11]}" =~  3                                                   ]]
  [[ "${lines[11]}" =~  example\ phrase                                     ]]
}

# `search` spacing and alignment ##############################################

@test "'search <query> --list / -l' includes extra spacing to align with max id length in folder." {
  {
    "${_NB}" init

    _setup_folders_and_files

    for ((_i=0; _i < 12; _i++))
    do
      "${_NB}" add "note ${_i}"
    done

    "${_NB}" add                            \
      --filename  "example.bookmark.md"     \
      --folder    "Example Folder"          \
      --content   "<http://example.test/>"  \
      --title     "Example Title One"
  }

  run "${_NB}" search 'example.test' --no-color --list

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                     ]]
  [[    "${#lines[@]}"  -eq 1                     ]]

  [[ !  "${lines[0]}"   =~  example-1.bookmark.md ]]
  [[    "${lines[0]}"   =~  Example\ Folder/6     ]]
  [[    "${lines[0]}"   =~  Example\ Title\ One   ]]
  [[    "${lines[0]}"   =~  \]\ 🔖                ]]

  for ((_i=0; _i < 12; _i++))
  do
    "${_NB}" add "Example Folder/note ${_i}"
  done

  run "${_NB}" search 'example.test' --no-color --list

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                     ]]
  [[    "${#lines[@]}"  -eq 1                     ]]

  [[ !  "${lines[0]}"   =~  example-1.bookmark.md ]]
  [[    "${lines[0]}"   =~  Example\ Folder/6   ]]
  [[    "${lines[0]}"   =~  Example\ Title\ One   ]]
  [[    "${lines[0]}"   =~  \]\ \ 🔖              ]]
}

# `search` ####################################################################

@test "'search <query>' skips unindexed subfolders." {
  {
    "${_NB}" init

    _setup_folders_and_files

    mkdir -p "${NB_DIR}/home/Example Unindexed/Sample Unindexed"
    cat <<HEREDOC > "${NB_DIR}/home/Example Unindexed/Sample Unindexed/document.md"
# Example Unindexed / Sample Unindexed / Document

example phrase
HEREDOC
  }

  run "${_NB}" search "example phrase"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                             ]]

  [[ !  "${output}" =~  Unindexed                                     ]]

  [[    "${output}" =~  Example\ Folder/Sample\ Folder/3              ]]
  [[    "${output}" =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]
}

# `search <folder>/` ##########################################################

@test "'search <query> <folder>/' (slash) searches for <query> within <folder> and subfolders." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "example phrase" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                             ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                 ]]
  [[ "${lines[2]}"  =~  3                                             ]]
  [[ "${lines[2]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                 ]]
  [[ "${lines[5]}"  =~  3                                             ]]
  [[ "${lines[5]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/2.*Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                 ]]
  [[ "${lines[8]}"  =~  3                                             ]]
  [[ "${lines[8]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/4.*Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                 ]]
  [[ "${lines[11]}" =~  3                                             ]]
  [[ "${lines[11]}" =~  example\ phrase                               ]]
}

@test "'search <query> <folder>' (no slash) searches for <query> within <folder> and subfolders." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "example phrase" Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                             ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                 ]]
  [[ "${lines[2]}"  =~  3                                             ]]
  [[ "${lines[2]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                 ]]
  [[ "${lines[5]}"  =~  3                                             ]]
  [[ "${lines[5]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/2.*Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                 ]]
  [[ "${lines[8]}"  =~  3                                             ]]
  [[ "${lines[8]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/4.*Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                 ]]
  [[ "${lines[11]}" =~  3                                             ]]
  [[ "${lines[11]}" =~  example\ phrase                               ]]
}

# `search --no-recurse` #######################################################

@test "'search <query> <folder>/ --no-recurse' (slash) searches within <folder> only." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "example phrase" Example\ Folder/ --no-recurse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                              ]]

  [[    "${lines[0]}"  =~  Example\ Folder/4              ]]
  [[    "${lines[0]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[0]}"  =~  Two|Four                       ]]
  [[    "${lines[1]}"  =~  -----------------------------  ]]
  [[    "${lines[2]}"  =~  3                              ]]
  [[    "${lines[2]}"  =~  example\ phrase                ]]

  [[    "${lines[3]}"  =~  Example\ Folder/2              ]]
  [[    "${lines[3]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[3]}"  =~  Two|Four                       ]]
  [[    "${lines[4]}"  =~  -----------------------------  ]]
  [[    "${lines[5]}"  =~  3                              ]]
  [[    "${lines[5]}"  =~  example\ phrase                ]]

  [[ -z "${lines[6]}"                                     ]]
}

@test "'search <query> <folder> --no-recurse' (no slash) searches within <folder> only." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "example phrase" Example\ Folder --no-recurse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                              ]]

  [[    "${lines[0]}"  =~  Example\ Folder/4              ]]
  [[    "${lines[0]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[0]}"  =~  Two|Four                       ]]
  [[    "${lines[1]}"  =~  -----------------------------  ]]
  [[    "${lines[2]}"  =~  3                              ]]
  [[    "${lines[2]}"  =~  example\ phrase                ]]

  [[    "${lines[3]}"  =~  Example\ Folder/2              ]]
  [[    "${lines[3]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[3]}"  =~  Two|Four                       ]]
  [[    "${lines[4]}"  =~  -----------------------------  ]]
  [[    "${lines[5]}"  =~  3                              ]]
  [[    "${lines[5]}"  =~  example\ phrase                ]]

  [[ -z "${lines[6]}"                                     ]]
}

# `search` local notebook #####################################################

@test "'search <query> <folder>/' (slash) in local notebook exits with status 0 and prints output." {
  {
    "${_NB}" init

    _setup_folders_and_files

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    _setup_folders_and_files --local
  }

  run "${_NB}" search "example phrase" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                       ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                           ]]
  [[ "${lines[2]}"  =~  3                                                       ]]
  [[ "${lines[2]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                           ]]
  [[ "${lines[5]}"  =~  3                                                       ]]
  [[ "${lines[5]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/2.*Local\ /\ Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                           ]]
  [[ "${lines[8]}"  =~  3                                                       ]]
  [[ "${lines[8]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/4.*Local\ /\ Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                           ]]
  [[ "${lines[11]}" =~  3                                                       ]]
  [[ "${lines[11]}" =~  example\ phrase                                         ]]
}

@test "'search <query> <folder>' (no slash) in local notebook exits with status 0 and prints output." {
  {
    "${_NB}" init

    _setup_folders_and_files

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    _setup_folders_and_files --local
  }

  run "${_NB}" search "example phrase" Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                       ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                           ]]
  [[ "${lines[2]}"  =~  3                                                       ]]
  [[ "${lines[2]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                           ]]
  [[ "${lines[5]}"  =~  3                                                       ]]
  [[ "${lines[5]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/2.*Local\ /\ Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                           ]]
  [[ "${lines[8]}"  =~  3                                                       ]]
  [[ "${lines[8]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/4.*Local\ /\ Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                           ]]
  [[ "${lines[11]}" =~  3                                                       ]]
  [[ "${lines[11]}" =~  example\ phrase                                         ]]
}

# no match ####################################################################

@test "'search <no-match-query> <filename>/' (slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "no-match-query" File\ One.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${#lines[@]}" -eq 1                                     ]]
  [[ "${output}"    =~  Not\ found\ in                        ]]
  [[ "${output}"    =~  File\ One.md[^/].*:\ .*no-match-query ]]
}

@test "'search <no-match-query> <filename>' (no slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "no-match-query" File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${#lines[@]}" -eq 1                                     ]]
  [[ "${output}"    =~  Not\ found\ in                        ]]
  [[ "${output}"    =~  File\ One.md[^/].*:\ .*no-match-query ]]
}

@test "'search <no-match-query> <folder>/' (slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "no-match-query" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${#lines[@]}" -eq 1                                     ]]
  [[ "${output}"    =~  Not\ found\ in                        ]]
  [[ "${output}"    =~  Example\ Folder/.*:\ .*no-match-query ]]
}

@test "'search <no-match-query> <folder>' (no slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files
  }

  run "${_NB}" search "no-match-query" Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${#lines[@]}" -eq 1                                     ]]
  [[ "${output}"    =~  Not\ found\ in                        ]]
  [[ "${output}"    =~  Example\ Folder/.*:\ .*no-match-query ]]
}

@test "'search <no-match-query> <notebook>:<folder>/' (slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                           ]]
  [[ "${#lines[@]}" -eq 1                                           ]]
  [[ "${output}"    =~  Not\ found\ in                              ]]
  [[ "${output}"    =~  home:Example\ Folder/.*:\ .*no-match-query  ]]
}

@test "'search <no-match-query> <notebook>:<folder>' (no slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                           ]]
  [[ "${#lines[@]}" -eq 1                                           ]]
  [[ "${output}"    =~  Not\ found\ in                              ]]
  [[ "${output}"    =~  home:Example\ Folder/.*:\ .*no-match-query  ]]
}

@test "'search <no-match-query> <notebook>:<folder-id>/' (slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:5/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                             ]]
  [[ "${#lines[@]}" -eq 1                             ]]
  [[ "${output}"    =~  Not\ found\ in                ]]
  [[ "${output}"    =~  home:5/.*:\ .*no-match-query  ]]
}

@test "'search <no-match-query> <notebook>:<folder-id>' (no slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:5

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                             ]]
  [[ "${#lines[@]}" -eq 1                             ]]
  [[ "${output}"    =~  Not\ found\ in                ]]
  [[ "${output}"    =~  home:5/.*:\ .*no-match-query  ]]
}

@test "'search <notebook>: <no-match>' (no slash, space / query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home: no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${#lines[@]}" -eq 1                                     ]]
  [[ "${output}"    =~  Not\ found\ in\ .*home.*:\ .*no-match ]]
}

@test "'search <query> <notebook>:<no-match>' (no slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:no-match.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                         ]]
  [[ "${#lines[@]}" -eq 1                         ]]
  [[ "${output}"    =~  home.*:\ .*no-match-query ]]
}

@test "'search <notebook>:<no-match>' (no slash, no space, no query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home:no-match.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]
  [[ "${#lines[@]}" -eq 1                       ]]
  [[ "${output}"    =~  home.*:\ .*no-match.md  ]]
}

@test "'search <notebook>:<no-match>/' (slash, no space, no query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search home:no-match.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                           ]]
  [[ "${#lines[@]}" -eq 1                           ]]
  [[ "${output}"    =~  home.*:\ .*no-match.md[^/]  ]]
}

@test "'search <no-match-query> <notebook>:<no-match>/' (slash, no space, query) exits with 1 and prints message." {
  {
    "${_NB}" init

    _setup_folders_and_files

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" search "no-match-query" home:no-match.md/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                         ]]
  [[ "${#lines[@]}" -eq 1                         ]]
  [[ "${output}"    =~  home.*:\ .*no-match-query ]]
}
