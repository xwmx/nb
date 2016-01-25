#!/usr/bin/env bats

@test "when no arguments are passed print help" {
  run notes
  [ "$status" -eq 0 ] \
    && $(echo "$output" | grep 'notes help \[<subcommand>\]' -q)
}
