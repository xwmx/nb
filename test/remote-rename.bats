#!/usr/bin/env bats

load test_helper

# `remote rename` #############################################################

@test "'remote rename <remote-branch> <name>' with orphan <remote-branch> updates remote branch." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote                \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")

    "${_NB}" notebooks use "Example Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
  }

  run "${_NB}" remote rename sample-notebook "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  [[ "${lines[0]}"  =~  Renaming\ remote\ branch                    ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  From:\ sample-notebook                      ]]
  [[ "${lines[3]}"  =~  To:\ \ \ .*updated-branch-name.*$           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]

  printf "local example branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "local sample branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" branch --all
  )"

  printf "remote branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                   \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch:     '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nupdated-branch-name\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\n  remotes/origin/master\\n")


  "${_NB}" notebooks use "Sample Notebook"

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nupdated-branch-name\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")

  run "${_NB}" sync <<< "y${_NEWLINE}1${_NEWLINE}2${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  printf "local example branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "local sample branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" branch --all
  )"

  printf "remote branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                   \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch:     '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  [[ "${lines[1]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[2]}"  =~  \
Branch\ not\ present\ on\ remote:\ .*sample-notebook                ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\. ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.    ]]
  [[ "${lines[5]}"  =~  [^-]------------------------------[^-]      ]]
  [[ "${lines[6]}"  =~  Remote\ branches:                           ]]
  [[ "${lines[7]}"  =~  .*[.*1.*].*\ master                         ]]
  [[ "${lines[8]}"  =~  .*[.*2.*].*\ updated-branch-name            ]]
  [[ "${lines[9]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[10]}" =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[11]}" =~  Remote\ removed.                            ]]
  [[ "${lines[12]}" =~  [^-]---------------[^-]                     ]]
  [[ "${lines[13]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*updated-branch-name.*\)  ]]

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nupdated-branch-name\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (updated-branch-name)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* updated-branch-name\\n  remotes/origin/updated-branch-name\\n")
}

@test "'remote rename <name>' with orphan current branch updates local and remote branch." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote                \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")

    "${_NB}" notebooks use "Example Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
  }

  run "${_NB}" remote rename "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                                             ]]

  [[ "${output}"  =~  \
!.*\ Only\ orphan\ branches\ can\ be\ renamed\.                     ]]

  printf "local branches:     '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "remote branches:    '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                   \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch: '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

# error handling ##############################################################

@test "'remote rename <remote-branch> <name>' with <remote-branch> as remote HEAD prints message without updating." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote                \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
  }

  run "${_NB}" remote rename master "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                                             ]]

  [[ "${output}"  =~  \
!.*\ Only\ orphan\ branches\ can\ be\ renamed\.                     ]]

  printf "local branches:     '%s'\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" branch --all
  )"

  printf "remote branches:    '%s'\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" ls-remote                    \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch: '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
}

@test "'remote rename <name>' with current branch as remote HEAD prints message without updating." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" ls-remote                \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")

    "${_NB}" notebooks use "Example Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
  }

  run "${_NB}" remote rename "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                                             ]]

  [[ "${output}"  =~  \
!.*\ Only\ orphan\ branches\ can\ be\ renamed\.                     ]]

  printf "local branches:     '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "remote branches:    '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                    \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch: '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

@test "'remote rename <remote-branch> <name>' with only one remote branch displays message without updating." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote rename master "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                                             ]]

  [[ "${output}"  =~  \
!.*\ Only\ orphan\ branches\ can\ be\ renamed\.                     ]]

  printf "local branches:     '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "remote branches:    '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                   \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch: '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

@test "'remote rename <name>' with only one remote branch displays message without updating." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote rename "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 1                                             ]]

  [[ "${output}"  =~  \
!.*\ Only\ orphan\ branches\ can\ be\ renamed\.                     ]]

  printf "local branches:     '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "remote branches:    '%s'\\n" "$(
    git -C "${NB_DIR}/Example Notebook" ls-remote                   \
      --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g"
  )"

  printf "remote HEAD branch: '%s'\\n" "$(
    git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD                \
      | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}'
  )"

  diff                                                              \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD              \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')   \
    <(printf "master\\n")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "master\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

@test "'remote rename <name>' with no remote renames current branch." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    diff                                                            \
      <(git -C "${NB_DIR}/home" branch --all)                       \
      <(printf "* master\\n")

    [[ "$("${_NB}" remote 2>&1)" =~  \!.*\ No\ remote\ configured\. ]]
  }

  run "${_NB}" remote rename "updated-branch-name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  [[ "${lines[0]}"  =~  Renaming\ current\ branch                   ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]             ]]
  [[ "${lines[2]}"  =~  From:\ master                               ]]
  [[ "${lines[3]}"  =~  To:\ \ \ .*updated-branch-name.*$           ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[5]}"  =~  Renamed\ to:\ .*updated-branch-name.*$      ]]

    diff                                                            \
      <(git -C "${NB_DIR}/home" branch --all)                       \
      <(printf "* updated-branch-name\\n")

  [[ "$("${_NB}" remote 2>&1)" =~  \!.*\ No\ remote\ configured\.   ]]
}

@test "'remote rename' with missing <name> prints help." {
  {
    mkdir "${_GIT_REMOTE_PATH}"
    cd "${_GIT_REMOTE_PATH}"
    git init --bare &>/dev/null

    cd "${_TMP_DIR}"

    "${_NB}" init

    "${_NB}" notebooks rename "home" "Example Notebook"

    [[ !  -e "${NB_DIR}/home"                                       ]]
    [[    -d "${NB_DIR}/Example Notebook/.git"                      ]]

    "${_NB}" add "Example File.md" --content "Example content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" ls-remote               \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "master\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
  }

  run "${_NB}" remote rename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]

  [[ "${lines[0]}"  =~  Usage.*\:               ]]
  [[ "${lines[1]}"  =~  \ \ nb\ remote          ]]
}
