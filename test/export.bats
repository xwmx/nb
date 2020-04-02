#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`export\` with no arguments exits with status 1 and prints help." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add
  }

  run "${_NOTES}" export
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[1]}" =~ '  notes export' ]]
}

# <id> ######################################################################

@test "\`export\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Export Example"
  }

  run "${_NOTES}" export 1 "${_TMP_DIR}/example.md"
  cat "${_TMP_DIR}/example.md"
  [[ -e "${_TMP_DIR}/example.md" ]]
  [[ $(grep '# Export Example' "${_TMP_DIR}/example.md") ]]
}

@test "\`export\` with valid <id> and <path> with diff file type converts." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Export Example"
  }

  run "${_NOTES}" export 1 "${_TMP_DIR}/example.html"
  cat "${_TMP_DIR}/example.html"
  [[ -e "${_TMP_DIR}/example.html" ]]
  [[ $(grep 'DOCTYPE html' "${_TMP_DIR}/example.html") ]]
}

# `pandoc <id>` ###############################################################

@test "\`export pandoc\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add "# Export Example"
  }

  run "${_NOTES}" export pandoc 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ '<h1 id="export-example">Export Example</h1>' ]]
}

@test "\`export pandoc\` with invalid <id> returns error." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" export pandoc 100
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Note not found' ]]
}

# help ########################################################################

@test "\`help export\` returns usage information." {
  run "${_NOTES}" help export
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ '  notes export' ]]
}


