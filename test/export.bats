#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`export\` with no arguments exits with status 1 and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" add
  }

  run "${_NB}" export

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                ]]
  [[ "${lines[1]}" =~ '  nb export' ]]
}

# <id> ######################################################################

@test "\`export\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -e "${_TMP_DIR}/example.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/example.md"
}

@test "\`export\` with valid <id> and directory <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example" --filename "example.md"
  }

  run "${_NB}" export 1 "${_TMP_DIR}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -e "${_TMP_DIR}/example.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/example.md"
}

@test "\`export\` with valid <id> and different basename <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example" --filename "example.md"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/sample.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"
  cat "${_TMP_DIR}/sample.md"

  [[ -e "${_TMP_DIR}/sample.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/sample.md"
}

@test "\`export\` with valid <id> and <path> with diffferent file type converts." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.html"

  cat "${_TMP_DIR}/example.html"

  [[ -e "${_TMP_DIR}/example.html" ]]
  grep -q 'DOCTYPE html' "${_TMP_DIR}/example.html"
}

# `notebook` ##################################################################

@test "\`export notebook\` with valid <name> and <path> exports." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "example"
    [[ -d "${NB_DIR}/example" ]]
    [[ ! -d "${_TMP_DIR}/example" ]]
  }

  run "${_NB}" export notebook "example" "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"

  [[ ${status} -eq 0                ]]
  [[ -d "${_TMP_DIR}/example"       ]]
  [[ -d "${_TMP_DIR}/example/.git"  ]]
  [[ "${lines[0]}" =~ "Exported"    ]]
}

# `pandoc <id>` ###############################################################

@test "\`export pandoc\` with valid <id> and <path> exports a new note file." {
  {
    run "${_NB}" init
    run "${_NB}" add "# Export Example"
  }

  run "${_NB}" export pandoc 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                              ]]
  [[ "${output}" =~ '<h1 id="export-example">Export Example</h1>' ]]
}

@test "\`export pandoc\` with invalid <id> returns error." {
  {
    run "${_NB}" init
  }

  run "${_NB}" export pandoc 100

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${output}" =~ 'Not found' ]]
}

# help ########################################################################

@test "\`help export\` returns usage information." {
  run "${_NB}" help export

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" == "Usage:"      ]]
  [[ "${lines[1]}" =~ '  nb export' ]]
}
