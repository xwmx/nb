#!/usr/bin/env bats

load test_helper

# `show <id> --info-line` #####################################################

@test "'show <id> --info-line' exits with status 0 and prints unscoped note info." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --title "Example Title"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${output}" =~ 1               ]]
  [[ "${output}" =~ example.md      ]]
  [[ "${output}" =~ Example\ Title  ]]
  [[ ! "${output}" =~ home          ]]
}

@test "'show <id> --info-line' exits with status 0 and prints scoped note info." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
    run "${_NB}" one:add "example.md" --title "Example Title"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" show one:1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${output}" =~ one:1           ]]
  [[ "${output}" =~ one:example.md  ]]
  [[ "${output}" =~ Example\ Title  ]]
}

@test "'show <id> --info-line' prints escaped multi-word notebook name when scoped." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "multi word"
    run "${_NB}" multi\ word:add "example.md" --title "Example Title"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" show multi\ word:1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${output}" =~ multi\\\ word:1           ]]
  [[ "${output}" =~ multi\\\ word:example.md  ]]
  [[ "${output}" =~ Example\ Title            ]]
}

@test "'show <id> --info-line' includes indicators." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.bookmark.md"  \
      --title   "Example Title"             \
      --content "<https://example.test>"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}      -eq 0                   ]]
  [[ "${output}"    =~ 1                    ]]
  [[ "${output}"    =~ example.bookmark.md  ]]
  [[ "${output}"    =~ Example\ Title       ]]
  [[ ! "${output}"  =~ home                 ]]
  [[ "${output}"    =~ 🔖                   ]]
  [[ ! "${output}"  =~ 🔒                   ]]
}

@test "'show <id> --info-line' includes encrypted indicators." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.bookmark.md"  \
      --title   "Example Title"             \
      --content "<https://example.test>"    \
      --encrypt --password=password

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}      -eq 0                       ]]
  [[ "${output}"    =~ 1                        ]]
  [[ "${output}"    =~ example.bookmark.md.enc  ]]
  [[ ! "${output}"  =~ Example\ Title           ]]
  [[ ! "${output}"  =~ home                     ]]
  [[ "${output}"    =~ 🔖                       ]]
  [[ "${output}"    =~ 🔒                       ]]
}
