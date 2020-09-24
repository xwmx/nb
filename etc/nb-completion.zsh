#compdef nb
###############################################################################
# __          _
# \ \   _ __ | |__
#  \ \ | '_ \| '_ \
#  / / | | | | |_) |
# /_/  |_| |_|_.__/
#
# `nb` · `notes` && `bookmark`
#
# Command line note-taking, bookmarking, and archiving with encryption, search,
# Git-backed versioning and syncing, Pandoc-backed format conversion, and more
# in a single portable script.
#
# https://github.com/xwmx/nb
###############################################################################
_nb_subcommands() {
  # _cache_completions()
  #
  # Usage:
  #   _cache_completions <path>
  #
  # Description:
  #   Cache completions for `nb`. Generating completions can be slow and
  #   native shell caching doesn't appear to help.
  _cache_completions() {
    local _cache_path="${1:-}"

    local _commands
    IFS=$'\n' _commands=($(nb subcommands))

    local _notebooks
    IFS=$'\n' _notebooks=($(nb notebooks --names --no-color --unarchived))

    local _completions=()
    IFS=$'\n' _completions=(${_commands[@]})

    local _commands_cached=
    local _notebooks_cached=

    if [[ -e "${_cache_path}" ]]
    then
      local _counter=0

      while IFS= read -r __line
      do
        _counter=$((_counter+1))

        if [[ "${_counter}" == 1 ]]
        then
          _commands_cached="${__line}"
        elif [[ "${_counter}" == 2 ]]
        then
          _notebooks_cached="${__line}"
        else
          break
        fi
      done < "${_cache_path}"
    fi

    if [[ "${_commands_cached}"  != "${_commands[*]:-}"   ]] ||
       [[ "${_notebooks_cached}" != "${_notebooks[*]:-}"  ]]
    then
      # Construct <notebook>:<subcommand> completions.
      for __notebook in "${_notebooks[@]}"
      do
        for __command in "${_commands[@]}"
        do
          if [[ -n "${__notebook:-}" ]] && [[ -n "${__command:-}" ]]
          then
            _completions+=("${__notebook}:${__command}")
          fi
        done
      done

      local _directory_path
      _directory_path="$(dirname "${_cache_path}")"
      mkdir -p "${_directory_path}"

      printf "" > "${_cache_path}"

      {
        (IFS=$' '; printf "%s\\n" "${_commands[*]}")
        (IFS=$' '; printf "%s\\n" "${_notebooks[*]}")
        printf "%s\\n" "${_completions[@]}"
      } >> "${_cache_path}"
    fi
  }


  local _nb_dir=
  _nb_dir="$(nb env | grep 'NB_DIR' | cut -d = -f 2)"

  if [[ -z "${_nb_dir:?}"  ]] ||
     [[ ! -e "${_nb_dir}"  ]]
  then
    return 0
  elif [[ -L "${_nb_dir}" ]]
  then
    if hash "realpath" 2>/dev/null
    then
      _nb_dir="$(realpath "${_nb_dir}")"
    else
      _nb_dir="$(readlink "${_nb_dir}")"
    fi
  fi

  if [[ ! -d "${_nb_dir}"  ]]
  then
    return 0
  fi

  local _cache_path="${_nb_dir}/.cache/nb-completion-cache-zsh"
  local _completions_cached=()

  if [[ ! -e "${_cache_path}" ]]
  then
    _cache_completions "${_cache_path}"
  fi

  if [[ -e "${_cache_path}" ]]
  then
    local _counter=0

    while IFS= read -r __line
    do
      _counter=$((_counter+1))

      if [[ "${_counter}" -gt 2 ]]
      then
        _completions_cached+=("${__line}")
      fi
    done < "${_cache_path}"

    (_cache_completions "${_cache_path}" &)
  fi

  if [[ "${?}" -eq 0 ]]
  then
    compadd -- "${_completions_cached[@]}"
    return 0
  else
    return 1
  fi
}

_nb_subcommands "$@"
