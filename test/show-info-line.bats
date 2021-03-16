#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'show <not-valid> --info-line' exits with status 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/example.md" --title "Example Title"
  }

  run "${_NB}" show "99" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 1           ]]
  [[    "${output}" =~  Not\ found: ]]
  [[    "${output}" =~  99          ]]
}

@test "'show <folder>/<not-valid> --info-line' exits with status 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/example.md" --title "Example Title"
  }

  run "${_NB}" show "Example Folder/99" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 1           ]]
  [[    "${output}" =~  Not\ found: ]]
  [[    "${output}" =~  99          ]]
}

# edge cases ##################################################################

@test "'show <id> --info-line' exits with status 0 and prints note info when filename contains colon and spaces." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --content   "Example content."    \
      --filename  "http: not a url.md"  \
      --title     "Example Title"
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                     ]]
  [[    "${output}" =~  1                     ]]
  [[    "${output}" =~  http:\ not\ a\ url.md ]]
  [[    "${output}" =~  Example\ Title        ]]
  [[ !  "${output}" =~  home                  ]]
}

# folders #####################################################################

@test "'show <relative-path> --info-line' exits with status 0 and prints nested file info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/example.md" --title "Example Title"
  }

  run "${_NB}" show "Example Folder/example.md" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                   ]]
  [[    "${output}" =~  1                   ]]
  [[    "${output}" =~  Example\ Folder/1   ]]
  [[    "${output}" =~  example.md          ]]
  [[    "${output}" =~  Example\ Title      ]]
  [[ !  "${output}" =~  home                ]]
}

@test "'show <relative-path> --info-line' exits with status 0 and prints nested folder info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/"
  }

  run "${_NB}" show "Example Folder/Sample Folder" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                               ]]
  [[    "${output}" =~  1                               ]]
  [[    "${output}" =~  Example\ Folder/1               ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder  ]]
  [[ !  "${output}" =~  home                            ]]
}

@test "'show <folder>/<id> --info-line' exits with status 0 and prints nested file info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/example.md" --title "Example Title"
  }

  run "${_NB}" show "Example Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                 ]]
  [[    "${output}" =~  1                 ]]
  [[    "${output}" =~  Example\ Folder/1 ]]
  [[    "${output}" =~  example.md        ]]
  [[    "${output}" =~  Example\ Title    ]]
  [[ !  "${output}" =~  home              ]]
}

@test "'show <folder>/<id> --info-line' exits with status 0 and prints nested folder info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/"
  }

  run "${_NB}" show "Example Folder/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                               ]]
  [[    "${output}" =~  1                               ]]
  [[    "${output}" =~  Example\ Folder/1               ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder  ]]
  [[ !  "${output}" =~  home                            ]]
}

@test "'show <folder>/<folder-id>/<id> --info-line' exits with status 0 and prints nested file info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/example.md" --title "Example Title"
  }

  run "${_NB}" show "Example Folder/1/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                         ]]
  [[    "${output}" =~  1                                         ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder/1          ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder/example.md ]]
  [[    "${output}" =~  Example\ Title                            ]]
  [[ !  "${output}" =~  home                                      ]]
}

@test "'show <folder>/<folder-id>/<id> --info-line' exits with status 0 and prints nested folder info." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/"
  }

  run "${_NB}" show "Example Folder/1/1" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                           ]]
  [[    "${output}" =~  1                                           ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder/1            ]]
  [[    "${output}" =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[ !  "${output}" =~  home                                        ]]
}

@test "'show <notebook>:<folder-id>/<filename> --info-line' exits with status 0 and prints nested folder info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" add  "Example Notebook:Sample Folder/Example File.md"  \
      --title     "Example Title"                                   \
      --content   "Example content."
  }

  run "${_NB}" show "Example Notebook:1/Example File.md" --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                                 ]]
  [[    "${output}" =~  1                                                 ]]
  [[    "${output}" =~  Example\ Notebook:Sample\ Folder/1                ]]
  [[    "${output}" =~  Example\ Notebook:Sample\ Folder/Example\ File.md ]]
  [[ !  "${output}" =~  home                                              ]]
}

# first line #################################################################

@test "'show <id> --info-line' with path in title prints title." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.md"
# Example /path/in/title/Example File.md
HEREDOC
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"  -eq 0                                           ]]
  [[   "${output}"  =~  1                                           ]]
  [[   "${output}"  =~  example.md                                  ]]
  [[   "${output}"  =~  \"Example\ /path/in/title/Example\ File.md  ]]
  [[ ! "${output}"  =~  __first_line                                ]]
}

@test "'show <id> --info-line' exits with status 0 and does not print first line." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.md"
Example line one.

Example line three (line two is blank).
HEREDOC
  }

  run "${_NB}" show 1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"  -eq 0                   ]]
  [[   "${output}"  =~  1                   ]]
  [[   "${output}"  =~  example.md          ]]
  [[ ! "${output}"  =~  Example\ line\ one. ]]
  [[ ! "${output}"  =~  __first_line        ]]
}

# `show <id> --info-line` #####################################################

@test "'show <id> --info-line' exits with status 0 and prints unscoped note info." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --title "Example Title"
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
    "${_NB}" init
    "${_NB}" notebooks add one
    "${_NB}" one:add "example.md" --title "Example Title"
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
    "${_NB}" init
    "${_NB}" notebooks add "multi word"
    "${_NB}" multi\ word:add "example.md" --title "Example Title"
  }

  run "${_NB}" show multi\ word:1 --info-line

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                        ]]
  [[ "${output}" =~ multi\ word:1           ]]
  [[ "${output}" =~ multi\ word:example.md  ]]
  [[ "${output}" =~ Example\ Title          ]]
}

@test "'show <id> --info-line' includes indicators." {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md"    \
      --title   "Example Title"           \
      --content "<https://example.test>"
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
    "${_NB}" init
    "${_NB}" add "example.bookmark.md"    \
      --title   "Example Title"           \
      --content "<https://example.test>"  \
      --encrypt --password=password
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
