#!/usr/bin/env bats

load test_helper

# remote ######################################################################

@test "'init <remote-url> <branch>' creates a clone in '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  {
    _setup_remote_repo

    "${_NB}" init
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

    mv "${NB_DIR}" "${NB_DIR}.bak"

    [[ ! -e "${NB_DIR}" ]]
  }

  run "${_NB}" init "${_GIT_REMOTE_URL}" "example-branch"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  diff                                                            \
    <(cd "${NB_DIR}/home" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                            \
    <(cd "${NB_DIR}/home" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  [[ -f "${NB_DIR}/home/Example File One.md" ]]

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'init <remote-url>' creates a clone in '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  {
    _setup_remote_repo

    "${_NB}" init
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

    mv "${NB_DIR}" "${NB_DIR}.bak"

    [[ ! -e "${NB_DIR}" ]]
  }

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  diff                                                            \
    <(cd "${NB_DIR}/home" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                            \
    <(cd "${NB_DIR}/home" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "master\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master                                ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/HEAD\ \-\>\ origin/master  ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master                     ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  example-branch                            ]]
}

# config ######################################################################

@test "'init --author' displays config prompt and sets email and name." {
  run "${_NB}" init --author \
    <<< "y${_NEWLINE}local@example.test${_NEWLINE}Example Local Name${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 18  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)"  ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)"  ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[8]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[12]}" =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[13]}" =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[14]}" =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[15]}" =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[16]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[17]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

# --email and --name ##########################################################

@test "'init --email <email> --name <name>' sets the local email and name." {
  run "${_NB}" init               \
    --email "local@example.test"  \
    --name  "Example Local Name"  \
    <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 20  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[8]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[12]}" =~ Update:                                                ]]
  [[ "${lines[13]}" =~ [^-]-------[^-]                                        ]]
  [[ "${lines[14]}" =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[15]}" =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[16]}" =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[17]}" =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[18]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[19]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'init --email <email>' sets the local email." {
  run "${_NB}"  init              \
    --email "local@example.test"  \
    <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 19  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[8]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[12]}" =~ Update:                                                ]]
  [[ "${lines[13]}" =~ [^-]-------[^-]                                        ]]
  [[ "${lines[14]}" =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[15]}" =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[16]}" =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[17]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[18]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: %s <local@example.test>\\n" "${_global_name}")
}

@test "'init --name <name>' sets the local name." {
  run "${_NB}" init               \
    --name "Example Local Name"   \
    <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 19  ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[8]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[12]}" =~ Update:                                                ]]
  [[ "${lines[13]}" =~ [^-]-------[^-]                                        ]]
  [[ "${lines[14]}" =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[15]}" =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[16]}" =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[17]}" =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[18]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <%s>\\n" "${_global_email}")
}

# `init` ######################################################################

@test "'init' exits with status 0." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
}

@test "'init' exits with status 1 when '\$NB_DIR' exists as a file." {
  {
    touch "${NB_DIR}"

    [[ -e "${NB_DIR}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1 ]]
}

@test "'init' exits with status 0 when '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home' exists." {
  {
    mkdir -p "${NB_DIR}/home"

    [[ -e "${NB_DIR}/home" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ !  "${output}" =~  exists  ]]
  [[    "${status}" -eq 0       ]]
}

@test "'init' creates '\$NB_DIR' and '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home' directories." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${NB_DIR}"       ]]
  [[ -d "${NB_DIR}/home"  ]]
}

@test "'init' creates a git directory in '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -d "${NB_DIR}/home/.git" ]]
}

@test "'init' creates an .index '\$NB_NOTEBOOK_PATH' / '\$NB_DIR/home'." {
  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -e "${NB_DIR}/home/.index" ]]
}

@test "'init' exits with status 0 when '\$NBRC_PATH' exists." {
  {
    touch "${NBRC_PATH}"

    [[ -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
}

@test "'init' creates a .nbrc file at '\$NBRC_PATH'." {
  {
    [[ ! -e "${NBRC_PATH}" ]]
  }

  run "${_NB}" init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "%s\\n" "$(cat "${NBRC_PATH}")"

  [[ -e "${NBRC_PATH}" ]]

  grep -q "Configuration file for \`nb\`"  "${NBRC_PATH}"
  grep -q "NB_ENCRYPTION_TOOL"             "${NBRC_PATH}"
}

@test "'init' creates git commit." {
  run "${_NB}" init

  cd "${NB_DIR}/home" || return 1

  printf "\$(git log): '%s'\n" "$(git log)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Initialize'
}

# help ########################################################################

@test "'help init' exits with status 0." {
  run "${_NB}" help init

  [[ "${status}" -eq 0 ]]
}

@test "'help init' prints help information." {
  run "${_NB}" help init

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*:      ]]
  [[ "${lines[1]}" =~ \ \ nb\ init  ]]
}
