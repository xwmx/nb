_notes_subcommands() {
  local _commands
  _commands=($(notes commands))
  local _notebooks
  _notebooks=($(notes notebooks --names --no-color --unarchived))
  local _completions
  _completions=(${_commands[@]})

  local _current="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()

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

  COMPREPLY=($(compgen -W "${_completions[*]}" -- ${_current}))
}

complete -F _notes_subcommands notes
