#compdef notes

_notes_subcommands() {
  local _commands
  _commands=($(notes commands))
  local _notebooks
  _notebooks=($(notes notebooks --names --no-color --unarchived))
  local _completions=()

  local _cache_path="${HOME}/.notes-completion-cache"
  local _commands_match=0
  local _counter=0
  local _notebooks_match=0

  if [[ -e "${_cache_path}" ]]
  then
    while IFS= read -r __line
    do
      _counter=$((_counter+1))

      if [[ "${_counter}" == 1 ]]
      then
        [[ "${__line}" == "${_commands[*]}" ]] &&
          _commands_match=1
      elif [[ "${_counter}" == 2 ]]
      then
        [[ "${__line}" == "${_notebooks[*]}" ]] &&
          _notebooks_match=1
      else
        _completions+=("${__line}")
      fi
    done < "${_cache_path}"
  fi

  if [[ ! -e "${_cache_path}" ]]  ||
     ! ((_commands_match))        ||
     ! ((_notebooks_match))       ||
     [[ -z "${_completions[*]}" ]]
  then

    _completions=(${_commands[@]})

    # Construct <notebook>:<subcommand> completions.
    for __notebook in "${_notebooks[@]}"
    do
      for __command in "${_commands[@]}"
      do
        if [[ -n "${__notebook:-}" ]] && [[ -n "${__command}" ]]
        then
          _completions+=("${__notebook}:${__command}")
        fi
      done
    done

    printf "" > "${_cache_path}"
    printf "%s\\n" "${_commands[*]}" >> "${_cache_path}"
    printf "%s\\n" "${_notebooks[*]}" >> "${_cache_path}"
    printf "%s\\n" "${_completions[@]}" >> "${_cache_path}"
  fi

  if [[ "${?}" -eq 0 ]]
  then
    compadd -- "${_completions[@]}"
    return 0
  else
    return 1
  fi
}

_notes_subcommands "$@"
