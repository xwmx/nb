#!/usr/bin/env bats

load test_helper

# `_clear_notes_cache()` ######################################################

@test "\`_clear_notes_cache()\` clears the notes cache." {
  {
    "${_NOTES}" init
    mkdir -p "${NOTES_DIR}/.cache"
    echo "Example" > "${NOTES_DIR}/.cache/example"
    [[ -e "${NOTES_DIR}/.cache" ]]
  }


  run "${_NOTES}" notebooks add "example"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ ! -e "${NOTES_DIR}/.cache" ]]
}

# `_get_title()` ##############################################################

@test "\`_get_title()\` detects and returns Markdown title formats." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "one.md"
# Title One
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "two.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "three.md"
# Title Three
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "four.md"
---
summary: Example Summary
custom: variable
---
# Title Four
line six
line seven
line eight
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "five.md"
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
    cat <<HEREDOC | "${_NOTES}" add "six.md"
---
summary: Example Summary
custom: variable
---
line five
line six
line seven
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "seven.md"
Title Seven
===========

line four
line five
line six
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "eight.md"
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
    cat <<HEREDOC | "${_NOTES}" add "nine.md"
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
    cat <<HEREDOC | "${_NOTES}" add "ten.md"
# Title Ten #
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "eleven.md"
[](https://example.com/example.png)

# Title Eleven
line two
line three
line four
HEREDOC
    # shellcheck disable=SC2006
    cat <<HEREDOC | "${_NOTES}" add "twelve.md"
[](https://example.com/example.png)

```text
# Example In Code Block
```

# Title Twelve
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ "${lines[0]}"  == "[12] Title Twelve"           ]]
  [[ "${lines[1]}"  == "[11] Title Eleven"           ]]
  [[ "${lines[2]}"  == "[10] Title Ten"              ]]
  [[ "${lines[3]}"  == "[9]  Title Nine"             ]]
  [[ "${lines[4]}"  == "[8]  Title Eight"            ]]
  [[ "${lines[5]}"  == "[7]  Title Seven"            ]]
  [[ "${lines[6]}"  == "[6]  six.md · \"line five\"" ]]
  [[ "${lines[7]}"  == "[5]  Title Five"             ]]
  [[ "${lines[8]}"  == "[4]  Title Four"             ]]
  [[ "${lines[9]}"  == "[3]  Title Three"            ]]
  [[ "${lines[10]}" == "[2]  two.md · \"line one\""  ]]
  [[ "${lines[11]}" == "[1]  Title One"              ]]
}

# `_get_unique_basename()` ####################################################

@test "\`_get_unique_basename()\` works for notes" {
  {
    "${_NOTES}" init
    "${_NOTES}" add "example.md" --content "Example"
  }

  run "${_NOTES}" add "example.md" --content "Example"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-01.md ]]

  run "${_NOTES}" add "example.md" --content "Example"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-02.md ]]
}

@test "\`_get_unique_basename()\` works for bookmarks" {
  {
    "${_NOTES}" init
    "${_NOTES}" add "example.bookmark.md" --content "<https://example.com>"
  }

  run "${_NOTES}" add "example.bookmark.md" --content "<https://example.com>"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-01.bookmark.md ]]

  run "${_NOTES}" add "example.bookmark.md" --content "<https://example.com>"

  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-02.bookmark.md ]]
}
