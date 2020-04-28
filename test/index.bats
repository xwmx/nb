#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "\`index\` builds an index if one doesn't exist." {
  {
    "${_NOTES}" init
    rm "${_NOTEBOOK_PATH}/.index"
    [[ ! -e "${_NOTEBOOK_PATH}/.index" ]]
  }

  run "${_NOTES}" index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
}

# add #########################################################################

@test "\`index add <filename>\` adds an item to the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    echo "" > "${_NOTEBOOK_PATH}/.index"
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NOTES}" index add "$(ls ${_NOTEBOOK_PATH})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(cat \${_NOTEBOOK_PATH}/.index): '%s'\\n" \
    "$(cat "${_NOTEBOOK_PATH}/.index")"
  printf "\$(ls ${_NOTEBOOK_PATH}): '%s'\\n" "$(ls ${_NOTEBOOK_PATH})"

  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ first.md$ ]]
}

@test "\`index add\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    echo "" > "${_NOTEBOOK_PATH}/.index"
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
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
    "${_NOTES}" add "first.md"  --title "one"
    echo "" > "${_NOTEBOOK_PATH}/.index"
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
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
    "${_NOTES}" add "first.md"  --title "one"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NOTES}" index add "$(ls ${_NOTEBOOK_PATH})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
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
    "${_NOTES}" add "first.md"  --title "one"
  }

  run "${_NOTES}" index get_basename 12345
  [[ ${status} -eq 1 ]]
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
}

@test "\`index get_basename\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
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
    "${_NOTES}" add "first.md"  --title "one"
  }

  run "${_NOTES}" index get_id "$(ls ${_NOTEBOOK_PATH})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" == "1" ]]
}

@test "\`index get_id\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
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
    "${_NOTES}" add "first.md"  --title "one"
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
    "${_NOTES}" add "first.md"  --title "one"
  }

  run "${_NOTES}" index delete "$(ls ${_NOTEBOOK_PATH})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "" ]]
}

@test "\`index delete\` with no argument returns 1 and prints help." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
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
    "${_NOTES}" add "first.md"  --title "one"
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
    "${_NOTES}" add "first.md"  --title "one"
    echo "" > "${_NOTEBOOK_PATH}/.index"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "" ]]
  }

  run "${_NOTES}" index rebuild
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls ${_NOTEBOOK_PATH})" ]]
}

@test "\`index rebuild\` creates git commit." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
    run "${_NOTES}" delete "${_filename}" --force
    run "${_NOTES}" add
  }

  run "${_NOTES}" index rebuild

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rebuild Index') ]]
}

# reconcile ###################################################################

@test "\`index reconcile\` does not modify a valid index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    "${_NOTES}" add "second.md" --title "two"
    printf \
      "\"\$(cat \"\${_NOTEBOOK_PATH}/.index\")\": '%s'\\n" \
      "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "\$(ls -r \${_NOTEBOOK_PATH}): '%s'\\n" "$(ls ${_NOTEBOOK_PATH})"
    _existing_index="$(cat "${_NOTEBOOK_PATH}/.index")"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls ${_NOTEBOOK_PATH})" ]]
  }

  run "${_NOTES}" index reconcile
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  "${_NOTES}" index verify
  [[ ${status} -eq 0 ]]
}

@test "\`index reconcile\` updates when file has been deleted." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    "${_NOTES}" add "second.md" --title "two"
    printf "not-a-file\n" >> "${_NOTEBOOK_PATH}/.index"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls ${_NOTEBOOK_PATH})" ]]
  }

  run "${_NOTES}" index reconcile
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"
  [[ ${status} -eq 0 ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ not-a-file ]]
  "${_NOTES}" index verify
}

@test "\`index reconcile\` updates when file has been added." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    "${_NOTES}" add "second.md" --title "two"
    echo "# Example" > "${_NOTEBOOK_PATH}/example.md"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls ${_NOTEBOOK_PATH})" ]]
  }

  run "${_NOTES}" index reconcile
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ example.md ]]
  "${_NOTES}" index verify
}

@test "\`index reconcile\` updates when files have been added and deleted." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    printf "\\n" >> "${_NOTEBOOK_PATH}/.index"
    printf "\\n" >> "${_NOTEBOOK_PATH}/.index"
    "${_NOTES}" add "second.md" --title "two"
    printf "not-a-file\\n" >> "${_NOTEBOOK_PATH}/.index"
    printf "also-no-file\\n" >> "${_NOTEBOOK_PATH}/.index"
    echo "# Example" > "${_NOTEBOOK_PATH}/example.md"
    echo "# Sample" > "${_NOTEBOOK_PATH}/sample.md"
    "${_SED_I_COMMAND[@]}" -e "s/^first.md$//g" "${_NOTEBOOK_PATH}/.index"

    printf "first.md id: %s\\n" "$("${_NOTES}" index get_id "first.md")"
    printf "second.md id: %s\\n" "$("${_NOTES}" index get_id "second.md")"
    printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "ls: '%s'\\n" "$(ls ${_NOTEBOOK_PATH})"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls ${_NOTEBOOK_PATH})" ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ first.md ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ sample.md    ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ sample.md    ]]
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ not-a-file   ]]
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ also-no-file ]]
    [[ "$("${_NOTES}" index get_id "second.md")" == '4' ]]
  }

  run "${_NOTES}" index reconcile
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ first.md     ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ example.md   ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ sample.md    ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ not-a-file   ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ also-no-file ]]
  [[ "$("${_NOTES}" index get_id "second.md")"  == '4' ]]
  [[ "$("${_NOTES}" index get_id "example.md")" == '7' ]]
  [[ "$("${_NOTES}" index get_id "first.md")"   == '8' ]]
  [[ "$("${_NOTES}" index get_id "sample.md")"  == '9' ]]

  "${_NOTES}" index verify
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
  [[ "${output}" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

# update ######################################################################

@test "\`index update <old> <new>\` updates the index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "# one"
  }

  run "${_NOTES}" index update "$(ls ${_NOTEBOOK_PATH})" "example.md"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf \
    "$(cat \"\${_NOTEBOOK_PATH}/.index\"): '%s'\\n" \
    "$(cat "${_NOTEBOOK_PATH}/.index")"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "example.md" ]]
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

  run "${_NOTES}" index update "$(ls ${_NOTEBOOK_PATH})"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
}

# verify ######################################################################

@test "\`index verify\` verifies a valid index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    "${_NOTES}" add "second.md" --title "two"
    printf \
      "\"\$(cat \"\${_NOTEBOOK_PATH}/.index\")\": '%s'\\n" \
      "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "\$(ls \${_NOTEBOOK_PATH}): '%s'\\n" "$(ls ${_NOTEBOOK_PATH})"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls ${_NOTEBOOK_PATH})" ]]
  }

  run "${_NOTES}" index verify
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`index verify\` returns 1 with an invalid index." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "first.md"  --title "one"
    "${_NOTES}" add "second.md" --title "two"
    printf "not-a-file\n" >> "${_NOTEBOOK_PATH}/.index"
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls ${_NOTEBOOK_PATH})" ]]
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
