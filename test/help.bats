#!/usr/bin/env bats

load test_helper

_HELP_HEADER="\
__                _
\ \   _ __   ___ | |_ ___  ___
 \ \ | '_ \ / _ \| __/ _ \/ __|
 / / | | | | (_) | ||  __/\__ \\
/_/  |_| |_|\___/ \__\___||___/"
export _HELP_HEADER

@test "\`help\` with no arguments exits with status 0." {
  run "${_NOTES}" help
  [ "${status}" -eq 0 ]
}

@test "\`help\` with no arguments prints default help." {
  run "${_NOTES}" help
  _compare "${_HELP_HEADER}" "$(IFS=$'\n'; echo "${lines[*]:0:11}")"
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`notes -h\` prints default help." {
  run "${_NOTES}" -h
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`notes --help\` prints default help." {
  run "${_NOTES}" --help
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`notes help help\` prints \`help\` subcommand usage." {
  run "${_NOTES}" help help
  _expected="$(
    cat <<HEREDOC
Usage:
  notes help [<subcommand>]

Description:
  Print the program help information. When a subcommand name is passed, print
  the help information for the subcommand.

Shortcut Alias: \`h\`
HEREDOC
  )"
  _compare "'${_expected}'" "'${output}'"
  [[ "${output}" == "${_expected}" ]]
}
