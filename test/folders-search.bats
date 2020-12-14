#!/usr/bin/env bats

load test_helper

_setup_folder_search() {
  "${_NB}" init

  # notebook root

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

example phrase
HEREDOC

  cat <<HEREDOC | "${_NB}" add "four.md"
# Four

demo phrase
HEREDOC

  # Example Folder /

  cat <<HEREDOC | "${_NB}" add "Example Folder/one.md"
# Example Folder / One

demo phrase
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

example phrase
HEREDOC

# Example Folder / Sample Folder /

  cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/one.md"
# Example Folder / Sample Folder / One

example phrase
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

# `search` ####################################################################

@test "'search' skips unindexed subfolders." {
  {
    _setup_folder_search

    mkdir -p "${NB_DIR}/home/Example Unindexed/Sample Unindexed"
    cat <<HEREDOC > "${NB_DIR}/home/Example Unindexed/Sample Unindexed/document.md"
# Example Unindexed / Sample Unindexed / Document

example phrase
HEREDOC
  }

  run "${_NB}" search "example phrase" --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0                                             ]]

  [[ !  "${output}" =~  Unindexed                                     ]]

  [[    "${output}" =~  Example\ Folder/Sample\ Folder/3              ]]
  [[    "${output}" =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]
}

# `search <folder>/` ##########################################################

@test "'search <folder>/' (slash) searches within <folder> and subfolders." {
  {
    _setup_folder_search
  }

  run "${_NB}" search "example phrase" Example\ Folder/ --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                             ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                 ]]
  [[ "${lines[2]}"  =~  3                                             ]]
  [[ "${lines[2]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1              ]]
  [[ "${output}"    =~  Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                 ]]
  [[ "${lines[5]}"  =~  3                                             ]]
  [[ "${lines[5]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/2.*Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                 ]]
  [[ "${lines[8]}"  =~  3                                             ]]
  [[ "${lines[8]}"  =~  example\ phrase                               ]]

  [[ "${output}"    =~  Example\ Folder/4.*Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                 ]]
  [[ "${lines[11]}" =~  3                                             ]]
  [[ "${lines[11]}" =~  example\ phrase                               ]]
}

# `search --no-recurse` #######################################################

@test "'search <folder>/ --no-recurse' (slash) searches within <folder> only." {
  {
    _setup_folder_search
  }

  run "${_NB}" search "example phrase" Example\ Folder/ --use-grep --no-recurse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                              ]]

  [[    "${lines[0]}"  =~  Example\ Folder/4              ]]
  [[    "${lines[0]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[0]}"  =~  Two|Four                       ]]
  [[    "${lines[1]}"  =~  -----------------------------  ]]
  [[    "${lines[2]}"  =~  3                              ]]
  [[    "${lines[2]}"  =~  example\ phrase                ]]

  [[    "${lines[3]}"  =~  Example\ Folder/2              ]]
  [[    "${lines[3]}"  =~  Example\ Folder\ /\            ]]
  [[    "${lines[3]}"  =~  Two|Four                       ]]
  [[    "${lines[4]}"  =~  -----------------------------  ]]
  [[    "${lines[5]}"  =~  3                              ]]
  [[    "${lines[5]}"  =~  example\ phrase                ]]

  [[ -z "${lines[6]}"                                     ]]
}

# `search` local notebook #####################################################

@test "'search folder/' (slash) in local notebook exits with status 0 and prints output." {
  {
    _setup_folder_search

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    # notebook root

    cat <<HEREDOC | "${_NB}" add "one.md"
# Local / One

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "two.md"
# Local / Two

sample phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "three.md"
# Local / Three

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "four.md"
# Local / Four

demo phrase
HEREDOC

    # Example Folder /

    cat <<HEREDOC | "${_NB}" add "Example Folder/one.md"
# Local / Example Folder / One

demo phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/two.md"
# Local / Example Folder / Two

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/three.md"
# Local / Example Folder / Three

sample phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/four.md"
# Local / Example Folder / Four

example phrase
HEREDOC

    # Example Folder / Sample Folder /

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/one.md"
# Local / Example Folder / Sample Folder / One

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/two.md"
# Local / Example Folder / Sample Folder / Two

demo phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/three.md"
# Local / Example Folder / Sample Folder / Three

example phrase
HEREDOC

    cat <<HEREDOC | "${_NB}" add "Example Folder/Sample Folder/four.md"
# Local / Example Folder / Sample Folder / Four

sample phrase
HEREDOC
  }

  run "${_NB}" search "example phrase" Example\ Folder/ --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                       ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/3                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ Three  ]]

  [[ "${lines[1]}"  =~  -----------------------------                           ]]
  [[ "${lines[2]}"  =~  3                                                       ]]
  [[ "${lines[2]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/Sample\ Folder/1                        ]]
  [[ "${output}"    =~  Local\ /\ Example\ Folder\ /\ Sample\ Folder\ /\ One    ]]

  [[ "${lines[4]}"  =~  -----------------------------                           ]]
  [[ "${lines[5]}"  =~  3                                                       ]]
  [[ "${lines[5]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/2.*Local\ /\ Example\ Folder\ /\ Two    ]]

  [[ "${lines[7]}"  =~  -----------------------------                           ]]
  [[ "${lines[8]}"  =~  3                                                       ]]
  [[ "${lines[8]}"  =~  example\ phrase                                         ]]

  [[ "${output}"    =~  Example\ Folder/4.*Local\ /\ Example\ Folder\ /\ Four   ]]

  [[ "${lines[10]}" =~  -----------------------------                           ]]
  [[ "${lines[11]}" =~  3                                                       ]]
  [[ "${lines[11]}" =~  example\ phrase                                         ]]
}
