#!/usr/bin/env bats

load test_helper

# remote set ##################################################################

@test "'remote set <url>' with no existing remote and matching branch name with no history sets remote and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

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

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~  From:\ \ \ https://example.test/example.git             ]]
  [[ "${lines[2]}"  =~  [^-]-------------------------[^-]                       ]]

  [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                        ]]
  [[ "${lines[4]}"  =~  Branch:\ .*master                                       ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[6]}"  =~  Removing\ remote:\ .*https://example.test/example.git   ]]
  [[ "${lines[7]}"  =~  Removed\ \ remote:\ .*https://example.test/example.git  ]]
  [[ "${lines[8]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[9]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)                        ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' to same URL and branch as existing remote with unshared history updates remote and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    _setup_remote_repo

    "${_NB}" git remote add origin "${_GIT_REMOTE_URL}"

    run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"    -eq 0 ]]

    [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home            ]]
    [[ "${lines[1]}"  =~  From:\ \ \ ${_GIT_REMOTE_URL}             ]]
    [[ "${lines[2]}"  =~  [^-]-------------------------[^-]         ]]

    [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}          ]]
    [[ "${lines[4]}"  =~  Branch:\ .*master                         ]]
    [[ "${lines[5]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[6]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

    diff                  \
      <("${_NB}" remote)  \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    declare _remote_hashes=()
    _remote_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" git log

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook     ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]   ]]

  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  \
Remote\ branch\ has\ existing\ history:\ .*master                   ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ existing\ remote\ branch\.     ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.    ]]
  [[ "${lines[8]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  declare _new_hashes=()
  _new_hashes=($("${_NB}" git rev-list origin/master))

  printf "remote hashes:  %s\\n" "${_remote_hashes[@]}"
  printf "new hashes:     %s\\n" "${_new_hashes[@]}"
  "${_NB}" git log

  [[ "${#_remote_hashes[@]}"  -eq 2                   ]]
  [[ "${#_new_hashes[@]}"     -eq 3                   ]]

  [[ "${_remote_hashes[0]}"   ==  "${_new_hashes[1]}" ]]
  [[ "${_remote_hashes[1]}"   ==  "${_new_hashes[2]}" ]]
}

@test "'remote set <url>' to same URL and branch as existing remote with shared history updates remote and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    _setup_remote_repo

    "${_NB}" git remote add origin "${_GIT_REMOTE_URL}"

    run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"    -eq 0 ]]

    [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home            ]]
    [[ "${lines[1]}"  =~  From:\ \ \ ${_GIT_REMOTE_URL}             ]]
    [[ "${lines[2]}"  =~  [^-]-------------------------[^-]         ]]

    [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}          ]]
    [[ "${lines[4]}"  =~  Branch:\ .*master                         ]]
    [[ "${lines[5]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[6]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

    diff                  \
      <("${_NB}" remote)  \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    declare _remote_hashes=()
    _remote_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" git log

    "${_NB}" remote unset "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}n${_NEWLINE}"

    [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured.       ]]

    "${_NB}" add "Example File Two.md" --content "Example content two."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                 ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]              ]]

  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  declare _new_hashes=()
  _new_hashes=($("${_NB}" git rev-list origin/master))

  printf "remote hashes:  %s\\n" "${_remote_hashes[@]}"
  printf "new hashes:     %s\\n" "${_new_hashes[@]}"
  "${_NB}" git log

  [[ "${#_remote_hashes[@]}"  -eq 2                   ]]
  [[ "${#_new_hashes[@]}"     -eq 3                   ]]

  [[ "${_remote_hashes[0]}"   ==  "${_new_hashes[1]}" ]]
  [[ "${_remote_hashes[1]}"   ==  "${_new_hashes[2]}" ]]
}

@test "'remote set <url> <branch>' with no existing remote and no matching remote branch pushes branch as new orphan, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    [[ -f "${NB_DIR}/home/Example File One.md" ]]

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "example" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "remote:    '%s'\\n" "$("${_NB}" remote)"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]

  [[ "${lines[5]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]
  [[ "${lines[8]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*example.*\)             ]]

  diff                                      \
    <(git -C "${NB_DIR}/home" branch --all) \
    <(printf "* example\\n  remotes/origin/example\\n")

  run "${_NB}" git branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}" =~ \*\ example            ]]
  [[    "${lines[1]}" =~ remotes/origin/example ]]
  [[ !  "${output}"   =~ remotes/origin/master  ]]

  git clone --branch "example" "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ example                              ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master ]]
  [[    "${lines[2]}"  =~ remotes/origin/example                   ]]
  [[    "${lines[3]}"  =~ remotes/origin/master                    ]]

  [[ -f "${_TMP_DIR}/new-clone/Example File One.md" ]]

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

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "example" <<< "y${_NEWLINE}1${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]

  [[ "${lines[5]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]

  [[ "${lines[8]}"  =~  Remote\ branches:                             ]]
  [[ "${lines[9]}"  =~  .*[.*1.*].*\ master                           ]]

  [[ "${lines[10]}" =~  \
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

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]

  [[ "${lines[5]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]
  [[ "${lines[8]}"  =~  \
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

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]

  [[ "${lines[5]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]

  [[ "${lines[8]}"  =~  Remote\ branches:                             ]]
  [[ "${lines[9]}"  =~  .*[.*1.*].*\ master                           ]]

  [[ "${lines[10]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)              ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set' with no URL exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote set

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1         ]]
  [[ "${lines[0]}"  =~  Usage.*\: ]]
}
