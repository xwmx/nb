#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`export\` with no arguments exits with status 1 and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" add
  }

  run "${_NB}" export
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[1]}" =~ '  nb export' ]]
}

# <id> ######################################################################

@test "\`export\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.md"
  cat "${_TMP_DIR}/example.md"
  [[ -e "${_TMP_DIR}/example.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/example.md"
}

@test "\`export\` with valid <id> and <path> with diff file type converts." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.html"
  cat "${_TMP_DIR}/example.html"
  [[ -e "${_TMP_DIR}/example.html" ]]
  grep -q 'DOCTYPE html' "${_TMP_DIR}/example.html"
}

# `pandoc <id>` ###############################################################

@test "\`export pandoc\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export pandoc 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ '<h1 id="export-example">Export Example</h1>' ]]
}

@test "\`export pandoc\` with invalid <id> returns error." {
  {
    run "${_NB}" init
  }

  run "${_NB}" export pandoc 100
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Note not found' ]]
}

# help ########################################################################

@test "\`help export\` returns usage information." {
  run "${_NB}" help export
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ '  nb export' ]]
}
