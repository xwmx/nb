#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`edit\` with no argument exits with status 1." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 1 ]]
}

@test "\`edit\` with no argument does not edit the note file." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }
  _original="$(cat "${NOTES_DATA_DIR}/${_filename}")"

  run "$_NOTES" edit
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_original}" ]]
}

@test "\`edit\` with no argument does not create git commit." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Edit') ]]
}

@test "\`edit\` with no argument prints help information." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes edit <index>" ]]
}

# <filename> ##################################################################

@test "\`edit\` with <filename> argument exits with status 0." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit "$_filename"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
}

@test "\`edit\` with <filename> argument updates note file." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }
  _original="$(cat "${NOTES_DATA_DIR}/${_filename}")"

  run "$_NOTES" edit "$_filename"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]
}

@test "\`edit\` with <filename> argument creates git commit." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit "$_filename"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]
}

# <index> #####################################################################

@test "\`edit\` with <index> argument exits with status 0." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit 0
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
}

@test "\`edit\` with <index> argument updates note file." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }
  _original="$(cat "${NOTES_DATA_DIR}/${_filename}")"

  run "$_NOTES" edit 0
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]
}

@test "\`edit\` with <index> argument creates git commit." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit 0

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]
}

# <path> ######################################################################

@test "\`edit\` with <path> argument exits with status 0." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit "${NOTES_DATA_DIR}/${_filename}"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ $status -eq 0 ]]
}

@test "\`edit\` with <path> argument updates note file." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }
  _original="$(cat "${NOTES_DATA_DIR}/${_filename}")"

  run "$_NOTES" edit "${NOTES_DATA_DIR}/${_filename}"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" != "${_original}" ]]
}

@test "\`edit\` with <path> argument creates git commit." {
  {
    run "$_NOTES" init
    run "$_NOTES" add
    _files=("$(ls "${NOTES_DATA_DIR}/")") && _filename="${_files[0]}"
  }

  run "$_NOTES" edit "${NOTES_DATA_DIR}/${_filename}"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Edit') ]]
}

# help ########################################################################

@test "\`help edit\` exits with status 0." {
  run "$_NOTES" help edit
  [[ $status -eq 0 ]]
}

@test "\`help edit\` prints help information." {
  run "$_NOTES" help edit
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes edit <index>" ]]
}
