#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063,SC2076

load test_helper

# t alias <folder> ############################################################

@test "'t open <folder>' exits with 0 and lists open todos and tasks in folder." {
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

  run "${_NB}" t open Example\ Folder/

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

@test "'t closed <folder>' exits with 0 and lists closed todos and tasks in folder." {
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

  run "${_NB}" t closed Example\ Folder/

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

@test "'t <folder>' exits with 0 and lists todos and tasks in folder." {
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

  run "${_NB}" t Example\ Folder/

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

# t alias <id> ################################################################

@test "'t open <folder>/<id>' exits with 0 and lists open tasks in the item." {
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

  run "${_NB}" t open Example\ Folder/1

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

  run "${_NB}" t closed Example\ Folder/1

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

  run "${_NB}" t Example\ Folder/1

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
