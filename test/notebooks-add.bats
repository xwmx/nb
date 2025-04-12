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

# errors ######################################################################

@test "'notebooks add' with no <name>, <remote-url>, or <branch> exits with 1 and prints help." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "${_NB}" notebooks add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "File Count: '%s'\\n" \
    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)"
  printf "%s\\n" "$(cd "${NB_DIR}" && find . -maxdepth 1)"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${lines[0]}"  =~  Usage.*:                              ]]
  [[ "${lines[1]}"  =~  \ \ nb\ notebooks\                    ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

# remote ######################################################################

@test "'notebooks add <remote-url> --all' with no existing notebooks matching branch names exits with 0 and adds notebooks for all branches." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    printf "Example File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"
    "${_NB}" git branch -m "sample-branch"

    "${_NB}" add "Sample File One.md" --content "Sample content one."

    printf "Sample File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote  \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\nsample-branch\\n")

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"
    "${_NB}" git branch -m "demo-branch"

    "${_NB}" add "Demo File One.md" --content "Demo content one."

    printf "Demo File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote    \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "demo-branch\\nexample-branch\\nmaster\\nsample-branch\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" --all \
    <<< "${_NEWLINE}${_NEWLINE}${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                               ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  Cloning\ into\ \'${NB_DIR}/demo-branch\'      ]]
  [[    "${lines[2]}"   =~  Added\ notebook\:\ .*demo-branch.*            ]]
  [[    "${lines[3]}"   =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[4]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[5]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch\'   ]]
  [[    "${lines[6]}"   =~  Added\ notebook\:\ .*example-branch.*         ]]
  [[    "${lines[7]}"   =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[8]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[9]}"   =~  Cloning\ into\ \'${NB_DIR}/remote\'           ]]
  [[    "${lines[10]}"  =~  Added\ notebook\:\ .*remote.*                 ]]
  [[    "${lines[11]}"  =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[12]}"  =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[13]}"  =~  Cloning\ into\ \'${NB_DIR}/sample-branch\'    ]]
  [[    "${lines[14]}"  =~  Added\ notebook\:\ .*sample-branch.*          ]]


  cd "${NB_DIR}" && find . -maxdepth 1 | wc -l
  cd "${NB_DIR}" && find . -maxdepth 1

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 13      ]]
  [[ -d "${NB_DIR}/example-branch/.git"                               ]]
  [[ -f "${NB_DIR}/example-branch/Example File One.md"                ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  cd "${NB_DIR}/demo-branch"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ demo-branch               ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/demo-branch    ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]

  cd "${NB_DIR}/example-branch"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]

  cd "${NB_DIR}/remote"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master                    ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master         ]]

  cd "${NB_DIR}/sample-branch"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ sample-branch             ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/sample-branch  ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <remote-url> <branch-1> <nonexistent-branch-2>' with existing <branch-1> notebook exits with 0 and adds notebook named <branch-1>." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    printf "Example File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"
    "${_NB}" git branch -m "sample-branch"

    "${_NB}" add "Sample File One.md" --content "Sample content one."

    printf "Sample File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote  \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\nsample-branch\\n")

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"
    "${_NB}" git branch -m "demo-branch"

    "${_NB}" add "Demo File One.md" --content "Demo content one."

    printf "Demo File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote    \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "demo-branch\\nexample-branch\\nmaster\\nsample-branch\\n")

    "${_NB}" notebooks add "example-branch"
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" \
     "nonexistent-branch" "example-branch" <<< "${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  \
Cloning\ into\ \'${NB_DIR}/nonexistent-branch\'                               ]]
  [[    "${lines[2]}"   =~  \
warning:\ Could\ not\ find\ remote\ branch\ nonexistent\-branch\ to\ clone\.  ]]
  [[    "${lines[3]}"   =~  \
fatal:\ Remote\ branch\ nonexistent\-branch\ not\ found\ in\ upstream\ origin ]]
  [[    "${lines[4]}"   =~  [^-]------------------------------------[^-]      ]]
  [[    "${lines[5]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[6]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch-1\'     ]]
  [[    "${lines[7]}"   =~  Added\ notebook\:\ .*example-branch-1.*           ]]

  cd "${NB_DIR}" && find . -maxdepth 1 | wc -l
  cd "${NB_DIR}" && find . -maxdepth 1

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 11      ]]
  [[ -d "${NB_DIR}/example-branch-1/.git"                             ]]
  [[ -f "${NB_DIR}/example-branch-1/Example File One.md"              ]]

  diff                                                                        \
    <(cd "${NB_DIR}/example-branch-1" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                        \
    <(cd "${NB_DIR}/example-branch-1" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  cd "${NB_DIR}/example-branch-1"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]

  [[ ! -e "${NB_DIR}/sample-branch"       ]]
  [[ ! -e "${NB_DIR}/nonexistent-branch"  ]]
}

@test "'notebooks add <remote-url> <branch-1> <branch-2>' with no existing notebooks with those names exits with 0 and adds notebook named <branch-1> and <branch-2>." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    printf "Example File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"
    "${_NB}" git branch -m "sample-branch"

    "${_NB}" add "Sample File One.md" --content "Sample content one."

    printf "Sample File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote  \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\nsample-branch\\n")

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"
    "${_NB}" git branch -m "demo-branch"

    "${_NB}" add "Demo File One.md" --content "Demo content one."

    printf "Demo File One.md created.\\n"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote    \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "demo-branch\\nexample-branch\\nmaster\\nsample-branch\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" \
    "example-branch" "demo-branch" <<< "${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                           ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch\'     ]]
  [[    "${lines[2]}"   =~  Added\ notebook\:\ .*example-branch.*           ]]
  [[    "${lines[3]}"   =~  [^-]------------------------------------[^-]    ]]
  [[    "${lines[4]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[5]}"   =~  Cloning\ into\ \'${NB_DIR}/demo-branch\'        ]]
  [[    "${lines[6]}"   =~  Added\ notebook\:\ .*demo-branch.*              ]]

  cd "${NB_DIR}" && find . -maxdepth 1 | wc -l
  cd "${NB_DIR}" && find . -maxdepth 1

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 11      ]]
  [[ -d "${NB_DIR}/example-branch/.git"                               ]]
  [[ -f "${NB_DIR}/example-branch/Example File One.md"                ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  cd "${NB_DIR}/example-branch"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]

  [[ ! -e "${NB_DIR}/sample-branch" ]]

  cd "${NB_DIR}/demo-branch"

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ demo-branch               ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/demo-branch    ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <remote-url> <branch>' with reserved notebook name as branch name exits with a and prints message." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "readme"

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "master\\nreadme\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" "readme" <<< "${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1                                     ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  !.*\ Name\ reserved:\ .*readme.*    ]]

  [[ ! -e "${NB_DIR}/readme"                                    ]]
}

@test "'notebooks add <remote-url> <branch>' with no existing notebook with that name exits with 0 and adds a notebook named <branch>." {
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

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" "example-branch" <<< "${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch\'     ]]
  [[    "${lines[2]}"   =~  Added\ notebook\:\ .*example-branch.*           ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8 ]]
  [[ -d "${NB_DIR}/example-branch/.git"                         ]]
  [[ -f "${NB_DIR}/example-branch/Example File One.md"          ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

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

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <name> <remote-url>' exits with 0 and adds a notebook." {
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

  run "${_NB}" notebooks add "Sample Notebook" "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cd "${NB_DIR}" && find . -maxdepth 1

  [[    "${status}"   -eq 0                                     ]]
  [[    "${lines[1]}" =~  Added\ notebook\:                     ]]
  [[    "${lines[1]}" =~  Sample\ Notebook                      ]]
  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8 ]]
  [[ -d "${NB_DIR}/Sample Notebook/.git"                        ]]

  diff                                                                      \
    <(cd "${NB_DIR}/Sample Notebook" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/Sample Notebook" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "master\\n")

  diff                                            \
    <("${_NB}" Sample\ Notebook:git branch --all) \
    <(cat <<HEREDOC
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
HEREDOC
    )
}

@test "'notebooks add <remote-url>' with multiple remote branches prompts for branch with 'All' response and notebook names with default response, and creates notebooks from branches." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    diff                          \
      <("${_NB}" git branch -a)   \
      <(printf "* example-branch\\n")

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    "${_NB}" git status
    "${_NB}" run ls -la

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}"     \
    <<< "3${_NEWLINE}${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}"   =~  Choose\ a\ remote\ branch\:                     ]]
  [[    "${lines[1]}"   =~  [^-]-----------------------[^-]                 ]]
  [[    "${lines[2]}"   =~  .*[.*1.*].*\ example-branch                     ]]
  [[    "${lines[3]}"   =~  .*[.*2.*].*\ master                             ]]
  [[    "${lines[4]}"   =~  .*[.*3.*].*\ All\ Branches                      ]]
  [[    "${lines[5]}"   =~  [^-]------------------------------------[^-]    ]]
  [[    "${lines[6]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[7]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch\'     ]]
  [[    "${lines[8]}"   =~  Added\ notebook\:\ .*example-branch.*           ]]
  [[    "${lines[9]}"   =~  [^-]------------------------------------[^-]    ]]
  [[    "${lines[10]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[11]}"  =~  Cloning\ into\ \'${NB_DIR}/remote\'             ]]
  [[    "${lines[12]}"  =~  Added\ notebook\:\ .*remote.*                   ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 9             ]]
  [[ -d "${NB_DIR}/example-branch/.git"                                     ]]
  [[ -d "${NB_DIR}/remote/.git"                                             ]]

  ls -la "${NB_DIR}/example-branch"

  [[ -f "${NB_DIR}/example-branch/Example File One.md"                      ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  diff                                                                      \
    <(cd "${NB_DIR}/remote" && git config --get remote.origin.url)          \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/remote" && git rev-parse --abbrev-ref HEAD)             \
    <(printf "master\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch              ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch   ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                     ]]

  "${_NB}" use remote

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master                      ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master           ]]
}

@test "'notebooks add <remote-url>' with multiple remote branches prompts for branch with 'All' response and notebook names with alpha response, and creates notebooks from branches." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    diff                          \
      <("${_NB}" git branch -a)   \
      <(printf "* example-branch\\n")

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    "${_NB}" git status
    "${_NB}" run ls -la

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}"     \
    <<< "3${_NEWLINE}sample-notebook${_NEWLINE}demo-notebook${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}"   =~  Choose\ a\ remote\ branch\:                     ]]
  [[    "${lines[1]}"   =~  [^-]-----------------------[^-]                 ]]
  [[    "${lines[2]}"   =~  .*[.*1.*].*\ example-branch                     ]]
  [[    "${lines[3]}"   =~  .*[.*2.*].*\ master                             ]]
  [[    "${lines[4]}"   =~  .*[.*3.*].*\ All\ Branches                      ]]
  [[    "${lines[5]}"   =~  [^-]------------------------------------[^-]    ]]
  [[    "${lines[6]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[7]}"   =~  Cloning\ into\ \'${NB_DIR}/sample-notebook\'    ]]
  [[    "${lines[8]}"   =~  Added\ notebook\:\ .*sample-notebook.*          ]]
  [[    "${lines[9]}"   =~  [^-]------------------------------------[^-]    ]]
  [[    "${lines[10]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[11]}"  =~  Cloning\ into\ \'${NB_DIR}/demo-notebook\'      ]]
  [[    "${lines[12]}"  =~  Added\ notebook\:\ .*demo-notebook.*            ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 9             ]]
  [[ -d "${NB_DIR}/sample-notebook/.git"                                    ]]
  [[ -d "${NB_DIR}/demo-notebook/.git"                                      ]]

  ls -la "${NB_DIR}/sample-notebook"

  [[ -f "${NB_DIR}/sample-notebook/Example File One.md"                     ]]

  diff                                                                      \
    <(cd "${NB_DIR}/sample-notebook" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/sample-notebook" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "example-branch\\n")

  diff                                                                      \
    <(cd "${NB_DIR}/demo-notebook" && git config --get remote.origin.url)   \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/demo-notebook" && git rev-parse --abbrev-ref HEAD)      \
    <(printf "master\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch              ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch   ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                     ]]

  "${_NB}" use demo-notebook

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master                      ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master           ]]
}

@test "'notebooks add <remote-url>' with multiple remote branches prompts for branch with numerical response and notebook name with alpha response, and creates notebook from branch." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    diff                          \
      <("${_NB}" git branch -a)   \
      <(printf "* example-branch\\n")

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    "${_NB}" git status
    "${_NB}" run ls -la

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" <<< "1${_NEWLINE}sample-notebook${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  Choose\ a\ remote\ branch\:                   ]]
  [[    "${lines[1]}" =~  [^-]-----------------------[^-]               ]]
  [[    "${lines[2]}" =~  .*[.*1.*].*\ example-branch                   ]]
  [[    "${lines[3]}" =~  .*[.*2.*].*\ master                           ]]
  [[    "${lines[4]}" =~  .*[.*3.*].*\ All\ Branches                    ]]
  [[    "${lines[5]}" =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[6]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[7]}" =~  Cloning\ into\ \'${NB_DIR}/sample-notebook\'  ]]
  [[    "${lines[8]}" =~  Added\ notebook\:\ .*sample-notebook.*        ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8         ]]
  [[ -d "${NB_DIR}/sample-notebook/.git"                                ]]

  ls -la "${NB_DIR}/sample-notebook"

  [[ -f "${NB_DIR}/sample-notebook/Example File One.md"                 ]]

  diff                                                                      \
    <(cd "${NB_DIR}/sample-notebook" && git config --get remote.origin.url) \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/sample-notebook" && git rev-parse --abbrev-ref HEAD)    \
    <(printf "example-branch\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <remote-url>' with multiple remote branches prompts for branch with alpha / branch name response and notebook name with <enter> response, and creates notebook from branch." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    diff                          \
      <("${_NB}" git branch -a)   \
      <(printf "* example-branch\\n")

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    "${_NB}" git status
    "${_NB}" run ls -la

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" <<< "example-branch${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  Choose\ a\ remote\ branch\:                   ]]
  [[    "${lines[1]}" =~  [^-]-----------------------[^-]               ]]
  [[    "${lines[2]}" =~  .*[.*1.*].*\ example-branch                   ]]
  [[    "${lines[3]}" =~  .*[.*2.*].*\ master                           ]]
  [[    "${lines[4]}" =~  .*[.*3.*].*\ All\ Branches                    ]]
  [[    "${lines[5]}" =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[6]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[7]}" =~  Cloning\ into\ \'${NB_DIR}/example-branch\'   ]]
  [[    "${lines[8]}" =~  Added\ notebook\:\ .*example-branch.*         ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8         ]]
  [[ -d "${NB_DIR}/example-branch/.git"                                 ]]

  ls -la "${NB_DIR}/example-branch"

  [[ -f "${NB_DIR}/example-branch/Example File One.md"                  ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <remote-url>' with multiple remote branches prompts for branch with numeric response and notebook name with <enter> response, and creates notebook from branch." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
    "${_NB}" git branch -m "example-branch"

    diff                          \
      <("${_NB}" git branch -a)   \
      <(printf "* example-branch\\n")

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    "${_NB}" git status
    "${_NB}" run ls -la

    diff                                              \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote \
          --heads "${_GIT_REMOTE_URL}"                \
          | sed "s/.*\///g" || :)                     \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" <<< "1${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  Choose\ a\ remote\ branch\:                   ]]
  [[    "${lines[1]}" =~  [^-]-----------------------[^-]               ]]
  [[    "${lines[2]}" =~  .*[.*1.*].*\ example-branch                   ]]
  [[    "${lines[3]}" =~  .*[.*2.*].*\ master                           ]]
  [[    "${lines[4]}" =~  .*[.*3.*].*\ All\ Branches                    ]]
  [[    "${lines[5]}" =~  [^-]------------------------------------[^-]  ]]
  [[    "${lines[6]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[7]}" =~  Cloning\ into\ \'${NB_DIR}/example-branch\'   ]]
  [[    "${lines[8]}" =~  Added\ notebook\:\ .*example-branch.*         ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 8         ]]
  [[ -d "${NB_DIR}/example-branch/.git"                                 ]]

  ls -la "${NB_DIR}/example-branch"

  [[ -f "${NB_DIR}/example-branch/Example File One.md"                  ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
  [[ !  "$("${_NB}" git branch --all)"  =~  master|main                   ]]
}

@test "'notebooks add <remote-url>' with one remote branch with uncommon default branch name uses repository name as notebook name." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" git branch -m  "example-branch"

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    _sed_i "s/master/example-branch/" "${_GIT_REMOTE_PATH}/HEAD"

    "${_NB}" git push origin :master

    diff                                  \
      <(git -C "${NB_DIR}/home" ls-remote \
          --heads "${_GIT_REMOTE_URL}"    \
          | sed "s/.*\///g" || :)         \
      <(printf "example-branch\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" <<< "${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                               ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  Cloning\ into\ \'${NB_DIR}/example-branch\'   ]]
  [[    "${lines[2]}"   =~  Added\ notebook\:\ .*example-branch.*         ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7           ]]
  [[ -d "${NB_DIR}/example-branch/.git"                                   ]]
  [[ -f "${NB_DIR}/example-branch/Example File One.md"                    ]]

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                                      \
    <(cd "${NB_DIR}/example-branch" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "example-branch\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ example-branch            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/example-branch ]]
}

@test "'notebooks add <remote-url>' with one remote branch with common default branch name uses repository name as notebook name." {
  {
    _setup_notebooks
    _setup_remote_repo

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                  \
      <(git -C "${NB_DIR}/home" ls-remote \
          --heads "${_GIT_REMOTE_URL}"    \
          | sed "s/.*\///g" || :)         \
      <(printf "master\\n")
  }

  run "${_NB}" notebooks add "${_GIT_REMOTE_URL}" <<< "${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                       ]]

  [[    "${lines[0]}"   =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\. ]]
  [[    "${lines[1]}"   =~  Cloning\ into\ \'${NB_DIR}/remote\'   ]]
  [[    "${lines[2]}"   =~  Added\ notebook\:\ .*remote.*         ]]

  [[    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7   ]]
  [[ -d "${NB_DIR}/remote/.git"                                   ]]
  [[ -f "${NB_DIR}/remote/Example File One.md"                    ]]

  diff                                                              \
    <(cd "${NB_DIR}/remote" && git config --get remote.origin.url)  \
    <(printf "%s\\n" "${_GIT_REMOTE_URL}")

  diff                                                              \
    <(cd "${NB_DIR}/remote" && git rev-parse --abbrev-ref HEAD)     \
    <(printf "master\\n")

  "${_NB}" git branch --all

  [[    "$("${_NB}" git branch --all)"  =~  \*\ master            ]]
  [[    "$("${_NB}" git branch --all)"  =~  remotes/origin/master ]]
}

# config ######################################################################

@test "'notebooks add --author' displays config prompt and sets email and name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global --includes user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global --includes user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks add "Example Notebook" --author \
    <<< "y${_NEWLINE}local@example.test${_NEWLINE}Example Local Name${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 11  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)"  ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)"  ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[4]}"  =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[5]}"  =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[6]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[7]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[8]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[9]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  [[ "${lines[10]}" =~ Added\ notebook:\ .*Example\ Notebook                  ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

# --email and --name ##########################################################

@test "'notebooks add --email <email> --name <name>' sets the local email and name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global --includes user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global --includes user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks add "Example Notebook"     \
    --email "local@example.test"                    \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 13  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks add --email <email>' sets the local email." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global --includes user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global --includes user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}"  notebooks add "Example Notebook"    \
    --email "local@example.test"                    \
    <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[11]}" =~ Added\ notebook:\ .*Example\ Notebook                  ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: %s <local@example.test>\\n" "${_global_name}")
}

@test "'notebooks add --name <name>' sets the local name." {
  {
    "${_NB}" init

    "${_NB}" add "Example Home File.md" --content "Example home content."

    declare _global_email=
    _global_email="$(git -C "${NB_DIR}/home" config --global --includes user.email)"

    declare _global_name=
    _global_name="$(git -C "${NB_DIR}/home" config --global --includes user.name)"

    diff                                            \
      <("${_NB}" git log -1 --stat | sed -n '2 p')  \
      <(printf "Author: %s <%s>\\n" "${_global_name}" "${_global_email}")
  }

  run "${_NB}" notebooks add "Example Notebook"     \
    --name "Example Local Name"                     \
    <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -z "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  [[ "${lines[11]}" =~ Added\ notebook:\ .*Example\ Notebook                  ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <%s>\\n" "${_global_email}")
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

    [[ "${status}"    -eq 1               ]]
    [[ "${lines[0]}"  =~  Name\ reserved  ]]
    [[ "${lines[0]}"  =~  ${__name}       ]]
  done
}

# `notebooks add <name>` ######################################################

@test "'notebooks add <existing>' exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add one


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                     ]]
  [[ "${lines[0]}"  =~  Already\ exists                       ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

@test "'notebooks add <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                     ]]
  [[ "${lines[0]}"  =~  Added\ notebook\:                     ]]
  [[ "${lines[0]}"  =~  example                               ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks add <name>' creates git commit." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf                                          \
    "\$(ls -la \"${NB_DIR}/example/\"): '%s'\\n"  \
    "$(ls -la "${NB_DIR}/example/")"

  [[ ${status} -eq 0 ]]

  printf "\$(git log): '%s'\n" "$(git -C "${NB_DIR}/example" log)"

  while [[ -n "$(git -C "${NB_DIR}/example" status --porcelain)" ]]
  do
    sleep 1
  done

  git -C "${NB_DIR}/example" log | grep -q '\[nb\] Initialize'
}

@test "'notebooks a <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks a example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]
  [[ "${output}"  =~  Added                                   ]]
  [[ "${output}"  =~  example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks create <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]
  [[ "${output}"  =~  Added                                   ]]
  [[ "${output}"  =~  example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "'notebooks new <name>' exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]
  [[ "${output}"  =~  Added                                   ]]
  [[ "${output}"  =~  example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}
