#!/usr/bin/env bats

load test_helper

# reconcile ###################################################################

@test "'index reconcile' does not modify a valid index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf \
      "\"\$(cat \"\${NB_DIR}/home/.index\")\": '%s'\\n" \
      "$(cat "${NB_DIR}/home/.index")"
    printf "\$(ls -r \${NB_DIR}/home): '%s'\\n" "$(ls "${NB_DIR}/home")"

    _existing_index="$(cat "${NB_DIR}/home/.index")"

    [[ "$(cat "${NB_DIR}/home/.index")" == "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" index verify

  [[ ${status} -eq 0                                              ]]
  [[ "$(cat "${NB_DIR}/home/.index")" == "${_existing_index}"  ]]
}

@test "'index reconcile' updates when file has been deleted." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\n" >> "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/.index"

  [[ ${status} -eq 0                                      ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ not-a-file  ]]

  "${_NB}" index verify
}

@test "'index reconcile' updates when file has been added." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"

    echo "# Example" > "${NB_DIR}/home/example.md"

    [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls "${NB_DIR}/home")" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ example.md ]]

  "${_NB}" index verify
}

@test "'index reconcile' updates when files have been added and deleted." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"

    printf "\\n" >> "${NB_DIR}/home/.index"
    printf "\\n" >> "${NB_DIR}/home/.index"

    "${_NB}" add "second.md" --title "two"

    printf "not-a-file\\n"    >> "${NB_DIR}/home/.index"
    printf "also-no-file\\n"  >> "${NB_DIR}/home/.index"
    echo "# Example"            > "${NB_DIR}/home/example.md"
    echo "# Sample"           > "${NB_DIR}/home/sample.md"

    # NOTE: `index get_id` calls `reconcile` when filename is not found.
    printf "first.md id: %s\\n"   "$("${_NB}" index get_id "first.md")"
    printf "second.md id: %s\\n"  "$("${_NB}" index get_id "second.md")"

    if sed --help >/dev/null 2>&1
    then
      sed -i -e "s/^first.md$//g" "${NB_DIR}/home/.index"
    else
      sed -i '' -e "s/^first.md$//g" "${NB_DIR}/home/.index"
    fi

    printf ".index: '%s'\\n" "$(cat "${NB_DIR}/home/.index")"
    printf "ls: '%s'\\n" "$(ls "${NB_DIR}/home")"

    [[    "$(cat "${NB_DIR}/home/.index")"        != "$(ls "${NB_DIR}/home")" ]]
    [[ !  "$(cat "${NB_DIR}/home/.index")"        =~ first.md                 ]]
    [[ !  "$(cat "${NB_DIR}/home/.index")"        =~ sample.md                ]]
    [[ !  "$(cat "${NB_DIR}/home/.index")"        =~ sample.md                ]]
    [[    "$(cat "${NB_DIR}/home/.index")"        =~ not-a-file               ]]
    [[    "$(cat "${NB_DIR}/home/.index")"        =~ also-no-file             ]]
    [[    "$("${_NB}" index get_id "second.md")"  == '4'                      ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/.index"

  [[    ${status} -eq 0                                         ]]
  [[    "$(cat "${NB_DIR}/home/.index")"        =~ first.md     ]]
  [[    "$(cat "${NB_DIR}/home/.index")"        =~ example.md   ]]
  [[    "$(cat "${NB_DIR}/home/.index")"        =~ sample.md    ]]
  [[ !  "$(cat "${NB_DIR}/home/.index")"        =~ not-a-file   ]]
  [[ !  "$(cat "${NB_DIR}/home/.index")"        =~ also-no-file ]]
  [[    "$("${_NB}" index get_id "second.md")"  == '4'          ]]
  [[    "$("${_NB}" index get_id "example.md")" == '7'          ]]
  [[    "$("${_NB}" index get_id "first.md")"   == '8'          ]]
  [[    "$("${_NB}" index get_id "sample.md")"  == '9'          ]]

  "${_NB}" index verify
}
