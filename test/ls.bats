#!/usr/bin/env bats

load test_helper


_setup_ls() {
  "$_NOTES" init
    cat <<HEREDOC | "$_NOTES" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# two
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# three
line two
line three
line four
HEREDOC
}

# `notes ls` ################################################################

@test "\`ls\` exits with 0 and lists files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}

# `notes ls [<excerpt length>]` ###############################################

@test "\`ls <[[:digits:]]>\` exits with 0 and displays excerpts." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls 5
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 18 ]]
}

@test "\`ls <[[:alpha:]]>\` exits with 0 and lists files as \`ls\`." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls x
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}
