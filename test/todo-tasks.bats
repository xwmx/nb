#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063,SC2076

load test_helper

# selectors and listing #######################################################

@test "'tasks <notebook>:' with empty notebook exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" tasks Example\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1               ]]
  [[    "${#lines[@]}"  -eq 1               ]]

  [[    "${lines[0]}"   =~  \!.*\ 0\ tasks. ]]
}

@test "'tasks <notebook>:' exits with 0 and lists todos and tasks at root level of <notebook>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --filename "Example Folder/One.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

- [ ] todo one task one.
- [ ] todo one task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Two.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description two.

- [ ] todo two task one.
- [x] todo two task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Three.todo.md"         \
      --content "$(cat <<HEREDOC
# [x] Example todo description three.

- [x] todo three task one.
- [x] todo three task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"

    "${_NB}" add                                        \
      --content "# [ ] Sample todo description one."    \
      --filename "Sample Folder/One.todo.md"

    "${_NB}" add                                        \
      --filename "One.todo.md"                          \
      --content "$(cat <<HEREDOC
# [x] Root todo description one.

- [x] root todo one task one.
- [x] root todo one task two.
HEREDOC
      )"

    "${_NB}" add                                        \
      --filename "Two.todo.md"                          \
      --content "$(cat <<HEREDOC
# [ ] Root todo description two.

- [ ] root todo two task one.
- [x] root todo two task two.
HEREDOC
      )"

    "${_NB}" use "home"
  }

  run "${_NB}" tasks Example\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0       ]]

  [[ !  "${output}"   =~  Four    ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Notebook:4.*\].*\ ✔️\ .*\[.*\ .*\].*\ Root\ todo\ description\ two\.  ]]
  [[    "${lines[1]}"   =~  ---                                                     ]]
  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Notebook:4\ 1.*\].*\ .*\[.*\ .*\].*\ root\ todo\ two\ task\ one\.    ]]
  [[    "${lines[3]}"   =~  \
.*\[.*Example\ Notebook:4\ 2.*\].*\ .*\[.*x.*\].*\ root\ todo\ two\ task\ two\.     ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Notebook:3.*\].*\ ✅\ .*\[.*\x.*\].*\ Root\ todo\ description\ one\. ]]
  [[    "${lines[5]}"   =~  ---                                                     ]]
  [[    "${lines[6]}"   =~  \
.*\[.*Example\ Notebook:3\ 1.*\].*\ .*\[.*\x.*\].*\ root\ todo\ one\ task\ one\.    ]]
  [[    "${lines[7]}"   =~  \
.*\[.*Example\ Notebook:3\ 2.*\].*\ .*\[.*x.*\].*\ root\ todo\ one\ task\ two\.     ]]
}

@test "'tasks <notebook>: --recursive' exits with 0 and lists todos and tasks recursively in <notebook>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --filename "Example Folder/One.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

- [ ] todo one task one.
- [ ] todo one task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Two.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description two.

- [ ] todo two task one.
- [x] todo two task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Three.todo.md"         \
      --content "$(cat <<HEREDOC
# [x] Example todo description three.

- [x] todo three task one.
- [x] todo three task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [ ] Sample todo description one."    \
      --filename "Sample Folder/One.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --filename "One.todo.md"                          \
      --content "$(cat <<HEREDOC
# [x] Root todo description one.

- [x] root todo one task one.
- [x] root todo one task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Two.todo.md"                          \
      --content "$(cat <<HEREDOC
# [ ] Root todo description two.

- [ ] root todo two task one.
- [x] root todo two task two.
HEREDOC
      )"

    "${_NB}" use "home"
  }

  run "${_NB}" tasks Example\ Notebook: --recursive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0       ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
  [[    "${lines[1]}"   =~  ---                                                                         ]]
  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3\ 1.*\].*\ .*\[.*x.*\].*\ todo\ three\ task\ one\. ]]
  [[    "${lines[3]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3\ 2.*\].*\ .*\[.*x.*\].*\ todo\ three\ task\ two\. ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ two\.     ]]
  [[    "${lines[5]}"   =~  ---                                                                         ]]
  [[    "${lines[6]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2\ 1.*\].*\ .*\[.*\ .*\].*\ todo\ two\ task\ one\.  ]]
  [[    "${lines[7]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2\ 2.*\].*\ .*\[.*x.*\].*\ todo\ two\ task\ two\.   ]]

  [[    "${lines[8]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/1.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.     ]]
  [[    "${lines[9]}"   =~  ---                                                                         ]]
  [[    "${lines[10]}"  =~  \
.*\[.*Example\ Notebook:Example\ Folder/1\ 1.*\].*\ .*\[.*\ .*\].*\ todo\ one\ task\ one\.  ]]
  [[    "${lines[11]}"  =~  \
.*\[.*Example\ Notebook:Example\ Folder/1\ 2.*\].*\ .*\[.*\ .*\].*\ todo\ one\ task\ two\.  ]]

  [[    "${lines[12]}"   =~  \
.*\[.*Example\ Notebook:Sample\ Folder/1.*\].*\ ✔️\ .*\[.*\ .*\].*\ Sample\ todo\ description\ one\.     ]]

  [[    "${lines[13]}"   =~  \
.*\[.*Example\ Notebook:4.*\].*\ ✔️\ .*\[.*\ .*\].*\ Root\ todo\ description\ two\.  ]]
  [[    "${lines[14]}"   =~  ---                                                    ]]
  [[    "${lines[15]}"   =~  \
.*\[.*Example\ Notebook:4\ 1.*\].*\ .*\[.*\ .*\].*\ root\ todo\ two\ task\ one\.    ]]
  [[    "${lines[16]}"   =~  \
.*\[.*Example\ Notebook:4\ 2.*\].*\ .*\[.*x.*\].*\ root\ todo\ two\ task\ two\.     ]]

  [[    "${lines[17]}"   =~  \
.*\[.*Example\ Notebook:3.*\].*\ ✅\ .*\[.*\x.*\].*\ Root\ todo\ description\ one\. ]]
  [[    "${lines[18]}"   =~  ---                                                    ]]
  [[    "${lines[19]}"   =~  \
.*\[.*Example\ Notebook:3\ 1.*\].*\ .*\[.*\x.*\].*\ root\ todo\ one\ task\ one\.    ]]
  [[    "${lines[20]}"   =~  \
.*\[.*Example\ Notebook:3\ 2.*\].*\ .*\[.*x.*\].*\ root\ todo\ one\ task\ two\.     ]]
}

@test "'tasks <notebook>:<folder>/' exits with 0 and lists todos and tasks in <folder>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --filename "Example Folder/One.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

- [ ] todo one task one.
- [ ] todo one task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Two.todo.md"           \
      --content "$(cat <<HEREDOC
# [ ] Example todo description two.

- [ ] todo two task one.
- [x] todo two task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --filename "Example Folder/Three.todo.md"         \
      --content "# [x] Example todo description three." \
      --content "$(cat <<HEREDOC
# [x] Example todo description three.

- [x] todo three task one.
- [x] todo three task two.
HEREDOC
      )"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"

    "${_NB}" add                                        \
      --content "# [ ] Sample todo description one."    \
      --filename "Sample Folder/One.todo.md"

    "${_NB}" use "home"
  }

  run "${_NB}" tasks Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0       ]]

  [[ !  "${output}"   =~  Four    ]]
  [[ !  "${output}"   =~  Sample  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
  [[    "${lines[1]}"   =~  ---                                                                         ]]
  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3\ 1.*\].*\ .*\[.*x.*\].*\ todo\ three\ task\ one\. ]]
  [[    "${lines[3]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/3\ 2.*\].*\ .*\[.*x.*\].*\ todo\ three\ task\ two\. ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ two\.     ]]
  [[    "${lines[5]}"   =~  ---                                                                         ]]
  [[    "${lines[6]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2\ 1.*\].*\ .*\[.*\ .*\].*\ todo\ two\ task\ one\.  ]]
  [[    "${lines[7]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/2\ 2.*\].*\ .*\[.*x.*\].*\ todo\ two\ task\ two\.   ]]

  [[    "${lines[8]}"   =~  \
.*\[.*Example\ Notebook:Example\ Folder/1.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.     ]]
  [[    "${lines[9]}"   =~  ---                                                                         ]]
  [[    "${lines[10]}"  =~  \
.*\[.*Example\ Notebook:Example\ Folder/1\ 1.*\].*\ .*\[.*\ .*\].*\ todo\ one\ task\ one\.  ]]
  [[    "${lines[11]}"  =~  \
.*\[.*Example\ Notebook:Example\ Folder/1\ 2.*\].*\ .*\[.*\ .*\].*\ todo\ one\ task\ two\.  ]]
}

# line wrapping ###############################################################

@test "'tasks <folder>/<id> <task-number>' exits with 0 and lists individual tasks with wrapping." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one with example sample demo test long title to test task list line-wrapping behavior one.
- [] Task two with example sample demo test long title to test task list line-wrapping behavior two.
- [x] Task three with example sample demo test long title to test task list line-wrapping behavior three.
  - [ ] Task four with example sample demo test long title to test task list line-wrapping behavior four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks Example\ Folder/1 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 3 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]

  [[    "${lines[0]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[0]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[ !  "${lines[1]}"   =~ "$(printf '\033[?7l')" ]]
  [[ !  "${lines[1]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\ with\ example\ sample                        ]]
  [[    "${lines[2]}"   =~  \
example\ sample\ demo\ test\ long\ title\ to\ test\ task\ list\ line\-wrapping\ behavior\ two\.   ]]

  [[ !  "${lines[2]}"   =~ "$(printf '\033[?7l')" ]]
  [[ !  "${lines[2]}"   =~ "$(printf '\033[?7h')" ]]
}

@test "'tasks <folder>/<id>' exits with 0 and lists multiple tasks without wrapping." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one with example sample demo test long title to test task list line-wrapping behavior one.
- [] Task two with example sample demo test long title to test task list line-wrapping behavior two.
- [x] Task three with example sample demo test long title to test task list line-wrapping behavior three.
  - [ ] Task four with example sample demo test long title to test task list line-wrapping behavior four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 6 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]

  [[    "${lines[0]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[0]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[ !  "${lines[1]}"   =~ "$(printf '\033[?7l')" ]]
  [[ !  "${lines[1]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\ with\ example\ sample                        ]]
  [[    "${lines[2]}"   =~  \
example\ sample\ demo\ test\ long\ title\ to\ test\ task\ list\ line\-wrapping\ behavior\ one\.   ]]

  [[    "${lines[2]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[2]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\ with\ example\ sample                        ]]
  [[    "${lines[3]}"   =~  \
example\ sample\ demo\ test\ long\ title\ to\ test\ task\ list\ line\-wrapping\ behavior\ two\.   ]]

  [[    "${lines[3]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[3]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\ with\ example\ sample                   ]]
  [[    "${lines[4]}"   =~  \
example\ sample\ demo\ test\ long\ title\ to\ test\ task\ list\ line\-wrapping\ behavior\ three\. ]]

  [[    "${lines[4]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[4]}"   =~ "$(printf '\033[?7h')" ]]

  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\ with\ example\ sample                        ]]
  [[    "${lines[5]}"   =~  \
example\ sample\ demo\ test\ long\ title\ to\ test\ task\ list\ line\-wrapping\ behavior\ four\.   ]]

  [[    "${lines[5]}"   =~ "$(printf '\033[?7l')" ]]
  [[    "${lines[5]}"   =~ "$(printf '\033[?7h')" ]]
}

# do task #####################################################################

@test "'tasks do <folder>/<id> <task-number>' with non-todo and open task with no space in brackets exits with 0 and marks task done." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename "Example Folder/File One.md" \
      --content "$(cat <<HEREDOC
# Example Title One

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "do" Example\ Folder/1 2

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  .*\[.*Example\ Folder/1.*].*\ Example\ Title\ One ]]
  [[    "${lines[1]}"   =~  [^-]------------------------------------[^-]      ]]
  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 2.*\].*\ .*[.*x.*].*\ Task\ two\.             ]]
}

@test "'tasks do <folder>/<id> <task-number>' with non-todo and open task with space in brackets exits with 0 and marks task done." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename "Example Folder/File One.md" \
      --content "$(cat <<HEREDOC
# Example Title One

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "do" Example\ Folder/1 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  .*\[.*Example\ Folder/1.*].*\ Example\ Title\ One ]]
  [[    "${lines[1]}"   =~  [^-]------------------------------------[^-]      ]]
  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 2.*\].*\ .*[.*x.*].*\ Task\ two\.             ]]
}

@test "'tasks do <folder>/<id> <task-number>' with open task with no space in brackets exits with 0 and marks task done." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "do" Example\ Folder/1 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/Todo One.todo.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 2.*\].*\ .*[.*x.*].*\ Task\ two\. ]]
}

@test "'tasks do <folder>/<id> <task-number>' with open task with space in brackets exits with 0 and marks task done." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "do" Example\ Folder/1 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/Todo One.todo.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 2.*\].*\ .*[.*x.*].*\ Task\ two\. ]]
}

@test "'tasks do <folder>/<id> <task-number>' with indented open task with space in brackets exits with 0 and marks task done." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "do" Example\ Folder/1 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/Todo One.todo.md"

  [[    "${status}"     -eq 0                                       ]]
  [[    "${#lines[@]}"  -eq 3                                       ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 4.*\].*\ .*[.*x.*].*\ Task\ four\.  ]]
}

# undo task ###################################################################

@test "'tasks undo <folder>/<id> <task-number>' with non-todo and indented closed task exits with 0 and marks task undone." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename "Example Folder/File One.md" \
      --content "$(cat <<HEREDOC
# Example Title One

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [x] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "undo" Example\ Folder/1 4

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  .*\[.*Example\ Folder/1.*].*\ Example\ Title\ One ]]
  [[    "${lines[1]}"   =~  [^-]------------------------------------[^-]      ]]
  [[    "${lines[2]}"   =~  \
Undone:\ .*\[.*Example\ Folder/1\ 4.*\].*\ .*[\ ].*\ Task\ four\.             ]]
}

@test "'tasks undo <folder>/<id> <task-number>' with non-todo and closed task exits with 0 and marks task undone." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename "Example Folder/File One.md" \
      --content "$(cat <<HEREDOC
# Example Title One

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "undo" Example\ Folder/1 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 3                                     ]]

  [[    "${lines[0]}"   =~  .*\[.*Example\ Folder/1.*].*\ Example\ Title\ One ]]
  [[    "${lines[1]}"   =~  [^-]------------------------------------[^-]      ]]
  [[    "${lines[2]}"   =~  \
Undone:\ .*\[.*Example\ Folder/1\ 3.*\].*\ .*[\ ].*\ Task\ three\.            ]]
}

@test "'tasks undo <folder>/<id> <task-number>' with closed task exits with 0 and marks task undone." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [ ] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks "undo" Example\ Folder/1 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/Todo One.todo.md"

  [[    "${status}"     -eq 0                                       ]]
  [[    "${#lines[@]}"  -eq 3                                       ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
Undone:\ .*\[.*Example\ Folder/1\ 3.*\].*\ .*[\ ].*\ Task\ three\.  ]]
}

# tasks subcommand ############################################################

@test "'tasks open <folder>/<id>' exits with 0 and lists open tasks in the item." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks open Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 5                           ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.   ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.   ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.  ]]
}

@test "'tasks closed <folder>/<id>' exits with 0 and lists closed tasks in the item." {
  {
    "${_NB}" init

    "${_NB}" add                                      \
      --filename  "Example Folder/Todo One.todo.md"   \
      --content   "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks closed Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 3                                   ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Folder/1\ 3.*\].*\ .*\[.*x.*\].*\ Task\ three\.  ]]
}

@test "'tasks <folder>/<id>' exits with 0 and lists tasks." {
  {
    "${_NB}" init

    "${_NB}" add                                      \
      --filename "Example Folder/Todo One.todo.md"    \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" tasks Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 6                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.       ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.       ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.      ]]
}

# todos tasks <id> <task-number> ##############################################

@test "'todos tasks open <folder>/<id> <not-valid-number>' exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/1 123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                   ]]
  [[    "${#lines[@]}"  -eq 3                   ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  0\ matching\ tasks. ]]
}

@test "'todos tasks closed <folder>/<id> 3' exits with 0 and lists task." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks closed Example\ Folder/1 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 3                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
}

@test "'todos tasks <folder>/<id> 3' exits with 0 and lists task." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/1 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 3                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
}

# todos tasks #################################################################

@test "'todos tasks open <folder>/<id>' exits with 0 and lists open tasks." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks open Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 5                           ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.   ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.   ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.  ]]
}

@test "'todos tasks closed <folder>/<id>' exits with 0 and lists closed tasks." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks closed Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 3                                   ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Folder/1\ 3.*\].*\ .*\[.*x.*\].*\ Task\ three\.  ]]
}

@test "'todos tasks <folder>/<id>' exits with 0 and lists tasks." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 6                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.       ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.       ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.      ]]
}

# todo tasks <folder> #########################################################

@test "'todos tasks open <folder>' exits with 0 and lists open todos and tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
  - [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                              \
      --filename "Example Folder/Note One.md" \
      --content "$(cat <<HEREDOC
# Example Note Title One.

Example content.

- [x] Task one.
- [ ] Task two.
- [ ] Task three.

## Tags

#tag2 #tag3
HEREDOC
)"
    "${_NB}" add                                    \
      --filename  "Example Folder/Note Two.md"      \
      --content   "Example note content two."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Three.todo.md"   \
      --content   "# [x] Example todo description three."

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Four.todo.md"    \
      --content   "# [ ] Example todo description four."
  }

  run "${_NB}" todos tasks open Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0   ]]
  [[    "${#lines[@]}"  -eq 13  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/6.*].*\ ✔️\ \ *[\ ].*\ Example\ todo\ description\ four\.      ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/4\ 1.*].*\ .*[\ ].*\ Task\ one\.                               ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.              ]]
  [[    "${lines[5]}"   =~  .*------------------------------------.*  ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/2\ 2.*].*\ .*[\ ].*\ Task\ two\.                 ]]
  [[    "${lines[7]}"  =~  \
.*[.*Example\ Folder/2\ 3.*].*\ .*[\ ].*\ Task\ three\.               ]]

  [[    "${lines[8]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[9]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[10]}"  =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.                             ]]
  [[    "${lines[11]}"  =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.                             ]]
  [[    "${lines[12]}"  =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.                            ]]
}

@test "'todos tasks closed <folder>' exits with 0 and lists closed todos and tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                              \
      --filename "Example Folder/Note One.md" \
      --content "$(cat <<HEREDOC
# Example Note Title One.

Example content.

- [x] Task one.
- [ ] Task two.
- [ ] Task three.

## Tags

#tag2 #tag3
HEREDOC
)"
    "${_NB}" add                                    \
      --filename  "Example Folder/Note Two.md"      \
      --content   "Example note content two."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Three.todo.md"   \
      --content   "# [x] Example todo description three."

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Four.todo.md"    \
      --content   "# [ ] Example todo description four."
  }

  run "${_NB}" todos tasks closed Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0   ]]
  [[    "${#lines[@]}"  -eq 10  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/5.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\.  ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.    ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                  ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/4\ 2.*].*\ .*[.*x.*].*\ Task\ two\.                              ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.              ]]
  [[    "${lines[5]}"   =~  .*------------------------------------.*  ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/2\ 1.*].*\ .*[.*x.*].*\ Task\ one\.              ]]

  [[    "${lines[7]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[8]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[9]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.                        ]]
}

@test "'todos tasks <folder>' exits with 0 and lists todos and tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                              \
      --filename "Example Folder/Note One.md" \
      --content "$(cat <<HEREDOC
# Example Note Title One.

Example content.

- [x] Task one.
- [ ] Task two.
- [ ] Task three.

## Tags

#tag2 #tag3
HEREDOC
)"
    "${_NB}" add                                    \
      --filename  "Example Folder/Note Two.md"      \
      --content   "Example note content two."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Three.todo.md"   \
      --content   "# [x] Example todo description three."

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Four.todo.md"    \
      --content   "# [ ] Example todo description four."
  }

  run "${_NB}" todos tasks Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0   ]]
  [[    "${#lines[@]}"  -eq 17  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/6.*].*\ ✔️\ \ .*[\ ].*\ Example\ todo\ description\ four\.       ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/5.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\.  ]]
  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.    ]]
  [[    "${lines[3]}"   =~  .*------------------------------------.*                  ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/4\ 1.*].*\ .*[\ ].*\ Task\ one\.                                 ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/4\ 2.*].*\ .*[.*x.*].*\ Task\ two\.                              ]]

  [[    "${lines[6]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.              ]]
  [[    "${lines[7]}"   =~  .*------------------------------------.*  ]]
  [[    "${lines[8]}"   =~  \
.*[.*Example\ Folder/2\ 1.*].*\ .*[.*x.*].*\ Task\ one\.              ]]
  [[    "${lines[9]}"   =~  \
.*[.*Example\ Folder/2\ 2.*].*\ .*[\ ].*\ Task\ two\.                 ]]
  [[    "${lines[10]}"  =~  \
.*[.*Example\ Folder/2\ 3.*].*\ .*[\ ].*\ Task\ three\.               ]]

  [[    "${lines[11]}"  =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[12]}"  =~  .*------------------------------------.*              ]]
  [[    "${lines[13]}"  =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.                             ]]
  [[    "${lines[14]}"  =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.                             ]]
  [[    "${lines[15]}"  =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.                        ]]
  [[    "${lines[16]}"  =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.                            ]]
}

@test "'todos tasks <folder>' exits with 0 and lists todos with and without tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                                    \
      --filename  "Example Folder/Note One.md"      \
      --content   "Example note content one."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tags

#tag2 #tag3
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 7 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/3.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.    ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.                               ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.                               ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.                          ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.                              ]]
}

@test "'todos tasks <folder>' with no tasks exits with 0 and lists todos." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                                    \
      --filename  "Example Folder/Note One.md"      \
      --content   "Example note content one."
  }

  run "${_NB}" todos tasks Example\ Folder/

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 1 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
}

# tasks done / undone #########################################################

@test "'todos tasks undone <folder>' exits with 0 and lists open todos and tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                              \
      --filename "Example Folder/Note One.md" \
      --content "$(cat <<HEREDOC
# Example Note Title One.

Example content.

- [x] Task one.
- [ ] Task two.
- [ ] Task three.

## Tags

#tag2 #tag3
HEREDOC
)"
    "${_NB}" add                                    \
      --filename  "Example Folder/Note Two.md"      \
      --content   "Example note content two."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Three.todo.md"   \
      --content   "# [x] Example todo description three."

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Four.todo.md"    \
      --content   "# [ ] Example todo description four."
  }

  run "${_NB}" todos tasks undone Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0   ]]
  [[    "${#lines[@]}"  -eq 13  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/6.*].*\ ✔️\ \ *[\ ].*\ Example\ todo\ description\ four\.      ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/4\ 1.*].*\ .*[\ ].*\ Task\ one\.                               ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.              ]]
  [[    "${lines[5]}"   =~  .*------------------------------------.*  ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/2\ 2.*].*\ .*[\ ].*\ Task\ two\.                 ]]
  [[    "${lines[7]}"  =~  \
.*[.*Example\ Folder/2\ 3.*].*\ .*[\ ].*\ Task\ three\.               ]]

  [[    "${lines[8]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[9]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[10]}"  =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.                             ]]
  [[    "${lines[11]}"  =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.                             ]]
  [[    "${lines[12]}"  =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.                            ]]
}

@test "'todos tasks done <folder>' exits with 0 and lists closed todos and tasks in folder." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [x] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"

    "${_NB}" add                              \
      --filename "Example Folder/Note One.md" \
      --content "$(cat <<HEREDOC
# Example Note Title One.

Example content.

- [x] Task one.
- [ ] Task two.
- [ ] Task three.

## Tags

#tag2 #tag3
HEREDOC
)"
    "${_NB}" add                                    \
      --filename  "Example Folder/Note Two.md"      \
      --content   "Example note content two."

    "${_NB}" add                                    \
      --filename "Example Folder/Todo Two.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description two.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Three.todo.md"   \
      --content   "# [x] Example todo description three."

    "${_NB}" add                                        \
      --filename  "Example Folder/Todo Four.todo.md"    \
      --content   "# [ ] Example todo description four."
  }

  run "${_NB}" todos tasks "done" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0   ]]
  [[    "${#lines[@]}"  -eq 10  ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/5.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\.  ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.    ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                  ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/4\ 2.*].*\ .*[.*x.*].*\ Task\ two\.                              ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.              ]]
  [[    "${lines[5]}"   =~  .*------------------------------------.*  ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/2\ 1.*].*\ .*[.*x.*].*\ Task\ one\.              ]]

  [[    "${lines[7]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[8]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[9]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.                        ]]
}

# empty messages ##############################################################

@test "'todos tasks open <folder>/<id>' with closed todo with no open tasks exits with 0 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [x] Example todo description one.

## Due

2200-02-02

## Tasks

- [x] Task one.
- [x] Task two.
- [x] Task three.
- [x] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks open Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 3 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*                ]]
  [[    "${lines[2]}"   =~  0\ open\ tasks.                                         ]]
}

@test "'todos tasks open <folder>/<id>' with open todo with no open tasks exits with 0 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [x] Task one.
- [x] Task two.
- [x] Task three.
- [x] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks open Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 3 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[2]}"   =~  0\ open\ tasks.                                       ]]
}

@test "'todos tasks closed <folder>/<id>' with no closed tasks exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [] Task two.
- [ ] Task three.
- [ ] Task four.

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks closed Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 3 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]
  [[    "${lines[2]}"   =~  0\ closed\ tasks\.                                    ]]
}

@test "'todos tasks <folder>/<id>' with no tasks prints todo." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
      --filename "Example Folder/Todo One.todo.md"  \
      --content "$(cat <<HEREDOC
# [ ] Example todo description one.

## Due

2200-02-02

## Tags

#tag1 #tag2
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0 ]]
  [[    "${#lines[@]}"  -eq 3 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ [\ ].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*        ]]
  [[    "${lines[2]}"   =~  0\ tasks\.                                      ]]
}

@test "'todos tasks <folder>' with no todos or tasks exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md" --content "Example content one."
    "${_NB}" add "Example Folder/File Two.md" --content "Example content two."
  }

  run "${_NB}" todos tasks Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1 ]]
  [[    "${#lines[@]}"  -eq 1 ]]

  [[    "${lines[0]}"   =~  .*!.*\ 0\ tasks\.   ]]
}
