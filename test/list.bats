#!/usr/bin/env bats

load test_helper

# `notes list` ################################################################

@test "\`list\` exits with 0 and lists files in reverse order." {
  {
    "$_NOTES" init
    "$_NOTES" add "# one"
    sleep 1
    "$_NOTES" add "# two"
    sleep 1
    "$_NOTES" add "# three"
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[0]}" =~ ${_files[2]} ]]
  [[ "${lines[1]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[1]}" =~ ${_files[1]} ]]
  [[ "${lines[2]}" =~ 20[0-9]+\.md$ ]] && [[ "${lines[2]}" =~ ${_files[0]} ]]
}

# `notes list --noindex` ######################################################

@test "\`list --noindex\` exits with 0 and lists files in reverse order." {
  {
    "$_NOTES" init
    "$_NOTES" add "# one"
    sleep 1
    "$_NOTES" add "# two"
    sleep 1
    "$_NOTES" add "# three"
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list --noindex
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" == "${_files[2]}" ]]
  [[ "${lines[1]}" == "${_files[1]}" ]]
  [[ "${lines[2]}" == "${_files[0]}" ]]
}
