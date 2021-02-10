#!/usr/bin/env bats

load test_helper

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
