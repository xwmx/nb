#!/usr/bin/env bats

load test_helper

# `backlink` ##################################################################

@test "'nb backlink' with links adds backlinks." {
  if ! hash "note-link-janitor" 2>/dev/null
  then
    skip "note-link-janitor not installed."
  fi

  {
    "${_NB}" init
    run "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/backlink.nb-plugin"

    cat <<HEREDOC | "${_NB}" add 'first.md'
# one

Example content [[three]] apple pear.
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'second.md'
# two

Sample content [[three]] orange.
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'third.md'
# three

Demo content [[one]] apricot plum.
HEREDOC

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" backlink --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR}/home/first.md"
  cat "${NB_DIR}/home/second.md"
  cat "${NB_DIR}/home/third.md"

  _first_content="# one

Example content [[three]] apple pear.
## Backlinks
* [[three]]
	* Demo content [[one]] apricot plum.
"

  _second_content="# two

Sample content [[three]] orange."

  _third_content="# three

Demo content [[one]] apricot plum.
## Backlinks
* [[one]]
	* Example content [[three]] apple pear.
* [[two]]
	* Sample content [[three]] orange.
"

  [[ "${status}" == 0               ]]
  [[ "${output:-}" == "Backlinked!" ]]

  diff <(cat "${NB_DIR}/home/first.md")  <(echo "${_first_content}")
  diff <(cat "${NB_DIR}/home/second.md") <(echo "${_second_content}")
  diff <(cat "${NB_DIR}/home/third.md")  <(echo "${_third_content}")

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Backlinked'
}

@test "'nb backlink' with no links does not add backlinks." {
  if ! hash "note-link-janitor" 2>/dev/null
  then
    skip "note-link-janitor not installed."
  fi

  {
    "${_NB}" init
    run "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/backlink.nb-plugin"

    cat <<HEREDOC | "${_NB}" add 'first.md'
# one

Example content three apple pear.
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'second.md'
# two

Sample content three orange.
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'third.md'
# three

Demo content one apricot plum.
HEREDOC

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" backlink --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR}/home/first.md"
  cat "${NB_DIR}/home/second.md"
  cat "${NB_DIR}/home/third.md"

  _first_content="# one

Example content three apple pear."

  _second_content="# two

Sample content three orange."

  _third_content="# three

Demo content one apricot plum."

  [[ "${status}" == 0                       ]]
  [[ "${output:-}" == "No new links found." ]]

  diff <(cat "${NB_DIR}/home/first.md")  <(echo "${_first_content}")
  diff <(cat "${NB_DIR}/home/second.md") <(echo "${_second_content}")
  diff <(cat "${NB_DIR}/home/third.md")  <(echo "${_third_content}")

  # Does not create git commit
  cd "${NB_DIR}/home" || return 1
  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  ! git log | grep -q '\[nb\] Backlinked'
}

# help ########################################################################

@test "'help backlink' exits with status 0 and prints usage." {
  if ! hash "note-link-janitor" 2>/dev//null
  then
    skip "note-link-janitor not installed."
  fi

  {
    "${_NB}" init
    run "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/backlink.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" help backlink

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*\:     ]]
  [[ "${lines[1]}" =~ nb\ backlink  ]]
}
