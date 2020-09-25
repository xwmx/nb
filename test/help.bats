#!/usr/bin/env bats
# shellcheck disable=SC2089,SC2090

load test_helper

@test "\`help\` with no arguments exits with status 0." {
  run "${_NB}" help

  [[ "${status}" -eq 0 ]]
}

@test "\`help\` with no arguments prints default help." {
  run "${_NB}" help

  [[ "${output}" =~ notes\ \&\ bookmarks ]]
}

@test "\`-h\` prints default help." {
  run "${_NB}" -h

  [[ "${output}" =~ notes\ \&\ bookmarks ]]
}

@test "\`--help\` prints default help." {
  run "${_NB}" --help

  [[ "${output}" =~ notes\ \&\ bookmarks ]]
}

@test "\`help help\` prints \`help\` subcommand usage." {
  run "${_NB}" help help

  _expected="$(
    cat <<HEREDOC
Usage:
  nb help [<subcommand>] [-p | --print]
  nb help [-c | --colors] | [-r | --readme] | [-s | --short] [-p | --print]

Options:
  -c, --colors  View information about color themes and color settings.
  -p, --print   Print to standard output / terminal.
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
