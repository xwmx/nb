#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "'index' builds an index if one doesn't exist." {
  {
    "${_NB}" init

    rm "${NB_DIR}/home/.index"

    [[ ! -e "${NB_DIR}/home/.index" ]]
  }

  run "${_NB}" index

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -e "${NB_DIR}/home/.index" ]]
}

# add #########################################################################

@test "'index add <filename>' adds an item to the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${NB_DIR}/home/.index"

    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add "$(ls "${NB_DIR}/home")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(cat \${NB_DIR}/home/.index): '%s'\\n" \
    "$(cat "${NB_DIR}/home/.index")"
  printf "\$(ls ${NB_DIR}/home): '%s'\\n" "$(ls "${NB_DIR}/home")"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ first.md$ ]]
}

@test "'index add' with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${NB_DIR}/home/.index"

    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                              ]]
  [[ "${lines[0]}" =~ Usage.*\:                   ]]
  [[ "${lines[1]}" == "  nb index add <filename>" ]]
}

@test "'index add <filename>' with non-file returns 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    echo "" > "${NB_DIR}/home/.index"

    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add 'not-a-file'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                    ]]
  [[ "${lines[0]}" =~ File\ not\ found  ]]
}

@test "'index add <filename>' with existing entry does nothing." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    [[ "$(cat "${NB_DIR}/home/.index")" =~ ^first.md$ ]]
  }

  run "${_NB}" index add "$(ls "${NB_DIR}/home")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ ^first.md$   ]]
  [[ -z "${lines[1]}"                                 ]]
}

# get_basename ################################################################

@test "'index get_basename' with valid index prints the filename for an id." {
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

@test "'index get_basename' with invalid index prints nothing." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_basename 12345

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

@test "'index get_basename' with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_basename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

# get_id #########################################################################

@test "'index get_id <filename>' returns the id for <filename>." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_id "$(ls "${NB_DIR}/home")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" == "1" ]]
}

@test "'index get_id' with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index get_id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

@test "'index get_id <filename>' with non-entry returns 1." {
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

@test "'index get_max_id' returns the max id number." {
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

@test "'index get_max_id' with empty notebook returns 0." {
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

@test "'index delete <filename>' deletes an item from the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete "$(ls "${NB_DIR}/home")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                        ]]
  [[ "$(cat "${NB_DIR}/home/.index")" == "" ]]
}

@test "'index delete' with no argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

@test "'index delete <filename>' with non-file returns 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
  }

  run "${_NB}" index delete 'not-a-file'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

# show ########################################################################

@test "'index show' prints index." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index show

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                  ]]
  [[ "${output}" == "$(cat "${NB_DIR}/home/.index")"  ]]
}

# update ######################################################################

@test "'index update <old> <new>' updates the index." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update "$(ls "${NB_DIR}/home")" "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf \
    "$(cat \"\$\{NB_DIR\}/home/.index\"): '%s'\\n" \
    "$(cat "${NB_DIR}/home/.index")"

  [[ ${status} -eq 0                                  ]]
  [[ "$(cat "${NB_DIR}/home/.index")" == "example.md" ]]
}

@test "'index update' with no arguments returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

@test "'index update' with first argument returns 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "# one"
  }

  run "${_NB}" index update "$(ls "${NB_DIR}/home")"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${lines[0]}" =~ Usage.*\: ]]
}

# verify ######################################################################

@test "'index verify' verifies a valid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf \
      "\"\$(cat \"\${NB_DIR}/home/.index\")\": '%s'\\n" \
      "$(cat "${NB_DIR}/home/.index")"
    printf "\$(ls \${NB_DIR}/home): '%s'\\n" "$(ls "${NB_DIR}/home")"

    [[ "$(cat "${NB_DIR}/home/.index")" == "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
}

@test "'index verify' returns 1 with an invalid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\\n" >> "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

@test "'index verify' returns 1 with a duplicates." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "second.md\\n" >> "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index verify

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
}

# help ########################################################################

@test "'help index' exits with status 0." {
  run "${_NB}" help index

  [[ ${status} -eq 0 ]]
}

@test "'help index' prints help information." {
  run "${_NB}" help index

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*\:                   ]]
  [[ "${lines[1]}" == "  nb index add <filename>" ]]
}
