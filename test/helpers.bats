#!/usr/bin/env bats

load test_helper


# `_get_title()` ##############################################################

@test "\`_get_title()\` exits with 0 and displays a list of titles." {
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
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }


  run "${_NOTES}" list --titles --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" == "[6] six.md"      ]]
  [[ "${lines[1]}" == "[5] Title Five"  ]]
  [[ "${lines[2]}" == "[4] Title Four"  ]]
  [[ "${lines[3]}" == "[3] Title Three" ]]
  [[ "${lines[4]}" == "[2] two.md"      ]]
  [[ "${lines[5]}" == "[1] Title One"   ]]
}
