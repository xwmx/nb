#!/usr/bin/env bats

load test_helper

# reconcile ###################################################################

@test "'index reconcile' skips common temporary files when .index is not present." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Example content one."
    sleep 1

    "${_NB}" add "File Two.md"    --content "Example content two."
    sleep 1

    "${_NB}" add "File Three.md"  --content "Example content three."
    sleep 1

    declare _temp_filenames=(
      "Example Temp One.md~"
      "#Example Temp Two.md#"
      "Example Temp Three.md.swp"
      "Example Temp Four.md.swap"
      ".#Example Temp Five.md"
    )

    declare __filename=
    for     __filename in "${_temp_filenames[@]:-}"
    do
      "${_NB}" run touch "${__filename:-}"

      [[ -f "${NB_DIR}/home/${__filename:-}" ]]
    done

    rm "${NB_DIR}/home/.index"

    [[ ! -e "${NB_DIR}/home/.index" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "LS: \\n"

  ls -t -r "${NB_DIR}/home"

  printf "INDEX: \\n"

  cat "${NB_DIR}/home/.index"

  [[ "${status}" -eq 0 ]]

  diff                              \
    <(cat "${NB_DIR}/home/.index")  \
    <(cat <<HEREDOC
File One.md
File Two.md
File Three.md
HEREDOC
    )
}

@test "'index reconcile' skips common temporary files when empty .index exists." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Example content one."
    sleep 1

    "${_NB}" add "File Two.md"    --content "Example content two."
    sleep 1

    "${_NB}" add "File Three.md"  --content "Example content three."
    sleep 1

    declare _temp_filenames=(
      "Example Temp One.md~"
      "#Example Temp Two.md#"
      "Example Temp Three.md.swp"
      "Example Temp Four.md.swap"
      ".#Example Temp Five.md"
    )

    declare __filename=
    for     __filename in "${_temp_filenames[@]:-}"
    do
      "${_NB}" run touch "${__filename:-}"

      [[ -f "${NB_DIR}/home/${__filename:-}" ]]
    done

    echo "" > "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" == "" ]]
  }

  run "${_NB}" index reconcile

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "LS: \\n"

  ls -t -r "${NB_DIR}/home"

  printf "INDEX: \\n"

  cat "${NB_DIR}/home/.index"

  [[ "${status}" -eq 0 ]]

  diff                              \
    <(cat "${NB_DIR}/home/.index")  \
    <(cat <<HEREDOC

File One.md
File Three.md
File Two.md
HEREDOC
    )
}

@test "'index reconcile' does not create a git commit." {
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

  [[ "${status}" -eq 0                              ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ example.md ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(git status --porcelain)"                 ]]

  "${_NB}" index verify
}

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

  [[ "${status}" -eq 0                                        ]]
  [[ "$(cat "${NB_DIR}/home/.index")" == "${_existing_index}" ]]
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

  [[ "${status}" -eq 0                                ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ not-a-file ]]

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

  [[ "${status}" -eq 0                                ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ example.md   ]]

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
    echo "# Example"          > "${NB_DIR}/home/example.md"
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
