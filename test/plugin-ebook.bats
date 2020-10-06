#!/usr/bin/env bats

load test_helper

# `ebook init <name>` #########################################################

@test "\`ebook init <name>\` creates new ebook notebook." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook init "example-ebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0                               ]]
  [[ "${lines[0]}" =~ Added\ notebook               ]]
  [[ "${lines[0]}" =~ example-ebook                 ]]
  [[ -d "${NB_DIR}/example-ebook"                   ]]

  [[ "${lines[1]}" =~ Added:                        ]]
  [[ "${lines[1]}" =~ example-ebook:1               ]]
  [[ "${lines[1]}" =~ example-ebook:title.txt       ]]
  [[ -f "${NB_DIR}/example-ebook/title.txt"         ]]

  [[ "${lines[2]}" =~ Added:                        ]]
  [[ "${lines[2]}" =~ example-ebook:2               ]]
  [[ "${lines[2]}" =~ example-ebook:stylesheet.css  ]]
  [[ -f "${NB_DIR}/example-ebook/stylesheet.css"    ]]

  [[ "${lines[3]}" =~ Added:                        ]]
  [[ "${lines[3]}" =~ example-ebook:3               ]]
  [[ "${lines[3]}" =~ example-ebook:01-chapter1.md  ]]
  [[ -f "${NB_DIR}/example-ebook/01-chapter1.md"    ]]

  [[ "${lines[4]}" =~ Ebook\ initialized:           ]]
  [[ "${lines[4]}" =~ example-ebook                 ]]
}

@test "\`ebook init\` sets up current notebook as ebook." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add example
    run "${_NB}" use example

    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook init --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  echo "ls example:"
  ls "${NB_DIR}/example"
  echo "ls home:"
  ls "${NB_DIR}/home"

  [[ "${status}" == 0                         ]]

  [[ "${lines[0]}" =~ Adding\ the\ following  ]]
  [[ "${lines[0]}" =~ current\ notebook       ]]
  [[ "${lines[1]}" =~ title.txt               ]]
  [[ "${lines[2]}" =~ stylesheet.css          ]]
  [[ "${lines[3]}" =~ 01-chapter1.md          ]]

  [[ "${lines[4]}" =~ Added:                  ]]
  [[ "${lines[4]}" =~ 1                       ]]
  [[ "${lines[4]}" =~ title.txt               ]]
  [[ -f "${NB_DIR}/example/title.txt"         ]]

  [[ "${lines[5]}" =~ Added:                  ]]
  [[ "${lines[5]}" =~ 2                       ]]
  [[ "${lines[5]}" =~ stylesheet.css          ]]
  [[ -f "${NB_DIR}/example/stylesheet.css"    ]]

  [[ "${lines[6]}" =~ Added:                  ]]
  [[ "${lines[6]}" =~ 3                       ]]
  [[ "${lines[6]}" =~ 01-chapter1.md          ]]
  [[ -f "${NB_DIR}/example/01-chapter1.md"    ]]

  [[ "${lines[7]}" =~ Ebook\ initialized:     ]]
  [[ "${lines[7]}" =~ example                 ]]
}

@test "\`ebook init <existing>\` sets up <existing> notebook as ebook." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add example
    run "${_NE}" example

    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook init example --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Adding\ the\ following  ]]
  [[ "${lines[0]}" =~ example                 ]]
  [[ "${lines[1]}" =~ title.txt               ]]
  [[ "${lines[2]}" =~ stylesheet.css          ]]
  [[ "${lines[3]}" =~ 01-chapter1.md          ]]

  [[ "${status}" == 0                         ]]
  [[ "${lines[4]}" =~ Added:                  ]]
  [[ "${lines[4]}" =~ example:1               ]]
  [[ "${lines[4]}" =~ example:title.txt       ]]
  [[ -f "${NB_DIR}/example/title.txt"         ]]

  [[ "${lines[5]}" =~ Added:                  ]]
  [[ "${lines[5]}" =~ example:2               ]]
  [[ "${lines[5]}" =~ example:stylesheet.css  ]]
  [[ -f "${NB_DIR}/example/stylesheet.css"    ]]

  [[ "${lines[6]}" =~ Added:                  ]]
  [[ "${lines[6]}" =~ example:3               ]]
  [[ "${lines[6]}" =~ example:01-chapter1.md  ]]
  [[ -f "${NB_DIR}/example/01-chapter1.md"    ]]

  [[ "${lines[7]}" =~ Ebook\ initialized:     ]]
  [[ "${lines[7]}" =~ example                 ]]
}

# `ebook publish` #############################################################

@test "\`ebook publish\` generates epub file." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"
    run "${_NB}" ebook new "example-ebook"
    run "${_NB}" use "example-ebook"

    # Add chapters out of order to validate final ordering.
    run "${_NB}" add              \
      --filename "03-chapter3.md" \
      --title "Chapter Three"     \
      --content "Content three."

    run "${_NB}" add              \
      --filename "02-chapter2.md" \
      --title "Chapter Two"       \
      --content "Content two."

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook publish

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                  ]]
  [[ "${lines[0]}" =~ Added\:                         ]]
  [[ "${lines[0]}" =~ example-ebook.epub              ]]
  [[ -f "${NB_DIR}/example-ebook/example-ebook.epub"  ]]

  _markdown="$(
    pandoc -f epub -t html "${NB_DIR}/example-ebook/example-ebook.epub" \
      | pandoc -f html-native_divs-native_spans -t markdown_strict
  )"

  printf "\${_markdown}: '%s'\\n" "${_markdown}"
  _expected="Chapter One
===========

Chapter Two
===========

Content two.

Chapter Three
=============

Content three."

  [[ "${_markdown}" == "${_expected}" ]]
}

# help ########################################################################

@test "\`ebook\` with no argument exits with status 1 and prints usage." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Usage\:     ]]
  [[ "${lines[1]}" =~ nb\ ebook   ]]
}

@test "\`help ebook\` exits with status 0 and prints usage." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" help ebook

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ Usage\:     ]]
  [[ "${lines[1]}" =~ nb\ ebook   ]]
}

