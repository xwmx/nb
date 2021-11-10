#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# undo task ###################################################################

@test "'tasks undo <folder>/<id> <task-number>' with non-todo and closed task exits with 0 and marks task done." {
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

@test "'tasks undo <folder>/<id> <task-number>' with closed task exits with 0 and marks task open." {
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
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

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
# [x] Example todo description three.

## Due

2200-02-02

## Tasks

- [ ] Task one.
- [x] Task two.

## Tags

#tag2 #tag3
HEREDOC
)"
  }

  run "${_NB}" todos tasks Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 15                              ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/4.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*                  ]]

  [[    "${lines[2]}"   =~  \
.*[.*Example\ Folder/4\ 1.*].*\ .*[\ ].*\ Task\ one\.       ]]
  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/4\ 2.*].*\ .*[.*x.*].*\ Task\ two\.    ]]

  [[    "${lines[4]}"   =~  \
.*\[.*Example\ Folder/2.*].*\ Example\ Note\ Title\ One.    ]]
  [[    "${lines[5]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/2\ 1.*].*\ .*[.*x.*].*\ Task\ one\.    ]]
  [[    "${lines[7]}"   =~  \
.*[.*Example\ Folder/2\ 2.*].*\ .*[\ ].*\ Task\ two\.       ]]
  [[    "${lines[8]}"   =~  \
.*[.*Example\ Folder/2\ 3.*].*\ .*[\ ].*\ Task\ three\.     ]]

  [[    "${lines[9]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[10]}"  =~  .*------------------------------------.*              ]]

  [[    "${lines[11]}"  =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.       ]]
  [[    "${lines[12]}"  =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.       ]]
  [[    "${lines[13]}"  =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
  [[    "${lines[14]}"  =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.      ]]
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

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 7                               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/3.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[1]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.    ]]
  [[    "${lines[2]}"   =~  .*------------------------------------.*                ]]

  [[    "${lines[3]}"   =~  \
.*[.*Example\ Folder/1\ 1.*].*\ .*[\ ].*\ Task\ one\.       ]]
  [[    "${lines[4]}"   =~  \
.*[.*Example\ Folder/1\ 2.*].*\ .*[\ ].*\ Task\ two\.       ]]
  [[    "${lines[5]}"   =~  \
.*[.*Example\ Folder/1\ 3.*].*\ .*[.*x.*].*\ Task\ three\.  ]]
  [[    "${lines[6]}"   =~  \
.*[.*Example\ Folder/1\ 4.*].*\ .*[\ ].*\ Task\ four\.      ]]
}

@test "'todos tasks <folder>' exits with 0 and lists todos with 0 tasks message." {
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

  [[    "${status}"     -eq 0                 ]]
  [[    "${#lines[@]}"  -eq 1                 ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
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

  [[    "${status}"     -eq 0               ]]
  [[    "${#lines[@]}"  -eq 3               ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  0\ open\ tasks. ]]
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

  [[    "${status}"     -eq 0                   ]]
  [[    "${#lines[@]}"  -eq 3                   ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
  [[    "${lines[1]}"   =~  .*------------------------------------.*              ]]

  [[    "${lines[2]}"   =~  0\ closed\ tasks\.  ]]
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

  [[    "${status}"     -eq 0           ]]
  [[    "${#lines[@]}"  -eq 1           ]]

  [[    "${lines[0]}"   =~  \
.*\[.*Example\ Folder/1.*].*\ ✔️\ [\ ].*\ Example\ todo\ description\ one\.  ]]
}
