#!/usr/bin/env bats

load test_helper

# local #######################################################################

@test "'helpers get_id_selector <notebook-full-path> --notebook' in local notebook exits with 0 and prints local notebook selector." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example File.md" \
      --title     "Title One"       \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local"                 ]]
    [[ -f "${_TMP_DIR}/Example Local/Example File.md" ]]
  }

  run "${_NB}" helpers              \
    get_id_selector                 \
    "${_TMP_DIR}/Example Local"     \
    --notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "local:"  ]]
}

@test "'helpers get_id_selector <id>/<id>/<id>/<id> --notebook' in local notebook exits with 0 and prints id selector with notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "1/1/1/1"           \
    --notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

@test "'helpers get_id_selector <id>/<id>/<id>/<id>' in local notebook exits with 0 and prints id selector without notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "1/1/1/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "1/1/1/1" ]]
}

@test "'helpers get_id_selector local:<id>/<id>/<id>/<id>' exits with 0 and prints id selector with notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "local:1/1/1/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

@test "'helpers get_id_selector /<notebook-path>/<folder>/<folder>/<folder>/<filename>' exits with 0 and prints id selector without notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers                                                \
    get_id_selector                                                   \
    "${_TMP_DIR}/Example Local/Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

@test "'helpers get_id_selector /<notebook-path>/<folder>/<folder>/<folder>/<filename> --notebook' exits with 0 and prints id selector with notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers                                                                    \
    get_id_selector                                                                       \
    "${_TMP_DIR}/Example Local/Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

@test "'helpers get_id_selector <folder>/<folder>/<folder>/<filename> --notebook' exits with 0 and prints id selector with notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers                                                \
    get_id_selector                                                   \
    "local:Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --notebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

@test "'helpers get_id_selector <folder>/<folder>/<folder>/<filename>' exits with 0 and prints id selector without notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "1/1/1/1" ]]
}

@test "'helpers get_id_selector local:<folder>/<folder>/<folder>/<filename>' exits with 0 and prints id selector with notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "Title One"                                                 \
      --content   "Content one."

    [[ -d "${_TMP_DIR}/Example Local/Example Folder"        ]]
    [[ -f "${_TMP_DIR}/Example Local/Example Folder/.index" ]]
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "local:Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "local:1/1/1/1" ]]
}

# selectors ###################################################################

@test "'helpers get_id_selector <notebook>:<id>/<id>/<id>/<id>' exits with 0 and prints id selector." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "home:1/1/1/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0               ]]
  [[   "${#lines[@]}" ==  1               ]]

  [[   "${lines[0]}"  ==  "home:1/1/1/1"  ]]
}

# conflicting id / name #######################################################

@test "'helpers get_id_selector' favors id with conflicting id and folder name." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Example Folder"  "2" --force
    "${_NB}" move "Sample Folder"   "1" --force

    [[ -d "${NB_DIR}/home/2"              ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]
  }

  run "${_NB}" helpers get_id_selector 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "2/"              ]]

  run "${_NB}" helpers get_id_selector 1/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "2/1"             ]]

  run "${_NB}" helpers get_id_selector 2/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]
  [[ "${output}"  ==  "1/"              ]]
}

# full path ###################################################################

@test "'helpers get_id_selector </full/path/to/file>' exits with 0 and prints id selector." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "home:1/1/1/1" ]]
}

# not-valid ###################################################################

@test "'helpers get_id_selector <not-valid/path>' exits with 1 and prints nothing." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "Example Folder/Not Valid/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1       ]]
  [[    "${#lines[@]}"  ==  0       ]]

  [[ -z "${output}"                 ]]
}

# get_id_selector #############################################################

@test "'helpers get_id_selector' resolves name to folder id selectors." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/File Example.md"
    "${_NB}" add "Sample Folder/File Sample.md"

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -d "${NB_DIR}/home/1"              ]]
  }

  run "${_NB}" helpers get_id_selector 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "1"                 ]]

  run "${_NB}" helpers get_id_selector 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "2/"                ]]

  run "${_NB}" helpers get_id_selector 1/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "2/1"               ]]


  run "${_NB}" helpers get_id_selector 1/File\ Sample.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "2/1"               ]]

  run "${_NB}" helpers get_id_selector Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "1/"                ]]

  run "${_NB}" helpers get_id_selector Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "1/1"               ]]


  run "${_NB}" helpers get_id_selector Example\ Folder/File\ Example.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                   ]]
  [[ "${output}"  ==  "1/1"               ]]
}

@test "'helpers get_id_selector <relative/path/to/file>' exits with 0 and prints id selector." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "1/1/1/1" ]]
}

@test "'helpers get_id_selector <relative/path/to/folder>/' (slash) exits with 0 and prints id selector to folder with trailing slash." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "Example Folder/Sample Folder/Demo Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0         ]]
  [[   "${#lines[@]}" ==  1         ]]

  [[   "${lines[0]}"  ==  "1/1/1/"  ]]
}

@test "'helpers get_id_selector <relative/path/to/folder>' (no slash) exits with 0 and prints id selector to folder with no slash." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
      --title     "one"                                                       \
      --content   "Content one."
  }

  run "${_NB}" helpers  \
    get_id_selector     \
    "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0       ]]
  [[   "${#lines[@]}" ==  1       ]]

  [[   "${lines[0]}"  ==  "1/1/1" ]]
}
