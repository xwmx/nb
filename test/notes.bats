#!/usr/bin/env bats

load test_helper

_setup_notes() {
  "$_NOTES" init
  "$_NOTES" add "# one"
  sleep 1
  "$_NOTES" add "# two"
  sleep 1
  "$_NOTES" add "# three"
}

# `notes` (empty repo) ########################################################

@test "\`notes\` with an empty repo exits with status 1." {
  run "$_NOTES"
  [[ "$status" -eq 1 ]]
}

@test "\`notes\` with an empty repo prints error." {
  run "$_NOTES"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" =~ ❌ ]]
}

# `notes` (non-empty repo) ####################################################

@test "\`notes\` with an non-empty repo exits with 0 and prints list." {
  {
    _setup_notes
    _files=($(ls -t "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${_files[*]}" "${lines[*]}"

  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}
