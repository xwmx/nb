#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# templates ###################################################################

@test "'add todo <title>' with assigned \$NB_DEFAULT_TEMPLATE skips the template and creates new todo." {
  {
    "${_NB}" init

    export NB_DEFAULT_TEMPLATE="Example template with no template tags."
  }

  run "${_NB}" add todo "Example todo title." \
    --related "http://example.com"            \
    --related "example:123"                   \
    --related "[[sample:456]]"                \
    --related "Example Title"                 \
    --tag     tag1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Related

- <http://example.com>
- [[example:123]]
- [[sample:456]]
- [[Example Title]]

## Tags

#tag1
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# edge cases ##################################################################

@test "'todo add check <multi-word> <description>' exits with 0, creates new todo with 'check <multi-word> <description>' as title, creates commit." {

  {
    "${_NB}" init
  }

  run "${_NB}" todo add check example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]


  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "# [ ] check example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ check\ example\ multi-word\ description\.\"  ]]
}

# `add todo` ##################################################################

@test "'add todo <title> --related <URL> --related <selector> --tag <tag>' exits with 0, creates new todo with <title> as title, related items, and tag, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add todo "Example todo title." \
    --related "http://example.com"            \
    --related "example:123"                   \
    --related "[[sample:456]]"                \
    --related "Example Title"                 \
    --tag     tag1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Related

- <http://example.com>
- [[example:123]]
- [[sample:456]]
- [[Example Title]]

## Tags

#tag1
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# aliases #####################################################################

@test "'todo a <multi-word> <description>' exits with 0, creates new todo with <multi-word> <description>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo a Example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]


  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\"  ]]
}

@test "'todo + <multi-word> <description>' exits with 0, creates new todo with <multi-word> <description>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo + Example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]


  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\"  ]]
}

# container selectors #########################################################

@test "'todo add <notebook>: <multi-word> <description>' exits with 0, creates new todo in <notebook> with <multi-word> <description>, creates commit." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" todo add Example\ Notebook: Example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                 ]]

  _home_files=($(ls "${NB_DIR}/home/"))

  [[ "${#_home_files[@]}" -eq 0             ]]

  _files=($(ls "${NB_DIR}/Example Notebook/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                 ]]
  [[ "${_files[0]}"   =~ ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/Example Notebook/${_files[0]}"

  diff                                                \
    <(cat "${NB_DIR}/Example Notebook/${_files[0]}")  \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/Example Notebook" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/Example Notebook" log | grep -q '\[nb\] Add'

  [[ "${lines[0]}"  =~  \
Added:\ .*\[.*Example\ Notebook:1.*\].*\ ✔️\ \ .*Example\ Notebook:[0-9]+\.todo\.md        ]]
  [[ "${lines[0]}"  =~  \
Example\ Notebook:[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\"  ]]
}

@test "'todo add <folder> <multi-word> <description>' exits with 0, creates new todo in <folder> with <multi-word> <description>, creates commit." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"
  }

  run "${_NB}" todo add Example\ Folder/ Example multi-word description.

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]

  _files=($(ls "${NB_DIR}/home/Example Folder/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/Example Folder/${_files[0]}"

  diff                                                        \
    <(cat "${NB_DIR}/home/Example Folder/${_files[0]}")       \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${lines[0]}"    =~  \
Added:\ .*\[.*Example\ Folder/1.*\].*\ ✔️\ \ .*Example\ Folder/[0-9]+\.todo\.md          ]]
  [[ "${lines[0]}"    =~  \
Example\ Folder/[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\"  ]]
}

# --related ###################################################################

@test "'todo add <title> --related <URL> --relared <selector>' exits with 0, creates new todo with <title> as title and related items, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." \
    --related "http://example.com"            \
    --related "example:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Related

- <http://example.com>
- [[example:123]]
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# --tag #######################################################################

@test "'todo add <title> --tag <one> --tag <two>' exits with 0, creates new todo with <title> as title and tags, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." \
    --tag "tag1"                              \
    --tag "tag2"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Tags

#tag1 #tag2
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# --task ######################################################################

@test "'todo add <title> --task <one> --task <two>' exits with 0, creates new todo with <title> as title and tasklist, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." \
    --task "Task title one."                  \
    --task "Task title two."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq  0                  ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Tasks

- [ ] Task title one.
- [ ] Task title two.
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# --description ###############################################################

@test "'todo add --description' with no <description> exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example content." --description

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 1                                   ]]
  [[ "${output}"      =~  \
\!.*\ .*--description.*\ requires\ a\ valid\ argument\.       ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 0                                   ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Add'
}

# --due #######################################################################

@test "'todo add --due' with no <date> exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example content." --due

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 1                     ]]
  [[ "${output}"      =~  \
\!.*\ .*--due.*\ requires\ a\ valid\ argument\. ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 0                     ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Add'
}

@test "'todo add <title> --description <description> --due <datetime>' exits with 0, creates new todo with <title> as title, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." \
    --description "Example description."      \
    --due         "2200-01-01"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(cat <<HEREDOC
# [ ] Example todo title.

## Due

2200-01-01

## Description

Example description.
HEREDOC
)

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

# todo add ####################################################################

@test "'todo add' with no <title> exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 1                 ]]
  [[ "${lines[0]}"    =~  Usage             ]]
  [[ "${lines[1]}"    =~  todo\ add         ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 0                 ]]

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -v -q '\[nb\] Add'
}

@test "'todo add <title>' exits with 0, creates new todo with <title> as title, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "# [ ] Example todo title.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <title> --edit' exits with 0, creates new todo with \$EDITOR, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." --edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "\
# [ ] Example todo title.
# mock_editor %s/home/%s\\n" "${NB_DIR}" "${_files[0]%.md}")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}

@test "'todo add <title> --description <description>' exits with 0, creates new todo with <title> and <description>, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" todo add "Example todo title." --description "Example description."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ todo\ title\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "\
# [ ] Example todo title.

## Description

Example description.\\n")

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

  [[ "${status}"      -eq 0                   ]]
  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ Title\ ·\ Example\ todo\ description\.\"  ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                  ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$ ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
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

  [[ "${status}"      -eq 0                   ]]


  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}"  -eq 1                   ]]
  [[ "${_files[0]}"   =~  ^[0-9]+\.todo\.md$  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                        \
    <(cat "${NB_DIR}/home/${_files[0]}")      \
    <(printf "# [ ] Example multi-word description.\\n")

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  [[ "${output}"      =~  \
Added:\ .*\[.*1.*\].*\ ✔️\ \ .*[0-9]+\.todo\.md.*\ \".*\[\ \].*\ Example\ multi-word\ description\.\"  ]]
}
