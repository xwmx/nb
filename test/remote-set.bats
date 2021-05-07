#!/usr/bin/env bats

load test_helper

# empty remote ################################################################

@test "'remote set' with empty remote pushes branch." {
  {
    mkdir "${_TMP_DIR}/bare-repo"
    cd "${_TMP_DIR}/bare-repo"
    git init
    mv "${_TMP_DIR}/bare-repo/.git" "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git config --bool core.bare true

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                   ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"  ]]

    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Example\ Notebook    ]]
  [[ "${lines[1]}"  =~  [^-]----------------------------------[^-]  ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "master\\n")

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

# exiting #####################################################################

@test "'remote set' with exit on third prompt removes new remote." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                   ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"  ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."

    "${_NB}" git branch -m "sample-branch"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}q${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured. ]]
}

@test "'remote set' with exit on second prompt removes new remote." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                   ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"  ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."

    "${_NB}" git branch -m "sample-branch"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}q${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured. ]]
}

# remote set ##################################################################

@test "'remote set' with unrelated histories displays prompt and merges with existing." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                   ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"  ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[6]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ existing\ remote\ branch\.         ]]
  [[ "${lines[7]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.        ]]
  [[ "${lines[8]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)                  ]]

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "master\\n")

  declare _sample_hashes=()
  _sample_hashes=($("${_NB}" git rev-list origin/master))

  [[ "${#_example_hashes[@]}" -eq 2                       ]]
  [[ "${#_sample_hashes[@]}"  -eq 3                       ]]

  [[ "${_example_hashes[0]}"  ==  "${_sample_hashes[1]}"  ]]
  [[ "${_example_hashes[1]}"  ==  "${_sample_hashes[2]}"  ]]

  _contains "${_example_hashes[0]}" "${_sample_hashes[@]}"
  _contains "${_example_hashes[1]}" "${_sample_hashes[@]}"
}

@test "'remote set' with unrelated histories displays prompt and creates new orphan." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                   ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"  ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[6]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ existing\ remote\ branch\.         ]]
  [[ "${lines[7]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.        ]]
  [[ "${lines[8]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*sample-notebook.*\)         ]]

  diff                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote \
        --heads "${_GIT_REMOTE_URL}"                \
        | sed "s/.*\///g" || :)                     \
    <(printf "master\\nsample-notebook\\n")

  declare _sample_hashes=()
  _sample_hashes=($("${_NB}" git rev-list origin/sample-notebook))

  [[ "${#_example_hashes[@]}" -eq 2                       ]]
  [[ "${#_sample_hashes[@]}"  -eq 2                       ]]

  ! _contains "${_example_hashes[0]}" "${_sample_hashes[@]}"
  ! _contains "${_example_hashes[1]}" "${_sample_hashes[@]}"
}

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
