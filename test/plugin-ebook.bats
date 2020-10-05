#!/usr/bin/env bats

load test_helper

# `ebook new <name>` ##########################################################

@test "\`ebook new <name>\` creates new ebook notebook." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook new "example-ebook"

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

  [[ "${lines[4]}" =~ Created:                      ]]
  [[ "${lines[4]}" =~ example-ebook                 ]]
}

@test "\`ebook new\` with no name exits with status 1 and prints usage." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/ebook.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" ebook new

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Usage\:     ]]
  [[ "${lines[1]}" =~ nb\ ebook   ]]
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

