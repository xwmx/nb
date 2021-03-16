#!/usr/bin/env bats

load test_helper

# search-based pinning integration ############################################

@test "'pin' integrates with search-based pinning and preserves .pindex order." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"   --content "#pinned"
    "${_NB}" add "File Three.md"  --title "Title Three"
    "${_NB}" add "File Four.md"   --title "Title Four"

    "${_NB}" pin 1
    "${_NB}" pin 4

    diff                                        \
      <(printf "File One.md\\nFile Four.md\\n") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  NB_PINNED_PATTERN="#pinned" run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 4                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ 📌\ Title\ Four ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ 📌\ Title\ Two  ]]
  [[ "${lines[3]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
}

@test "'pin' and search-based pinning preserve .pindex order and don't duplicate pinned entries." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"   --content "#pinned"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"
    "${_NB}" add "File Four.md"   --title "Title Four"

    "${_NB}" pin 1
    "${_NB}" pin 4

    diff                                        \
      <(printf "File One.md\\nFile Four.md\\n") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  NB_PINNED_PATTERN="#pinned" run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 4                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ 📌\ Title\ Four ]]
  [[ "${lines[2]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[3]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]
}

# error handling ##############################################################

@test "'pin' with not-valid selector prints message." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex") || return 0
  }

  run "${_NB}" pin not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex") || return 0

  # prints message

  [[ "${output}" =~ Not\ found:\ .*not-valid ]]

  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File One.md' || return 0
}

@test "'unpin' with not-valid selector prints message." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  run "${_NB}" unpin not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  # prints message

  [[ "${output}" =~ Not\ found:\ .*not-valid ]]

  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md' || return 0
}

@test "'pin' with already-pinned selector exits with 1 and prints message." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title One"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  run "${_NB}" pin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  # prints message

  [[ "${output}" =~ Already\ pinned:\ .*File\ One.md ]]

  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ "$(git log | grep -c '\[nb\] Pinned: File One.md')" -eq 1 ]]
}

@test "'unpin' with not-pinned selector prints message." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title One"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  run "${_NB}" unpin File\ Two.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  # prints message

  [[ "${output}" =~ Not\ pinned:\ .*File\ Two.md ]]

  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File Two.md' || return 0
}

@test "'pin' with no selector prints help." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder"  --type folder

    diff                                  \
      <(printf "%s\\n" "Example Folder")  \
      <(cat "${NB_DIR}/home/.pindex") || return 0
  }

  run "${_NB}" pin

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                                  \
    <(printf "%s\\n" "Example Folder")  \
    <(cat "${NB_DIR}/home/.pindex") || return 0

  # prints help

  [[ "${output}" =~ Usage:      ]]
  [[ "${output}" =~ nb\ pin     ]]


  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: Example Folder' || return 0
}

@test "'unpin' with no selector prints help." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder"  --type folder

    "${_NB}" pin "Example Folder"

    diff                                  \
      <(printf "%s\\n" "Example Folder")  \
      <(cat "${NB_DIR}/home/.pindex")
  }

  run "${_NB}" unpin

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 1

  [[ "${status}" -eq 1 ]]

  # does not change pindex

  diff                                  \
    <(printf "%s\\n" "Example Folder")  \
    <(cat "${NB_DIR}/home/.pindex") || return 0

  # prints help

  [[ "${output}" =~ Usage:      ]]
  [[ "${output}" =~ nb\ unpin   ]]


  # does not create  git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: Example Folder' || return 0
}

# pin / unpin #################################################################

@test "'pin <filename>' and 'unpin <filename>' pin and unpin items." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One    ]]

  # `pin` an item

  run "${_NB}" pin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1               ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  ^File\ One.md$  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*1.*].*\ .*File\ One.md      ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File One.md'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]

  # `pin` an item

  run "${_NB}" pin File\ Two.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md${_NEWLINE}File Two.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 2             ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  File\ One.md  ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  File\ Two.md  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*2.*].*\ .*File\ Two.md    ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File Two.md'

  # `list` with two pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ 📌\ Title\ Two  ]]
  [[ "${lines[2]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]

  # `unpin` an item

  run "${_NB}" unpin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File Two.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[    "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1            ]]
  [[ !  "$(cat "${NB_DIR}/home/.pindex")"      =~  File\ One.md ]]
  [[    "$(cat "${NB_DIR}/home/.pindex")"      =~  File\ Two.md ]]

  # prints output

  [[    "${output}" =~ Unpinned:\ .*[.*1.*].*\ .*File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*2.*].*\ 📌\ Title\ Two  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One      ]]
}

# pin #########################################################################

@test "'pin <filename>' adds an item to the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One    ]]

  # `pin` an item

  run "${_NB}" pin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1               ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  ^File\ One.md$  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*1.*].*\ .*File\ One.md      ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File One.md'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]
}

@test "'pin <id>' adds an item to the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  run "${_NB}" pin 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1               ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  ^File\ One.md$  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*1.*].*\ .*File\ One.md      ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File One.md'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]
}

@test "'pin <title>' adds an item to the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  run "${_NB}" pin Title\ One

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1               ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  ^File\ One.md$  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*1.*].*\ .*File\ One.md      ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: File One.md'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]] 
}

@test "'pin <folder-name>' adds a folder to the parent folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder" --type  "folder"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  run "${_NB}" pin Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                                  \
    <(printf "%s\\n" "Example Folder")  \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1                 ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  Example\ Folder$  ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*3.*].*\ .*Example\ Folder     ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: Example Folder'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ 📌\ 📂\ Example\ Folder ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ Title\ Three            ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two              ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One              ]]
}

@test "'pin <folder-id>' adds a folder to the parent folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder"  --type "folder"
    "${_NB}" add "File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  run "${_NB}" pin 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                                  \
    <(printf "%s\\n" "Example Folder")  \
    <(cat "${NB_DIR}/home/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/.pindex")"  -eq 1                   ]]
  [[ "$(cat "${NB_DIR}/home/.pindex")"      =~  ^Example\ Folder$   ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*3.*].*\ .*Example\ Folder       ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: Example Folder'

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ 📌\ 📂\ Example\ Folder ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ Title\ Three            ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two              ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One              ]]
}

@test "'pin <dolder>/<id>' adds an item to the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/home/.pindex" ]]
  }

  run "${_NB}" pin Example\ Folder/File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/home/Example Folder/.pindex")

  [[ "$(wc -l < "${NB_DIR}/home/Example Folder/.pindex")"  -eq 1              ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.pindex")"      =~  ^File\ One.md$ ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*Example\ Folder/1.*].*\ .*File\ One.md  ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: Example Folder/File One.md'

  # `list` with one pinned item

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]
}

@test "'pin <notebook>:<dolder>/<id>' adds an item to the folder's .pindex." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Notebook:Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Notebook:Example Folder/File Three.md"  --title "Title Three"

    [[ ! -e "${NB_DIR}/Example Notebook/.pindex" ]]
  }

  # `pin` an item

  run "${_NB}" pin Example\ Notebook:Example\ Folder/File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/.pindex")

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # updates pindex

  diff                              \
    <(printf "%s\\n" "File One.md") \
    <(cat "${NB_DIR}/Example Notebook/Example Folder/.pindex")

  [[ "$(wc -l < "${NB_DIR}/Example Notebook/Example Folder/.pindex")"  -eq 1                      ]]
  [[ "$(cat "${NB_DIR}/Example Notebook/Example Folder/.pindex")"      =~  ^File\ One.md$         ]]

  # prints output

  [[ "${output}" =~ Pinned:\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*File\ One.md  ]]

  # creates git commit

  cd "${NB_DIR}/Example Notebook"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Pinned: Example Folder/File One.md'

  # `list` with one pinned item

  run "${_NB}" list Example\ Notebook:Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/2.*].*\ Title\ Two      ]]
}

# unpin #######################################################################

@test "'unpin <filename>' removes an item from the folder's .pindex without unpinning other pinned items." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"
    "${_NB}" add "File Four.md"   --title "Title Four"

    "${_NB}" pin "File One.md"
    "${_NB}" pin "File Three.md"

    diff                                          \
      <(printf "File One.md\\nFile Three.md\\n")  \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                               ]]
  [[ "${#lines[@]}" -eq 4                               ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One    ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ 📌\ Title\ Three  ]]
  [[ "${lines[2]}"  =~  \.*[.*4.*].*\ Title\ Four       ]]
  [[ "${lines[3]}"  =~  \.*[.*2.*].*\ Title\ Two        ]]

  # `unpin` an item

  run "${_NB}" unpin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes item from the .pindex file

    diff                            \
      <(printf "File Three.md\\n")  \
      <(cat "${NB_DIR}/home/.pindex")

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*1.*].*\ .*File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                               ]]
  [[ "${#lines[@]}" -eq 4                               ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ 📌\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ Title\ Four       ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two        ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One        ]]
}

@test "'unpin <filename>' removes an item from the folder's .pindex when it's the last pinned item." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]

  # `unpin` an item

  run "${_NB}" unpin File\ One.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*1.*].*\ .*File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One    ]]
}

@test "'unpin <id>' removes an item from the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]

  # `unpin` an item

  run "${_NB}" unpin 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*1.*].*\ .*File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One    ]]
}

@test "'unpin <title>' removes an item from the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    "${_NB}" pin "File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${lines[0]}"  =~  \.*[.*1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two      ]]

  # `unpin` an item

  run "${_NB}" unpin Title\ One

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*1.*].*\ .*File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: File One.md'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                           ]]
  [[ "${#lines[@]}" -eq 3                           ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*1.*].*\ Title\ One    ]]
}

@test "'unpin <folder-name>' removes a folder from the parent folder's .pindex." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder"  --type "folder"
    "${_NB}" add "File Three.md"  --title "Title Three"

    "${_NB}" pin "Example Folder"

    diff                                  \
      <(printf "%s\\n" "Example Folder")  \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ 📌\ 📂\ Example\ Folder ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ Title\ Three            ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two              ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One              ]]

  # `unpin` an item

  run "${_NB}" unpin Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*3.*].*\ .*Example\ Folder ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: Example Folder'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]
  [[ "${#lines[@]}" -eq 4                                 ]]

  [[ "${lines[0]}"  =~  \.*[.*4.*].*\ Title\ Three        ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ 📂\ Example\ Folder ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two          ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One          ]]
}

@test "'unpin <folder-id>' removes a folder from the parent folder's .pindex." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder"  --type folder
    "${_NB}" add "File Three.md"  --title "Title Three"

    "${_NB}" pin "Example Folder"

    diff                                  \
      <(printf "%s\\n" "Example Folder")  \
      <(cat "${NB_DIR}/home/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${#lines[@]}" -eq 4                                     ]]

  [[ "${lines[0]}"  =~  \.*[.*3.*].*\ 📌\ 📂\ Example\ Folder ]]
  [[ "${lines[1]}"  =~  \.*[.*4.*].*\ Title\ Three            ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two              ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One              ]]

  # `unpin` an item

  run "${_NB}" unpin 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*3.*].*\ .*Example\ Folder ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: Example Folder'

  # `list` with no pinned items

  run "${_NB}" list --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]
  [[ "${#lines[@]}" -eq 4                                 ]]

  [[ "${lines[0]}"  =~  \.*[.*4.*].*\ Title\ Three        ]]
  [[ "${lines[1]}"  =~  \.*[.*3.*].*\ 📂\ Example\ Folder ]]
  [[ "${lines[2]}"  =~  \.*[.*2.*].*\ Title\ Two          ]]
  [[ "${lines[3]}"  =~  \.*[.*1.*].*\ Title\ One          ]]
}

@test "'unpin <folder>/<id>' removes an item from the folder's .pindex." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    "${_NB}" pin "Example Folder/File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/home/Example Folder/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}"  =~  \.*[.*Example\ Folder/1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*Example\ Folder/3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*Example\ Folder/2.*].*\ Title\ Two      ]]

  # `unpin` an item

  run "${_NB}" unpin Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/home/Example Folder/.pindex" ]]

  # prints output

  [[ "${output}" =~ Unpinned:\ .*[.*Example\ Folder/1.*].*\ .*Example\ Folder/File\ One.md ]]

  # creates git commit

  cd "${NB_DIR}/home"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: Example Folder/File One.md'

  # `list` with no pinned items

  run "${_NB}" list Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]
  [[ "${#lines[@]}" -eq 3                                           ]]

  [[ "${lines[0]}"  =~  \.*[.*Example\ Folder/3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*Example\ Folder/2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*Example\ Folder/1.*].*\ Title\ One    ]]
}

@test "'unpin <notebook>:<folder>/<id>' removes an item from the folder's .pindex." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Notebook:Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Notebook:Example Folder/File Three.md"  --title "Title Three"

    [[ -f "${NB_DIR}/Example Notebook/Example Folder/File One.md" ]]

    "${_NB}" pin "Example Notebook:Example Folder/File One.md"

    diff                              \
      <(printf "%s\\n" "File One.md") \
      <(cat "${NB_DIR}/Example Notebook/Example Folder/.pindex")
  }

  # `list` with one pinned item

  run "${_NB}" list Example\ Notebook:Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/1.*].*\ 📌\ Title\ One  ]]
  [[ "${lines[1]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/3.*].*\ Title\ Three    ]]
  [[ "${lines[2]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/2.*].*\ Title\ Two      ]]

  # `unpin` an item

  run "${_NB}" unpin Example\ Notebook:Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # removes the pindex when it's last

  [[ ! -e "${NB_DIR}/Example Notebook/Example Folder/.pindex" ]]

  # prints output

  [[ "${lines[0]}" =~ Unpinned:\ .*[.*Example\ Notebook:Example\ Folder/1.*].*\ .*Example ]]
  [[ "${lines[0]}" =~ Example\ Notebook:Example\ Folder/File\ One.md                      ]]

  # creates git commit

  cd "${NB_DIR}/Example Notebook"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Unpinned: Example Folder/File One.md'

  # `list` with no pinned items

  run "${_NB}" list Example\ Notebook:Example\ Folder/ --with-pinned

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                             ]]
  [[ "${#lines[@]}" -eq 3                                                             ]]

  [[ "${lines[0]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/3.*].*\ Title\ Three  ]]
  [[ "${lines[1]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/2.*].*\ Title\ Two    ]]
  [[ "${lines[2]}"  =~  \.*[.*Example\ Notebook:Example\ Folder/1.*].*\ Title\ One    ]]
}
