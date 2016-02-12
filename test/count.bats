#!/usr/bin/env bats

load test_helper


_setup_count() {
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

# `notes count` ###############################################################

@test "\`count\` exits with 0 and prints count." {
  {
    _setup_count
  }

  run "$_NOTES" count
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "3"

  [[ "${lines[0]}" -eq 3 ]]
}

# help ########################################################################

@test "\`help count\` exits with status 0." {
  run "$_NOTES" help count
  [[ $status -eq 0 ]]
}

@test "\`help count\` prints help information." {
  run "$_NOTES" help count
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes count" ]]
}
