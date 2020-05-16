#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "\`settings\` with no arguments start prompt." {
skip "Determine how to test interactive prompt."
  {
    "${_NB}" init
  }

  run "${_NB}" settings

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Settings ]]
}

# `colors` ####################################################################

@test "\`settings colors\` prints colors." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings colors

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ '   0' ]]
  [[ "${output}" =~ ' 105' ]]
  [[ "${output}" =~ ' 106' ]]
}

@test "\`settings colors <number>\` prints color." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings colors 105

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ ' 105' ]]
  [[ ! "${output}" =~ ' 106' ]]
}

# `edit` ######################################################################

@test "\`settings edit\` edits .nbrc." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings edit

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${NBRC_PATH}")" =~ 'mock_editor' ]]
}

# `get` #######################################################################

@test "\`settings get\` with no argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings get

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings get\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings get EXAMPLE

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\: ]]
  [[ "${output}" =~ EXAMPLE               ]]
}

@test "\`settings get\` with argument exits and prints." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings get NB_DIR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ ${NB_DIR} ]]
}

@test "\`settings get\` with lowercase argument exits and prints." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings get nb_dir

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ ${NB_DIR} ]]
}

# `list` ######################################################################

@test "\`settings list\` lists available settings." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings list

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ 1             ]]
  [[ "${lines[0]}" =~ editor        ]]
  [[ "${lines[1]}" =~ 2             ]]
  [[ "${lines[1]}" =~ nb_auto_sync  ]]
}

@test "\`settings list --long\` lists available settings with \`show\`." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings list --long

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ 1             ]]
  [[ "${lines[0]}" =~ editor        ]]
  [[ "${lines[1]}" =~ ------        ]]
}

# `set` #######################################################################

@test "\`settings set\` with no argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings set\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set EXAMPLE example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\: ]]
  [[ "${output}" =~ EXAMPLE               ]]
}

@test "\`settings set\` with one argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set EDITOR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings set\` with argument exits and sets." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set EDITOR example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc: '%s'\\n" "$(cat "${NBRC_PATH}")"

  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ EDITOR    ]]
  [[ "${output}" =~ set\ to\  ]]
  [[ "${output}" =~ example   ]]
  [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="${EDITOR:-example}"' ]]
}

@test "\`settings set\` with multi-word argument exits and sets." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set EDITOR "example editor"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc: '%s'\\n" "$(cat "${NBRC_PATH}")"

  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ EDITOR            ]]
  [[ "${output}" =~ set\ to\          ]]
  [[ "${output}" =~ example\ editor   ]]
  [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="${EDITOR:-example editor}"' ]]
}

@test "\`settings set\` with lowercase setting name exits and sets." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set editor example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc: '%s'\\n" "$(cat "${NBRC_PATH}")"

  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ EDITOR    ]]
  [[ "${output}" =~ set\ to\  ]]
  [[ "${output}" =~ example   ]]
  [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="${EDITOR:-example}"' ]]
}

# `set NB_AUTO_SYNC` #######################################################

@test "\`settings set NB_AUTO_SYNC\` with valid argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_AUTO_SYNC 0

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_AUTO_SYNC  ]]
  [[ "${output}" =~ set\ to\      ]]
  [[ "${output}" =~ '0'           ]]
  [[ "$("${_NB}" settings get NB_AUTO_SYNC)" == '0' ]]
}

@test "\`settings set NB_AUTO_SYNC\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_AUTO_SYNC '0'

  [[ "${output}" =~ NB_AUTO_SYNC  ]]
  [[ "${output}" =~ set\ to\      ]]
  [[ "${output}" =~ '0'           ]]

  run "${_NB}" settings set NB_AUTO_SYNC example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  # [[ "${output}" == "NB_AUTO_SYNC must be either '0' or '1'." ]]
  [[ "${output}" =~ NB_AUTO_SYNC        ]]
  [[ "${output}" =~ must\ be\ either    ]]

  printf "get NB_AUTO_SYNC: '%s'\\n" "$("${_NB}" settings get NB_AUTO_SYNC)"
  [[ "$("${_NB}" settings get NB_AUTO_SYNC)" == '0' ]]
}

# `set NB_COLOR_PRIMARY` ######################################################

@test "\`settings set NB_COLOR_PRIMARY\` with valid argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_PRIMARY 123

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_COLOR_PRIMARY    ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ 123                 ]]
  printf "NB_COLOR_PRIMARY: %s\\n" "$("${_NB}" settings get NB_COLOR_PRIMARY)"
  [[ "$(NB_COLOR_PRIMARY='' "${_NB}" settings get NB_COLOR_PRIMARY)" == '123' ]]
}

@test "\`settings set NB_COLOR_PRIMARY\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_PRIMARY 123

  [[ "${output}" =~ NB_COLOR_PRIMARY    ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ 123                 ]]
  [[ "$(NB_COLOR_PRIMARY='' "${_NB}" settings get NB_COLOR_PRIMARY)" == '123' ]]

  run "${_NB}" settings set NB_COLOR_PRIMARY invalid-color

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'NB_COLOR_PRIMARY must be a number.' ]]
  printf "NB_COLOR_PRIMARY: %s\\n" "$("${_NB}" settings get NB_COLOR_PRIMARY)"
  [[ "$(NB_COLOR_PRIMARY='' "${_NB}" settings get NB_COLOR_PRIMARY)" == '123' ]]
}

# `set NB_COLOR_SECONDARY` ####################################################

@test "\`settings set NB_COLOR_SECONDARY\` with valid argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_SECONDARY 123

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_COLOR_SECONDARY  ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ 123                 ]]
  printf "NB_COLOR_SECONDARY: %s\\n" "$("${_NB}" settings get NB_COLOR_SECONDARY)"
  [[ "$("${_NB}" settings get NB_COLOR_SECONDARY)" == '123' ]]
}

@test "\`settings set NB_COLOR_SECONDARY\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_SECONDARY 123

  [[ "${output}" =~ NB_COLOR_SECONDARY  ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ 123                 ]]
  [[ "$("${_NB}" settings get NB_COLOR_SECONDARY)" == '123' ]]

  run "${_NB}" settings set NB_COLOR_SECONDARY invalid-color

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'NB_COLOR_SECONDARY must be a number.' ]]
  printf "NB_COLOR_SECONDARY: %s\\n" "$("${_NB}" settings get NB_COLOR_SECONDARY)"
  [[ "$("${_NB}" settings get NB_COLOR_SECONDARY)" == '123' ]]
}

# `set NB_COLOR_THEME` ##############################################################

@test "\`settings set NB_COLOR_THEME\` with valid argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_THEME "console"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_COLOR_THEME  ]]
  [[ "${output}" =~ set\ to         ]]
  [[ "${output}" =~ console         ]]
  printf "NB_COLOR_THEME: %s\\n" "$("${_NB}" settings get NB_COLOR_THEME)"
  [[ "$(NB_COLOR_THEME='' "${_NB}" settings get NB_COLOR_THEME)" == 'console' ]]
}

@test "\`settings set NB_COLOR_THEME\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_COLOR_THEME "forest"

  [[ "${output}" =~ NB_COLOR_THEME                    ]]
  [[ "${output}" =~ set\ to                           ]]
  [[ "${output}" =~ forest                            ]]
  [[ "$(NB_COLOR_THEME='' "${_NB}" settings get NB_COLOR_THEME)" == 'forest'  ]]

  run "${_NB}" settings set NB_COLOR_THEME invalid-theme

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'NB_COLOR_THEME must be one of the available themes.' ]]
  printf "NB_COLOR_THEME: %s\\n" "$("${_NB}" settings get NB_COLOR_THEME)"
  [[ "$(NB_COLOR_THEME='' "${_NB}" settings get NB_COLOR_THEME)" == 'forest' ]]
}

# `set NB_DIR` #############################################################

@test "\`settings set NB_DIR\` with full path argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_DIR /tmp/path/to/data/dir

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "settings get NB_DIR: '%s'\\n" "$("${_NB}" settings get NB_DIR)"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_DIR                ]]
  [[ "${output}" =~ set\ to               ]]
  [[ "${output}" =~ /tmp/path/to/data/dir ]]
  [[ "$(NB_DIR='' "${_NB}" settings get NB_DIR)" == '/tmp/path/to/data/dir' ]]
}

@test "\`settings set NB_DIR\` with spaces sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_DIR "/tmp/path to data/dir"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "settings get NB_DIR: '%s'\\n" "$("${_NB}" settings get NB_DIR)"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_DIR                  ]]
  [[ "${output}" =~ set\ to                 ]]
  [[ "${output}" =~ /tmp/path\ to\ data/dir ]]
  [[ "$(NB_DIR='' "${_NB}" settings get NB_DIR)" == '/tmp/path to data/dir' ]]
}

@test "\`settings set NB_DIR\` with unquoted ~/ sets with \$HOME." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_DIR ~/tmp/path

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_DIR            ]]
  [[ "${output}" =~ set\ to           ]]
  [[ "${output}" =~ ${HOME}/tmp/path  ]]
  [[ "$(NB_DIR='' "${_NB}" settings get NB_DIR)" == "${HOME}/tmp/path" ]]
}

@test "\`settings set NB_DIR\` with quoted ~/ sets with \$HOME." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_DIR "${HOME}/tmp/path"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_DIR            ]]
  [[ "${output}" =~ set\ to           ]]
  [[ "${output}" =~ ${HOME}/tmp/path  ]]
  [[ "$(NB_DIR='' "${_NB}" settings get NB_DIR)" == "${HOME}/tmp/path" ]]
}

@test "\`settings set NB_DIR\` with invalid directory exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_DIR "/"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ \'\/\'\ is\ not\ a\ valid\ location\ for\ NB_DIR\. ]]
  [[ ! "$(NB_DIR='' "${_NB}" settings get NB_DIR)" == "/" ]]
}

# `set NB_ENCRYPTION_TOOL` #################################################

@test "\`settings set NB_ENCRYPTION_TOOL\` with valid argument sets and exits." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_ENCRYPTION_TOOL gpg

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NB_ENCRYPTION_TOOL  ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ gpg                 ]]
  [[ "$(NB_ENCRYPTION_TOOL='' "${_NB}" settings get NB_ENCRYPTION_TOOL)" == 'gpg' ]]
}

@test "\`settings set NB_ENCRYPTION_TOOL\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings set NB_ENCRYPTION_TOOL 'gpg'

  [[ "${output}" =~ NB_ENCRYPTION_TOOL  ]]
  [[ "${output}" =~ set\ to             ]]
  [[ "${output}" =~ gpg                 ]]

  run "${_NB}" settings set NB_ENCRYPTION_TOOL example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ NB_ENCRYPTION_TOOL        ]]
  [[ "${output}" =~ must\ be\ either          ]]
  [[ "${output}" =~ \'openssl\'\ or\ \'gpg\'  ]]
  [[ "$(NB_ENCRYPTION_TOOL='' "${_NB}" settings get NB_ENCRYPTION_TOOL)" == 'gpg' ]]
}

# `list` ######################################################################

@test "\`settings show <name>\` in lowercase shows setting." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings show nb_auto_sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ nb_auto_sync ]]
  [[ "${lines[1]}" =~ ------------ ]]
}

@test "\`settings show <name>\` in uppercase shows setting." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings show NB_COLOR_THEME

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ nb_color_theme ]]
  [[ "${lines[1]}" =~ -------------- ]]
}

@test "\`settings show <id>\` shows setting." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings show 3

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ nb_color_primary ]]
  [[ "${lines[1]}" =~ ---------------- ]]
}

# `unset` #####################################################################

@test "\`settings unset\` with no argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings unset

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings unset\` with invalid argument exits with error." {
  {
    "${_NB}" init
  }

  run "${_NB}" settings unset EXAMPLE

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\: ]]
  [[ "${output}" =~ EXAMPLE               ]]
}

@test "\`settings unset\` with argument unset, prints, and exits." {
  {
    "${_NB}" init
    run "${_NB}" settings set EDITOR sample
    [[ "$(EDITOR='' "${_NB}" settings get EDITOR)" == 'sample'  ]]
    [[ "$(cat "${NBRC_PATH}")" =~ 'EDITOR="${EDITOR:-sample}"'  ]]
  }

  run "${_NB}" settings unset EDITOR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".nbrc:\\n'%s'\\n" "$(cat "${NBRC_PATH}")"
  [[ ${status} -eq 0 ]]
  [[ ! "$(cat "${NBRC_PATH}")" =~ 'EDITOR="sample"'             ]]
  [[ ! "$(cat "${NBRC_PATH}")" =~ 'EDITOR="${EDITOR:-sample}"'  ]]
  [[ "${output}" =~ EDITOR                                      ]]
  [[ "${output}" =~ restored\ to\ the\ default                  ]]
  [[ ! "${output}" =~ sample                                    ]]
}
