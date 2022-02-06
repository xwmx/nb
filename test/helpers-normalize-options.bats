#!/usr/bin/env bats

load test_helper

@test "'_normalize_options()' separates joined single-letter options." {
  run "${_NB}" helpers print_normalized_options -abc

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 5                           ]]
  [[ "${lines[0]}"  ==  "helpers"                   ]]
  [[ "${lines[1]}"  ==  "print_normalized_options"  ]]
  [[ "${lines[2]}"  ==  "-a"                        ]]
  [[ "${lines[3]}"  ==  "-b"                        ]]
  [[ "${lines[4]}"  ==  "-c"                        ]]
}

@test "'_normalize_options()' retains multi-digit option." {
  run "${_NB}" helpers print_normalized_options -123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]
  [[ "${lines[0]}"  ==  "helpers"                   ]]
  [[ "${lines[1]}"  ==  "print_normalized_options"  ]]
  [[ "${lines[2]}"  ==  "-123"                      ]]
}

@test "'_normalize_options()' keeps multiple digits together." {
  run "${_NB}" helpers print_normalized_options -abc123edf45

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 10                          ]]
  [[ "${lines[0]}"  ==  "helpers"                   ]]
  [[ "${lines[1]}"  ==  "print_normalized_options"  ]]
  [[ "${lines[2]}"  ==  "-a"                        ]]
  [[ "${lines[3]}"  ==  "-b"                        ]]
  [[ "${lines[4]}"  ==  "-c"                        ]]
  [[ "${lines[5]}"  ==  "-123"                      ]]
  [[ "${lines[6]}"  ==  "-e"                        ]]
  [[ "${lines[7]}"  ==  "-d"                        ]]
  [[ "${lines[8]}"  ==  "-f"                        ]]
  [[ "${lines[9]}"  ==  "-45"                       ]]
}
