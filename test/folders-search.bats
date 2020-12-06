#!/usr/bin/env bats

load test_helper

# `search` ####################################################################

@test "'search <folder>/' (slash) searches within <folder> and subfolders." {
  {
    "${_NB}" init

    cat <<HEREDOC | "${_NB}" add "one.md"
# One

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "two.md"
# Two

sample phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "three.md"
# Three

demo phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "four.md"
# Four

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/one.md"
# Example Folder / One

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/two.md"
# Example Folder / Two

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/three.md"
# Example Folder / Three

sample phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/four.md"
# Example Folder / Four

demo phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/one.md"
# Example Folder / Sample Folder / One

sample phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/two.md"
# Example Folder / Sample Folder / Two

demo phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/three.md"
# Example Folder / Sample Folder / Three

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/four.md"
# Example Folder / Sample Folder / Four

sample phrase
HEREDOC
  }

  run "${_NB}" search "example phrase" Example\ Folder/ --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                               ]]
  [[ "${lines[0]}"  =~  Example\ Folder\ \/\            ]]
  [[ "${lines[0]}"  =~  Two|One                         ]]
  [[ "${lines[1]}"  =~  -----------------------------   ]]
  [[ "${lines[2]}"  =~ 3                                ]]
  [[ "${lines[2]}"  =~  example\ phrase                 ]]
  [[ "${lines[3]}"  =~  Example\ Folder\ \/\            ]]
  [[ "${lines[3]}"  =~  Two|One                         ]]
  [[ "${lines[4]}"  =~  -----------------------------   ]]
  [[ "${lines[5]}"  =~ 3                                ]]
  [[ "${lines[5]}"  =~  example\ phrase                 ]]
}
