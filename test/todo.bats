#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# todos #######################################################################

@test "'todos' with empty notebook exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todos

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  \!.*\ No\ todos\ found\.  ]]
}

@test "'todos open' with empty notebook exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todos open

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  \!.*\ No\ open\ todos\ found\.  ]]
}

@test "'todos <notebook>:' with empty notebook exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" todos Example\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                         ]]
  [[    "${#lines[@]}"  -eq 1                         ]]

  [[    "${lines[0]}"   =~  \!.*\ No\ todos\ found\.  ]]
}

@test "'todos open <notebook>:' with empty notebook exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" todos open Example\ Notebook:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 1                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  \!.*\ No\ open\ todos\ found\.  ]]
}

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

  [[    "${status}"   -eq 0     ]]

  [[ !  "${output}"   =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
  [[    "${lines[1]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ two\.     ]]
  [[    "${lines[2]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/1.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.     ]]
}

# todos closed / done #########################################################

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

  [[    "${status}"   -eq 0     ]]

  [[ !  "${output}"   =~  One   ]]
  [[ !  "${output}"   =~  Two   ]]
  [[ !  "${output}"   =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
}

@test "'todos done <notebook>:<folder>/' exits with 0 and lists todos." {
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

  run "${_NB}" todos "done" Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0     ]]

  [[ !  "${output}"   =~  One   ]]
  [[ !  "${output}"   =~  Two   ]]
  [[ !  "${output}"   =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:Example\ Folder/3.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ three\. ]]
}

# todos open ##################################################################

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

  [[    "${status}"    -eq  1 ]]
  [[    "${#lines[@]}" -eq  1 ]]

  [[    "${lines[0]}"   =~  .*!.*\ No\ open\ todos\ found\. ]]
}

@test "'todos open <notebook>:<folder>/' exits with 0 and lists open todos." {
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

  run "${_NB}" todos open Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0     ]]

  [[ !  "${output}" =~  Three ]]
  [[ !  "${output}" =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*[.*Example\ Folder/2.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[1]}" =~  \
.*[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
}

@test "'todos undone <notebook>:<folder>/' exits with 0 and lists open todos." {
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

  run "${_NB}" todos "undone" Example\ Notebook:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0     ]]

  [[ !  "${output}"   =~  Three ]]
  [[ !  "${output}"   =~  Four  ]]

  [[    "${lines[0]}" =~  \
.*[.*Example\ Folder/2.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ two\.  ]]
  [[    "${lines[1]}" =~  \
.*[.*Example\ Folder/1.*].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ one\.  ]]
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
Done:\ .*\[.*Example\ Notebook:Example\ Folder/2.*\].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]

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

# todos close / done ##########################################################

@test "'todos close <id>' exits with 0 and checks todo." {
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

  [[    "${status}"    -eq 0    ]]

  [[ !  "${output}"   =~  One   ]]
  [[ !  "${output}"   =~  Three ]]
  [[ !  "${output}"   =~  Four  ]]

  [[    "${lines[0]}" =~  \
Done:\ .*[.*Example\ Folder/2.*].*\ ✅\ .*\[.*x.*\].*\ Example\ todo\ description\ two\.  ]]
}

@test "'todos done <id>' exits with 0 and checks todo." {
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

  run "${_NB}" todos "done" Example\ Folder/2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1 ]]
  [[    "${#lines[@]}" -eq 1 ]]

  [[    "${lines[0]}"   =~  .*!.*\ No\ closed\ todos\ found\. ]]
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

  [[ "${status}"    -eq 0                 ]]
  [[ "${output}"    =~  \
Undone:\ .*\[.*3.*\].*\ ✔️\ \ .*\[\ \].*\ Example\ todo\ description\ three\.  ]]

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

  [[ "${status}"      -eq 1               ]]
  [[ "${lines[0]}"    =~  Usage.*:        ]]
  [[ "${lines[1]}"    =~  ${_ME}\ todo    ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 0               ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Undone'
}
