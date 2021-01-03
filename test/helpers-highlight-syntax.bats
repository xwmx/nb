#!/usr/bin/env bats

load test_helper

@test "'_highlight_syntax_if_available()' with piped content and no arguments highlights as Markdown." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | ${_NB} helpers highlight_syntax"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0          ]]
  [[    "${lines[0]}"  =~  Piped      ]]
  [[ !  "${lines[0]}"  ==  "# Piped"  ]]

  diff                              \
    <(printf "%s\\n" "${lines[0]}") \
    <(printf "%s\\n" "# Piped")     \
    || true
}

@test "'_highlight_syntax_if_available()' with piped content and language argument highlights as language." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | ${_NB} helpers highlight_syntax txt"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0          ]]
  [[    "${lines[0]}"  =~  Piped      ]]

  diff                                                    \
    <(printf "%s\\n" "${lines[0]}")                       \
    <(echo '# Piped' | "${_NB}" helpers highlight_syntax) \
    || true
}


@test "'_highlight_syntax_if_available()' with <path> highlights as extension." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      --filename  "Example File.md" \
      --title     "Example Title"   \
      --content   "Example content with *formatting*."
  }

  run "${_NB}" helpers highlight_syntax "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                              ]]
  [[    "${lines[0]}"  =~  \#.*Example\ Title                             ]]
  [[ !  "${lines[0]}"  ==  "# Example Title"                              ]]
  [[    "${lines[1]}"  =~  Example\ content\ with.*\*.*formatting.*\*.*\. ]]
  [[ !  "${lines[1]}"  ==  "Example content with *formatting*."           ]]

  diff                                                                    \
    <(printf "%s\\n" "${output}")                                         \
    <("${_NB}" helpers highlight_syntax "${NB_DIR}/home/Example File.md")
}

@test "'_highlight_syntax_if_available()' with .db extension skips --language option." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      --filename  "Example File.md" \
      --title     "Example Title"   \
      --content   "Example content with *formatting*."

    "${_NB}" add                    \
      --filename  "Example File.db" \
      --title     "Example Title"   \
      --content   "Example content with *formatting*."
  }

  run "${_NB}" helpers highlight_syntax "${NB_DIR}/home/Example File.db"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                              ]]
  [[    "${lines[0]}"  =~  \#.*Example\ Title                             ]]
  [[ !  "${lines[0]}"  ==  "# Example Title"                              ]]
  [[    "${lines[1]}"  =~  Example\ content\ with.*\*.*formatting.*\*.*\. ]]
  [[ !  "${lines[1]}"  ==  "Example content with *formatting*."           ]]

  diff                                                                    \
    <(printf "%s\\n" "${output}")                                         \
    <("${_NB}" helpers highlight_syntax "${NB_DIR}/home/Example File.md") \
    || true
}
