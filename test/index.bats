#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "\`index\` builds an index if one doesn't exist." {
  {
    "${_NOTES}" init
    rm "${NOTES_DATA_DIR}/.index"
    [[ ! -e "${NOTES_DATA_DIR}/.index" ]]
  }

  run "${_NOTES}" index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
}

# add #########################################################################

@test "\`index add <filename>\` adds an item to the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    echo "" > "${NOTES_DATA_DIR}/.index"
    [[ ! "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
  }

  run "${_NOTES}" index add "$(ls ${NOTES_DATA_DIR})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
}

@test "\`index add\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    echo "" > "${NOTES_DATA_DIR}/.index"
    [[ ! "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
  }

  run "${_NOTES}" index add
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes index add <filename>" ]]
}

@test "\`index add <filename>\` with non-file returns 1 and prints message." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    echo "" > "${NOTES_DATA_DIR}/.index"
    [[ ! "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
  }

  run "${_NOTES}" index add 'not-a-file'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" =~ File\ not\ found ]]
}

@test "\`index add <filename>\` with existing entry does nothing." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    [[ "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
  }

  run "${_NOTES}" index add "$(ls ${NOTES_DATA_DIR})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "$(cat "${NOTES_DATA_DIR}/.index")" =~ 20[0-9]+\.md$ ]]
  [[ -z "${lines[1]}" ]]
}

# get_basename ################################################################

@test "\`index get_basename\` with valid index prints the filename for an index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index get_basename 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
}

@test "\`index get_basename\` with invalid index prints nothing." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index get_basename 12345
  [[ ${status} -eq 1 ]]
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
}

@test "\`index get_basename\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index get_basename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

# get_id #########################################################################

@test "\`index get_id <filename>\` deletes an item from the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index get_id "$(ls ${NOTES_DATA_DIR})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

@test "\`index get_id\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index get_id
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

@test "\`index delete <filename>\` with non-entry returns 1." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index delete 'not-an-entry'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" == "" ]]
}

# delete ######################################################################

@test "\`index delete <filename>\` deletes an item from the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index delete "$(ls ${NOTES_DATA_DIR})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${NOTES_DATA_DIR}/.index")" == "" ]]
}

@test "\`index delete\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index delete
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

@test "\`index delete <filename>\` with non-file returns 1 and prints message." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index delete 'not-a-file'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
}

# rebuild #####################################################################

@test "\`index rebuild\` rebuilds the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    echo "" > "${NOTES_DATA_DIR}/.index"
    [[ "$(cat "${NOTES_DATA_DIR}/.index")" == "" ]]
  }

  run "${_NOTES}" index rebuild
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${NOTES_DATA_DIR}/.index")" == "$(ls ${NOTES_DATA_DIR})" ]]
}

@test "\`index rebuild\` creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
    run "${_NOTES}" delete "${_filename}" --force
    run "${_NOTES}" add
  }

  run "${_NOTES}" index rebuild

  cd "${NOTES_DATA_DIR}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rebuild Index') ]]
}

# show ########################################################################

@test "\`index show\` prints index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index show
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
}

# update ######################################################################

@test "\`index update <old> <new>\` updates the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index update "$(ls ${NOTES_DATA_DIR})" "example.md"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf \
    "$(cat \"\${NOTES_DATA_DIR}/.index\"): '%s'\\n" \
    "$(cat "${NOTES_DATA_DIR}/.index")"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${NOTES_DATA_DIR}/.index")" == "example.md" ]]
}

@test "\`index update\` with no arguments returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index update
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

@test "\`index update\` with first argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index update "$(ls ${NOTES_DATA_DIR})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

# verify ######################################################################

@test "\`index verify\` verifies a valid index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    "${_NOTES}" add "# two"
    printf \
      "\"\$(cat \"\${NOTES_DATA_DIR}/.index\")\": '%s'\\n" \
      "$(cat "${NOTES_DATA_DIR}/.index")"
    printf "\$(ls -r \${NOTES_DATA_DIR}): '%s'\\n" "$(ls -r ${NOTES_DATA_DIR})"
    [[ "$(cat "${NOTES_DATA_DIR}/.index")" == "$(ls -r ${NOTES_DATA_DIR})" ]]
  }

  run "${_NOTES}" index verify
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`index verify\` returns 1 with an valid index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
    "${_NOTES}" add "# two"
    printf "not-a-file\n" >> "${NOTES_DATA_DIR}/.index"
    [[ "$(cat "${NOTES_DATA_DIR}/.index")" != "$(ls ${NOTES_DATA_DIR})" ]]
  }

  run "${_NOTES}" index verify
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
}

# help ########################################################################

@test "\`help index\` exits with status 0." {
  run "${_NOTES}" help index
  [[ ${status} -eq 0 ]]
}

@test "\`help index\` prints help information." {
  run "${_NOTES}" help index
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes index add <filename>" ]]
}
