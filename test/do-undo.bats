#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# error handling ##############################################################

@test "'do <id> <task-number>' with non-existent todo <id> exits with 1 and prints message." {
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

  run "${_NB}" "do" 654 123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  .*!.*\ Todo\ not\ found\. ]]
}

@test "'undo <id> <task-number>' with non-existent todo <id> exits with 1 and prints message." {
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

  run "${_NB}" "undo" 654 123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  .*!.*\ Todo\ not\ found\. ]]
}

@test "'do <id> <task-number>' with non-existent task exits with 1 and prints message." {
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

  run "${_NB}" "do" Example\ Folder/1 123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  .*!.*\ Task\ not\ found\. ]]
}

@test "'undo <id> <task-number>' with non-existent task exits with 1 and prints message." {
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

  run "${_NB}" "undo" Example\ Folder/1 123

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/Example Folder/File One.md"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  .*!.*\ Task\ not\ found\. ]]
}

@test "'do' with non-todo exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                          \
      --content   "Example content one."  \
      --filename  "File One.md"
  }

  run "${_NB}" "do" 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                     ]]
  [[ "${output}"    =~  \!.*\ Not\ a\ todo\.  ]]

  diff                                    \
    <(cat "${NB_DIR}/home/File One.md")   \
    <(printf "Example content one.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Done'
}

@test "'undo' with non-todo exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add                          \
      --content   "Example content one."  \
      --filename  "File One.md"
  }

  run "${_NB}" "undo" 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                     ]]
  [[ "${output}"    =~  \!.*\ Not\ a\ todo\.  ]]

  diff                                    \
    <(cat "${NB_DIR}/home/File One.md")   \
    <(printf "Example content one.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Done'
}

# do todo #####################################################################

@test "'do <notebook>:<folder>/<id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    "${_NB}" use "home"
  }

  run "${_NB}" "do" Example\ Notebook:Example\ Folder/2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ .*\[.*x.*\].*\ Example\ todo\ description\ two\. ]]

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/One.todo.md")    \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/Two.todo.md")    \
    <(printf "# [x] Example todo description two.\\n")

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/Three.todo.md")  \
    <(printf "# [x] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/Example Notebook" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/Example Notebook" log | grep -q '\[nb\] Done: Example Folder/Two.todo.md'
}

@test "'do <id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" "do" 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*2.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]

  diff                                    \
    <(cat "${NB_DIR}/home/One.todo.md")   \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Two.todo.md")   \
    <(printf "# [x] Example todo description two.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Three.todo.md") \
    <(printf "# [x] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Done: Two.todo.md'
}

@test "'do' with no selector exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" "do"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                     ]]
  [[ "${lines[0]}"  =~  Usage.*:              ]]
  [[ "${lines[1]}"  =~  ${_ME}\ todo          ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0                    ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Done'
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

  run "${_NB}" "do" Example\ Folder/1 2

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

  run "${_NB}" "do" Example\ Folder/1 2

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

  run "${_NB}" "do" Example\ Folder/1 2

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

# undo todo ###################################################################

@test "'undo <notebook>:<folder>/<id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    "${_NB}" use "home"
  }

  run "${_NB}" "undo" Example\ Notebook:Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ three\.  ]]

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/One.todo.md")    \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/Two.todo.md")    \
    <(printf "# [ ] Example todo description two.\\n")

  diff                                                                \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/Three.todo.md")  \
    <(printf "# [ ] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/Example Notebook" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/Example Notebook" log | grep -q '\[nb\] Undone: Example Folder/Three.todo.md'
}

@test "'undo <id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" "undo" 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*3.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ three\. ]]

  diff                                    \
    <(cat "${NB_DIR}/home/One.todo.md")   \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Two.todo.md")   \
    <(printf "# [ ] Example todo description two.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Three.todo.md") \
    <(printf "# [ ] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Undone: Three.todo.md'
}

@test "'undo' with no selector exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" "undo"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1             ]]
  [[ "${lines[0]}"  =~  Usage.*:      ]]
  [[ "${lines[1]}"  =~  ${_ME}\ todo  ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0            ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Undone'
}

# undo task ###################################################################

@test "'undo <folder>/<id> <task-number>' with non-todo and closed task exits with 0 and marks task done." {
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

  run "${_NB}" "undo" Example\ Folder/1 3

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

@test "'undo <folder>/<id> <task-number>' with closed task exits with 0 and marks task open." {
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

  run "${_NB}" "undo" Example\ Folder/1 3

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

# close alias #################################################################

@test "'close <id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" "close" 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*2.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]

  diff                                    \
    <(cat "${NB_DIR}/home/One.todo.md")   \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Two.todo.md")   \
    <(printf "# [x] Example todo description two.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Three.todo.md") \
    <(printf "# [x] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Done: Two.todo.md'
}

# done alias ##################################################################

@test "'done <id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" "done" 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*2.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]

  diff                                    \
    <(cat "${NB_DIR}/home/One.todo.md")   \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Two.todo.md")   \
    <(printf "# [x] Example todo description two.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Three.todo.md") \
    <(printf "# [x] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Done: Two.todo.md'
}

# undone alias ################################################################

@test "'undone <id>' exits with 0, updates todo, and commits." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "One.todo.md"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Two.todo.md"

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Three.todo.md"
  }

  run "${_NB}" "undone" 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*3.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ three\. ]]

  diff                                    \
    <(cat "${NB_DIR}/home/One.todo.md")   \
    <(printf "# [ ] Example todo description one.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Two.todo.md")   \
    <(printf "# [ ] Example todo description two.\\n")

  diff                                    \
    <(cat "${NB_DIR}/home/Three.todo.md") \
    <(printf "# [ ] Example todo description three.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Undone: Three.todo.md'
}
