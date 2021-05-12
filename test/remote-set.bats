#!/usr/bin/env bats

load test_helper

# reassignment ################################################################

@test "'remote set <url>' to same existing remote branch sets remote and prints message and resets remote branch." {
  {
    "${_NB}" init

    _setup_remote_repo

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    diff                  \
      <("${_NB}" remote)  \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL}")

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                       ]]

  [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~  From:\ \ \ ${_GIT_REMOTE_URL}                           ]]
  [[ "${lines[2]}"  =~  [^-]-------------------------[^-]                       ]]
  [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                        ]]
  [[ "${lines[4]}"  =~  Branch:\ .*master                                       ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[6]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[7]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}                 ]]
  [[ "${lines[8]}"  =~  Remote\ branch\ reset:\ .*master                        ]]
  [[ "${lines[9]}"  =~  Remote\ removed\.                                       ]]
  [[ "${lines[10]}" =~  [^-]---------------[^-]                                 ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)                        ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

# alias #######################################################################

@test "'set remote <url> <branch>' with no existing remote and no matching remote branch pushes branch as new orphan, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    [[ -f "${NB_DIR}/home/Example File One.md"                      ]]

    _setup_remote_repo
  }

  run "${_NB}" set remote "${_GIT_REMOTE_URL}" "example" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "remote:    '%s'\\n" "$("${_NB}" remote)"

  [[ "${status}"    -eq 0                                               ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                     ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                  ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                              ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                          ]]

  [[ "${lines[5]}"  =~  [^-]--------------[^-]                          ]]
  [[ "${lines[6]}"  =~  Branch\ not\ present\ on\ remote:\ .*example    ]]
  [[ "${lines[7]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.     ]]
  [[ "${lines[8]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.        ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]          ]]
  [[ "${lines[10]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\           ]]
  [[ "${lines[10]}" =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.            ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*example.*\)               ]]

  diff                                                                  \
    <(git -C "${NB_DIR}/home" branch --all)                             \
    <(printf "* example\\n  remotes/origin/example\\n")

  run "${_NB}" git branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}" =~ \*\ example                                    ]]
  [[    "${lines[1]}" =~ remotes/origin/example                         ]]
  [[ !  "${output}"   =~ remotes/origin/master                          ]]

  git clone --branch "example" "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ example                                   ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master      ]]
  [[    "${lines[2]}"  =~ remotes/origin/example                        ]]
  [[    "${lines[3]}"  =~ remotes/origin/master                         ]]

  [[ -f "${_TMP_DIR}/new-clone/Example File One.md"                     ]]

  diff                                                                  \
    <("${_NB}" remote)                                                  \
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

# merge with existing branch ##################################################

@test "'remote set <url> <branch>' with unshared histories syncs to same branch." {
  {
    "${_NB}" init

    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"
  }

  # Notebook One

  {
    "${_NB}" notebooks init "${_TMP_DIR}/Notebook One"
    cd "${_TMP_DIR}/Notebook One"

    "${_NB}" add "File One.md" --content "Content."

    [[    -f "${_TMP_DIR}/Notebook One/File One.md"                 ]]
    [[ !  -f "${_TMP_DIR}/Notebook One/File Two.md"                 ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "shared-branch" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  printf "local branches:   '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook One" branch --all
  )"

  printf "remote branches:  '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook One" ls-remote                     \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*local                ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*shared-branch                    ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*shared-branch.*\)     ]]

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (shared-branch)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook One" branch --all)               \
    <(printf "* shared-branch\\n  remotes/origin/shared-branch\\n")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook One" ls-remote                   \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "shared-branch\\n")

  # Notebook Two

  {
    sleep 1

    "${_NB}" notebooks init "${_TMP_DIR}/Notebook Two"
    cd "${_TMP_DIR}/Notebook Two"

    "${_NB}" add "File Two.md" --content "Content."

    [[ !  -f "${_TMP_DIR}/Notebook Two/File One.md"                 ]]
    [[    -f "${_TMP_DIR}/Notebook Two/File Two.md"                 ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "shared-branch" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  printf "local branches:   '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook Two" branch --all
  )"

  printf "remote branches:  '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook Two" ls-remote                     \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*local                ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*shared-branch                    ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[6]}"  =~  \
Remote\ branch\ has\ existing\ history:\ .*shared-branch            ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*shared-branch ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                      ]]
  [[ "${lines[9]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*shared-branch.*\)     ]]

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (shared-branch)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook Two" branch --all)               \
    <(printf "* shared-branch\\n  remotes/origin/shared-branch\\n")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook Two" ls-remote                   \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "shared-branch\\n")

  [[    -f "${_TMP_DIR}/Notebook Two/File One.md"                   ]]
  [[    -f "${_TMP_DIR}/Notebook Two/File Two.md"                   ]]
}

@test "'remote set <url>' with unshared histories syncs to same branch." {
  {
    "${_NB}" init

    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"
  }

  # Notebook One

  {
    "${_NB}" notebooks init "${_TMP_DIR}/Notebook One"
    cd "${_TMP_DIR}/Notebook One"

    "${_NB}" add "File One.md" --content "Example content one."

    [[    -f "${_TMP_DIR}/Notebook One/File One.md"                 ]]
    [[ !  -f "${_TMP_DIR}/Notebook One/File Two.md"                 ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  printf "local branches:   '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook One" branch --all
  )"

  printf "remote branches:  '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook One" ls-remote                     \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*local                ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook One" branch --all)               \
    <(printf "* master\\n  remotes/origin/master\\n")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook One" ls-remote                   \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\n")

  # Notebook Two

  {
    sleep 1

    "${_NB}" notebooks init "${_TMP_DIR}/Notebook Two"
    cd "${_TMP_DIR}/Notebook Two"

    "${_NB}" add "File Two.md" --content "Sample content two."

    [[ !  -f "${_TMP_DIR}/Notebook Two/File One.md"                 ]]
    [[    -f "${_TMP_DIR}/Notebook Two/File Two.md"                 ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  printf "local branches:   '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook Two" branch --all
  )"

  printf "remote branches:  '%s'\\n" "$(
    git -C "${_TMP_DIR}/Notebook Two" ls-remote                     \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*local                ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[6]}"  =~  \
Remote\ branch\ has\ existing\ history:\ .*master                   ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]
  [[ "${lines[9]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook Two" branch --all)               \
    <(printf "* master\\n  remotes/origin/master\\n")

  diff                                                              \
    <(git -C "${_TMP_DIR}/Notebook Two" ls-remote                   \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\n")

  [[    -f "${_TMP_DIR}/Notebook Two/File One.md"                   ]]
  [[    -f "${_TMP_DIR}/Notebook Two/File Two.md"                   ]]
}

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

  [[ "${status}"    -eq 0                                           ]]

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

  diff                                                  \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote     \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g") \
    <(printf "master\\n")

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

# exiting #####################################################################

@test "'remote set' with exit on third prompt does not set new remote." {
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

  [[ "${status}"                -eq 0                       ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured. ]]
}

@test "'remote set' with exit on second prompt does not set new remote." {
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

  [[ "${status}"                -eq 0                       ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured. ]]
}

# remote set ##################################################################

@test "'remote set' with unrelated histories displays prompt and merges with existing branch." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                               ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"              ]]

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

  [[ "${status}"    -eq 0                                                 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[6]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]
  [[ "${lines[9]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)                  ]]

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "master\\n")

  diff                                                    \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote        \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")   \
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

@test "'remote set' with unrelated histories displays prompts and merges with selected existing branch." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                               ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"              ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

    diff                                                    \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote       \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")   \
      <(printf "master\\n")

    diff                                                    \
      <("${_NB}" remote)                                    \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                    \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)   \
      <(printf "* master\\n  remotes/origin/HEAD -> origin/master\\n  remotes/origin/master\\n")

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"

    "${_NB}" add "Demo File.md" --content "Demo content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                    \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote          \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")   \
      <(printf "demo-notebook\\nmaster\\n")

    diff                                                    \
      <("${_NB}" remote)                                    \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                    \
      <(git -C "${NB_DIR}/Demo Notebook" branch --all)      \
      <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

    declare _demo_hashes=()
    _demo_hashes=($("${_NB}" git rev-list origin/demo-notebook))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[6]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Merge\ and\ sync\ with\ a\ different\ existing\ remote\ branch\.   ]]
  [[ "${lines[9]}"  =~  \
.*\[.*3.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]

  [[ "${lines[10]}"  =~  [^-]------------------------------[^-]           ]]
  [[ "${lines[11]}" =~  Remote\ branches:                                 ]]
  [[ "${lines[12]}" =~  .*[.*1.*].*\ demo-notebook                        ]]
  [[ "${lines[13]}" =~  .*[.*2.*].*\ master                               ]]

  [[ "${lines[14]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*demo-notebook.*\)           ]]

  diff                                                    \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote        \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")   \
    <(printf "demo-notebook\\nmaster\\n")

  diff                                                    \
    <("${_NB}" remote)                                    \
    <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                    \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)    \
    <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

  declare _sample_hashes=()
  _sample_hashes=($("${_NB}" git rev-list origin/demo-notebook))

  printf "\${#_example_hashes[@]}:  '%s'\\n" "${#_example_hashes[@]}"
  printf "\${#_demo_hashes[@]}:     '%s'\\n" "${#_demo_hashes[@]}"
  printf "\${#_sample_hashes[@]}:   '%s'\\n" "${#_sample_hashes[@]}"

  [[ "${#_example_hashes[@]}" -eq 2                       ]]
  [[ "${#_demo_hashes[@]}"    -eq 2                       ]]
  [[ "${#_sample_hashes[@]}"  -eq 3                       ]]

  [[ "${_demo_hashes[0]}"     ==  "${_sample_hashes[1]}"  ]]
  [[ "${_demo_hashes[1]}"     ==  "${_sample_hashes[2]}"  ]]

  _contains   "${_demo_hashes[0]}" "${_sample_hashes[@]}"
  _contains   "${_demo_hashes[1]}" "${_sample_hashes[@]}"

  ! _contains "${_example_hashes[0]}" "${_sample_hashes[@]}"
  ! _contains "${_example_hashes[1]}" "${_sample_hashes[@]}"
}

@test "'remote set' with unrelated histories displays prompt and creates new orphan branch with name from prompt." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                             ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"            ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

  diff                                                    \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"                      \
        | sed "s/.*\///g" || :)                           \
    <(printf "master\\n")

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}"            \
    <<< "y${_NEWLINE}3${_NEWLINE}branch-name-from-prompt${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[6]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]            ]]
  [[ "${lines[10]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\             ]]
  [[ "${lines[10]}" =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.              ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*branch-name-from-prompt.*\) ]]

  diff                                                    \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"                      \
        | sed "s/.*\///g" || :)                           \
    <(printf "branch-name-from-prompt\\nmaster\\n")

  declare _sample_hashes=()
  _sample_hashes=($("${_NB}" git rev-list origin/branch-name-from-prompt))

  [[ "${#_example_hashes[@]}" -eq 2                       ]]
  [[ "${#_sample_hashes[@]}"  -eq 2                       ]]

  ! _contains "${_example_hashes[0]}" "${_sample_hashes[@]}"
  ! _contains "${_example_hashes[1]}" "${_sample_hashes[@]}"
}

@test "'remote set' with unrelated histories displays prompt and creates new orphan branch named after notebook." {
  {
    _setup_remote_repo

    "${_NB}" init "${_GIT_REMOTE_URL}"

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                             ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"            ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" sync

  diff                                                    \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"                      \
        | sed "s/.*\///g" || :)                           \
    <(printf "master\\n")

    declare _example_hashes=()
    _example_hashes=($("${_NB}" git rev-list origin/master))

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[6]}"  =~  Remote\ branch\ has\ existing\ history:\ .*master ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]            ]]
  [[ "${lines[10]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\             ]]
  [[ "${lines[10]}" =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.              ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*sample-notebook.*\)         ]]

  diff                                                    \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"                      \
        | sed "s/.*\///g" || :)                           \
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

  [[ "${status}"    -eq 0                                             ]]

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

@test "'remote set <url>' with existing invalid remote sets remote and prints message." {
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

  [[ "${status}"    -eq 0                                                       ]]

  [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~  From:\ \ \ https://example.test/example.git             ]]
  [[ "${lines[2]}"  =~  [^-]-------------------------[^-]                       ]]
  [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                        ]]
  [[ "${lines[4]}"  =~  Branch:\ .*master                                       ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[6]}"  =~  [^-]--------------[^-]                                  ]]
  [[ "${lines[7]}"  =~  Removing\ remote:\ .*https://example.test/example.git   ]]
  [[ "${lines[8]}"  =~  \!.*\ Unable\ to\ contact\ remote\.                     ]]
  [[ "${lines[9]}"  =~  Remote\ removed\.                                       ]]
  [[ "${lines[10]}" =~  [^-]---------------[^-]                                 ]]
  [[ "${lines[11]}" =~  \
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

    [[ "${status}"    -eq 0                                         ]]

    [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home            ]]
    [[ "${lines[1]}"  =~  From:\ \ \ ${_GIT_REMOTE_URL}             ]]
    [[ "${lines[2]}"  =~  [^-]-------------------------[^-]         ]]
    [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}          ]]
    [[ "${lines[4]}"  =~  Branch:\ .*master                         ]]
    [[ "${lines[5]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[6]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[7]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
    [[ "${lines[8]}"  =~  Remote\ removed.                          ]]
    [[ "${lines[9]}"  =~  [^-]---------------[^-]                   ]]
    [[ "${lines[10]}" =~  \
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

  [[ "${status}"    -eq 0                                           ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook     ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]   ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}            ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[6]}"  =~  \
Remote\ branch\ has\ existing\ history:\ .*master                   ]]
  [[ "${lines[7]}"  =~  \
.*\[.*1.*\].*\ Merge\ and\ sync\ with\ the\ existing\ remote\ branch\:\ .*master  ]]
  [[ "${lines[8]}"  =~  \
.*\[.*2.*\].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.                ]]
  [[ "${lines[9]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]

  declare _new_hashes=()
  _new_hashes=($("${_NB}" git rev-list origin/master))

  printf "remote hashes:  %s\\n" "${_remote_hashes[@]}"
  printf "new hashes:     %s\\n" "${_new_hashes[@]}"
  "${_NB}" git log

  [[ "${#_remote_hashes[@]}"  -eq 2                                 ]]
  [[ "${#_new_hashes[@]}"     -eq 3                                 ]]

  [[ "${_remote_hashes[0]}"   ==  "${_new_hashes[1]}"               ]]
  [[ "${_remote_hashes[1]}"   ==  "${_new_hashes[2]}"               ]]
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

    [[ "${status}"    -eq 0                                         ]]

    [[ "${lines[0]}"  =~  Updating\ remote\ for:\ .*home            ]]
    [[ "${lines[1]}"  =~  From:\ \ \ ${_GIT_REMOTE_URL}             ]]
    [[ "${lines[2]}"  =~  [^-]-------------------------[^-]         ]]
    [[ "${lines[3]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}          ]]
    [[ "${lines[4]}"  =~  Branch:\ .*master                         ]]
    [[ "${lines[5]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[6]}"  =~  [^-]--------------[^-]                    ]]
    [[ "${lines[7]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
    [[ "${lines[8]}"  =~  Remote\ removed.                          ]]
    [[ "${lines[9]}"  =~  [^-]---------------[^-]                   ]]
    [[ "${lines[10]}" =~  \
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

  [[ "${status}"    -eq 0                                           ]]

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

  [[ "${#_remote_hashes[@]}"  -eq 2                                 ]]
  [[ "${#_new_hashes[@]}"     -eq 3                                 ]]

  [[ "${_remote_hashes[0]}"   ==  "${_new_hashes[1]}"               ]]
  [[ "${_remote_hashes[1]}"   ==  "${_new_hashes[2]}"               ]]
}

@test "'remote set <url> <branch>' with no existing remote and no matching remote branch pushes branch as new orphan, sets remote, and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File One.md" --content "Example content one."

    [[ -f "${NB_DIR}/home/Example File One.md"                      ]]

    _setup_remote_repo
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" "example" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "remote:    '%s'\\n" "$("${_NB}" remote)"

  [[ "${status}"    -eq 0                                               ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                     ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                  ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                              ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                          ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                          ]]
  [[ "${lines[6]}"  =~  Branch\ not\ present\ on\ remote:\ .*example    ]]
  [[ "${lines[7]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.     ]]
  [[ "${lines[8]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.        ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]          ]]
  [[ "${lines[10]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\           ]]
  [[ "${lines[10]}" =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.            ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*example.*\)               ]]

  diff                                                                  \
    <(git -C "${NB_DIR}/home" branch --all)                             \
    <(printf "* example\\n  remotes/origin/example\\n")

  run "${_NB}" git branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}" =~ \*\ example                                    ]]
  [[    "${lines[1]}" =~ remotes/origin/example                         ]]
  [[ !  "${output}"   =~ remotes/origin/master                          ]]

  git clone --branch "example" "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ example                                   ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master      ]]
  [[    "${lines[2]}"  =~ remotes/origin/example                        ]]
  [[    "${lines[3]}"  =~ remotes/origin/master                         ]]

  [[ -f "${_TMP_DIR}/new-clone/Example File One.md"                     ]]

  diff                                                                  \
    <("${_NB}" remote)                                                  \
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

  [[ "${status}"    -eq 0                                             ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[6]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[7]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[8]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]        ]]
  [[ "${lines[10]}" =~  Remote\ branches:                             ]]
  [[ "${lines[11]}" =~  .*[.*1.*].*\ master                           ]]

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

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0                                             ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[6]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[7]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[8]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]        ]]
  [[ "${lines[10]}" =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\         ]]
  [[ "${lines[10]}" =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.          ]]
  [[ "${lines[11]}" =~  \
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

  [[ "${status}"    -eq 0                                             ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home                   ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]                ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}              ]]
  [[ "${lines[3]}"  =~  Branch:\ .*example                            ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[5]}"  =~  [^-]--------------[^-]                        ]]
  [[ "${lines[6]}"  =~  Branch\ not\ present\ on\ remote:\ .*example  ]]
  [[ "${lines[7]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\.   ]]
  [[ "${lines[8]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.      ]]
  [[ "${lines[9]}"  =~  [^-]------------------------------[^-]        ]]
  [[ "${lines[10]}" =~  Remote\ branches:                             ]]
  [[ "${lines[11]}" =~  .*[.*1.*].*\ master                           ]]
  [[ "${lines[12]}" =~  \
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
