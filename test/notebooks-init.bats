#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init

  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"

  mkdir -p "${NB_DIR}/two"

  cd "${NB_DIR}" || return 1
}

# remote ######################################################################

@test "'notebooks init <path> <remote-url> <branch>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/example" "${_GIT_REMOTE_URL}" "example-branch"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  diff                                                                \
    <(cd "${_TMP_DIR}/example" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                \
    <(cd "${_TMP_DIR}/example" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "example-branch\\n")

  [[    "${status}"   -eq 0                             ]]
  [[    "${lines[0]}" =~  Cloning                       ]]
  [[    "${lines[1]}" =~  Initialized\ local\ notebook  ]]
  [[    "${lines[1]}" =~  example                       ]]
  [[ -d "${_TMP_DIR}/example/.git"                      ]]
  [[ -f "${_TMP_DIR}/example/.index"                    ]]
  [[ -f "${_TMP_DIR}/example/Example File One.md"       ]]

  cd "${_TMP_DIR}/example" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v 'Initial commit.'
  git log | grep 'Initialize'

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks init <path> <remote-url>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/example" "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  diff                                                                \
    <(cd "${_TMP_DIR}/example" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                \
    <(cd "${_TMP_DIR}/example" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "master\\n")

  [[    "${status}"   -eq 0                             ]]
  [[    "${lines[0]}" =~  Cloning                       ]]
  [[    "${lines[1]}" =~  Initialized\ local\ notebook  ]]
  [[    "${lines[1]}" =~  example                       ]]
  [[ -d "${_TMP_DIR}/example/.git"                      ]]
  [[ -f "${_TMP_DIR}/example/.index"                    ]]

  cd "${_TMP_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep 'Initial commit.'

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master                                ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/HEAD\ \-\>\ origin/master  ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master                     ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  example-branch                            ]]
}

# config ######################################################################

@test "'notebooks init --author' displays config prompt and sets email and name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/Example Local Notebook" --author \
    <<< "y${_NEWLINE}local@example.test${_NEWLINE}Example Local Name${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 11  ]]

  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.email  || :)"  ]]
  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.name   || :)"  ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*local                         ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[4]}"  =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[5]}"  =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[6]}"  =~ Updated\ author\ for:\ .*local                         ]]
  [[ "${lines[7]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[8]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[9]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  [[ "${lines[10]}" =~ \
Initialized\ local\ notebook:\ .*${_TMP_DIR}/Example\ Local\ Notebook         ]]

  cd "${_TMP_DIR}/Example Local Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

# --email and --name ##########################################################

@test "'notebooks init --email <email> --name <name>' sets the local email and name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/Example Local Notebook"     \
    --email "local@example.test"                                        \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 13  ]]

  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*local                         ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*local                         ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  [[ "${lines[12]}" =~ \
Initialized\ local\ notebook:\ .*${_TMP_DIR}/Example\ Local\ Notebook         ]]

  cd "${_TMP_DIR}/Example Local Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks init --email <email>' sets the local email." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}"  notebooks init "${_TMP_DIR}/Example Local Notebook" \
    --email "local@example.test"                                    \
    <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*local                         ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*local                         ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[11]}" =~ \
Initialized\ local\ notebook:\ .*${_TMP_DIR}/Example\ Local\ Notebook         ]]

  cd "${_TMP_DIR}/Example Local Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: %s <local@example.test>\\n" "${_global_name}")
}

@test "'notebooks init --name <name>' sets the local name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/Example Local Notebook"  \
    --name "Example Local Name"                                     \
    <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -z "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${_TMP_DIR}/Example Local Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*local                         ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*local                         ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  [[ "${lines[11]}" =~ \
Initialized\ local\ notebook:\ .*${_TMP_DIR}/Example\ Local\ Notebook         ]]

  cd "${_TMP_DIR}/Example Local Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <%s>\\n" "${_global_email}")
}

# `notebooks init` ############################################################

@test "'notebooks init' with no arguments initializes the current directory" {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
  }

  run "${_NB}" notebooks init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ Initialized\ local\ notebook  ]]
  [[ "${lines[0]}" =~ example                       ]]
  [[ -d "${_TMP_DIR}/example/.git"                  ]]
  [[ -f "${_TMP_DIR}/example/.index"                ]]
}

@test "'notebooks init' in existing notebook exits with 1 and prints error message." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                    ]]
  [[ "${lines[0]}" =~ Notebook\ exists  ]]
  [[ "${lines[0]}" =~ example           ]]
}

@test "'notebooks init' in existing git repo exits with 1 and prints error message." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null
  }

  run "${_NB}" notebooks init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                            ]]
  [[ "${lines[0]}" =~ Git\ repository\ exists   ]]
  [[ "${lines[0]}" =~ example                   ]]
}

@test "'notebooks init <relative path>' with no arguments succeeds." {
  {
    _setup_notebooks

    cd "${_TMP_DIR}"

    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NB}" notebooks init example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ Initialized\ local\ notebook  ]]
  [[ "${lines[0]}" =~ example                       ]]
  [[ -d "${_TMP_DIR}/example/.git"                  ]]
  [[ -f "${_TMP_DIR}/example/.index"                ]]
}

@test "'notebooks init <relative path>' in existing notebook exits with 1." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    cd "${_TMP_DIR}"

    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NB}" notebooks init example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                    ]]
  [[ "${lines[0]}" =~ Notebook\ exists  ]]
  [[ "${lines[0]}" =~ example           ]]
}

@test "'notebooks init <relative path>' in existing git repo exits with 1." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null

    cd "${_TMP_DIR}"

    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NB}" notebooks init example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                          ]]
  [[ "${lines[0]}" =~ Git\ repository\ exists ]]
  [[ "${lines[0]}" =~ example                 ]]
}

@test "'notebooks init <absolute path>' with no arguments succeeds." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ Initialized\ local\ notebook  ]]
  [[ "${lines[0]}" =~ example                       ]]
  [[ -d "${_TMP_DIR}/example/.git"                  ]]
  [[ -f "${_TMP_DIR}/example/.index"                ]]

  cd "${_TMP_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep '\[nb\] Initialize'
}

@test "'notebooks init <absolute path>' in existing notebook exits with 1." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                    ]]
  [[ "${lines[0]}" =~ Notebook\ exists  ]]
  [[ "${lines[0]}" =~ example           ]]
}

@test "'notebooks init <absolute path>' in existing git repo exits with 1." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null
  }

  run "${_NB}" notebooks init "${_TMP_DIR}/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                          ]]
  [[ "${lines[0]}" =~ Git\ repository\ exists ]]
  [[ "${lines[0]}" =~ example                 ]]
}
