#compdef notes

_notes_subcommands() {
  local _commands
  _commands=($(notes commands))
  local _notebooks
  _notebooks=($(notes notebooks --names --no-color --unarchived))
  local _completions
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

  if [[ "${?}" -eq 0 ]]
  then
    compadd -- "${_completions[@]}"
    return 0
  else
    return 1
  fi
}

_notes_subcommands "$@"
