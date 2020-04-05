#!/usr/bin/env bats

load test_helper

# `notes show` ################################################################

@test "\`show\` with no argument exits with status 1 and prints help." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]" ]]
}

@test "\`show\` with no argument does not show the note file." {
  skip "TODO: Determine how to test for \`\$PAGER\`."
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
}

# `notes show --dump` #########################################################

@test "\`show --dump\` with argument exits with 0 and prints note with highlighting." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Example"
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ ! "${lines[0]}" =~ "# Example" ]]
  [[ "${lines[0]}" =~ "Example" ]]
}

@test "\`show --dump --no-color\` with argument exits with 0 and prints note without highlighting." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Example"
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --dump --no-color
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ "# Example" ]]
}

@test "\`show --dump\` with no argument exits with 1 and prints help." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Example"
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]

  [[ ! "${output}" =~ mock_editor ]]

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]" ]]
}

# <selector> ##################################################################

@test "\`show <selector>\` with empty repo exits with 1 and prints help." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" show 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Note not found." ]]
}

# `notes show <filename> --dump` ##############################################

@test "\`show <filename> --dump\` exits with status 0 and dumps note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${_filename}" --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ mock_editor ]]
}

# `notes show <id> --dump` ####################################################

@test "\`show <id> --dump\` exits with status 0 and dumps note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ mock_editor ]]
}

# `notes show <path> --dump` #################################################

@test "\`show <path> --dump\` exits with status 0 and dumps note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${NOTES_DATA_DIR}/${_filename}" --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ mock_editor ]]
}

# `notes show <title> --dump` #################################################

@test "\`show <title> --dump\` exits with status 0 and dumps note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" show "${_title}" --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ mock_editor ]]
}

# `notes show <filename> --path` ##############################################

@test "\`show <filename> --path\` exits with status 0 and prints note path." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${_filename}" --path
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "${NOTES_DATA_DIR}/${_filename}" ]]
}

# `notes show <id> --path` ####################################################

@test "\`show <id> --path\` exits with status 0 and prints note path." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --path
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "${NOTES_DATA_DIR}/${_filename}" ]]
}


# `notes show <path> --path` #################################################

@test "\`show <path> --path\` exits with status 0 and prints note path." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${NOTES_DATA_DIR}/${_filename}" --path
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "${NOTES_DATA_DIR}/${_filename}" ]]
}

# `notes show <title> --path` #################################################

@test "\`show <title> --path\` exits with status 0 and prints note path." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" show "${_title}" --path
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "${NOTES_DATA_DIR}/${_filename}" ]]
}

# `notes show <filename> --id` ################################################

@test "\`show <filename> --id\` exits with status 0 and prints note id." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${_filename}" --id
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

# `notes show <id> --id` ######################################################

@test "\`show <id> --id\` exits with status 0 and prints note id." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --id
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

# `notes show <path> --id` ####################################################

@test "\`show <path> --id\` exits with status 0 and prints note id." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show "${NOTES_DATA_DIR}/${_filename}" --id
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

# `notes show <title> --id` ###################################################

@test "\`show <title> --id\` exits with status 0 and prints note id." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${NOTES_DATA_DIR}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" show "${NOTES_DATA_DIR}/${_filename}" --id
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

# encrypted ###################################################################

@test "\`show\` with encrypted file show properly without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Content" --encrypt --password=example
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" show 1 --password=example --dump
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints file content
  [[ "${output}" =~ Content ]]
}

# help ########################################################################

@test "\`help show\` exits with status 0." {
  run "${_NOTES}" help show
  [[ ${status} -eq 0 ]]
}

@test "\`help show\` prints help information." {
  run "${_NOTES}" help show
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes show (<id> | <filename> | <path> | <title>) [--id | --path | --render]" ]]
}
