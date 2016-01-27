#!/usr/bin/env bats

load test_helper

_setup_search() {
  "$_NOTES" init
    cat <<HEREDOC | "$_NOTES" add
# one
idyl
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# two
hoof
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# three
sweetish
HEREDOC
}

# `search` ####################################################################

@test "\`search\` with no argument exits with status 1." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 1 ]]
}

@test "\`search\` with no argument prints help information." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes search <query> [--path]" ]]
}

# `search <query with no matches>` ############################################

@test "\`search <query with no matches>\` exits with status 1." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'query with no matches'
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 1 ]]
}

@test "\`search <query with no matches>\` does not print output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "$_NOTES" search 'query with no matches'
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ -z "$output" ]]
}
