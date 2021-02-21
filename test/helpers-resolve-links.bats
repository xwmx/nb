#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'_resolve_links' return status 1 and prints nothing when passed blank arguments." {
  {
    "${_NB}" init
  }

  run "${_NB}" helpers resolve_links "" ""

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_links' return status 1 and prints nothing when notebook path is omitted." {
  {
    "${_NB}" init

    "${_NB}" add --title "Example File" --content "Example content."
  }

  run "${_NB}" helpers resolve_links "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

@test "'_resolve_links' return status 1 and prints nothing when file not found." {
  {
    "${_NB}" init
  }

  run "${_NB}" helpers resolve_links  \
    "${NB_DIR}/home/not-a-file.html"  \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

# .html #######################################################################

@test "'_resolve_links --browse' with .html includes pagination params in tag links." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                          \
      --from=markdown               \
      --to=html                     \
      --output="${_html_file_path}" \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links  \
    --browse                          \
    "${_html_file_path}"              \
    "${NB_DIR}/home"                  \
    --page 123 --per-page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: <a.* href=\"http://localhost:6789/home:2/1?--per-page=2\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: <a.* href=\"http://localhost:6789/home:3?--per-page=2\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: <a.* href=\"http://localhost:6789/home:?--per-page=2&--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: <a.* href=\"http://localhost:6789/home:?--per-page=2&--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "<p><a.* href=\"http://localhost:6789/home:?--per-page=2&--query=%23tag3\">#tag3</a></p>"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]] and tags in partial .html files to .html links to local web server URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                          \
      --from=markdown               \
      --to=html                     \
      --output="${_html_file_path}" \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links  \
    --browse                          \
    "${_html_file_path}"              \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: <a.* href=\"http://localhost:6789/home:2/1\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: <a.* href=\"http://localhost:6789/home:3\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: <a.* href=\"http://localhost:6789/home:?--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: <a.* href=\"http://localhost:6789/home:?--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "<p><a.* href=\"http://localhost:6789/home:?--query=%23tag3\">#tag3</a></p>"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]] and tags in standalone .html files to .html links to local web server URLs without altering CSS values." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                          \
      --from=markdown               \
      --to=html                     \
      --output="${_html_file_path}" \
      --standalone                  \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links  \
    --browse                          \
    "${_html_file_path}"              \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: <a.* href=\"http://localhost:6789/home:2/1\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: <a.* href=\"http://localhost:6789/home:3\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: <a.* href=\"http://localhost:6789/home:?--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: <a.* href=\"http://localhost:6789/home:?--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "<p><a.* href=\"http://localhost:6789/home:?--query=%23tag3\">#tag3</a></p>"

  printf "%s\\n" "${output}" | grep -q \
    "color: \#1a1a1a;"
}

@test "'_resolve_links' resolves [[wiki-style links]] in partial .html files to .html links to local file URLs without linking tags." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                          \
      --from=markdown               \
      --to=html                     \
      --output="${_html_file_path}" \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links  \
    "${_html_file_path}"              \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: <a.* href=\"file://${NB_DIR}/home/Example Folder/Example Nested File One.md\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: <a.* href=\"file://${NB_DIR}/home/Root File One.md\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q \
    "<p>#tag3</p>"
}

@test "'_resolve_links' resolves [[wiki-style links]] in standalone .html files to .html links to local file URLs without linking tags or altering CSS values." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                          \
      --from=markdown               \
      --to=html                     \
      --output="${_html_file_path}" \
      --standalone                  \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links  \
    "${_html_file_path}"              \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: <a.* href=\"file://${NB_DIR}/home/Example Folder/Example Nested File One.md\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: <a.* href=\"file://${NB_DIR}/home/Root File One.md\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q \
    "<p>#tag3</p>"

  printf "%s\\n" "${output}" | grep -q \
    "color: \#1a1a1a;"
}

# .org ########################################################################

@test "'_resolve_links --browse' with .org includes pagination params in tag links." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links                          \
    --browse                                                  \
    "${NB_DIR}/home/Sample Folder/Sample Nested File One.org" \
    "${NB_DIR}/home"                                          \
    --page 123 --per-page 2 --terminal

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: \[\[http://localhost:6789/home:2/1?--per-page=2\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: \[\[http://localhost:6789/home:3?--per-page=2\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: \[\[http://localhost:6789/home:?--per-page=2&--query=%23tag_1\]\[#tag_1\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: \[\[http://localhost:6789/home:?--per-page=2&--query=%23tag-2\]\[#tag-2\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link: \[\[http://example.com\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link with description: \[\[http://example.com\]\[Example Description\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "^\[\[http://localhost:6789/home:?--per-page=2&--query=%23tag3\]\[#tag3\]\]$"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]] and #tags in .org files to .org links to local web server URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links                          \
    --browse                                                  \
    "${NB_DIR}/home/Sample Folder/Sample Nested File One.org" \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: \[\[http://localhost:6789/home:2/1\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: \[\[http://localhost:6789/home:3\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: \[\[http://localhost:6789/home:?--query=%23tag_1\]\[#tag_1\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: \[\[http://localhost:6789/home:?--query=%23tag-2\]\[#tag-2\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link: \[\[http://example.com\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link with description: \[\[http://example.com\]\[Example Description\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "^\[\[http://localhost:6789/home:?--query=%23tag3\]\[#tag3\]\]$"
}

@test "'_resolve_links' resolves [[wiki-style links]] in .org files to .org links to local file URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links                          \
    "${NB_DIR}/home/Sample Folder/Sample Nested File One.org" \
    "${NB_DIR}/home"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q \
    "Selector link one: \[\[file://${NB_DIR}/home/Example Folder/Example Nested File One.md\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Selector link two: \[\[file://${NB_DIR}/home/Root File One.md\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q \
    "Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link: \[\[http://example.com\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Org mode link with description: \[\[http://example.com\]\[Example Description\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q \
    "^#tag3$"
}
