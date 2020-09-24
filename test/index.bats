#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "\`index\` builds an index if one doesn't exist." {
  {
    "${_NB}" init

    rm "${_NOTEBOOK_PATH}/.index"

    [[ ! -e "${_NOTEBOOK_PATH}/.index" ]]
  }

  run "${_NB}" index

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
}

# add #########################################################################

@test "\`index add <filename>\` adds an item to the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${_NOTEBOOK_PATH}/.index"

    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add "$(ls "${_NOTEBOOK_PATH}")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(cat \${_NOTEBOOK_PATH}/.index): '%s'\\n" \
    "$(cat "${_NOTEBOOK_PATH}/.index")"
  printf "\$(ls ${_NOTEBOOK_PATH}): '%s'\\n" "$(ls "${_NOTEBOOK_PATH}")"

  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ first.md$ ]]
}

@test "\`index add\` with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${_NOTEBOOK_PATH}/.index"

    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                              ]]
  [[ "${lines[0]}" =~ Usage\:                     ]]
  [[ "${lines[1]}" == "  nb index add <filename>" ]]
}

@test "\`index add <filename>\` with non-file returns 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${_NOTEBOOK_PATH}/.index"

    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add 'not-a-file'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                    ]]
  [[ "${lines[0]}" =~ File\ not\ found  ]]
}

@test "\`index add <filename>\` with existing entry does nothing." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add "$(ls "${_NOTEBOOK_PATH}")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ ^first.md$  ]]
  [[ -z "${lines[1]}"                                   ]]
}

# get_basename ################################################################

@test "\`index get_basename\` with valid index prints the filename for an index." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index get_basename 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
}

@test "\`index get_basename\` with invalid index prints nothing." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_basename 12345

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

@test "\`index get_basename\` with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_basename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

# get_id #########################################################################

@test "\`index get_id <filename>\` returns the id for <filename>." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_id "$(ls "${_NOTEBOOK_PATH}")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" == "1" ]]
}

@test "\`index get_id\` with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "\`index get_id <filename>\` with non-entry returns 1." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_id 'not-an-entry'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1    ]]
  [[ "${output}" == ""  ]]
}

# get_max_id ##################################################################

@test "\`index get_max_id\` returns the max id number." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"    --title "one"
    "${_NB}" add "second.md"   --title "two"
    "${_NB}" add "third.md"    --title "three"
  }

  run "${_NB}" index get_max_id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" == "3" ]]
}

@test "\`index get_max_id\` with empty notebook returns 0." {
  {
    "${_NB}" init
  }

  run "${_NB}" index get_max_id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${lines[0]}" == "0" ]]
}

# delete ######################################################################

@test "\`index delete <filename>\` deletes an item from the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete "$(ls "${_NOTEBOOK_PATH}")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                            ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == ""  ]]
}

@test "\`index delete\` with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "\`index delete <filename>\` with non-file returns 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete 'not-a-file'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

# rebuild #####################################################################

@test "\`index rebuild\` rebuilds the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"
    "${_NB}" add "third.md"  --title "three"

    "${_NB}" edit "second.md" --content "New conent."

    echo "" > "${_NOTEBOOK_PATH}/.index"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "" ]]
  }

  run "${_NB}" index rebuild

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls -t -r "${_NOTEBOOK_PATH}"

  [[ ${status} -eq 0                                                          ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls -t -r "${_NOTEBOOK_PATH}")" ]]
}

@test "\`index rebuild\` creates git commit." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    run "${_NB}" delete "${_filename}" --force
    run "${_NB}" add
  }

  run "${_NB}" index rebuild

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rebuild Index'
}

# show ########################################################################

@test "\`index show\` prints index." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index show

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                    ]]
  [[ "${output}" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]
}

# update ######################################################################

@test "\`index update <old> <new>\` updates the index." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update "$(ls "${_NOTEBOOK_PATH}")" "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf \
    "$(cat \"\$\{_NOTEBOOK_PATH\}/.index\"): '%s'\\n" \
    "$(cat "${_NOTEBOOK_PATH}/.index")"

  [[ ${status} -eq 0                                      ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "example.md"  ]]
}

@test "\`index update\` with no arguments returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

@test "\`index update\` with first argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update "$(ls "${_NOTEBOOK_PATH}")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1          ]]
  [[ "${lines[0]}" =~ Usage\: ]]
}

# verify ######################################################################

@test "\`index verify\` verifies a valid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf \
      "\"\$(cat \"\${_NOTEBOOK_PATH}/.index\")\": '%s'\\n" \
      "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "\$(ls \${_NOTEBOOK_PATH}): '%s'\\n" "$(ls "${_NOTEBOOK_PATH}")"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
}

@test "\`index verify\` returns 1 with an invalid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\\n" >> "${_NOTEBOOK_PATH}/.index"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

@test "\`index verify\` returns 1 with a duplicates." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "second.md\\n" >> "${_NOTEBOOK_PATH}/.index"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

# help ########################################################################

@test "\`help index\` exits with status 0." {
  run "${_NB}" help index

  [[ ${status} -eq 0 ]]
}

@test "\`help index\` prints help information." {
  run "${_NB}" help index

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage\:                     ]]
  [[ "${lines[1]}" == "  nb index add <filename>" ]]
}
