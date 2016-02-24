#!/usr/bin/env bats

load test_helper

_setup_search() {
  "${_NOTES}" init &>/dev/null
    cat <<HEREDOC | "${_NOTES}" add
# one
idyl
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# two
sweetish
HEREDOC
    sleep 1
    cat <<HEREDOC | "${_NOTES}" add
# three
sweetish
HEREDOC
}

# `search` ####################################################################

@test "\`search\` exits with status 1 and prints help information." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes search <query> [-a | --all] [--path]" ]]
}

# `search <no match>` #########################################################

@test "\`search <no match>\` exits with status 1 and does not print output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search 'no match'
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ -z "${output}" ]]
}

# `search <one match> [--path]` ###############################################

@test "\`search <one match>\` exits with status 0 and prints output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search 'idyl'
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[0]}: '%s'\n" "${lines[0]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ idyl ]]
}

@test "\`search <one match> --path\` exits with status 0 and prints path." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search 'idyl' --path
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 1 ]]
}

# `search <multiple matches> [--path]` ########################################

@test "\`search <multiple matches>\` exits with status 0 and prints output." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search 'sweetish'
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[3]}: '%s'\n" "${lines[3]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ sweetish ]]
  [[ "${lines[3]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[4]}" =~ -*-$ ]]
  [[ "${lines[5]}" =~ sweetish ]]
  [[ "${lines[0]}" != "${lines[3]}" ]]
}

@test "\`search <multiple matches> --path\` exits with 0 and prints paths." {
  {
    _setup_search
    _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" search 'sweetish' --path
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[0]}: '%s'\n" "${lines[0]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ ${_NOTES_DATA_DIR}/20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 2 ]]
}

# `search <query> --all [--path]` #############################################

_search_all_setup() {
  _setup_search
  "${_NOTES}" notebook add one
  "${_NOTES}" use one
  "${_NOTES}" add "# sweetish"
}

@test "\`search <query> --all\` exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null
  }

  run "${_NOTES}" search 'sweetish' --all
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ home:1 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ sweetish ]]
  [[ "${lines[3]}" =~ home:0 ]]
  [[ "${lines[3]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[4]}" =~ -*-$ ]]
  [[ "${lines[5]}" =~ sweetish ]]
  [[ "${lines[6]}" =~ one:0 ]]
  [[ "${lines[6]}" =~ 20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 9 ]]
}

@test "\`search <query> -a\` exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null
  }

  run "${_NOTES}" search 'sweetish' -a
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ home:1 ]]
  [[ "${lines[0]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ -*-$ ]]
  [[ "${lines[2]}" =~ sweetish ]]
  [[ "${lines[3]}" =~ home:0 ]]
  [[ "${lines[3]}" =~ 20[0-9]+\.md$ ]]
  [[ "${lines[4]}" =~ -*-$ ]]
  [[ "${lines[5]}" =~ sweetish ]]
  [[ "${lines[6]}" =~ one:0 ]]
  [[ "${lines[6]}" =~ 20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 9 ]]
}

@test "\`search <no matching query> --all\` exits with status 1 and not output." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NOTES}" search 'no match' --all
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[3]}: '%s'\n" "${lines[3]}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}" ]]
}

@test "\`search <multiple matches> --all --path\` exits with 0 and prints paths." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NOTES}" search 'sweetish' --all --path
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[0]}: '%s'\n" "${lines[0]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ ${_NOTES_DIR}/home/20[0-9]+\.md$ ]]
  [[ "${lines[1]}" =~ ${_NOTES_DIR}/home/20[0-9]+\.md$ ]]
  [[ "${lines[2]}" =~ ${_NOTES_DIR}/one/20[0-9]+\.md$ ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`search <no matching query> --all --path\` exits with 1 and no output." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NOTES}" search 'no match' --all --path
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  printf "\${lines[0]}: '%s'\n" "${lines[0]}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}" ]]
}

# help ########################################################################

@test "\`help search\` exits with status 0." {
  run "${_NOTES}" help search
  [[ ${status} -eq 0 ]]
}

@test "\`help search\` prints help information." {
  run "${_NOTES}" help search
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes search <query> [-a | --all] [--path]" ]]
}
