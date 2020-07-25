#!/usr/bin/env bats
# shellcheck disable=SC2089,SC2090

load test_helper

_HELP_HEADER="\
__          _
\ \   _ __ | |__
 \ \ | '_ \| '_ \\
 / / | | | | |_) |
/_/  |_| |_|_.__/"
export _HELP_HEADER

@test "\`help\` with no arguments exits with status 0." {
  run "${_NB}" help
  [ "${status}" -eq 0 ]
}

@test "\`help\` with no arguments prints default help." {
  run "${_NB}" help
  _compare "${_HELP_HEADER}" "$(IFS=$'\n'; echo "${lines[*]:0:11}")"
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`-h\` prints default help." {
  run "${_NB}" -h
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`--help\` prints default help." {
  run "${_NB}" --help
  [[ $(IFS=$'\n'; echo "${lines[*]:0:5}") == "${_HELP_HEADER}" ]]
}

@test "\`help help\` prints \`help\` subcommand usage." {
  run "${_NB}" help help
  _expected="$(
    cat <<HEREDOC
Usage:
  nb help [<subcommand>]
  nb help  [-c | --colors] | [-r | --readme] | [-s | --short]

Options:
  -c, --colors  View information about color themes and color settings.
  -r, --readme  View the \`nb\` README file.
  -s, --short   Print shorter help without subcommand descriptions.

Description:
  Print the program help information. When a subcommand name is passed, print
  the help information for the subcommand.

Shortcut Alias: \`h\`
HEREDOC
  )"
  _compare "'${_expected}'" "'${output}'"
  [[ "${output}" == "${_expected}" ]]
}
