#!/usr/bin/env bats

load test_helper

# git checkpoint ##############################################################

@test "'git checkpoint' with no message and clean repo does not create new commit." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."

    printf "New content.\\n" >> "${NB_DIR}/home/Example File.md"

    grep -q "New content" "${NB_DIR}/home/Example File.md"
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # creates git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q -v '\[nb\] Commit'
}

@test "'git checkpoint' with no message and dirty repo creates a new commit with the default message." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."

    printf "New content.\\n" >> "${NB_DIR}/home/Example File.md"

    grep -q "New content" "${NB_DIR}/home/Example File.md"
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # creates git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Commit'
}

@test "'git checkpoint <message>' with dirty repo creates a new commit with <message>." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."

    printf "New content.\\n" >> "${NB_DIR}/home/Example File.md"

    grep -q "New content" "${NB_DIR}/home/Example File.md"
  }

  run "${_NB}" git checkpoint "Unique message."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # creates git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep -q 'Unique message.'
}

# git dirty ###################################################################

@test "'git dirty' with dirty repo returns 0 and does not create commit." {
  {
    "${_NB}" init

    touch "${NB_DIR:?}/home/example.md"

    [[ -n "$(git -C "${NB_DIR:?}/home" status --porcelain)" ]]
  }

  run "${_NB}" git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # does not create git commit

  sleep 1

  git log | grep -v -q 'Commit'
}

@test "'<notebook>:git dirty' with dirty repo returns 0 and does not create commit." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"

    touch "${NB_DIR:?}/one/example.md"

    [[ -n "$(git -C "${NB_DIR:?}/one" status --porcelain)" ]]
  }

  run "${_NB}" one:git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 0

  [[ "${status}" -eq 0 ]]

  # does not create git commit

  sleep 1

  git log | grep -v -q 'Commit'
}

@test "'git dirty' with clean repo returns 1 and does not create commit." {
  {
    "${_NB}" init

    [[ -z "$(git -C "${NB_DIR:?}/home" status --porcelain)" ]]
  }

  run "${_NB}" git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 1

  [[ "${status}" -eq 1 ]]

  # does not create git commit

  sleep 1

  git log | grep -v -q 'Commit'
}

@test "'<notebook>:git dirty' with clean repo returns 1 and does not create commit." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"

    [[ -z "$(git -C "${NB_DIR:?}/one" status --porcelain)" ]]
  }

  run "${_NB}" one:git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # returns status 1

  [[ "${status}" -eq 1 ]]

  # does not create git commit

  sleep 1

  git log | grep -v -q 'Commit'
}

# git config ##################################################################

@test "'_git_required()' recognizes git configuration that uses 'includeIf' with 'hasconfig:remote' when inside the specified directory." {
  {
    export HOME="${_TMP_DIR}"

    git config --global user.name   "Sample Name"
    git config --global user.email  "sample@example.test"

    cat <<HEREDOC > "${_TMP_DIR}/.gitconfig_conditional_include_example"
[user]
  name  = Example Name
  email = example@example.test
HEREDOC

    cat <<HEREDOC >> "${_TMP_DIR}/.gitconfig"
[includeIf "hasconfig:remote.*.url:file://${_TMP_DIR}*/**"]
  path = ${_TMP_DIR}/.gitconfig_conditional_include_example
HEREDOC

    cat "${_TMP_DIR}/.gitconfig"

    "${_NB}" init
    "${_NB}" add "Sample File.md" --content "Sample content."

    "${_NB}" notebooks create "Example Notebook"
    "${_NB}" use "Example Notebook"

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" show home:1 --author

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                                     ]]
  [[ "${output}" ==   "Sample Name <sample@example.test>"   ]]

  run "${_NB}" show Example\ Notebook:1 --author

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                                       ]]
  [[ "${output}" ==   "Example Name <example@example.test>"   ]]
}

@test "'_git_required()' recognizes git configuration that uses 'includeIf' when inside the specified directory." {
  {
    export HOME="${_TMP_DIR}"

    git config --global user.name   "Example Name"
    git config --global user.email  "example@example.test"

    cat <<HEREDOC > "${_TMP_DIR}/.gitconfig_conditional_include_example"
[user]
  name  = Sample Name
  email = sample@example.test
HEREDOC

    cat <<HEREDOC >> "${_TMP_DIR}/.gitconfig"
[includeIf "gitdir:~/"]
  path = ${_TMP_DIR}/.gitconfig_conditional_include_example
HEREDOC

    cat "${_TMP_DIR}/.gitconfig"

    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" show 1 --author

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                                     ]]
  [[ "${output}" ==   "Sample Name <sample@example.test>"   ]]
}

@test "'_git_required()' recognizes global git configuration  ignores 'includeIf' when outiside the specified directory." {
  {
    export HOME="${_TMP_DIR}"

    git config --global user.name   "Example Name"
    git config --global user.email  "example@example.test"

    cat <<HEREDOC > "${_TMP_DIR}/.gitconfig_conditional_include_example"
[user]
  name  = Sample Name
  email = sample@example.test
HEREDOC

    cat <<HEREDOC >> "${_TMP_DIR}/.gitconfig"
[includeIf "gitdir:~/example-path"]
  path = ${_TMP_DIR}/.gitconfig_conditional_include_example
HEREDOC

    cat "${_TMP_DIR}/.gitconfig"

    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" show 1 --author

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                                     ]]
  [[ "${output}" ==   "Example Name <example@example.test>" ]]
}

@test "'_git_required()' recognizes global git configuration for the user." {
  {
    export HOME="${_TMP_DIR}"

    git config --global user.name   "Example Name"
    git config --global user.email  "example@example.test"

    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" show 1 --author

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq  0                                     ]]
  [[ "${output}" ==   "Example Name <example@example.test>" ]]
}
