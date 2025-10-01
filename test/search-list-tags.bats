#!/usr/bin/env bats

load test_helper

_setup_tagged_items() {
  "${_NB}" init

  "${_NB}" add  "File One.md"                       \
    --title     "Title One"                         \
    --content   "Sample Content One #tag1 Sample Phrase."

  "${_NB}" add  "File Two.bookmark.md"              \
    --title     "Title Two"                         \
    --content   "$(cat <<HEREDOC
Example Title with #title-tag and #123 Hello

## Comment

Example Content Two #tag3 Example #tag1 Phrase.

More content.

#lõw-tag

Even more content with #parent-tag/child-tag/grandchild-tag in the middle.

## Content

#content-tag
HEREDOC
)"

  "${_NB}" add  "File Three.bookmark.md"            \
    --title     "Title Three"                       \
    --content   "$(cat <<HEREDOC
Example Content Three #out-of-bounds-tag Example Phrase.

## Tags

#tag2

## Source

#source-tag
HEREDOC
)"

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

# filename handlng ############################################################

@test "'--tags' with uncommon filenames lists all unique, readable tags in current notebook." {
  {
    _setup_tagged_items

    "${_NB}" rename "File One.md"           "File [] One.md"          --force
    "${_NB}" rename "File Two.bookmark.md"  "File ] Two.bookmark.md"  --force
  }

  run "${_NB}" --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 7                                     ]]

  [[ "${output}"    =~  \#nested-tag1                         ]]
  [[ "${output}"    =~  \#nested-tag2                         ]]
  [[ "${output}"    =~  \#tag1                                ]]
  [[ "${output}"    =~  \#tag2                                ]]
  [[ "${output}"    =~  \#tag3                                ]]
  [[ "${output}"    =~  \#lõw-tag                             ]]
  [[ "${output}"    =~  \#parent-tag/child-tag/grandchild-tag ]]
}

# _GIT_ENABLED=0 ##############################################################

@test "'--tags' with _GIT_ENABLED=0 lists all unique, readable tags in <item>." {
  {
    _setup_tagged_items
  }

  _GIT_ENABLED=0 run "${_NB}" --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 7                                     ]]

  [[ "${output}"    =~  \#nested-tag1                         ]]
  [[ "${output}"    =~  \#nested-tag2                         ]]
  [[ "${output}"    =~  \#tag1                                ]]
  [[ "${output}"    =~  \#tag2                                ]]
  [[ "${output}"    =~  \#tag3                                ]]
  [[ "${output}"    =~  \#lõw-tag                             ]]
  [[ "${output}"    =~  \#parent-tag/child-tag/grandchild-tag ]]
}

# edge cases ##################################################################

@test "'--tags' skips URI fragments." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" \
      --content "$(
        cat <<HEREDOC
#tag1

https://example.com/example#fragment

#tag2 #tag3
HEREDOC
      )"
  }

  run "${_NB}" --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 3             ]]

  [[ "${lines[0]}"  =~  \#tag1        ]]
  [[ "${lines[1]}"  =~  \#tag2        ]]
  [[ "${lines[2]}"  =~  \#tag3        ]]

}

# https://github.com/xwmx/nb/issues/154
@test "'<item> --tags' and '--tags' with note lists tags in <item>." {
  {
    "${_NB}" init

    "${_NB}" add --tags foo,bar --title baz "foo bar baz" foo.md
  }

  run "${_NB}" --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/foo.md"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#foo         ]]
  [[ "${lines[1]}"  =~  \#bar         ]]

  run "${_NB}" ls --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/foo.md"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#foo         ]]
  [[ "${lines[1]}"  =~  \#bar         ]]

  run "${_NB}" list --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/foo.md"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#foo         ]]
  [[ "${lines[1]}"  =~  \#bar         ]]

  run "${_NB}" search --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/foo.md"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#foo         ]]
  [[ "${lines[1]}"  =~  \#bar         ]]

  run "${_NB}" 1 --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/foo.md"

  [[ "${status}"    -eq 0             ]]
  [[ "${#lines[@]}" -eq 2             ]]

  [[ "${lines[0]}"  =~  \#foo         ]]
  [[ "${lines[1]}"  =~  \#bar         ]]
}

# `nb` (`ls`) #################################################################

@test "'<item> --tags' lists all unique, readable tags in <item>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" 2 --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \#tag3                                ]]
  [[ "${lines[1]}"  =~  \#tag1                                ]]
  [[ "${lines[2]}"  =~  \#lõw-tag                             ]]
  [[ "${output}"    =~  \#parent-tag/child-tag/grandchild-tag ]]
}

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

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 7                                     ]]

  [[ "${lines[0]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[1]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[2]}"  =~  \#tag1                                ]]
  [[ "${lines[3]}"  =~  \#tag2                                ]]
  [[ "${lines[4]}"  =~  \#tag3                                ]]
  [[ "${lines[5]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[6]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

@test "'--tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 8                                     ]]

  [[ "${lines[0]}"  =~  \#other-tag1                          ]]
  [[ "${lines[1]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[2]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[3]}"  =~  \#tag1                                ]]
  [[ "${lines[4]}"  =~  \#tag2                                ]]
  [[ "${lines[5]}"  =~  \#tag3                                ]]
  [[ "${lines[6]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[7]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

# `list` ######################################################################

@test "'list <item> --tags' lists all unique, readable tags in <item>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" list 2 --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \#tag3                                ]]
  [[ "${lines[1]}"  =~  \#tag1                                ]]
  [[ "${lines[2]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[3]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

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

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 7                                     ]]

  [[ "${lines[0]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[1]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[2]}"  =~  \#tag1                                ]]
  [[ "${lines[3]}"  =~  \#tag2                                ]]
  [[ "${lines[4]}"  =~  \#tag3                                ]]
  [[ "${lines[5]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[6]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

@test "'list --tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" list --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 8                                     ]]

  [[ "${lines[0]}"  =~  \#other-tag1                          ]]
  [[ "${lines[1]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[2]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[3]}"  =~  \#tag1                                ]]
  [[ "${lines[4]}"  =~  \#tag2                                ]]
  [[ "${lines[5]}"  =~  \#tag3                                ]]
  [[ "${lines[6]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[7]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

# `search` ####################################################################

@test "'search <item> --tags' lists all unique, readable tags in <item>." {
  {
    _setup_tagged_items
  }

  run "${_NB}" search 2 --tags

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \#tag3                                ]]
  [[ "${lines[1]}"  =~  \#tag1                                ]]
  [[ "${lines[2]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[3]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

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

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 7                                     ]]

  [[ "${lines[0]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[1]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[2]}"  =~  \#tag1                                ]]
  [[ "${lines[3]}"  =~  \#tag2                                ]]
  [[ "${lines[4]}"  =~  \#tag3                                ]]
  [[ "${lines[5]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[6]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}

@test "'search --tags --all' lists all unique tags in all notebooks." {
  {
    _setup_tagged_items
  }

  run "${_NB}" search --tags --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 8                                     ]]

  [[ "${lines[0]}"  =~  \#other-tag1                          ]]
  [[ "${lines[1]}"  =~  \#nested-tag1                         ]]
  [[ "${lines[2]}"  =~  \#nested-tag2                         ]]
  [[ "${lines[3]}"  =~  \#tag1                                ]]
  [[ "${lines[4]}"  =~  \#tag2                                ]]
  [[ "${lines[5]}"  =~  \#tag3                                ]]
  [[ "${lines[6]}"  =~  \#lõw-tag                             ]]
  [[ "${lines[7]}"  =~  \#parent-tag/child-tag/grandchild-tag ]]
}
