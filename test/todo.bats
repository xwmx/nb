#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# todos #####################################################################

@test "'todos <notebook>:<folder>/' exits with 0 and lists todos." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"

    "${_NB}" use "home"
  }

  run "${_NB}" todos Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ !  "${output}" =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
  [[    "${lines[1]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ two\.      ]]
  [[    "${lines[2]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/1.*\].*\ ✅\ .*\[\ \].*\ Example\ todo\ description\ one\.      ]]
}

# todos closed ################################################################

@test "'todos closed <notebook>:<folder>/' exits with 0 and lists todos." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" use "Example Notebook"

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"

    "${_NB}" use "home"
  }

  run "${_NB}" todos closed Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ !  "${output}" =~  One   ]]
  [[ !  "${output}" =~  Two   ]]
  [[ !  "${output}" =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
}

# todos open ################################################################

@test "'todos open <id>' exits with 0 and undos todo." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"
  }

  run "${_NB}" todos open Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ !  "${output}" =~  One   ]]
  [[ !  "${output}" =~  Two   ]]
  [[ !  "${output}" =~  Four  ]]

  [[    "${lines[0]}" =~  \
Undone:\ .*[.*Example\ Folder/3.*].*\ ✅\ .*Example\ Folder/Three.todo.md   ]]
  [[    "${lines[0]}" =~  \
Three.todo.md.*\ \".*\[\ \].*\ Example\ todo\ description\ three\.\"        ]]
}

# todo do #####################################################################

@test "'todo do <notebook>:<folder>/<id>' exits with 0, updates todo, and commits." {
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

  run "${_NB}" todo "do" Example\ Notebook:Example\ Folder/2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✅\ .*Example\ Notebook:  ]]
  [[ "${output}"    =~  \
Example\ Notebook:Example\ Folder/Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\"  ]]

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

@test "'todo do <id>' exits with 0, updates todo, and commits." {
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

  run "${_NB}" todo "do" 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Done:\ .*\[.*2.*\].*\ ✅\ .*Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\" ]]

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

@test "'todo do' with no selector exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo "do"

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

# todos close #################################################################

@test "'todos close <id>' exits with 0 and does todo." {
  {
    "${_NB}" init

    "${_NB}" add                                        \
      --content "# [ ] Example todo description one."   \
      --filename "Example Folder/One.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [ ] Example todo description two."   \
      --filename "Example Folder/Two.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# [x] Example todo description three." \
      --filename "Example Folder/Three.todo.md"

    sleep 1

    "${_NB}" add                                        \
      --content "# Example description four."           \
      --filename "Example Folder/Four.md"
  }

  run "${_NB}" todos close Example\ Folder/2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0     ]]

  [[ !  "${output}" =~  One   ]]
  [[ !  "${output}" =~  Three ]]
  [[ !  "${output}" =~  Four  ]]

  [[    "${lines[0]}" =~  \
Done:\ .*[.*Example\ Folder/2.*].*\ ✅\ .*Example\ Folder/Two.todo.md ]]
  [[    "${lines[0]}" =~  \
Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\"   ]]
}

# todo undo #####################################################################

@test "'todo undo <notebook>:<folder>/<id>' exits with 0, updates todo, and commits." {
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

  run "${_NB}" todo "undo" Example\ Notebook:Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*Example\ Notebook:  ]]
  [[ "${output}"    =~  \
Example\ Notebook:Example\ Folder/Three.todo.md.*\ \".*\[\ \].*\ Example\ todo\ description\ three\.\"  ]]

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

@test "'todo undo <id>' exits with 0, updates todo, and commits." {
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

  run "${_NB}" todo "undo" 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0       ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*3.*\].*\ ✅\ .*Three.todo.md.*\ \".*\[\ \].*\ Example\ todo\ description\ three\.\"  ]]

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

@test "'todo undo' with no selector exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo "undo"

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
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Undone'
}

# todo add ####################################################################

@test "'todo add' with no <description> exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                       ]]
  [[ "${output}"  =~  \
\!.*\ .*add.*\ requires\ a\ valid\ argument\. ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0                    ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Add'
}

@test "'todo add <description>' exits with 0, creates new todo with <description> as title, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo description."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}"  =~  \
Added:\ .*\[.*1.*\].*\ ✅\ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ description\.\" ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1                  ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]}")    \
    <(printf "# [ ] Example todo description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <description> --edit' exits with 0, creates new todo with \$EDITOR, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo description." --edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}"  =~  \
Added:\ .*\[.*1.*\].*\ ✅\ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ description\.\" ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1                  ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]}")    \
    <(printf "\
# [ ] Example todo description.
# mock_editor %s/home/%s\\n" "${NB_DIR}" "${_files[0]%.md}")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <description> --content <content>' exits with 0, creates new todo with <description> and <content>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo description." --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                     ]]
  [[ "${output}"  =~  \
Added:\ .*\[.*1.*\].*\ ✅\ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ description\.\" ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1                  ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]}")    \
    <(printf "\
# [ ] Example todo description.

Example content.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <description> --content <content> --title <title>' exits with 0, creates new todo with <description>, <content>, and <title>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add           \
    "Example todo description."   \
    --content "Example content."  \
    --title   "Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                      ]]
  [[ "${output}"  =~  \
Added:\ .*\[.*1.*\].*\ ✅\ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ Title\ ·\ Example\ todo\ description\.\" ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1                  ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]}")    \
    <(printf "\
# [ ] Example Title · Example todo description.

Example content.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <multi-word> <description>' exits with 0, creates new todo with <multi-word> <description>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add Example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                      ]]


  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1                  ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]}")    \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${output}"  =~  \
Added:\ .*\[.*1.*\].*\ ✅\ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\" ]]
}
