#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# undo task ###################################################################

@test "'tasks undo <folder>/<id> <task-number>' with closed task with space in brackets exits with 0 and marks task open." {
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
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
Undone:\ .*\[.*Example\ Folder/1\ 3.*\].*\ .*[\ ].*\ Task\ three\.  ]]
}

# do task #####################################################################

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
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

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
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
Done:\ .*\[.*Example\ Folder/1\ 2.*\].*\ .*[.*x.*].*\ Task\ two\. ]]
}

# tasks subcommand ############################################################

@test "'tasks open <folder>/<id>' exits with 0 and lists open tasks." {
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

  [[    "${status}"     -eq 0                         ]]
  [[    "${#lines[@]}"  -eq 5                         ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ \[\ \]\ Task\ one\.   ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ \[\]\ Task\ two\.     ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ \[\ \]\ Task\ four\.  ]]
}

@test "'tasks closed <folder>/<id>' exits with 0 and lists closed tasks." {
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

  run "${_NB}" tasks closed Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 3                                   ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*\[.*Example\ Folder/1\ 3.*\].*\ .*\[.*x.*\].*\ Task\ three\.  ]]
}

@test "'tasks <folder>/<id>' exits with 0 and lists tasks." {
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

  run "${_NB}" tasks Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 6                                 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*\[\ \].*\ Task\ one\.       ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*\[\].*\ Task\ two\.         ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*\[.*x.*\].*\ Task\ three\.  ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*\[\ \].*\ Task\ four\.      ]]
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

  [[    "${status}"     -eq 1       ]]
  [[    "${#lines[@]}"  -eq 3       ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*!.*\ No\ matching\ tasks\ found.  ]]
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

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 3                             ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]
  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ \[.*x.*\]\ Task\ three\.  ]]
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

  [[    "${status}"     -eq 0                             ]]
  [[    "${#lines[@]}"  -eq 3                             ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]
  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ \[.*x.*\]\ Task\ three\.  ]]
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

  [[    "${status}"     -eq 0                         ]]
  [[    "${#lines[@]}"  -eq 5                         ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ \[\ \]\ Task\ one\.   ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ \[\]\ Task\ two\.     ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ \[\ \]\ Task\ four\.  ]]
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
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

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

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 6                                 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*\[\ \].*\ Task\ one\.       ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*\[\].*\ Task\ two\.         ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*\[.*x.*\].*\ Task\ three\.  ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*\[\ \].*\ Task\ four\.      ]]
}

# empty messages ##############################################################

@test "'todos tasks open <folder>/<id>' with no open tasks exits with 1 and prints message." {
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

  [[    "${status}"     -eq 1                               ]]
  [[    "${#lines[@]}"  -eq 3                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  .*!.*\ No\ open\ tasks\ found\. ]]
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

  [[    "${status}"     -eq 1                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  .*!.*\ No\ closed\ tasks\ found\. ]]
}

@test "'todos tasks <folder>/<id>' with no tasks exits with 1 and prints message." {
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

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 3                         ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\. ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*            ]]

  [[    "${lines[2]}"   =~  .*!.*\ No\ tasks\ found\. ]]
}
