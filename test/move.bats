#!/usr/bin/env bats

load test_helper

# multiple files and globbing #################################################

@test "'move <id> <id> <id> <notebook-1>:<id> <notebook-2>:<folder>/' with multiple selectors moves files." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md"    --content "Example content one."
    "${_NB}" add "Example File Two.md"    --content "Example content two."
    "${_NB}" add "Example File Three.md"  --content "Example content three."

    "${_NB}" notebooks add "Sample Notebook"

    "${_NB}" add "Sample Notebook:Sample File One.md" --content "Sample content one."

    "${_NB}" notebooks add "Demo Notebook"

    "${_NB}" add folder "Demo Notebook:Demo Folder"

    [[   -f "${NB_DIR}/home/Example File One.md"                        ]]
    [[   -f "${NB_DIR}/home/Example File Two.md"                        ]]
    [[   -f "${NB_DIR}/home/Example File Three.md"                      ]]
    [[   -f "${NB_DIR}/Sample Notebook/Sample File One.md"              ]]
    [[   -d "${NB_DIR}/Demo Notebook/Demo Folder"                       ]]
    [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File One.md"   ]]
    [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File Two.md"   ]]
    [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File Three.md" ]]
    [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Sample File One.md"    ]]
  }

  run "${_NB}" move     \
    "1"                 \
    "2"                 \
    "3"                 \
    "Sample Notebook:1" \
    "Demo Notebook:Demo Folder/" <<< "y${_NEWLINE}y${_NEWLINE}y${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves files:

  [[ ! -e "${NB_DIR}/home/Example File One.md"                        ]]
  [[ ! -e "${NB_DIR}/home/Example File Two.md"                        ]]
  [[ ! -e "${NB_DIR}/home/Example File Three.md"                      ]]
  [[ ! -e "${NB_DIR}/Sample Notebook/Sample File One.md"              ]]
  [[   -d "${NB_DIR}/Demo Notebook/Demo Folder"                       ]]
  [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File One.md"   ]]
  [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File Two.md"   ]]
  [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File Three.md" ]]
  [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Sample File One.md"    ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: Example File One.md'
  git log | grep -q '\[nb\] Delete: Example File Two.md'
  git log | grep -q '\[nb\] Delete: Example File Three.md'

  cd "${NB_DIR}/Sample Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete: Sample File One.md'

  cd "${NB_DIR}/Demo Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Demo Folder/Example File One.md'
  git log | grep -q '\[nb\] Add: Demo Folder/Example File Two.md'
  git log | grep -q '\[nb\] Add: Demo Folder/Example File Three.md'
  git log | grep -q '\[nb\] Add: Demo Folder/Sample File One.md'

  # Prints output:

  [[ "${lines[0]}"  =~    \
Moving:\ \ \ .*\[.*1.*\].*\ .*Example\ File\ One.md                     ]]
  [[ "${lines[1]}"  =~    \
To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ One.md    ]]
  [[ "${lines[2]}"  =~    \
Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ One.md         ]]

  [[ "${lines[3]}"  =~    \
Moving:\ \ \ .*\[.*2.*\].*\ .*Example\ File\ Two.md                     ]]
  [[ "${lines[4]}"  =~    \
To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Two.md    ]]
  [[ "${lines[5]}"  =~    \
Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Two.md         ]]

  [[ "${lines[6]}"  =~    \
Moving:\ \ \ .*\[.*3.*\].*\ .*Example\ File\ Three.md                   ]]
  [[ "${lines[7]}"  =~    \
To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Three.md  ]]
  [[ "${lines[8]}"  =~    \
Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Three.md       ]]

  [[ "${lines[9]}"  =~    \
Moving:\ \ \ .*\[.*Sample\ Notebook:1.*\].*\ .*Sample\ File\ One.md     ]]
  [[ "${lines[10]}"  =~   \
To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Sample\ File\ One.md     ]]
  [[ "${lines[11]}"  =~   \
Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Sample\ File\ One.md          ]]
}

# TODO
# @test "'move * <notebook-1>:<id> <notebook-2>:<folder>/' with multiple selectors moves files." {
#   {
#     "${_NB}" init

#     "${_NB}" add "Example File One.md"    --content "Example content one."
#     "${_NB}" add "Example File Two.md"    --content "Example content two."
#     "${_NB}" add "Example File Three.md"  --content "Example content three."

#     "${_NB}" notebooks add "Sample Notebook"

#     "${_NB}" add "Sample Notebook:Sample File One.md" --content "Sample content one."

#     "${_NB}" notebooks add "Demo Notebook"

#     "${_NB}" add folder "Demo Notebook:Demo Folder"

#     [[   -f "${NB_DIR}/home/Example File One.md"                        ]]
#     [[   -f "${NB_DIR}/home/Example File Two.md"                        ]]
#     [[   -f "${NB_DIR}/home/Example File Three.md"                      ]]
#     [[   -f "${NB_DIR}/Sample Notebook/Sample File One.md"              ]]
#     [[   -d "${NB_DIR}/Demo Notebook/Demo Folder"                       ]]
#     [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File One.md"   ]]
#     [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File Two.md"   ]]
#     [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Example File Three.md" ]]
#     [[ ! -e "${NB_DIR}/Demo Notebook/Demo Folder/Sample File One.md"    ]]
#   }

#   run "${_NB}" move *   \
#     "Sample Notebook:1" \
#     "Demo Notebook:Demo Folder/" <<< "y${_NEWLINE}y${_NEWLINE}y${_NEWLINE}y${_NEWLINE}"

#   printf "\${status}: '%s'\\n" "${status}"
#   printf "\${output}: '%s'\\n" "${output}"

#   # Returns status 0:

#   [[ ${status} -eq 0 ]]

#   # Moves files:

#   [[ ! -e "${NB_DIR}/home/Example File One.md"                        ]]
#   [[ ! -e "${NB_DIR}/home/Example File Two.md"                        ]]
#   [[ ! -e "${NB_DIR}/home/Example File Three.md"                      ]]
#   [[ ! -e "${NB_DIR}/Sample Notebook/Sample File One.md"              ]]
#   [[   -d "${NB_DIR}/Demo Notebook/Demo Folder"                       ]]
#   [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File One.md"   ]]
#   [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File Two.md"   ]]
#   [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Example File Three.md" ]]
#   [[   -f "${NB_DIR}/Demo Notebook/Demo Folder/Sample File One.md"    ]]

#   # Creates git commits:

#   cd "${NB_DIR}/home" || return 1
#   while [[ -n "$(git status --porcelain)" ]]
#   do
#     sleep 1
#   done
#   git log
#   git log | grep -q '\[nb\] Delete: Example File One.md'
#   git log | grep -q '\[nb\] Delete: Example File Two.md'
#   git log | grep -q '\[nb\] Delete: Example File Three.md'

#   cd "${NB_DIR}/Sample Notebook" || return 1
#   while [[ -n "$(git status --porcelain)" ]]
#   do
#     sleep 1
#   done
#   git log
#   git log | grep -q '\[nb\] Delete: Sample File One.md'

#   cd "${NB_DIR}/Demo Notebook" || return 1
#   while [[ -n "$(git status --porcelain)" ]]
#   do
#     sleep 1
#   done
#   git log | grep -q '\[nb\] Add: Demo Folder/Example File One.md'
#   git log | grep -q '\[nb\] Add: Demo Folder/Example File Two.md'
#   git log | grep -q '\[nb\] Add: Demo Folder/Example File Three.md'
#   git log | grep -q '\[nb\] Add: Demo Folder/Sample File One.md'

#   # Prints output:

#   [[ "${lines[0]}"  =~    \
# Moving:\ \ \ .*\[.*1.*\].*\ .*Example\ File\ One.md                     ]]
#   [[ "${lines[1]}"  =~    \
# To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ One.md    ]]
#   [[ "${lines[2]}"  =~    \
# Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ One.md         ]]

#   [[ "${lines[3]}"  =~    \
# Moving:\ \ \ .*\[.*2.*\].*\ .*Example\ File\ Two.md                     ]]
#   [[ "${lines[4]}"  =~    \
# To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Two.md    ]]
#   [[ "${lines[5]}"  =~    \
# Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Two.md         ]]

#   [[ "${lines[6]}"  =~    \
# Moving:\ \ \ .*\[.*3.*\].*\ .*Example\ File\ Three.md                   ]]
#   [[ "${lines[7]}"  =~    \
# To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Three.md  ]]
#   [[ "${lines[8]}"  =~    \
# Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Example\ File\ Three.md       ]]

#   [[ "${lines[9]}"  =~    \
# Moving:\ \ \ .*\[.*Sample\ Notebook:1.*\].*\ .*Sample\ File\ One.md     ]]
#   [[ "${lines[10]}"  =~   \
# To:\ \ \ \ \ \ \ .*Demo\ Notebook:Demo\ Folder/Sample\ File\ One.md     ]]
#   [[ "${lines[11]}"  =~   \
# Moved\ to:\ .*Demo\ Notebook:Demo\ Folder/Sample\ File\ One.md          ]]
# }

# argument ordering ###########################################################

@test "'move <folder>/<id> <notebook>:<folder>/' moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    "${_NB}" notebooks add "Sample Notebook"

    "${_NB}" add folder "Sample Notebook:Sample Folder"

    [[   -f "${NB_DIR}/home/Example Folder/Example File.md"           ]]
    [[   -d "${NB_DIR}/Sample Notebook/Sample Folder"                 ]]
    [[ ! -e "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" move "Example Folder/1" "Sample Notebook:Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.md"             ]]
  [[   -f "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md"   ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Sample Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  \
Moving:\ \ \ .*\[.*Example\ Folder/1.*\].*\ .*Example\ File.md      ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Sample\ Notebook:Sample\ Folder/Example\ File.md ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Sample\ Notebook:Sample\ Folder/Example\ File.md      ]]
}

@test "'<folder>/<id> move <notebook>:<folder>/' moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    "${_NB}" notebooks add "Sample Notebook"

    "${_NB}" add folder "Sample Notebook:Sample Folder"

    [[   -f "${NB_DIR}/home/Example Folder/Example File.md"           ]]
    [[   -d "${NB_DIR}/Sample Notebook/Sample Folder"                 ]]
    [[ ! -e "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" "Example Folder/1" move "Sample Notebook:Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.md"             ]]
  [[   -f "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md"   ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Sample Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  \
Moving:\ \ \ .*\[.*Example\ Folder/1.*\].*\ .*Example\ File.md      ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Sample\ Notebook:Sample\ Folder/Example\ File.md ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Sample\ Notebook:Sample\ Folder/Example\ File.md      ]]
}

@test "'<folder>/<id> <notebook>:<folder>/ move' moves file." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    "${_NB}" notebooks add "Sample Notebook"

    "${_NB}" add folder "Sample Notebook:Sample Folder"

    [[   -f "${NB_DIR}/home/Example Folder/Example File.md"           ]]
    [[   -d "${NB_DIR}/Sample Notebook/Sample Folder"                 ]]
    [[ ! -e "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md" ]]
  }

  run "${_NB}" "Example Folder/1" "Sample Notebook:Sample Folder/" move <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.md"             ]]
  [[   -f "${NB_DIR}/Sample Notebook/Sample Folder/Example File.md"   ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log
  git log | grep -q '\[nb\] Delete'

  cd "${NB_DIR}/Sample Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  \
Moving:\ \ \ .*\[.*Example\ Folder/1.*\].*\ .*Example\ File.md      ]]
  [[ "${lines[1]}"  =~  \
To:\ \ \ \ \ \ \ .*Sample\ Notebook:Sample\ Folder/Example\ File.md ]]
  [[ "${lines[2]}"  =~  \
Moved\ to:\ .*Sample\ Notebook:Sample\ Folder/Example\ File.md      ]]
}

# pinning #####################################################################

@test "'move' with pinned item and other notebook destination retains pinning in new notebook." {
  {
    "${_NB}" init
    "${_NB}" add "Example File One.md"    --content "Example content one."
    "${_NB}" add "Example File Two.md"    --content "Example content two."
    "${_NB}" add "Example File Three.md"  --content "Example content three."
    "${_NB}" add "Example File Four.md"   --content "Example content four."
    "${_NB}" add "Example File Five.md"   --content "Example content five."

    "${_NB}" pin 2
    "${_NB}" pin 4

    [[ -e "${NB_DIR}/home/Example File Two.md"    ]]

    diff                                          \
      <(cat "${NB_DIR}/home/.pindex")             \
      <(printf "Example File Two.md\\nExample File Four.md\\n")

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File One.md"     --content "Sample content one."
    "${_NB}" add "Sample File Two.md"     --content "Sample content two."
    "${_NB}" add "Sample File Three.md"   --content "Sample content three."
    "${_NB}" add "Sample File Four.md"    --content "Sample content four."

    "${_NB}" pin 3

    diff                                          \
      <(cat "${NB_DIR}/Sample Notebook/.pindex")  \
      <(printf "Sample File Three.md\\n")

    "${_NB}" notebooks use "home"
  }

  run "${_NB}" move "Example File Two.md" "Sample Notebook:" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File Two.md"             ]]
  [[    -e "${NB_DIR}/Sample Notebook/Example File Two.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete: Example File Two.md'

  cd "${NB_DIR}/Sample Notebook" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example File Two.md'

  # Updates .pindexes:

  diff                              \
    <(cat "${NB_DIR}/home/.pindex") \
    <(printf "Example File Four.md\\n")

  diff                                          \
    <(cat "${NB_DIR}/Sample Notebook/.pindex")  \
    <(printf "Sample File Three.md\\nExample File Two.md\\n")

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*2.*].*\ .*File\ Two\.md                           ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*Sample\ Notebook:Example\ File\ Two\.md          ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*Sample\ Notebook:5.*].*\ .*Example\ File\ Two.md   ]]
}

@test "'move' with pinned item and other folder destination retains pinning in new folder." {
  {
    "${_NB}" init
    "${_NB}" add "Example File One.md"    --content "Example content one."
    "${_NB}" add "Example File Two.md"    --content "Example content two."
    "${_NB}" add "Example File Three.md"  --content "Example content three."
    "${_NB}" add "Example File Four.md"   --content "Example content four."
    "${_NB}" add "Example File Five.md"   --content "Example content five."

    "${_NB}" pin 2
    "${_NB}" pin 4

    [[ -e "${NB_DIR}/home/Example File Two.md"  ]]

    diff                                        \
      <(cat "${NB_DIR}/home/.pindex")           \
      <(printf "Example File Two.md\\nExample File Four.md\\n")

    "${_NB}" add folder "Sample Folder"

    "${_NB}" add "Sample Folder/Sample File One.md"     --content "Sample content one."
    "${_NB}" add "Sample Folder/Sample File Two.md"     --content "Sample content two."
    "${_NB}" add "Sample Folder/Sample File Three.md"   --content "Sample content three."
    "${_NB}" add "Sample Folder/Sample File Four.md"    --content "Sample content four."

    "${_NB}" pin Sample\ Folder/3

    diff                                            \
      <(cat "${NB_DIR}/home/Sample Folder/.pindex") \
      <(printf "Sample File Three.md\\n")
  }

  run "${_NB}" move "Example File Two.md" "Sample Folder/" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/Example File Two.md"               ]]
  [[    -e "${NB_DIR}/home/Sample Folder/Example File Two.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates .pindexes:

  diff                              \
    <(cat "${NB_DIR}/home/.pindex") \
    <(printf "Example File Four.md\\n")

  diff                                            \
    <(cat "${NB_DIR}/home/Sample Folder/.pindex") \
    <(printf "Sample File Three.md\\nExample File Two.md\\n")

  # Prints output:

  [[ "${lines[0]}" =~ \
Moving:\ \ \ .*[.*2.*].*\ .*File\ Two\.md                                       ]]
  [[ "${lines[1]}" =~ \
To:\ \ \ \ \ \ \ .*Sample\ Folder/Example\ File\ Two\.md                        ]]
  [[ "${lines[2]}" =~ \
Moved\ to:\ .*[.*Sample\ Folder/5.*].*\ .*Sample\ Folder/Example\ File\ Two.md  ]]
}

@test "'move' with pinned item and same folder destination updates .pindex while retaining order." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --content "Example content one."
    "${_NB}" add "File Two.md"    --content "Example content two."
    "${_NB}" add "File Three.md"  --content "Example content three."
    "${_NB}" add "File Four.md"   --content "Example content four."
    "${_NB}" add "File Five.md"   --content "Example content five."

    "${_NB}" pin 2
    "${_NB}" pin 4

    [[ -e "${NB_DIR}/home/File Two.md"  ]]

    diff                                \
      <(cat "${NB_DIR}/home/.pindex")   \
      <(printf "File Two.md\\nFile Four.md\\n")
  }

  run "${_NB}" move "File Two.md" "Example File Two.md" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ !  -e "${NB_DIR}/home/File Two.md"         ]]
  [[    -e "${NB_DIR}/home/Example File Two.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move'

  # Updates .pindex:

  diff                              \
    <(cat "${NB_DIR}/home/.pindex") \
    <(printf "Example File Two.md\\nFile Four.md\\n")

  # Prints output:

  [[ "${lines[0]}" =~ Moving:\ \ \ .*[.*2.*].*\ .*File\ Two\.md         ]]
  [[ "${lines[1]}" =~ To:\ \ \ \ \ \ \ .*Example\ File\ Two\.md         ]]
  [[ "${lines[2]}" =~ Moved\ to:\ .*[.*2.*].*\ .*Example\ File\ Two.md  ]]
}

# prompt ######################################################################

@test "'move' with non-affirmative prompt response exits without moving note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" move 1 destination: <<< "n${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0                          ]]

  # Does not file:

  [[    -e "${NB_DIR}/home/example.md"        ]]
  [[ !  -e "${NB_DIR}/destination/example.md" ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"     ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moving                    ]]
  [[ "${output}" =~ Exiting.*\.\.\.           ]]
}

# no argument #################################################################

@test "'move' with no arguments exits with status 1." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with 1:

  [[ "${status}" -eq 1 ]]

  # Does not delete file:

  [[ -e "${NB_DIR}/home/example.md" ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep '\[nb\] Delete'

  # Prints help:

  [[ "${lines[0]}" =~ Usage.*\: ]]
  [[ "${lines[1]}" =~ nb\ move  ]]
}

# <selector> ##################################################################

@test "'move <selector> <notebook>:' with empty repo exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" move 1 destination:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ 1           ]]

}

@test "'move <invalid> <notebook>:' exits with 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "invalid" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ invalid     ]]

}

@test "'move <selector> <invalid>:' exits with 1 and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move 1 invalid: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                                ]]
  [[ "${lines[0]}" =~ Target\ notebook\ not\ found  ]]
  [[ "${lines[0]}" =~ invalid                       ]]
}

@test "'move <selector> <notebook>: (no force)' returns 0 and moves note." {
  skip "Determine how to test interactive prompt."
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    [[ -e "${NB_DIR}/home/example.md" ]]
  }

  run "${_NB}" move "example.md" destination:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ ! -e "${NB_DIR}/home/example.md" ]]
}

# <notebook>:<selector> #######################################################

@test "'move <notebook>:<filename> <notebook>:' with <filename> argument moves note." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "example.md" --content "Example content."

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" move one:example.md home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0              ]]
  [[ "${output}" =~ Moved\ to       ]]
  [[ "${output}" =~ home:1          ]]
  [[ "${output}" =~ home:example.md ]]
}

@test "'<notebook>:move <filename> <notebook>:' with <filename> argument moves note." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" one:move "${_filename}" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:[A-Za-z0-9]*     ]]
  [[ "${output}" =~ home:[A-Za-z0-9]+.md  ]]
}

@test "'<notebook>:<filename> move <notebook>:' with <filename> argument moves note." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add "example.md" --content "Example content."

    "${_NB}" use "home"

    [[    -e "${NB_DIR}/one/example.md"   ]]
    [[ !  -e "${NB_DIR}/home/example.md"  ]]
  }

  run "${_NB}" one:example.md move home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:example.md       ]]

  [[ !  -e "${NB_DIR}/one/example.md"     ]]
  [[    -e "${NB_DIR}/home/example.md"    ]]

}

@test "'<filename> <notebook>:move <notebook>:' with <filename> argument moves note." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" use "one"
    "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "${_filename}" one:move home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:[A-Za-z0-9]*     ]]
  [[ "${output}" =~ home:[A-Za-z0-9]+.md  ]]
}

# <filename> ##################################################################

@test "'move' with <filename> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "example.md" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <id> ########################################################################

@test "'move' with <id> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" move 1 destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

@test "'<id> move' successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" 1 move destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to                   ]]
  [[ "${output}" =~ destination:[A-Za-z0-9]*    ]]
  [[ "${output}" =~ destination:[A-Za-z0-9]+.md ]]
}

@test "'move' with <id> argument and trailing colon on destination successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move 1 destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <path> ######################################################################

@test "'move' with <path> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "${NB_DIR}/home/example.md" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <title> #####################################################################

@test "'move' with <title> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add --title "Example Title" --filename "example.md"
    "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "Example Title" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"       ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <folder> ####################################################################

@test "'move' with <folder> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "destination"
    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/Example Folder"

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" move "Example Folder" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves folder:

  [[ ! -e "${NB_DIR}/home/Example Folder"       ]]
  [[ -e "${NB_DIR}/destination/Example Folder"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to                   ]]
  [[ "${output}" =~ destination:1               ]]
  [[ "${output}" =~ destination:Example\ Folder ]]
}

# local #######################################################################

@test "'move' to local with <filename> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."

    [[ -e "${NB_DIR}/home/example.md" ]]

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" move "home:example.md" local: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/example.md"           ]]
  [[ -e "${_TMP_DIR}/example-local/example.md"  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to         ]]
  [[ "${output}" =~ local:1           ]]
  [[ "${output}" =~ local:example.md  ]]
}

@test "'move' from local with <filename> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    "${_NB}" add "local-example.md" --content "local example content"
  }

  run "${_NB}" move "local-example.md" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ -e "${NB_DIR}/home/local-example.md"               ]]
  [[ ! -e "${_TMP_DIR}/example-local/local-example.md"  ]]

  # Creates git commit:

  cd "${_TMP_DIR}/example-local" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:2                ]]
  [[ "${output}" =~ home:local-example.md ]]
}

@test "'move' from local with local:<filename> argument successfully moves note." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."
    "${_NB}" notebooks add "destination"

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    "${_NB}" add "local-example.md" --content "local example content"
  }

  run "${_NB}" move "local:local-example.md" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ -e "${NB_DIR}/home/local-example.md"               ]]
  [[ ! -e "${_TMP_DIR}/example-local/local-example.md"  ]]

  # Creates git commit:

  cd "${_TMP_DIR}/example-local" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:2                ]]
  [[ "${output}" =~ home:local-example.md ]]
}

# help ########################################################################

@test "'help move' exits with status 0." {
  run "${_NB}" help move

  [[ ${status} -eq 0 ]]
}

@test "'help move' prints help information." {
  run "${_NB}" help move

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*\: ]]
  [[ "${lines[1]}" =~ nb\ move  ]]
}
