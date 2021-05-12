#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'remote delete <branch>' with non-valid remote prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" git remote add origin "https://example.test/example.git"

    diff                  \
      <("${_NB}" remote)  \
      <(printf "https://example.test/example.git (master)\\n")
  }

  run "${_NB}" remote delete "master"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                   ]]
  [[ "${#lines[@]}" -eq 1                                   ]]

  [[ "${lines[0]}"  =~  \!.*\ Unable\ to\ contact\ remote\. ]]
}

@test "'remote delete <branch>' with no remote prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote delete "master"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                               ]]
  [[ "${#lines[@]}" -eq 1                               ]]

  [[ "${lines[0]}"  =~  \!.*\ No\ remote\ configured\.  ]]
}

@test "'remote delete' with missing <remote-branch> prints help." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"
  }

  run "${_NB}" remote delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1           ]]

  [[ "${lines[0]}"  =~  Usage.*\:   ]]
  [[ "${lines[1]}"  =~  nb\ remote  ]]
}

@test "'remote delete <not-valid>' with missing <remote-branch> prints help." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}"
  }

  run "${_NB}" remote delete "example-branch"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1           ]]
  [[ "${#lines[@]}" -eq 1           ]]

  [[ "${lines[0]}"  =~  Remote\ branch\ not\ found:\ .*example-branch   ]]
}

# `remote delete` primary branch ##############################################

@test "'remote delete <remote-branch>' with primary current <remote-branch> resets remote branch." {
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

    declare _example_before_hashes=()
    _example_before_hashes=($("${_NB}" git rev-list origin/master))

    [[ "${#_example_before_hashes[@]}"  -eq 2                       ]]

    "${_NB}" git log

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Example\ File\.md ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" add "Sample File.md" --content "Sample content."

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

    declare _sample_before_hashes=()
    _sample_before_hashes=($("${_NB}" git rev-list origin/sample-notebook))

    [[ "${#_sample_before_hashes[@]}"  -eq 2                        ]]

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Sample\ File\.md  ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    sleep 1

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Demo Notebook"   ]]

    "${_NB}" add "Demo File.md" --content "Demo content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote                  \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" branch --all)              \
      <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

    declare _demo_before_hashes=()
    _demo_before_hashes=($("${_NB}" git rev-list origin/demo-notebook))

    [[ "${#_demo_before_hashes[@]}"  -eq 2                          ]]

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Demo\ File\.md    ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    "${_NB}" notebooks use "Example Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote delete master <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  [[ "${lines[0]}"  =~  Resetting\ remote\ branch:\ .*master        ]]
  [[ "${lines[1]}"  =~  [^-]------------------------[^-]            ]]
  [[ "${lines[2]}"  =~  Remote\ branch\ reset\.                     ]]

  git clone "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ master                                ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master  ]]
  [[    "${lines[2]}"  =~ remotes/origin/demo-notebook              ]]
  [[    "${lines[3]}"  =~ remotes/origin/master                     ]]
  [[    "${lines[4]}"  =~ remotes/origin/sample-notebook            ]]

  declare _example_after_hashes=()
  _example_after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  printf "_example_after_hashes: %s\\n" "${_example_after_hashes[@]}"

  [[ "${#_example_after_hashes[@]}" -eq 1                             ]]

  ! _contains "${_example_after_hashes[0]}" "${_example_before_hashes[@]}"

  [[ "${_example_after_hashes[0]}"  != "${_example_before_hashes[0]}" ]]
  [[ "${_example_after_hashes[0]}"  != "${_example_before_hashes[1]}" ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize  ]]

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
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\n  remotes/origin/master\\n")

  run "${_NB}" sync <<< "y${_NEWLINE}2${_NEWLINE}${_NEWLINE}"

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

  [[ "${lines[0]}"  =~  Syncing:\ .*Example\ Notebook.*\.\.\.       ]]
  [[ "${lines[1]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[2]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[3]}"  =~  Remote\ branch\ reset:\ .*master            ]]
  [[ "${lines[4]}"  =~  Remote\ removed.                            ]]
  [[ "${lines[5]}"  =~  [^-]---------------[^-]                     ]]
  [[ "${lines[6]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]
  [[ "${lines[7]}"  =~  Done\!                                      ]]

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

@test "'remote reset <remote-branch>' with primary non-current <remote-branch> resets remote branch." {
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

    declare _example_before_hashes=()
    _example_before_hashes=($("${_NB}" git rev-list origin/master))

    [[ "${#_example_before_hashes[@]}"  -eq 2                       ]]

    "${_NB}" git log

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Example\ File\.md ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Sample Notebook" ]]

    "${_NB}" add "Sample File.md" --content "Sample content."

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

    declare _sample_before_hashes=()
    _sample_before_hashes=($("${_NB}" git rev-list origin/sample-notebook))

    [[ "${#_sample_before_hashes[@]}"  -eq 2                        ]]

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Sample\ File\.md  ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    sleep 1

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Demo Notebook"   ]]

    "${_NB}" add "Demo File.md" --content "Demo content."

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote                  \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" branch --all)              \
      <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

    declare _demo_before_hashes=()
    _demo_before_hashes=($("${_NB}" git rev-list origin/demo-notebook))

    [[ "${#_demo_before_hashes[@]}"  -eq 2                          ]]

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Demo\ File\.md    ]]
    [[ "$("${_NB}" git log)"    =~  Initialize                      ]]

    "${_NB}" notebooks use "Sample Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
  }

  run "${_NB}" remote delete master <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                           ]]

  [[ "${lines[0]}"  =~  Resetting\ remote\ branch:\ .*master        ]]
  [[ "${lines[1]}"  =~  [^-]------------------------[^-]            ]]
  [[ "${lines[2]}"  =~  Remote\ branch\ reset\.                     ]]

  git clone "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ master                                ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master  ]]
  [[    "${lines[2]}"  =~ remotes/origin/demo-notebook              ]]
  [[    "${lines[3]}"  =~ remotes/origin/master                     ]]
  [[    "${lines[4]}"  =~ remotes/origin/sample-notebook            ]]

  declare _example_after_hashes=()
  _example_after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  printf "_example_after_hashes: %s\\n" "${_example_after_hashes[@]}"

  [[ "${#_example_after_hashes[@]}" -eq 1                             ]]

  ! _contains "${_example_after_hashes[0]}" "${_example_before_hashes[@]}"

  [[ "${_example_after_hashes[0]}"  != "${_example_before_hashes[0]}" ]]
  [[ "${_example_after_hashes[0]}"  != "${_example_before_hashes[1]}" ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize  ]]

  printf "local example branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "local sample branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" branch --all
  )"

  printf "remote branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" ls-remote                    \
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
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\n  remotes/origin/sample-notebook\\n")


  "${_NB}" notebooks use "Example Notebook"

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")

  run "${_NB}" sync <<< "y${_NEWLINE}2${_NEWLINE}${_NEWLINE}"

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

  [[ "${lines[0]}"  =~  Syncing:\ .*Example\ Notebook.*\.\.\.       ]]
  [[ "${lines[1]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[2]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[3]}"  =~  Remote\ branch\ reset:\ .*master            ]]
  [[ "${lines[4]}"  =~  Remote\ removed.                            ]]
  [[ "${lines[5]}"  =~  [^-]---------------[^-]                     ]]
  [[ "${lines[6]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)            ]]
  [[ "${lines[7]}"  =~  Done\!                                      ]]

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" ls-remote                 \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Example Notebook" branch --all)             \
    <(printf "* master\\n  remotes/origin/master\\n")
}

# `remote delete` orphan branch ###############################################

@test "'remote delete <remote-branch>' with orphan current <remote-branch> deletes remote branch." {
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

    sleep 1

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Demo Notebook"   ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote                  \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" branch --all)              \
      <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

    "${_NB}" notebooks use "Sample Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Sample Notebook" branch --all)            \
      <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
  }

  run "${_NB}" remote delete sample-notebook <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                             ]]

  [[ "${lines[0]}"  =~  Deleting\ remote\ branch:\ .*sample-notebook  ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]               ]]
  [[ "${lines[2]}"  =~  Remote\ branch\ deleted\.                     ]]

  printf "local example branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Example Notebook" branch --all
  )"

  printf "local sample branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" branch --all
  )"

  printf "remote branches:\\n%s\\n" "$(
    git -C "${NB_DIR}/Sample Notebook" ls-remote                    \
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
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n")


  run "${_NB}" sync <<< "y${_NEWLINE}2${_NEWLINE}${_NEWLINE}"

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

  [[ "${lines[0]}"  =~  Syncing:\ .*Sample\ Notebook.*\.\.\.        ]]
  [[ "${lines[1]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[2]}"  =~  \
Branch\ not\ present\ on\ remote:\ .*sample-notebook                ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\. ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.    ]]
  [[ "${lines[5]}"  =~  [^-]------------------------------[^-]      ]]
  [[ "${lines[6]}"  =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\       ]]
  [[ "${lines[6]}"  =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.        ]]
  [[ "${lines[7]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[8]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[9]}"  =~  Remote\ removed.                            ]]
  [[ "${lines[10]}" =~  [^-]---------------[^-]                     ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*sample-notebook.*\)   ]]
  [[ "${lines[12]}" =~  Done\!                                      ]]

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
}

@test "'remote delete <remote-branch>' with orphan non-current <remote-branch> deletes remote branch." {
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

    sleep 1

    "${_NB}" notebooks add "Demo Notebook"
    "${_NB}" notebooks use "Demo Notebook"

    [[ "$("${_NB}" notebooks current --name --no-color)" == "Demo Notebook"   ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}3${_NEWLINE}"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "master\\n")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" ls-remote                  \
          --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")           \
      <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (demo-notebook)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Demo Notebook" branch --all)              \
      <(printf "* demo-notebook\\n  remotes/origin/demo-notebook\\n")

    "${_NB}" notebooks use "Example Notebook"

    diff                                                            \
      <("${_NB}" remote)                                            \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

    diff                                                            \
      <(git -C "${NB_DIR}/Example Notebook" branch --all)           \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote delete sample-notebook <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                             ]]

  [[ "${lines[0]}"  =~  Deleting\ remote\ branch:\ .*sample-notebook  ]]
  [[ "${lines[1]}"  =~  [^-]-----------------------[^-]               ]]
  [[ "${lines[2]}"  =~  Remote\ branch\ deleted\.                     ]]

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
    <(printf "demo-notebook\\nmaster\\n")

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
    <(printf "demo-notebook\\nmaster\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")

  run "${_NB}" sync <<< "y${_NEWLINE}2${_NEWLINE}${_NEWLINE}"

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

  [[ "${lines[0]}"  =~  Syncing:\ .*Sample\ Notebook.*\.\.\.        ]]
  [[ "${lines[1]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[2]}"  =~  \
Branch\ not\ present\ on\ remote:\ .*sample-notebook                ]]
  [[ "${lines[3]}"  =~  \
.*[.*1.*].*\ Merge\ and\ sync\ with\ an\ existing\ remote\ branch\. ]]
  [[ "${lines[4]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote\.    ]]
  [[ "${lines[5]}"  =~  [^-]------------------------------[^-]      ]]
  [[ "${lines[6]}"  =~  \
Press\ .*enter.*\ to\ use\ the\ selected\ name,\ .*type.*\ a\       ]]
  [[ "${lines[6]}"  =~  \
name,\ .*type.*\ a\ new\ name,\ or\ press\ .*q.*\ to\ quit\.        ]]
  [[ "${lines[7]}"  =~  [^-]--------------[^-]                      ]]
  [[ "${lines[8]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[9]}"  =~  Remote\ removed.                            ]]
  [[ "${lines[10]}" =~  [^-]---------------[^-]                     ]]
  [[ "${lines[11]}" =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*sample-notebook.*\)   ]]
  [[ "${lines[12]}" =~  Done\!                                      ]]

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" ls-remote                  \
        --heads "${_GIT_REMOTE_URL}" | sed "s/.*\///g")             \
    <(printf "demo-notebook\\nmaster\\nsample-notebook\\n")

  diff                                                              \
    <("${_NB}" remote)                                              \
    <(printf "%s (sample-notebook)\\n" "${_GIT_REMOTE_URL:-}")

  diff                                                              \
    <(git -C "${NB_DIR}/Sample Notebook" branch --all)              \
    <(printf "* sample-notebook\\n  remotes/origin/sample-notebook\\n")
}
