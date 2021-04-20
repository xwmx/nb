#!/usr/bin/env bats

load test_helper

# local #######################################################################

@test "'add <selector-with-folder-and-filename>' adds to local notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks init "${_TMP_DIR}/Example Local"

    cd "${_TMP_DIR}/Example Local"

    [[ "$(pwd)" == "${_TMP_DIR}/Example Local" ]]

  }

  run "${_NB}" add  "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --title         "Title One"                                                 \
    --content       "Content one."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[ -f "${_TMP_DIR}/Example Local/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]

  cat "${_TMP_DIR}/Example Local/Example Folder/Sample Folder/Demo Folder/Example File.md"

  diff                                                                                          \
    <(cat "${_TMP_DIR}/Example Local/Example Folder/Sample Folder/Demo Folder/Example File.md") \
    <(printf "# Title One\\n\\nContent one.\\n")

  cd "${_TMP_DIR}/Example Local" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       \ .*Example\ Folder/Sample\ Folder/Demo\ Folder/Example\ File.md ]]
  [[ "${output}" =~ \
       Added:\ .*[.*Example\ Folder/Sample\ Folder/Demo\ Folder/1.*]    ]]
}

# arguments ##################################################################

@test "'add <selector-with-folder>/ --filename <relative-path> --folder <notebook> <folder> <content>' (slash) creates file at <selector-with-folder>/<relative-path> containing <notebook>, <folder>, and <content> as content." {
  {
    "${_NB}" init

    "${_NB}" add "Test Folder" --type "folder"
    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" add          \
    "Example Folder/"       \
    "Example Notebook:"     \
    "Test Folder/"          \
    "Example content."      \
    --folder "Demo Folder"  \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[    -f "${NB_DIR}/home/Example Folder/Demo Folder/Sample Folder/Sample File.md" ]]

  cat "${NB_DIR}/home/Example Folder/Demo Folder/Sample Folder/Sample File.md"

  diff                                                                              \
    <(cat "${NB_DIR}/home/Example Folder/Demo Folder/Sample Folder/Sample File.md") \
    <(printf "Example Notebook: Test Folder/ Example content.\\n")

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       \ .*Example\ Folder/Demo\ Folder/Sample\ Folder/Sample\ File.md ]]
  [[ "${output}" =~ \
       Added:\ .*[.*Example\ Folder/Demo\ Folder/Sample\ Folder/1.*]   ]]
}

# --filename ##################################################################

@test "'add --filename <relative-path>' option creates file at <relative-path>." {
  {
    "${_NB}" init
  }

  run "${_NB}" add    \
    "Sample content." \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[    -f "${NB_DIR}/home/Sample Folder/Sample File.md" ]]

  cd "${NB_DIR}/home" || return 1

  grep -q "Sample content." "${NB_DIR}/home/Sample Folder/Sample File.md"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       Added:\ .*[.*Sample\ Folder/1.*].*\ .*Sample\ Folder/Sample\ File.md ]]
}

@test "'add <selector-with-filename> --filename <relative-path>' option overrides selector with <relative-path>." {
  {
    "${_NB}" init
  }

  run "${_NB}" add                    \
    "Example Folder/Example File.md"  \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[ !  -e "${NB_DIR}/home/Example Folder/Example File.md"  ]]
  [[    -f "${NB_DIR}/home/Sample Folder/Sample File.md"    ]]

  cd "${NB_DIR}/home" || return 1

  grep -q "Example Folder/Example File.md" "${NB_DIR}/home/Sample Folder/Sample File.md"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       Added:\ .*[.*Sample\ Folder/1.*].*\ .*Sample\ Folder/Sample\ File.md ]]
}

@test "'add <selector-with-folder>/ --filename <relative-path>' (slash) creates file at <selector-with-folder>/<relative-path>." {
  {
    "${_NB}" init
  }

  run "${_NB}" add    \
    "Example Folder/" \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[ !  -e "${NB_DIR}/home/Example Folder/Sample File.md"               ]]
  [[    -f "${NB_DIR}/home/Example Folder/Sample Folder/Sample File.md" ]]

  cd "${NB_DIR}/home" || return 1

  grep -q  "mock_editor"  "${NB_DIR}/home/Example Folder/Sample Folder/Sample File.md"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       \ .*Example\ Folder/Sample\ Folder/Sample\ File.md ]]
  [[ "${output}" =~ \
       Added:\ .*[.*Example\ Folder/Sample\ Folder/1.*]   ]]
}

@test "'add <selector-with-folder>/ --filename <relative-path> --folder <folder>' (slash) creates file at <selector-with-folder>/<folder>/<relative-path>." {
  {
    "${_NB}" init
  }

  run "${_NB}" add          \
    "Example Folder/"       \
    --folder "Demo Folder"  \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[    -f "${NB_DIR}/home/Example Folder/Demo Folder/Sample Folder/Sample File.md" ]]

  cd "${NB_DIR}/home" || return 1

  grep -q  "mock_editor"  "${NB_DIR}/home/Example Folder/Demo Folder/Sample Folder/Sample File.md"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       \ .*Example\ Folder/Demo\ Folder/Sample\ Folder/Sample\ File.md ]]
  [[ "${output}" =~ \
       Added:\ .*[.*Example\ Folder/Demo\ Folder/Sample\ Folder/1.*]   ]]
}

@test "'add <selector-with-folder> --filename <relative-path>' (no slash) creates file at relative-path> and <selector-with-folder>  as content." {
  {
    "${_NB}" init
  }

  run "${_NB}" add    \
    "Example Folder"  \
    --filename "Sample Folder/Sample File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[ !  -e "${NB_DIR}/home/Example Folder/Example File.md"  ]]
  [[    -f "${NB_DIR}/home/Sample Folder/Sample File.md"    ]]

  cd "${NB_DIR}/home" || return 1

  grep -q             \
    "Example Folder"  \
    "${NB_DIR}/home/Sample Folder/Sample File.md"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  [[ "${output}" =~ \
       Added:\ .*[.*Sample\ Folder/1.*].*\ .*Sample\ Folder/Sample\ File.md ]]
}

# <folder>/ <filename> ########################################################

@test "'add <not-a-folder-name> <string>' (no slash) creates new file containing content <not-a-folder-name> and <string> separated by a space." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder"                     ]]
    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/.index"              ]]
    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/example-filename.md" ]]
  }

  run "${_NB}" add Example\ Not\ A\ Folder Sample\ String

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  # Creates file:

  _files=($(LC_ALL=C ls "${NB_DIR}/home/"))

  [[   -n "${_files[0]:-}"                                            ]]

  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder"                     ]]
  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/.index"              ]]
  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/example-filename.md" ]]
  [[   -e "${NB_DIR:-}/home/${_files[0]}"                             ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[    -e "${NB_DIR}/home/.index"                      ]]
  [[ !  -e "${NB_DIR}/home/Example Not A Folder/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ ${_files[0]:-}  ]]

  # File contains content:

  printf "cat: '%s'\\n" "$(cat "${NB_DIR}/home/${_files[0]:-}")"

  diff                                                \
    <(printf "Example Not A Folder Sample String\\n") \
    <(cat "${NB_DIR}/home/${_files[0]:-}")
}

@test "'add <folder> <filename>' (no slash) creates new file with <filename> and the string in <folder> as content." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -e "${NB_DIR:-}/home/Example Folder"                     ]]
    [[   -e "${NB_DIR:-}/home/Example Folder/.index"              ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/example-filename.md" ]]
  }

  run "${_NB}" add Example\ Folder "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  # Creates folder and files:

  [[   -e "${NB_DIR:-}/home/Example Folder"                     ]]
  [[   -e "${NB_DIR:-}/home/Example Folder/.index"              ]]
  [[ ! -e "${NB_DIR:-}/home/Example Folder/example-filename.md" ]]
  [[   -e "${NB_DIR:-}/home/example-filename.md"                ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: example-filename.md'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]
  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:              ]]
  [[ "${output}" =~ example-filename.md ]]

  # File contains content:

  diff                            \
    <(printf "Example Folder\\n") \
    <(cat "${NB_DIR}/home/example-filename.md")
}

@test "'add <not-a-folder-name> <filename>' (no slash) creates new file with <filename> containing content <not-a-folder-name>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder"                     ]]
    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/.index"              ]]
    [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/example-filename.md" ]]
  }

  run "${_NB}" add Example\ Not\ A\ Folder "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  # Creates folder and files:

  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder"                     ]]
  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/.index"              ]]
  [[ ! -e "${NB_DIR:-}/home/Example Not A Folder/example-filename.md" ]]
  [[   -e "${NB_DIR:-}/home/example-filename.md"                      ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: example-filename.md'

  # Adds to index:

  [[    -e "${NB_DIR}/home/.index"                      ]]
  [[ !  -e "${NB_DIR}/home/Example Not A Folder/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:              ]]
  [[ "${output}" =~ example-filename.md ]]

  # File contains content:

  diff                                  \
    <(printf "Example Not A Folder\\n") \
    <(cat "${NB_DIR}/home/example-filename.md")
}

@test "'add <folder>/ <filename>' (slash) creates new file with <filename> in new <folder>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"                     ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"              ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/example-filename.md" ]]
  }

  run "${_NB}" add Example\ Folder/ "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  # Creates folder and files:

  [[   -e "${NB_DIR:-}/home/Example Folder"                     ]]
  [[   -e "${NB_DIR:-}/home/Example Folder/.index"              ]]
  [[   -e "${NB_DIR:-}/home/Example Folder/example-filename.md" ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example Folder/example-filename.md'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]
  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add <name-1> <name-2> --type folder' (no slash) creates new folder with <name-1>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"         ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"  ]]
    [[ ! -e "${NB_DIR:-}/home/Sample Folder"          ]]
    [[ ! -e "${NB_DIR:-}/home/Sample Folder/.index"   ]]
  }

  run "${_NB}" add  \
    Example\ Folder \
    Sample\ Folder  \
    --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  [[    -d "${NB_DIR}/home/Example Folder"        ]]
  [[    -e "${NB_DIR}/home/Example Folder/.index" ]]
  [[ !  -e "${NB_DIR}/home/Sample Folder"         ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example Folder'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index" ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ Example\ Folder ]]
}

@test "'add <folder>/ <folder-name> --type folder' (slash) creates new folder with <folder-name> in new <folder>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"                     ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/example-folder-name" ]]
  }

  run "${_NB}" add        \
    Example\ Folder/      \
    "example-folder-name" \
    --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path indexes:

  [[ !  -e "${NB_DIR}/home/example-folder-name"                       ]]
  [[    -d "${NB_DIR}/home/Example Folder/example-folder-name"        ]]
  [[    -f "${NB_DIR}/home/Example Folder/.index"                     ]]
  [[    -f "${NB_DIR}/home/Example Folder/example-folder-name/.index" ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example Folder/example-folder-name'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-folder-name ]]
}

# --folder option #############################################################

@test "'add --folder <folder> --filename <folder-name> --type folder' creates new folders without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"                     ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/example-folder-name" ]]
  }

  run "${_NB}" add            \
    --folder Example\ Folder  \
    --type folder             \
    --filename "example-folder-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path indexes:

  [[ !  -e "${NB_DIR}/home/example-folder-name"                       ]]
  [[    -d "${NB_DIR}/home/Example Folder/example-folder-name"        ]]
  [[    -f "${NB_DIR}/home/Example Folder/.index"                     ]]
  [[    -f "${NB_DIR}/home/Example Folder/example-folder-name/.index" ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-folder-name ]]
}

@test "'add --folder <folder> --type folder' creates new folders without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/folder"     ]]
  }

  run "${_NB}" add            \
    --folder Example\ Folder  \
    --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path and indexes:

  [[ !  -e "${NB_DIR}/home/folder"                        ]]
  [[    -d "${NB_DIR}/home/Example Folder/folder"         ]]
  [[    -f "${NB_DIR}/home/Example Folder/.index"         ]]
  [[    -f "${NB_DIR}/home/Example Folder/folder/.index"  ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                      ]]
  [[ "${output}" =~ Example\ Folder/folder      ]]
}

@test "'add --folder <folder> --filename' (no slash) creates new file and folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add              \
    --folder Example\ Folder    \
    --content "# Example Title" \
    --filename "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ example-filename.md          ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add --folder <folder>' (no slash) creates new file and folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add              \
    --folder Example\ Folder    \
    --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ [0-9]+.md                    ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                      ]]
  [[ "${output}" =~ Example\ Folder/[0-9]+.md   ]]
}

@test "'add --folder <folder>/ --filename' (slash) creates new file and folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add --folder Example\ Folder/ --content "# Example Title" \
    --filename "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ example-filename.md          ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add --folder <folder>/' (slash) creates new file and folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add Example\ Folder/ --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ [0-9]+.md                    ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                 ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  [[ -e "${NB_DIR}/home/Example Folder/.index"  ]]

  diff                                    \
    <(ls "${NB_DIR}/home/Example Folder") \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ Example\ Folder/[0-9]+.md ]]
}

# <id>/ #####################################################################

@test "'add folder <id>/' (trailing slash) creates new nested folder without errors." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -d "${NB_DIR}/home/Example Folder"                      ]]
    [[   -f "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "1/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  [[ -d "${NB_DIR}/home/Example Folder/folder"          ]]
  [[ -f "${NB_DIR}/home/Example Folder/folder/.index"   ]]

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "_files: ${_files[*]}"

  [[ -d "${NB_DIR}/home/Example Folder"                 ]]
  [[ "${#_files[@]}"  == 5                              ]]
  [[ "${_files[3]}"   == ".index"                       ]]
  [[ "${_files[4]}"   == "Example Folder"               ]]


  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  echo "_folder_files: ${_folder_files[*]}"

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  [[ "${#_folder_files[@]}" == 4                        ]]
  [[ "${_folder_files[2]}"  == ".index"                 ]]
  [[ "${_folder_files[3]}"  == "folder"                 ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  # Prints output:

  [[    "${output}" =~ Added:                 ]]
  [[    "${output}" =~ 📂                     ]]
  [[    "${output}" =~ Example\ Folder/folder ]]
  [[ !  "${output}" =~ \.                     ]]
}

@test "'add folder <id>/' (trailing slash) creates new nested folder with incremented name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Example Folder/folder" --type folder

    [[   -d "${NB_DIR}/home/Example Folder"                      ]]
    [[   -f "${NB_DIR}/home/Example Folder/.index"               ]]
    [[   -d "${NB_DIR}/home/Example Folder/folder"               ]]
    [[   -f "${NB_DIR}/home/Example Folder/folder/.index"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/folder-1"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "1/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  [[ -d "${NB_DIR}/home/Example Folder/folder-1"        ]]
  [[ -f "${NB_DIR}/home/Example Folder/folder-1/.index" ]]

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "_files:  ${_files[*]}"
  echo "#_files: ${#_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"     ]]
  [[ "${#_files[@]}"  == 5                  ]]
  [[ "${_files[3]}"   == ".index"           ]]
  [[ "${_files[4]}"   == "Example Folder"   ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  echo "_folder_files: ${_folder_files[*]}"

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  [[ "${#_folder_files[@]}" == 5                        ]]
  [[ "${_folder_files[2]}"  == ".index"                 ]]
  [[ "${_folder_files[3]}"  == "folder"                 ]]
  [[ "${_folder_files[4]}"  == "folder-1"               ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  # Prints output:

  [[    "${output}" =~ Added:                   ]]
  [[    "${output}" =~ 📂                       ]]
  [[    "${output}" =~ Example\ Folder/folder-1 ]]
  [[ !  "${output}" =~ \.                       ]]
}

@test "'add folder <id>/<folder>' creates new nested folder without errors." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -d "${NB_DIR}/home/Example Folder"                      ]]
    [[   -f "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "1/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "_files: ${_files[*]}"

  [[ -d "${NB_DIR}/home/Example Folder"                 ]]
  [[ "${#_files[@]}"  == 5                              ]]
  [[ "${_files[3]}"   == ".index"                       ]]
  [[ "${_files[4]}"   == "Example Folder"               ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  echo "_folder_files: ${_folder_files[*]}"

  [[   -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  [[ "${#_folder_files[@]}" == 4                        ]]
  [[ "${_folder_files[2]}"  == ".index"                 ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"          ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[   -f "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  # Prints output:

  [[    "${output}" =~ Added:                         ]]
  [[    "${output}" =~ 📂                             ]]
  [[    "${output}" =~ Example\ Folder/Sample\ Folder ]]
  [[ !  "${output}" =~ \.                             ]]
  [[ !  "${output}" =~ folder                         ]]
}

@test "'add <id>/ --filename' creates new note without errors." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -d "${NB_DIR:-}/home/Example Folder"         ]]
    [[   -f "${NB_DIR:-}/home/Example Folder/.index"  ]]
  }

  run "${_NB}" add 1/ --content "# Example Title" \
    --filename "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ example-filename.md          ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  printf "ls  Example Folder:         '%s'\\n"  \
    "$(ls "${NB_DIR}/home/Example Folder/")"
  printf "cat Example Folder/.index:  '%s'\\n"  \
    "$(cat "${NB_DIR}/home/Example Folder/.index")"

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add <id>/' creates new note without errors." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -d "${NB_DIR}/home/Example Folder"             ]]
    [[   -f "${NB_DIR:-}/home/Example Folder/.index"    ]]
  }

  run "${_NB}" add 1/ --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ [0-9]+.md                    ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ Example\ Folder/[0-9]+.md ]]
}

# folder/ #####################################################################

@test "'add folder <folder>/' (trailing slash) creates new nested folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "Example Folder/"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "_files: ${_files[*]}"

  [[ -d "${NB_DIR}/home/Example Folder"                 ]]
  [[ "${#_files[@]}"  == 5                              ]]
  [[ "${_files[3]}"   == ".index"                       ]]
  [[ "${_files[4]}"   == "Example Folder"               ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  echo "_folder_files: ${_folder_files[*]}"

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder" ]]
  [[ "${#_folder_files[@]}" == 4                        ]]
  [[ "${_folder_files[2]}"  == ".index"                 ]]
  [[ "${_folder_files[3]}"  != "Sample Folder"          ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  # Prints output:

  [[    "${output}" =~ Added:                   ]]
  [[    "${output}" =~ 📂                       ]]
  [[    "${output}" =~ Example\ Folder/folder   ]]
  [[ !  "${output}" =~ \.                       ]]
}

@test "'add <folder>/ --filename' creates new note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add Example\ Folder/ --content "# Example Title" \
    --filename "example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ example-filename.md          ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add <folder>/' creates new note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR:-}/home/Example Folder"            ]]
    [[ ! -e "${NB_DIR:-}/home/Example Folder/.index"     ]]
  }

  run "${_NB}" add Example\ Folder/ --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[    "${#_files[@]}"  == 5                                   ]]
  [[    "${_files[3]}"   == ".index"                            ]]
  [[    "${_files[4]}"   == "Example Folder"                    ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[    "${#_folder_files[@]}"  == 4                            ]]
  [[    "${_folder_files[2]}"   == ".index"                     ]]
  [[    "${_folder_files[3]}"   =~ [0-9]+.md                    ]]
  [[ -e "${NB_DIR}/home/Example Folder/${_folder_files[3]}"     ]]

  printf "File:\\n"
  cat "${NB_DIR}/home/Example Folder/${_folder_files[3]}"

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                    ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"            ]]

  # Prints output:

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ Example\ Folder/[0-9]+.md ]]
}

# uniqueness ##################################################################

@test "'add <folder>/<folder>/example.md' with existing file at target creates file with unique filename." {
  {
    "${_NB}" init

    _folder_path="${NB_DIR}/home/Example Folder/Sample Folder"
    _existing_file_path="${_folder_path}/example-filename.md"
    _new_file_path="${_folder_path}/example-filename-1.md"

    mkdir -p "${_folder_path}"

    printf "# Example Title" > "${_existing_file_path}"
    cat "${_existing_file_path}"

    "${_NB}" index reconcile "${_folder_path}" --ancestors

    [[ "${status}" -eq 0            ]]
    [[ -e "${_existing_file_path}"  ]]

    _file_content="$(cat "${_existing_file_path}")"
    printf "_file_content: '%s'\\n" "${_file_content:-}"

    [[   "${_file_content}" =~ Example\ Title      ]]
    [[ ! "${_file_content}" =~ Example\ Title\ Two ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" --content "# Example Title Two"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  [[ -e "${_existing_file_path}"                                  ]]

  [[   "$(cat "${_existing_file_path}")"  =~ Example\ Title       ]]
  [[ ! "$(cat "${_existing_file_path}")"  =~ Example\ Title\ Two  ]]

  [[ -e "${_new_file_path}"                                       ]]
  [[ "$(cat "${_new_file_path}")"         =~ Example\ Title\ Two  ]]


  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  ls "${NB_DIR}/home/Example Folder/Sample Folder"

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"                                 ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" =~  example-filename.md   ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" =~  example-filename-1.md ]]

  # Prints output:

  [[ "${output}" =~ Added:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example-filename-1.md  ]]
}

@test "'add folder <folder>/<folder>/<folder>' with existing folder at target creates folder with unique filename." {
  {
    "${_NB}" init

    _folder_path="${NB_DIR}/home/Example Folder/Sample Folder"
    _existing_folder_path="${_folder_path}/Demo Folder"

    mkdir -p "${_existing_folder_path}"
    touch "${_existing_folder_path}/.index"

    [[ -d "${_existing_folder_path}"        ]]
    [[ -f "${_existing_folder_path}/.index" ]]

    "${_NB}" index reconcile "${_existing_folder_path}" --ancestors

    [[ "${status}" -eq 0              ]]
    [[ -e "${_existing_folder_path}"  ]]
  }

  run "${_NB}" add folder "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  [[ -e "${_existing_folder_path}"    ]]
  [[ -e "${_existing_folder_path}-1"  ]]


  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  ls "${NB_DIR}/home/Example Folder/Sample Folder"
  echo ---
  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"              ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" =~  \
        Demo\ Folder${_NEWLINE}Demo\ Folder-1$                            ]]

  # Prints output:

  [[ "${output}" =~ Added:                                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder-1   ]]
}

# error handling ##############################################################

@test "'add <folder>/<folder>/example.md' with existing file in path exits with error and prints message." {
  {
    "${_NB}" init

    touch "${NB_DIR}/home/Example Folder"

    [[   -f "${NB_DIR}/home/Example Folder"                                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md"  ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 1 ]]

  # Does not create path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -f "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md" ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Does not change index::

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${output}" =~ Unable\ to\ create\ folder:     ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder  ]]
}

@test "'add <folder>/<folder> --type folder' with existing file in path exits with error and prints message." {
  {
    "${_NB}" init

    touch "${NB_DIR}/home/Example Folder"

    [[   -f "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder" --type "folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 1 ]]

  # Does not create path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -f "${NB_DIR}/home/Example Folder"                           ]]
  [[ "${#_files[@]}"  == 5                                        ]]
  [[ "${_files[3]}"   == ".index"                                 ]]
  [[ "${_files[4]}"   == "Example Folder"                         ]]


  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"           ]]

  # Does not commit to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"     ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Does not change:

  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output:

  [[ "${output}" =~ Unable\ to\ create\ folder:     ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder  ]]
}

# folder <folder> #############################################################

@test "'add folder <folder>' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"       ]]
  [[ "${#_folder_files[@]}" == 3                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  != "Sample Folder"                ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")" ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"        ]]

  # Prints output:

  [[ "${output}" =~ Added:           ]]
  [[ "${output}" =~ Example\ Folder  ]]
}

@test "'add folder <folder>/<folder>' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add folder "Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  printf "_folder_folder_files: '%s'" "${_folder_folder_files[@]}"

  [[ "${#_folder_folder_files[@]}"  == 3                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")" ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"
  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
  ls -la "${NB_DIR}/home/Example Folder/Sample Folder"

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"           ]]
  [[ -z "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"  ]]

  # Prints output:

  [[ "${output}" =~ Added:                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder  ]]
}

@test "'add folder <folder>/<folder>/<folder>' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                  ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index" ]]
  }

  run "${_NB}" add folder "Example Folder/Sample Folder/Demo Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  printf "_folder_folder_files: '%s'" "${_folder_folder_files[@]}"

  [[ "${#_folder_folder_files[@]}"  == 4                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]
  [[ "${_folder_folder_files[3]}"   == "Demo Folder"          ]]

  _folder_folder_folder_files=($(
    LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"
  ))

  printf "_folder_folder_folder_files: '%s'" "${_folder_folder_folder_files[@]}"

  [[ "${#_folder_folder_folder_files[@]}"  == 3               ]]
  [[ "${_folder_folder_folder_files[2]}"   == ".index"        ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"                ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"
  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
  ls -la "${NB_DIR}/home/Example Folder/Sample Folder"

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"          ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index"           ]]
  [[ -z "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index")"  ]]

  # Prints output:

  [[ "${output}" =~ Added:                                      ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder ]]
}

# --type folder ###############################################################

@test "'add <folder> --type folder' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add "Example Folder" --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"       ]]
  [[ "${#_folder_files[@]}" == 3                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  != "Sample Folder"                ]]


  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ -z "$(cat "${NB_DIR}/home/Example Folder/.index")"               ]]

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"        ]]

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ Example\ Folder ]]
}

@test "'add <folder>/<folder> --type folder' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder" --type folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 3                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"                ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"          ]]
  [[ -z "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" ]]

  # Prints output:

  [[ "${output}" =~ Added:                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder  ]]
}

@test "'add <folder>/<folder>/<folder> --type folder' creates new folder without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                  ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"        ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index" ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type "folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  printf "_folder_folder_files: '%s'" "${_folder_folder_files[@]}"

  [[ "${#_folder_folder_files[@]}"  == 4                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]
  [[ "${_folder_folder_files[3]}"   == "Demo Folder"          ]]

  _folder_folder_folder_files=($(
    LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"
  ))

  printf "_folder_folder_folder_files: '%s'" "${_folder_folder_folder_files[@]}"

  [[ "${#_folder_folder_folder_files[@]}"  == 3               ]]
  [[ "${_folder_folder_folder_files[2]}"   == ".index"        ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                       ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"     ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"                ]]

  cat "${NB_DIR}/home/.index"
  cat "${NB_DIR}/home/Example Folder/.index"
  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
  ls -la "${NB_DIR}/home/Example Folder/Sample Folder"

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"          ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index"           ]]
  [[ -z "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index")"  ]]

  # Prints output:

  [[ "${output}" =~ Added:                                      ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder ]]
}

# folder/example.md ###########################################################

@test "'add <folder>/example.md' creates new note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example-filename.md"  ]]
  }

  run "${_NB}" add "Example Folder/example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                         ]]
  [[ "${#_files[@]}"  == 5                                      ]]
  [[ "${_files[3]}"   == ".index"                               ]]
  [[ "${_files[4]}"   == "Example Folder"                       ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -e "${NB_DIR}/home/Example Folder/example-filename.md"     ]]
  [[ "${#_folder_files[@]}" == 4                                ]]
  [[ "${_folder_files[2]}"  == ".index"                         ]]
  [[ "${_folder_files[3]}"   == "example-filename.md"           ]]


  grep -q '# Example Title' "${NB_DIR}/home/Example Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                     ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"   ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                      ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"              ]]

  # Prints output:

  [[ "${output}" =~ Added:                              ]]
  [[ "${output}" =~ Example\ Folder/example-filename.md ]]
}

@test "'add <folder>/<folder>/example.md' creates new note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md"  ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 4                      ]]
  [[ "${_folder_folder_files[2]}"   == ".index"               ]]
  [[ "${_folder_folder_files[3]}"   == "example-filename.md"  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md" ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder/Sample Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                         ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"       ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                          ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"                  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"            ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"    ]]

  # Prints output:

  [[ "${output}" =~ Added:                                              ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example-filename.md  ]]
}

@test "'add <folder>/<folder>/example.md' with no created note deletes empty ancestor folders." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md"  ]]
  }

  EDITOR=mock_editor_no_op \
    run "${_NB}" add "Example Folder/Sample Folder/example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Does not create path:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[   "${#_files[@]}"  == 4                                    ]]
  [[   "${_files[3]}"   == ".index"                             ]]
  [[ ! "${_files[*]}"   =~ "Example Folder"                     ]]

  [[ ! -d "${NB_DIR}/home/Example Folder"                                   ]]
  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"                     ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md" ]]

  # Does not commit to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Does not add to .indexes:

  [[ -e "${NB_DIR}/home/.index"                                ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  # Does not print output:

  [[ -z "${output}" ]]
}

@test "'add <folder>/<folder>/example.md --encrypt' creates new encrypted note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                    ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md"  ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/example-filename.md" \
    --content "# Example Title"                                       \
    --encrypt --password=password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  [[ "${#_folder_folder_files[@]}"  == 4                          ]]
  [[ "${_folder_folder_files[2]}"   == ".index"                   ]]
  [[ "${_folder_folder_files[3]}"   == "example-filename.md.enc"  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/example-filename.md.enc" ]]

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                         ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"       ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                          ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")" ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"            ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"    ]]
  # Prints output:

  [[ "${output}" =~ Added:                                              ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example-filename.md  ]]
}

@test "'add <folder>/<folder>/example.md' with no created note deletes only empty ancestor folders." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md" --content "# Example Title One"

    [[   -e "${NB_DIR}/home/Example Folder/one.md"                                         ]]
    [[   -e "${NB_DIR}/home/Example Folder/.index"                                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/example-filename.md"  ]]
  }

  EDITOR=mock_editor_no_op \
    run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/example-filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Removes only empty directories:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[   "${#_files[@]}"  == 5                        ]]
  [[   "${_files[3]}"   == ".index"                 ]]
  [[   "${_files[*]}"   =~ "Example Folder"         ]]

  [[   -d "${NB_DIR}/home/Example Folder"           ]]
  [[   -e "${NB_DIR}/home/Example Folder/.index"    ]]
  [[   -e "${NB_DIR}/home/Example Folder/one.md"    ]]


  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"                                 ]]
  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                     ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/example-filename.md" ]]

  # Does not commit to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log -n 1 | grep -v -q '\[nb\] Add'

  # Retains .index in populated directories:

  [[   -e "${NB_DIR}/home/.index"                                          ]]
  [[   "$(cat "${NB_DIR}/home/.index")" =~ Example                         ]]
  [[   -e "${NB_DIR}/home/Example Folder/.index"                           ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ one.md           ]]
  [[ ! "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample           ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index" ]]

  # Does not print output:

  [[ -z "${output}" ]]
}

@test "'add <folder>/<folder>/<folder>/example.md' creates new note without errors." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"                                                ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/.index"                                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                                  ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"                           ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/example-filename.md"  ]]
  }

  run "${_NB}" add "Example Folder/Sample Folder/Demo Folder/example-filename.md" \
    --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat
  "${_NB}" git status

  [[ "${status}" -eq 0 ]]

  # Creates path, target file, and indexes:

  _files=($(LC_ALL=C ls -a "${NB_DIR}/home/"))

  echo "${_files[@]}"

  [[ -d "${NB_DIR}/home/Example Folder"                       ]]
  [[ "${#_files[@]}"  == 5                                    ]]
  [[ "${_files[3]}"   == ".index"                             ]]
  [[ "${_files[4]}"   == "Example Folder"                     ]]

  _folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_files[2]}"  == ".index"                       ]]
  [[ "${_folder_files[3]}"  == "Sample Folder"                ]]

  _folder_folder_files=($(LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder"))

  [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ "${#_folder_files[@]}" == 4                              ]]
  [[ "${_folder_folder_files[2]}"  == ".index"                ]]
  [[ "${_folder_folder_files[3]}"  == "Demo Folder"           ]]

  _folder_folder_folder_files=($(
    LC_ALL=C ls -a "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"
  ))

  [[ "${#_folder_folder_folder_files[@]}"  == 4                      ]]
  [[ "${_folder_folder_folder_files[2]}"   == ".index"               ]]
  [[ "${_folder_folder_folder_files[3]}"   == "example-filename.md"  ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/example-filename.md" ]]

  grep -q '# Example Title' "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"/*

  # Commits to git:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index"                                                     ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")"                   ]]

  [[ -e "${NB_DIR}/home/Example Folder/.index"                                      ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/.index")"                              ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"                        ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"                ]]

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index"            ]]
  [[ "$(ls "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder")" == \
       "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/.index")"    ]]

  # Prints output:

  [[ "${output}" =~ Added:                                                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/example-filename.md ]]
}
