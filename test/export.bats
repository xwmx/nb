#!/usr/bin/env bats

load test_helper

# edge cases ##################################################################

@test "'export pandoc' with front matter title containing a colon requires quotes around title." {
  {
    "${_NB}" init

    "${_NB}" add                      \
        --filename  "Example File.md" \
        --content   "$(cat <<HEREDOC
---
title: 20240101010101 - Example Title Prefix: Example Title Content
public: true
date: 2024-01-01T01:01:01.010101+00:00
id: 20240101010101
---

# Example Title Content

<https://example.com>
HEREDOC
)"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0               ]]

  [[ ! -e "${_TMP_DIR}/example.html"    ]]

  [[    "${output}" =~ YAML             ]]

  [[ !  "${output}" =~ Exported         ]]
  [[ !  "${output}" =~ Example\ File    ]]

  {
    "${_NB}" add                      \
        --filename  "Example File.md" \
        --content   "$(cat <<HEREDOC
---
title: "20240101010101 - Example Title Prefix: Example Title Content"
public: true
date: 2024-01-01T01:01:01.010101+00:00
id: 20240101010101
---

# Example Title Content

<https://example.com>
HEREDOC
)"
  }

  run "${_NB}" export 2 "${_TMP_DIR}/example.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0               ]]

  cat "${_TMP_DIR}/example.html"

  [[ -e "${_TMP_DIR}/example.html"      ]]
  grep -q 'DOCTYPE html' "${_TMP_DIR}/example.html"

  [[ !  "${output}" =~ YAML             ]]

  [[    "${output}" =~ Exported         ]]
  [[    "${output}" =~ Example\ File-1  ]]
}

# embedded resources ##########################################################

@test "'export pandoc --self-contained' with reference to image in same directory embeds image." {
  {
    "${_NB}" init
    "${_NB}" add                                                      \
      --content   "# Export Example${_NEWLINE}${_NEWLINE}![](nb.png)" \
      --filename  "Example File.md"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"


    [[ -f "${NB_DIR}/home/Example File.md"  ]]
    [[ -f "${NB_DIR}/home/nb.png"           ]]
  }

  run "${_NB}" export pandoc 1 --self-contained <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ \<p\>\<img\ role=\"img\"\ src=\"data:image/png\;base64,iVBORw0KGgoAAAA ]]

  run ! diff                      \
    <(printf "%s\\n" "${output}") \
    <(cat <<HEREDOC
[WARNING] Could not fetch resource nb.png
<h1 id="export-example">Export Example</h1>
<p><img src="nb.png" /></p>
HEREDOC
    )
}

@test "'export --self-contained' with reference to image in same directory embeds image." {
  {
    "${_NB}" init
    "${_NB}" add                                                      \
      --content   "# Export Example${_NEWLINE}${_NEWLINE}![](nb.png)" \
      --filename  "Example File.md"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"


    [[ -f "${NB_DIR}/home/Example File.md"  ]]
    [[ -f "${NB_DIR}/home/nb.png"           ]]
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.html" --self-contained <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(cat "${_TMP_DIR}/example.html")" =~ \<p\>\<img\ role=\"img\"\ src=\"data:image/png\;base64,iVBORw0KGgoAAAA ]]
}

# existing file ###############################################################

@test "'export' with file at export path prompts user to confirm overwrite." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "# Export Example"

    echo "Example existing content." >> "${_TMP_DIR}/example.md"

    [[ -f "${NB_DIR}/home/Example File.md"  ]]
    [[ -f "${_TMP_DIR}/example.md"          ]]
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.md" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls  "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -f "${_TMP_DIR}/example.md" ]]

  grep -q '# Export Example' "${_TMP_DIR}/example.md"

  diff                              \
    <(cat "${_TMP_DIR}/example.md") \
    <(cat "${NB_DIR}/home/Example File.md")

  [[ "${output}" =~ Exported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'export' with file at export path and non-affirmative prompt response exits without overwriting." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "# Export Example"

    echo "Example existing content." >> "${_TMP_DIR}/example.md"

    [[ -f "${NB_DIR}/home/Example File.md"  ]]
    [[ -f "${_TMP_DIR}/example.md"          ]]
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.md" <<< "n${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls  "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -f "${_TMP_DIR}/example.md" ]]

  grep -q -v '# Export Example' "${_TMP_DIR}/example.md"

  diff                              \
    <(cat "${_TMP_DIR}/example.md") \
    <(printf "Example existing content.\\n")

  [[ "${lines[0]}" =~ File\ exists\ at\ .*${_TMP_DIR}/example.md  ]]
  [[ "${lines[1]}" =~ Exiting.*\.\.\.                             ]]
}

# no argument #################################################################

@test "'export' with no arguments exits with status 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add
  }

  run "${_NB}" export

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1               ]]
  [[ "${lines[0]}" =~ Usage           ]]
  [[ "${lines[1]}" =~ \ \ nb\ export  ]]
}

# <id> ######################################################################

@test "'export' with valid <id> and <path> exports a new note file." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "# Export Example"

    [[ -f "${NB_DIR}/home/Example File.md" ]]
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls  "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -f "${_TMP_DIR}/example.md" ]]

  grep -q '# Export Example' "${_TMP_DIR}/example.md"

  diff                              \
    <(cat "${_TMP_DIR}/example.md") \
    <(cat "${NB_DIR}/home/Example File.md")

  [[ "${output}" =~ Exported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'export' with valid <id> and directory <path> exports a new note file." {
  {
    "${_NB}" init
    "${_NB}" add "# Export Example" --filename "example.md"
  }

  run "${_NB}" export 1 "${_TMP_DIR}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"
  cat "${_TMP_DIR}/example.md"

  [[ -e "${_TMP_DIR}/example.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/example.md"

  # Prints output
  [[ "${output}" =~ Exported    ]]
  [[ "${output}" =~ example.md  ]]
}

@test "'export' with valid <id> and different basename <path> exports a new note file." {
  {
    "${_NB}" init
    "${_NB}" add "# Export Example" --filename "example.md"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/sample.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls "${_TMP_DIR}"
  cat "${_TMP_DIR}/sample.md"

  [[ -e "${_TMP_DIR}/sample.md" ]]
  grep -q '# Export Example' "${_TMP_DIR}/sample.md"

  # Prints output
  [[ "${output}" =~ Exported    ]]
  [[ "${output}" =~ example.md  ]]
  [[ "${output}" =~ sample.md   ]]
}

@test "'export' with valid <id> and <path> to HTML file type converts." {
  {
    "${_NB}" init
    "${_NB}" add "# Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.html"

  cat "${_TMP_DIR}/example.html"

  [[ -e "${_TMP_DIR}/example.html" ]]
  grep -q 'DOCTYPE html' "${_TMP_DIR}/example.html"

  # Prints output
  [[ "${output}" =~ Exported        ]]
  [[ "${output}" =~ Export\ Example ]]
  [[ "${output}" =~ example.html    ]]
}

@test "'export' with valid <id> and <path> to docx file type converts." {
  {
    "${_NB}" init
    "${_NB}" add --title "Export Example"
  }

  run "${_NB}" export 1 "${_TMP_DIR}/example.docx"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  file "${_TMP_DIR}/example.docx"

  [[ -e "${_TMP_DIR}/example.docx"                            ]]
  [[ "$(file "${_TMP_DIR}/example.docx")" =~ Microsoft\ Word  ]]

  # Prints output

  [[ "${lines[0]}" =~ \
^Exported:\ .*\[.*1.*\].*\ .*export_example\.md.*\ \"Export\ Example\"$ ]]
  [[ "${lines[1]}" =~ \
^To:\ \ \ \ \ \ \ \ .*${_TMP_DIR}/example.docx.*$                       ]]
}

# `notebook` ##################################################################

@test "'export notebook' with valid <name> and <path> exports." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "example"

    [[ -d "${NB_DIR}/example"     ]]
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

@test "'export pandoc' with valid <id> and <path> exports a new note file." {
  {
    "${_NB}" init
    "${_NB}" add "# Export Example"
  }

  run "${_NB}" export pandoc 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                              ]]
  [[ "${output}" =~ '<h1 id="export-example">Export Example</h1>' ]]
}

@test "'export pandoc' with invalid <id> returns error." {
  {
    "${_NB}" init
  }

  run "${_NB}" export pandoc 100

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1            ]]
  [[ "${output}" =~ 'Not found' ]]
}

# help ########################################################################

@test "'help export' returns usage information." {
  run "${_NB}" help export

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*:      ]]
  [[ "${lines[1]}" =~ '  nb export' ]]
}
