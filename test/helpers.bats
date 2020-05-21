#!/usr/bin/env bats

load test_helper

# `_clear_cache()` ############################################################

@test "\`_clear_cache()\` clears the cache." {
  {
    "${_NB}" init
    mkdir -p "${NB_DIR}/.cache"
    echo "Example" > "${NB_DIR}/.cache/example"
    [[ -e "${NB_DIR}/.cache" ]]
  }


  run "${_NB}" notebooks add "example"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ -e "${NB_DIR}/.cache" ]]
  [[ -z "$(ls -A "${NB_DIR}/.cache")" ]]
}

# `_get_title()` ##############################################################

@test "\`_get_title()\` detects and returns titles." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
# Title One
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "two.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "three.md"
# Title Three
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "four.md"
---
summary: Example Summary
custom: variable
---
# Title Four
line six
line seven
line eight
HEREDOC
    cat <<HEREDOC | "${_NB}" add "five.md"
---
summary: Example Summary
title: Title Five
custom: variable
---
# Second Title Five
line seven
line eight
line nine
HEREDOC
    cat <<HEREDOC | "${_NB}" add "six.md"
---
summary: Example Summary
custom: variable
---
line five
line six
line seven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "seven.md"
Title Seven
===========

line four
line five
line six
HEREDOC
    cat <<HEREDOC | "${_NB}" add "eight.md"
---
summary: Example Summary
custom: variable
---

  Title Eight
  ===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "nine.md"
---
summary: Example Summary
custom: variable
---
Title Nine
===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "ten.md"
# Title Ten #
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "eleven.md"
[](https://example.com/example.png)

# Title Eleven
line two
line three
line four
HEREDOC
    # shellcheck disable=SC2006
    cat <<HEREDOC | "${_NB}" add "twelve.md"
[](https://example.com/example.png)

```text
# Example In Code Block
```

# Title Twelve
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "thirteen.org"
#+TITLE: Example Org Title

line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "fourteen.org"
#+TITLE: Example
#+TITLE: Multi-Line
#+TITLE: Org Title

line three
line four
HEREDOC

    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ "${lines[0]}"  == "[14] Example Multi-Line Org Title"  ]]
  [[ "${lines[1]}"  == "[13] Example Org Title"             ]]
  [[ "${lines[2]}"  == "[12] Title Twelve"                  ]]
  [[ "${lines[3]}"  == "[11] Title Eleven"                  ]]
  [[ "${lines[4]}"  == "[10] Title Ten"                     ]]
  [[ "${lines[5]}"  == "[9]  Title Nine"                    ]]
  [[ "${lines[6]}"  == "[8]  Title Eight"                   ]]
  [[ "${lines[7]}"  == "[7]  Title Seven"                   ]]
  [[ "${lines[8]}"  == "[6]  six.md · \"line five\""        ]]
  [[ "${lines[9]}"  == "[5]  Title Five"                    ]]
  [[ "${lines[10]}" == "[4]  Title Four"                    ]]
  [[ "${lines[11]}" == "[3]  Title Three"                   ]]
  [[ "${lines[12]}" == "[2]  two.md · \"line one\""         ]]
  [[ "${lines[13]}" == "[1]  Title One"                     ]]
}

# `_get_unique_basename()` ####################################################

@test "\`_get_unique_basename()\` works for notes" {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" add "example.md" --content "Example"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-1.md ]]

  run "${_NB}" add "example.md" --content "Example"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-2.md ]]
}

@test "\`_get_unique_basename()\` works for bookmarks" {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" --content "<https://example.com>"
  }

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-1.bookmark.md ]]

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-2.bookmark.md ]]
}
