#!/usr/bin/env bats

load test_helper

# remote set ##################################################################

@test "'remote set <url> <branch>' with no existing remote and no matching remote branch pushes branch as new orphan, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "example" <<< "2${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Sync\ with\ an\ existing\ remote\ branch.                ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote.       ]]
  [[ "${lines[5]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[6]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[7]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[8]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[9]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[10]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*example.*\)             ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (example)\\n" "${_GIT_REMOTE_URL:-}")

  "${_NB}" git fetch origin
  "${_NB}" git push origin

  declare _master_branch_hashes=()
  _master_branch_hashes=($("${_NB}" git rev-list origin/master))

  [[ "${#_master_branch_hashes[@]}"   == "1"                            ]]

  declare _example_branch_hashes=()
  _example_branch_hashes=($("${_NB}" git rev-list origin/example))

  [[ "${#_example_branch_hashes[@]}"  == "2"                            ]]

  [[ "${_master_branch_hashes[0]}"    != "${_example_branch_hashes[0]}" ]]
  [[ "${_master_branch_hashes[0]}"    != "${_example_branch_hashes[1]}" ]]
}

@test "'remote set <url> <branch>' with no existing remote and no matching remote branch updates local branch, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "example" <<< "1${_NEWLINE}1${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Sync\ with\ an\ existing\ remote\ branch.                ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote.       ]]
  [[ "${lines[5]}"  =~  Remote\ branches:                             ]]
  [[ "${lines[6]}"  =~  .*[.*1.*].*\ master                           ]]
  [[ "${lines[7]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[8]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[9]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[10]}" =~  Branch:\ .*master                             ]]
  [[ "${lines[11]}" =~  [^-]--------------[^-]                        ]]
  [[ "${lines[12]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)              ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' with no existing remote and no matching remote branch pushes branch as new orphan, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" git branch -m example

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "2${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Sync\ with\ an\ existing\ remote\ branch.                ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote.       ]]
  [[ "${lines[5]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[6]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[7]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[8]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[9]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[10]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*example.*\)             ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (example)\\n" "${_GIT_REMOTE_URL:-}")

  "${_NB}" git fetch origin
  "${_NB}" git push origin

  declare _master_branch_hashes=()
  _master_branch_hashes=($("${_NB}" git rev-list origin/master))

  [[ "${#_master_branch_hashes[@]}"   == "1"                            ]]

  declare _example_branch_hashes=()
  _example_branch_hashes=($("${_NB}" git rev-list origin/example))

  [[ "${#_example_branch_hashes[@]}"  == "2"                            ]]

  [[ "${_master_branch_hashes[0]}"    != "${_example_branch_hashes[0]}" ]]
  [[ "${_master_branch_hashes[0]}"    != "${_example_branch_hashes[1]}" ]]
}

@test "'remote set <url>' with no existing remote and no matching remote branch updates local branch, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    "${_NB}" git branch -m example

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "1${_NEWLINE}1${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Sync\ with\ an\ existing\ remote\ branch.                ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote.       ]]
  [[ "${lines[5]}"  =~  Remote\ branches:                             ]]
  [[ "${lines[6]}"  =~  .*[.*1.*].*\ master                           ]]
  [[ "${lines[7]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[8]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[9]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[10]}" =~  Branch:\ .*master                             ]]
  [[ "${lines[11]}" =~  [^-]--------------[^-]                        ]]
  [[ "${lines[12]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)              ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

# previous: ###################################################################

@test "'remote set <url>' with no existing remote and matching branch name sets remote and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                             ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)              ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' with existing remote sets remote and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" git remote add origin "https://example.test/example.git"

    diff                  \
      <("${_NB}" remote)  \
      <(printf "https://example.test/example.git (master)\\n")
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]


  [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home              ]]
  [[ "${lines[1]}"  =~  [^-]-------------------------[^-]           ]]
  [[ "${lines[2]}"  =~  From:\ \ \ https://example.test/example.git ]]

  [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[4]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[6]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' to same URL and branch as existing remote exits and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"          -eq 1 ]]

  [[ "${lines[0]}"        =~  Remote\ already\ set\ to:             ]]
  [[ "${lines[1]}"        =~  .*${_GIT_REMOTE_URL}.*\ (.*master.*)  ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set' with no URL exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote set --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1       ]]
  [[ "${lines[0]}"  =~  Usage\: ]]
}
