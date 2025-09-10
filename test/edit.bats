#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

# encrypted ###################################################################

@test "'edit' with openssl -md sha256 encrypted file edits properly without errors." {
  {
    "${_NB}" init

    diff                                                                      \
      <("${_NB}" env | grep NB_ENCRYPTION_TOOL --color=never | cut -d= -f 2)  \
      <(printf "openssl\\n")

    "${_NB}" add "Example File.md" --content "# Content"

    [[    -f "${NB_DIR}/home/Example File.md"     ]]

    openssl enc                                   \
      -aes-256-cbc                                \
      -md   sha256                                \
      -in   "${NB_DIR}/home/Example File.md"      \
      -out  "${NB_DIR}/home/Example File.md.enc"  \
      -pass file:<(printf "password\\n") 2> /dev/null

    [[    -f "${NB_DIR}/home/Example File.md.enc" ]]

    rm "${NB_DIR}/home/Example File.md"

    [[ !  -f "${NB_DIR}/home/Example File.md"     ]]
    [[    -f "${NB_DIR}/home/Example File.md.enc" ]]

    declare _original_hash=
    _original_hash="$(_get_hash "${NB_DIR}/home/Example File.md.enc")"
  }

  run "${_NB}" edit "Example File.md.enc" --password=password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/Example File.md.enc")" != "${_original_hash}" ]]

  "${_NB}" show "Example File.md.enc" --no-color --password=password

  [[ "$("${_NB}" show "Example File.md.enc" --no-color --password=password)"  =~ \
\#\ Content${_NEWLINE}\#\ mock_editor\    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with openssl -md md5 encrypted file edits properly without errors." {
  {
    "${_NB}" init

    diff                                                                      \
      <("${_NB}" env | grep NB_ENCRYPTION_TOOL --color=never | cut -d= -f 2)  \
      <(printf "openssl\\n")

    "${_NB}" add "Example File.md" --content "# Content"

    [[    -f "${NB_DIR}/home/Example File.md"     ]]

    openssl enc                                   \
      -aes-256-cbc                                \
      -md   md5                                   \
      -in   "${NB_DIR}/home/Example File.md"      \
      -out  "${NB_DIR}/home/Example File.md.enc"  \
      -pass file:<(printf "password\\n") 2> /dev/null

    [[    -f "${NB_DIR}/home/Example File.md.enc" ]]

    rm "${NB_DIR}/home/Example File.md"

    [[ !  -f "${NB_DIR}/home/Example File.md"     ]]
    [[    -f "${NB_DIR}/home/Example File.md.enc" ]]

    declare _original_hash=
    _original_hash="$(_get_hash "${NB_DIR}/home/Example File.md.enc")"
  }

  run "${_NB}" edit "Example File.md.enc" --password=password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/Example File.md.enc")" != "${_original_hash}" ]]

  "${_NB}" show "Example File.md.enc" --no-color --password=password

  [[ "$("${_NB}" show "Example File.md.enc" --no-color --password=password)"  =~ \
\#\ Content${_NEWLINE}\#\ mock_editor\    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with openssl-encrypted file and gpg NB_ENCRYPTION_TOOL edits properly without errors." {
  {
    "${_NB}" init

    "${_NB}" set encryption_tool "gpg"

    diff                                                                      \
      <("${_NB}" env | grep NB_ENCRYPTION_TOOL --color=never | cut -d= -f 2)  \
      <(printf "gpg\\n")

    NB_ENCRYPTION_TOOL=openssl "${_NB}" add "# Content" --encrypt --password=example

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original_hash="$(_get_hash "${NB_DIR}/home/${_filename}")"
  }

  run "${_NB}" edit 1 --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/${_filename}")" != "${_original_hash}" ]]

  [[ "$("${_NB}" show 1 --no-color --password=example)"  =~ \
\#\ Content${_NEWLINE}\#\ mock_editor\    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with gpg-encrypted file and openssl NB_ENCRYPTION_TOOL edits properly without errors." {
  {
    "${_NB}" init

    diff                                                                      \
      <("${_NB}" env | grep NB_ENCRYPTION_TOOL --color=never | cut -d= -f 2)  \
      <(printf "openssl\\n")

    NB_ENCRYPTION_TOOL=gpg "${_NB}" add "# Content" --encrypt --password=example

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original_hash="$(_get_hash "${NB_DIR}/home/${_filename}")"
  }

  run "${_NB}" edit 1 --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/${_filename}")" != "${_original_hash}" ]]

  [[ "$("${_NB}" show 1 --no-color --password=example)"  =~ \
\#\ Content${_NEWLINE}\#\ mock_editor\  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with encrypted file edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "# Content" --encrypt --password=example

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original_hash="$(_get_hash "${NB_DIR}/home/${_filename}")"
  }

  run "${_NB}" edit 1 --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/${_filename}")" != "${_original_hash}" ]]

  [[ "$("${_NB}" show 1 --no-color --password=example)"  =~ \
\#\ Content${_NEWLINE}\#\ mock_editor\    ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with piped content and encrypted file edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "# Example" --encrypt --password=example

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original_hash="$(_get_hash "${NB_DIR}/home/${_filename}")"
  }

  run bash -c "echo '## Piped' | ${_NB} edit 1 --password=example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  "${_NB}" show 1 --no-color --password=example

  [[ "$(_get_hash "${NB_DIR}/home/${_filename}")" != "${_original_hash}" ]]

  [[ "$("${_NB}" show 1 --no-color --password=example)"  =~ \
\#\ Example${_NEWLINE}\#\#\ Piped         ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# no argument #################################################################

@test "'edit' with no argument exits and prints help." {
  {
    "${_NB}" init
    "${_NB}" add "Example initial content." --filename "example.md"

    _original="$(cat "${NB_DIR}/home/example.md")"
  }

  run "${_NB}" edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/example.md" \
    "$(cat "${NB_DIR}/home/example.md")"

  # Does not update note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/example.md" \
    "$(cat "${NB_DIR}/home/example.md")"

  diff <(cat "${NB_DIR}/home/example.md") <(printf "%s\\n" "${_original}")

  [[ ! "$(cat "${NB_DIR}/home/example.md")" =~ mock_editor ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  ! git log | grep -q '\[nb\] Edit'

  # Prints help information:

  [[ "${lines[0]}" =~ Usage.*\:     ]]
  [[ "${lines[1]}" =~ \ \ nb\ edit  ]]
}

# --content option ############################################################

@test "'edit' with --content option and content with leading dash appends new content." {
  {
    "${_NB}" init
    "${_NB}" add --title "Example Title" --content "Example initial content."
  }

  run "${_NB}" edit 1 --content "- Example new content with dash."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates note file:

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

Example initial content.

- Example new content with dash.
HEREDOC
)

  run "${_NB}" edit 1 --content "- Sample new content with dash."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates note file:

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

Example initial content.

- Example new content with dash.

- Sample new content with dash.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}" =~ Updated:\ .*[.*1.*].*\ .*example_title.md.*\ \"Example\ Title\" ]]
}

@test "'edit' with --content option appends new content." {
  {
    "${_NB}" init
    "${_NB}" add --title "Example Title" --content "Example initial content."
  }

  run "${_NB}" edit 1 --content "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates note file:

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

Example initial content.

Example new content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${lines[0]}" =~ Updated:\ .*[.*1.*].*\ .*example_title.md.*\ \"Example\ Title\" ]]
}

@test "'edit' with empty --content option exits with 1" {
  {
    "${_NB}" init
    "${_NB}" add "Example initial content."

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original="$(cat "${NB_DIR}/home/${_filename}")"

    [[ ! "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor ]]
  }

  run "${_NB}" edit 1 --content

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1:

  [[ ${status} -eq 1 ]]

  # Does not update note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}" \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ ! "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor   ]]

  diff <(cat "${NB_DIR}/home/${_filename}") <(printf "%s\\n" "${_original}")

  # Prints error message:

  [[ "${output}" =~ requires\ a\ valid\ argument ]]
}

# --append, --overwite, & --prepend  ##########################################

@test "'edit --append --content <content>' appends <content> to file with extra newline." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  ##########
  # edit 1 #

  run "${_NB}" edit 1 --append --content "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example initial content.

Example new content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 2 #

  run "${_NB}" edit 1 --append --content "Example new content two."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example initial content.

Example new content.

Example new content two.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

@test "'edit --append <content>' appends <content> to file without extra newline." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  ##########
  # edit 1 #

  run "${_NB}" edit 1 --append "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example initial content.
Example new content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 2 #

  run "${_NB}" edit 1 --append "Example new content two."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example initial content.
Example new content.
Example new content two.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 3 #

  run "${_NB}" edit 1 --append "- Example new content three."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example initial content.
Example new content.
Example new content two.
- Example new content three.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}


@test "'edit --prepend --content <content>' prepends <content> to file with extra newline." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  ##########
  # edit 1 #

  run "${_NB}" edit 1 --prepend --content "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example new content.

Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 2 #

  run "${_NB}" edit 1 --prepend --content "Example new content two."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example new content two.

Example new content.

Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

@test "'edit --prepend <content>' prepends <content> to file without extra newline." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  ##########
  # edit 1 #

  run "${_NB}" edit 1 --prepend "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example new content.
Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 2 #

  run "${_NB}" edit 1 --prepend "Example new content two."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example new content two.
Example new content.
Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]

  ##########
  # edit 3 #

  run "${_NB}" edit 1 --prepend "- Example new content three."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  cat "${NB_DIR}/home/Example Filename.md"

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
- Example new content three.
Example new content two.
Example new content.
Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

@test "'edit --prepend' prepends standard input to file." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  run bash -c "echo '## Piped Content' | ${_NB} edit 1 --prepend"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff                                          \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
## Piped Content
Example initial content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

@test "'edit --overwrite --content <content>' overwrites existing file content with content." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  run "${_NB}" edit 1 --overwrite --content "Example new content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
Example new content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

@test "'edit --overwrite' overwrites existing content with standard input." {
  {
    "${_NB}" init
    "${_NB}" add                        \
      --filename "Example Filename.md"  \
      --content  "Example initial content."
  }

  run bash -c "echo '## Piped Content' | ${_NB} edit 1 --overwrite"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Updates file:

  diff \
    <(cat "${NB_DIR}/home/Example Filename.md") \
    <(cat <<HEREDOC
## Piped Content
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:              ]]
  [[ "${output}" =~ [0-9]+                ]]
  [[ "${output}" =~ Example\ Filename.md  ]]
}

# --last option ###############################################################

@test "'edit --last' with empty repo exits and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" edit --last

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  if [[ -n "$(git status --porcelain)" ]]
  then
    sleep 1
  fi
  ! git log | grep -q '\[nb\] Edit'

  # Prints help information:

  [[ "${lines[0]}" =~ Usage.*\:     ]]
  [[ "${lines[1]}" =~ \ \ nb\ edit  ]]
}

@test "'edit --last' edits last modified item." {
  {
    "${_NB}" init
    "${_NB}" add "Example initial content one." --filename "example one.md"
    sleep 0.5
    "${_NB}" add "Example initial content two." --filename "example two.md"
    sleep 0.5
    "${_NB}" add "Example initial content three." --filename "example three.md"

    declare _original_content_one="$(cat "${NB_DIR}/home/example one.md")"
    declare _original_content_two="$(cat "${NB_DIR}/home/example two.md")"
    declare _original_content_three="$(cat "${NB_DIR}/home/example three.md")"

    declare -a _items_unedited=($(
      "${_NB}" list \
        --empty     \
        --filenames \
        --no-color  \
        --no-id     \
        2>/dev/null || :))

    printf "\$_items_unedited[0]: %s\\n" "${_items_unedited[0]}"
    printf "\$_items_unedited[1]: %s\\n" "${_items_unedited[1]}"
    printf "\$_items_unedited[2]: %s\\n" "${_items_unedited[2]}"

    [[ "${_items_unedited[0]}" == "example three.md" ]]
    [[ "${_items_unedited[1]}" == "example two.md"   ]]
    [[ "${_items_unedited[2]}" == "example one.md"   ]]

    run "${_NB}" edit "example two.md" --content "edit one"

    declare -a _items_after_edit_one=($(
      "${_NB}" list \
        --empty     \
        --filenames \
        --no-color  \
        --no-id     \
        2>/dev/null || :))

    printf "\$_items_after_edit_one[0]: %s\\n" "${_items_after_edit_one[0]}"
    printf "\$_items_after_edit_one[1]: %s\\n" "${_items_after_edit_one[1]}"
    printf "\$_items_after_edit_one[2]: %s\\n" "${_items_after_edit_one[2]}"

    [[ "${_items_after_edit_one[0]}" == "example two.md"    ]]
    [[ "${_items_after_edit_one[1]}" == "example three.md"  ]]
    [[ "${_items_after_edit_one[2]}" == "example one.md"    ]]


    [[    "$(cat "${NB_DIR}/home/example two.md")" =~ edit\ one   ]]
    [[ !  "$(cat "${NB_DIR}/home/example two.md")" =~ mock_editor ]]
  }

  run "${_NB}" edit --last

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/example two.md" \
    "$(cat "${NB_DIR}/home/example two.md")"

  [[ "$(cat "${NB_DIR}/home/example two.md")" =~ edit\ one   ]]
  [[ "$(cat "${NB_DIR}/home/example two.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ example\ two.md ]]
}

@test "'edit -l' edits last modified item." {
  {
    "${_NB}" init
    "${_NB}" add "Example initial content one." --filename "example one.md"
    sleep 0.5
    "${_NB}" add "Example initial content two." --filename "example two.md"
    sleep 0.5
    "${_NB}" add "Example initial content three." --filename "example three.md"

    declare _original_content_one="$(cat "${NB_DIR}/home/example one.md")"
    declare _original_content_two="$(cat "${NB_DIR}/home/example two.md")"
    declare _original_content_three="$(cat "${NB_DIR}/home/example three.md")"

    declare -a _items_unedited=($(
      "${_NB}" list \
        --empty     \
        --filenames \
        --no-color  \
        --no-id     \
        2>/dev/null || :))

    printf "\$_items_unedited[0]: %s\\n" "${_items_unedited[0]}"
    printf "\$_items_unedited[1]: %s\\n" "${_items_unedited[1]}"
    printf "\$_items_unedited[2]: %s\\n" "${_items_unedited[2]}"

    [[ "${_items_unedited[0]}" == "example three.md" ]]
    [[ "${_items_unedited[1]}" == "example two.md"   ]]
    [[ "${_items_unedited[2]}" == "example one.md"   ]]

    run "${_NB}" edit "example two.md" --content "edit one"

    declare -a _items_after_edit_one=($(
      "${_NB}" list \
        --empty     \
        --filenames \
        --no-color  \
        --no-id     \
        2>/dev/null || :))

    printf "\$_items_after_edit_one[0]: %s\\n" "${_items_after_edit_one[0]}"
    printf "\$_items_after_edit_one[1]: %s\\n" "${_items_after_edit_one[1]}"
    printf "\$_items_after_edit_one[2]: %s\\n" "${_items_after_edit_one[2]}"

    [[ "${_items_after_edit_one[0]}" == "example two.md"    ]]
    [[ "${_items_after_edit_one[1]}" == "example three.md"  ]]
    [[ "${_items_after_edit_one[2]}" == "example one.md"    ]]


    [[    "$(cat "${NB_DIR}/home/example two.md")" =~ edit\ one   ]]
    [[ !  "$(cat "${NB_DIR}/home/example two.md")" =~ mock_editor ]]
  }

  run "${_NB}" edit -l

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/example two.md" \
    "$(cat "${NB_DIR}/home/example two.md")"

  [[ "$(cat "${NB_DIR}/home/example two.md")" =~ edit\ one   ]]
  [[ "$(cat "${NB_DIR}/home/example two.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ example\ two.md ]]
}

# <selector> ##################################################################

@test "'edit <selector>' with empty repo exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
  [[ "${lines[0]}" =~ 1             ]]
}

# <scope>:<selector> ##########################################################

@test "'edit <scope>:<selector>' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example initial content." --filename "example.md"

    [[ -e "${NB_DIR}/one/example.md"                        ]]
    [[ ! "$(cat "${NB_DIR}/one/example.md")" =~ mock_editor ]]
  }

  run "${_NB}" edit "one:example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "EDITOR: '%s'\\n" "${EDITOR:-}"
  printf "env EDITOR: '%s'\\n" "$("${_NB}" env | grep 'EDITOR')"

  touch "${_TMP_DIR}/editor-test.md"
  eval "${EDITOR} \"${_TMP_DIR}/editor-test.md\""
  printf "cat \${_TMP_DIR}/editor-test.md: '%s'\\n"   \
    "$(cat "${_TMP_DIR}/editor-test.md")"

  printf "cat %s:\\n%s\\n" "${NB_DIR}/one/example.md" \
    "$(cat "${NB_DIR}/one/example.md")"

  [[ "$(cat "${NB_DIR}/one/example.md")" =~ mock_editor  ]]

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "'<scope>:edit <selector>' with <filename> argument prints scoped output." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one: -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                                      ]]
    [[ -e "${NB_DIR}/one/${_filename}"                        ]]
    [[ ! "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor ]]
  }

  run "${_NB}" one:edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "EDITOR: '%s'\\n" "${EDITOR:-}"

  printf "cat %s:\\n%s\\n" "${NB_DIR}/one/${_filename}" \
    "$(cat "${NB_DIR}/one/${_filename}")"

  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ mock_editor  ]]

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "'<scope>:<selector> edit' alternative with edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "one:${_filename}" edit --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/one/${_filename}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "EDITOR: '%s'\\n" "${EDITOR:-}"

  printf "cat %s:\\n%s\\n" "${NB_DIR}/one/${_filename}" \
    "$(cat "${NB_DIR}/one/${_filename}")"

  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ Example\ content\.  ]]

  # Prints output:

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

@test "'<selector> <scope>:edit' alternative with edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "Example initial content."

    _filename=$("${_NB}" one:list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "${_filename}" one:edit --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/one/${_filename}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/one/${_filename}" \
    "$(cat "${NB_DIR}/one/${_filename}")"

  [[ "$(cat "${NB_DIR}/one/${_filename}")" =~ Example\ content\.  ]]

  # Prints output:

  [[ "${output}" =~ Updated:            ]]
  [[ "${output}" =~ one\:[0-9]+         ]]
  [[ "${output}" =~ one:[A-Za-z0-9]+.md ]]
}

# <selector> (no changes) #####################################################

@test "'edit' with no changes does not print output." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content."

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  export EDITOR="${NB_TEST_BASE_PATH}/fixtures/bin/mock_editor_no_op" &&
    run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z ${output}     ]]
}

@test "'edit' encrypted with no changes does not print output." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example content." \
      --encrypt --password example

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  export EDITOR="${NB_TEST_BASE_PATH}/fixtures/bin/mock_editor_no_op" &&
    run "${_NB}" edit "${_filename}" --password example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z ${output}     ]]
}

# <filename> ##################################################################

@test "'edit' with <filename> argument edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "EDITOR: '%s'\\n" "${EDITOR:-}"

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit' with <filename> with spaces edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Note name with spaces.md"

    _filename="Note name with spaces.md"

    [[ -e "${NB_DIR}/home/${_filename}" ]]
  }

  run "${_NB}" edit "${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                    ]]
  [[ "${output}" =~ [0-9]+                      ]]
  [[ "${output}" =~ Note\ name\ with\ spaces.md ]]
}

# <id> ########################################################################

@test "'edit <id>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}" \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'<id> edit' alternative edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Example initial content."

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    [[ ! "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor ]]
  }

  run "${_NB}" 1 edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/${_filename}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "'edit' with <path> argument edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit "${NB_DIR}/home/${_filename}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# <title> #####################################################################

@test "'edit' with <title> argument edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add --title "Example Title"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" edit "Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# piped #######################################################################

@test "'edit' with piped content edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "# Example"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original="$(cat "${NB_DIR}/home/${_filename}")"
  }

  run bash -c "echo '## Piped' | ${_NB} edit 1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"        \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" != "${_original}"   ]]
  grep -q '# Example' "${NB_DIR}/home"/*
  grep -q '## Piped' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# $EDITOR #####################################################################

@test "'edit <id>' with multi-word \$EDITOR edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add --content "Example"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    "${_NB}" set editor "mock_editor --flag"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/${_filename}"    \
    "$(cat "${NB_DIR}/home/${_filename}")"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'edit <id>' with multi-word \$EDITOR edits properly with filename with spaces." {
  {
    "${_NB}" init
    "${_NB}" add --filename "multi-word filename.md"

    "${_NB}" set editor "mock_editor --flag"
  }

  run "${_NB}" edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates note file:

  printf "cat %s:\\n%s\\n" "${NB_DIR}/home/multi-word filename.md"    \
    "$(cat "${NB_DIR}/home/multi-word filename.md")"

  [[ "$(cat "${NB_DIR}/home/multi-word filename.md")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:        ]]
  [[ "${output}" =~ [0-9]+          ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# help ########################################################################

@test "'help edit' exits with status 0 and prints help information." {
  run "${_NB}" help edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*\:     ]]
  [[ "${lines[1]}" =~ \ \ nb\ edit  ]]
}
