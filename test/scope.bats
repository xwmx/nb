#!/usr/bin/env bats

load test_helper

_setup_scope() {
  "$_NOTES" init
  "$_NOTES" repo add one
  "$_NOTES" use one
  "$_NOTES" add "# first"
  "$_NOTES" use data
  "$_NOTES" repo add two
}

# `notes <name>:repo` #########################################################

@test "\`notes one:repo\` exits with 0 and scoped \`repo\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" one:repo
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" =~ "one" ]]
}

@test "\`notes two:repo\` exits with 0 and scoped \`repo\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" two:repo
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" =~ "two" ]]
}

@test "\`notes one:invalid\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" one:invalid
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ "first" ]]
}

# `notes <name>:` #########################################################

@test "\`notes one:\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" one:
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ "first" ]]
}

@test "\`notes one: --no-index\` exits with 0 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" one: --no-index
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" == "first" ]]
}

@test "\`notes two:\` exits with 1 and scoped \`ls\` output." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" two:
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ "0 notes." ]]
}

@test "\`notes invalid:\` exits with 1 and prints error." {
  {
    _setup_scope &>/dev/null
  }

  run "$_NOTES" invalid:
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ "Repository not found: invalid" ]]
}
