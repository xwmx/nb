#!/usr/bin/env bats

load test_helper

_setup_tagged_items() {
  "${_NB}" init

  "${_NB}" add  "File One.md"                       \
    --title     "Title One"                         \
    --content   "Sample Content One #tag1 Sample Phrase."

  "${_NB}" add  "File Two.md"                       \
    --title     "Title Two"                         \
    --content   "Example Content Two #tag3 Example #tag1 Phrase."

  "${_NB}" add  "File Three.md"                     \
    --title     "Title Three"                       \
    --content   "Example Content Three #tag2 Example Phrase."

  "${_NB}" add  "Example Folder/Nested File One.md" \
    --title     "Title One"                         \
    --content   "Example Content One #nested-tag1 Example Phrase."

  "${_NB}" add  "Example Folder/Nested File Two.md" \
    --title     "Title Two"                         \
    --content   "#nested-tag2"

  "${_NB}" notebooks add "Example Notebook"

  "${_NB}" add  "Example Notebook:File One.md"      \
    --title     "Title One"                         \
    --content   "Sample Content One #other-tag1 Sample Phrase."
}

# `nb` (`ls`) #################################################################

@test "'<folder>/ --tags' lists all unique tags in <folder>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" Example\ Folder/ --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
}

@test "'--tags' lists all unique tags in the current notebook." {
  {
    _setup_tagged_items
  }

  run "${_NB}" --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 5             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
  [[ "${lines[2]}"  =~  \#tag1        ]]
  [[ "${lines[3]}"  =~  \#tag2        ]]
  [[ "${lines[4]}"  =~  \#tag3        ]]
}

@test "'--tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 6             ]]

  [[ "${lines[0]}"  =~  \#other-tag1  ]]
  [[ "${lines[1]}"  =~  \#nested-tag1 ]]
  [[ "${lines[2]}"  =~  \#nested-tag2 ]]
  [[ "${lines[3]}"  =~  \#tag1        ]]
  [[ "${lines[4]}"  =~  \#tag2        ]]
  [[ "${lines[5]}"  =~  \#tag3        ]]
}

# `list` ######################################################################

@test "'list <folder>/ --tags' lists all unique tags in <folder>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" list Example\ Folder/ --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
}

@test "'list --tags' lists all unique tags in the current notebook." {
  {
    _setup_tagged_items
  }

  run "${_NB}" list --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 5             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
  [[ "${lines[2]}"  =~  \#tag1        ]]
  [[ "${lines[3]}"  =~  \#tag2        ]]
  [[ "${lines[4]}"  =~  \#tag3        ]]
}

@test "'list --tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" list --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 6             ]]

  [[ "${lines[0]}"  =~  \#other-tag1  ]]
  [[ "${lines[1]}"  =~  \#nested-tag1 ]]
  [[ "${lines[2]}"  =~  \#nested-tag2 ]]
  [[ "${lines[3]}"  =~  \#tag1        ]]
  [[ "${lines[4]}"  =~  \#tag2        ]]
  [[ "${lines[5]}"  =~  \#tag3        ]]
}

# `search` ####################################################################

@test "'search <folder>/ --tags' lists all unique tags in <folder>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" search Example\ Folder/ --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
}

@test "'search --tags' lists all unique tags in the current notebook." {
  {
    _setup_tagged_items
  }

  run "${_NB}" search --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 5             ]]

  [[ "${lines[0]}"  =~  \#nested-tag1 ]]
  [[ "${lines[1]}"  =~  \#nested-tag2 ]]
  [[ "${lines[2]}"  =~  \#tag1        ]]
  [[ "${lines[3]}"  =~  \#tag2        ]]
  [[ "${lines[4]}"  =~  \#tag3        ]]
}

@test "'search --tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" search --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 6             ]]

  [[ "${lines[0]}"  =~  \#other-tag1  ]]
  [[ "${lines[1]}"  =~  \#nested-tag1 ]]
  [[ "${lines[2]}"  =~  \#nested-tag2 ]]
  [[ "${lines[3]}"  =~  \#tag1        ]]
  [[ "${lines[4]}"  =~  \#tag2        ]]
  [[ "${lines[5]}"  =~  \#tag3        ]]
}
