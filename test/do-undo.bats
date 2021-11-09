#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# error handling ##############################################################

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

  [[ "${status}"    -eq 1                                   ]]
  [[ "${output}"    =~  \!.*\ Item\ must\ be\ a\ todo:\ .*1 ]]

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

  [[ "${status}"    -eq 1                                   ]]
  [[ "${output}"    =~  \!.*\ Item\ must\ be\ a\ todo:\ .*1 ]]

  diff                                    \
    <(cat "${NB_DIR}/home/File One.md")   \
    <(printf "Example content one.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Done'
}

# done ########################################################################

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
Done:\ .*\[.*2.*\].*\ .*Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\" ]]

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

# do ##########################################################################

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
Done:\ .*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ .*Example\ Notebook:  ]]
  [[ "${output}"    =~  \
Example\ Notebook:Example\ Folder/Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\" ]]

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
Done:\ .*\[.*2.*\].*\ .*Two.todo.md.*\ \".*\[.*x.*\].*\ Example\ todo\ description\ two\.\" ]]

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

# undone ######################################################################

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
Undone:\ .*\[.*3.*\].*\ .*Three.todo.md.*\ \".*\[\ \].*\ Example\ todo\ description\ three\.\"  ]]

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

# undo ########################################################################

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
Undone:\ .*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ .*Example\ Notebook:  ]]
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
Undone:\ .*\[.*3.*\].*\ .*Three.todo.md.*\ \".*\[\ \].*\ Example\ todo\ description\ three\.\"  ]]

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
