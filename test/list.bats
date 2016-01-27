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

# `notes list -e` #############################################################

@test "\`list -e\` exits with 0 and displays 5 line list items." {
  {
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
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list -e
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list -e 2\` exits with 0 and displays 4 line list items." {
  {
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
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list -e 2
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}

# `notes list --excerpt` ######################################################

@test "\`list --excerpt\` exits with 0 and displays 5 line list items." {
  {
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
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list --excerpt
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list --excerpt 2\` exits with 0 and displays 4 line list items." {
  {
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
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" list --excerpt 2
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}
