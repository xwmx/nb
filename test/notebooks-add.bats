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

@test "'notebooks add <name> <remote-url> <branch>' exits with 0 and adds a notebook." {
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

  run "${_NB}" notebooks add example "${_GIT_REMOTE_URL}" "example-branch"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]
  [[    "${lines[1]}" =~  Added\ notebook\:                     ]]
  [[    "${lines[1]}" =~  example                               ]]
  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8 ]]
  [[ -d "${NB_DIR}/example/.git"                                ]]
  [[ -f "${NB_DIR}/example/Example File One.md"                 ]]

  diff                                                              \
    <(cd "${NB_DIR}/example" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                              \
    <(cd "${NB_DIR}/example" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "example-branch\\n")
}

@test "'notebooks add <name> <remote-url>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "${_NB}" notebooks add example "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]
  [[    "${lines[1]}" =~  Added\ notebook\:                     ]]
  [[    "${lines[1]}" =~  example                               ]]
  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7 ]]
  [[ -d "${NB_DIR}/example/.git"                                ]]

  diff                                                              \
    <(cd "${NB_DIR}/example" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                              \
    <(cd "${NB_DIR}/example" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "master\\n")
}

# <name> validation ###########################################################

@test "'notebooks add <reserved>' exits with 1 and prints error message." {
  {
    "${_NB}" init

    _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  for __name in "${_names[@]}"
  do
    run "${_NB}" notebooks add "${__name}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ ${status} -eq 1                  ]]
    [[ "${lines[0]}" =~ Name\ reserved  ]]
    [[ "${lines[0]}" =~ ${__name}       ]]
  done
}

# `notebooks add <name>` ######################################################

@test "'notebooks add' exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "File Count: '%s'\\n" \
    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)"
  printf "%s\\n" "$(cd "${NB_DIR}" && find . -maxdepth 1)"

  [[ ${status} -eq 1                                          ]]
  [[ "${lines[1]}" =~ \ \ nb\ notebooks\ \[\<name\>\]         ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

@test "'notebooks add <existing>' exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add one


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                                          ]]
  [[ "${lines[0]}" =~ Already\ exists                         ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

@test "'notebooks add <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${lines[0]}" =~ Added\ notebook\:                       ]]
  [[ "${lines[0]}" =~ example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks add <name>' creates git commit." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(ls -la \"${NB_DIR}/example/\"): '%s'\\n" \
    "$(ls -la "${NB_DIR}/example/")"

  [[ ${status} -eq 0 ]]

  cd "${NB_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Initialize'
}

@test "'notebooks a <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks a example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks create <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks new <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}
