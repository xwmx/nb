#!/usr/bin/env bats

load test_helper

# reconcile ###################################################################

@test "\`index reconcile\` does not modify a valid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf \
      "\"\$(cat \"\${_NOTEBOOK_PATH}/.index\")\": '%s'\\n" \
      "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "\$(ls -r \${_NOTEBOOK_PATH}): '%s'\\n" "$(ls "${_NOTEBOOK_PATH}")"

    _existing_index="$(cat "${_NOTEBOOK_PATH}/.index")"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" index verify

  [[ ${status} -eq 0                                              ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "${_existing_index}"  ]]
}

@test "\`index reconcile\` updates when file has been deleted." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\n" >> "${_NOTEBOOK_PATH}/.index"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"

  [[ ${status} -eq 0                                      ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ not-a-file  ]]

  "${_NB}" index verify
}

@test "\`index reconcile\` updates when file has been added." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    echo "# Example" > "${_NOTEBOOK_PATH}/example.md"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls "${_NOTEBOOK_PATH}")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"

  [[ ${status} -eq 0                                    ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" =~ example.md  ]]

  "${_NB}" index verify
}

@test "\`index reconcile\` updates when files have been added and deleted." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    printf "\\n" >> "${_NOTEBOOK_PATH}/.index"
    printf "\\n" >> "${_NOTEBOOK_PATH}/.index"

    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\\n"    >> "${_NOTEBOOK_PATH}/.index"
    printf "also-no-file\\n"  >> "${_NOTEBOOK_PATH}/.index"
    echo "# Example"            > "${_NOTEBOOK_PATH}/example.md"
    echo "# Sample"           > "${_NOTEBOOK_PATH}/sample.md"

    # NOTE: `index get_id` calls `reconcile` when filename is not found.
    printf "first.md id: %s\\n"   "$("${_NB}" index get_id "first.md")"
    printf "second.md id: %s\\n"  "$("${_NB}" index get_id "second.md")"

    if sed --help >/dev/null 2>&1
    then
      sed -i -e "s/^first.md$//g" "${_NOTEBOOK_PATH}/.index"
    else
      sed -i '' -e "s/^first.md$//g" "${_NOTEBOOK_PATH}/.index"
    fi

    printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"
    printf "ls: '%s'\\n" "$(ls "${_NOTEBOOK_PATH}")"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls "${_NOTEBOOK_PATH}")" ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ first.md     ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ sample.md    ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"  =~ sample.md    ]]
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ not-a-file   ]]
    [[ "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ also-no-file ]]
    [[ "$("${_NB}" index get_id "second.md")" == '4'          ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/.index"

  [[ ${status} -eq 0                                          ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"      =~ first.md     ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"      =~ example.md   ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")"      =~ sample.md    ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ not-a-file   ]]
  [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")"    =~ also-no-file ]]
  [[ "$("${_NB}" index get_id "second.md")"   == '4'          ]]
  [[ "$("${_NB}" index get_id "example.md")"  == '7'          ]]
  [[ "$("${_NB}" index get_id "first.md")"    == '8'          ]]
  [[ "$("${_NB}" index get_id "sample.md")"   == '9'          ]]

  "${_NB}" index verify
}
