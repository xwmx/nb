#!/usr/bin/env bats
# shellcheck disable=SC2089,SC2090

load test_helper

# error handling ##############################################################

@test "'help example' exits with 0 and prints message." {
  run "${_NB}" help example_name_123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                       ]]
  [[ "${#lines[@]}" -eq 1                                       ]]

  [[ "${lines[0]}"  =~  \
No\ additional\ information\ for\ .*\`.*example_name_123.*\`.*$ ]]
}

@test "'help example:' exits with 0 and prints message." {
  run "${_NB}" help example:name:123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                       ]]
  [[ "${#lines[@]}" -eq 1                                       ]]

  [[ "${lines[0]}"  =~  \
No\ additional\ information\ for\ .*\`.*example:name:123.*\`.*$ ]]
}

# color #######################################################################

@test "'help' and 'help <subcommand>' respect --no-color option." {
  run "${_NB}" help --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                           ]]
  [[    "${output}" =~  \
nb\ -h\ \|\ \-\-help\ \|\ help\ \[\<subcommand\>\ \|\ \-\-readme\]  ]]

  run "${_NB}" help browse --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq  0                                          ]]
  [[    "${output}" =~  \[\-s\ \|\ \-\-serve\]                      ]]
}

@test "'help' and 'help <subcommand>' color usage." {
  run "${_NB}" help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                                             ]]

  [[    "${output}" =~  \
nb\ -h\ .*\|.*\ \-\-help\ .*\|.*\ help\ .*\[.*\<subcommand\>\ .*\|.*\ \-\-readme.*\]  ]]
  [[ !  "${output}" =~  \
nb\ -h\ \|\ \-\-help\ \|\ help\ \[\<subcommand\>\ \|\ \-\-readme\]                    ]]

  run "${_NB}" help browse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq  0                              ]]

  [[    "${output}" =~  \[.*\-s\ .*\|.*\ \-\-serve.*\]  ]]
  [[ !  "${output}" =~  \[\-s\ \|\ \-\-serve\]          ]]
}

@test "'help' and 'help <subcomman>' color hash in #tag* patterns." {
  run "${_NB}" help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0               ]]

  [[ "${output}" =~   \ .*#.*tagging  ]]

  run "${_NB}" help browse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0               ]]

  [[ "${output}" =~   \ .*#.*tags     ]]
}

# `help` ######################################################################

@test "'help' with no arguments exits with status 0 and prints default help." {
  run "${_NB}" help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                         ]]

  [[ "${output}" =~   nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~   nb\ edit                  ]]
}

@test "'-h' exits with 0 and prints default help." {
  run "${_NB}" -h

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                       ]]

  [[ "${output}" =~ nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~ nb\ edit                  ]]
}

@test "'--help' exits with 0 and prints default help." {
  run "${_NB}" --help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                       ]]

  [[ "${output}" =~ nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~ nb\ edit                  ]]
}

@test "'help help' exits with 0 and prints 'help' subcommand usage." {
  run "${_NB}" help help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                       ]]

  [[ "${lines[17]}" =~ Shortcut\ Alias.*\:$   ]]
  [[ "${lines[18]}" =~ ^\ \ nb\ h$            ]]
}

@test "'help settings' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" help settings

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}

@test "'h settings' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" h settings

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}

@test "'--help settings' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" --help settings

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}

@test "'settings --help' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" settings --help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}

@test "'-h settings' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" -h settings

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}

@test "'settings -h' exits with 0 and prints 'settings' subcommand usage." {
  run "${_NB}" settings -h

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq  0          ]]

  [[ "${lines[0]}"  =~  Usage.*:    ]]
  [[ "${lines[1]}"  =~  \ \ nb\ set ]]
}
