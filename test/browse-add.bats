#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# POST ########################################################################

@test "POST to --add <folder-name>/<folder-name>/<filename> URL with existing file creates another with incremented filename."  {
  {
    "${_NB}" init

    "${_NB}" add                                      \
      "Example Folder/Sample Folder/Example File.md"  \
      --content "Example content."

    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md" ]]

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                               \
    "content=Example%20content.&--title=Example%20Title" \
    "http://localhost:6789/home:Example%20Folder/Sample%20Folder/Example%20File.md?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Creates file:

  ls -la "${NB_DIR}/home/"

  [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File-1.md"     ]]

  diff                                                                      \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File-1.md")  \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                                           ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                        ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                                   ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                                ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                                 ]]
  [[ "${lines[4]}"  =~  \
Location:\ http:\/\/localhost:6789\/Example\ Folder/Sample\ Folder/2\?--per-page=30 ]]
}

@test "POST to --add <folder-name>/<folder-name> (no slash) URL creates folder and file named 'Sample Folder' and redirects."  {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                                \
    "content=Example%20content.&--title=Example%20Title"  \
    "http://localhost:6789/home:Example%20Folder/Sample%20Folder?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0  ]]

  # Creates file:

  [[ -f "${NB_DIR}/home/Example Folder/Sample Folder"     ]]

  diff                                                    \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder")  \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                             ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                          ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                     ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                  ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                   ]]
  [[ "${lines[4]}"  =~  \
Location:\ http:\/\/localhost:6789\/Example\ Folder/1\?--per-page=30  ]]
}

@test "POST to --add <folder-name>/<folder-name>/ (slash) URL creates folders and note and redirects."  {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                               \
    "content=Example%20content.&--title=Example%20Title" \
    "http://localhost:6789/home:Example%20Folder/Sample%20Folder/?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0  ]]

  # Creates file:

  _files=($(ls "${NB_DIR}/home/Example Folder/Sample Folder/"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/${_files[0]}"        ]]

  diff                                                                    \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/${_files[0]}")  \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                                           ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                        ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                                   ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                                ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                                 ]]
  [[ "${lines[4]}"  =~  \
Location:\ http:\/\/localhost:6789\/Example\ Folder/Sample\ Folder/1\?--per-page=30 ]]
}

@test "POST to --add <folder-name>/<folder-name>/<filename> URL creates folders and note and redirects."  {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                               \
    "content=Example%20content.&--title=Example%20Title" \
    "http://localhost:6789/home:Example%20Folder/Sample%20Folder/Example%20File.md?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Creates file:

  ls -la "${NB_DIR}/home/"

  [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md"     ]]

  diff                                                                    \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.md")  \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                                           ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                        ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                                   ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                                ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                                 ]]
  [[ "${lines[4]}"  =~  \
Location:\ http:\/\/localhost:6789\/Example\ Folder/Sample\ Folder/1\?--per-page=30 ]]
}

@test "POST to --add <folder-name>/<filename> URL creates folder and note and redirects."  {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                               \
    "content=Example%20content.&--title=Example%20Title" \
    "http://localhost:6789/home:Example%20Folder/Example%20File.md?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Creates file:

  ls -la "${NB_DIR}/home/"

  [[ -f "${NB_DIR}/home/Example Folder/Example File.md"     ]]

  diff                                                      \
    <(cat "${NB_DIR}/home/Example Folder/Example File.md")  \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                                                     ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                                  ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                                           ]]
  [[ "${lines[4]}"  =~  Location:\ http:\/\/localhost:6789\/Example\ Folder/1\?--per-page=30  ]]
}

@test "POST to --add <filename> URL creates note and redirects."  {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - --data                               \
    "content=Example%20content.&--title=Example%20Title" \
    "http://localhost:6789/home:Example%20File.md?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                  ]]

  # Creates file:

  ls -la "${NB_DIR}/home/"

  [[ -f "${NB_DIR}/home/Example File.md"    ]]

  diff                                      \
    <(cat "${NB_DIR}/home/Example File.md") \
    <(cat <<HEREDOC
# Example Title

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Prints output:

  [[ "${#lines[@]}" -eq 5                                                     ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 302\ Found                                  ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                                           ]]
  [[ "${lines[4]}"  =~  Location:\ http:\/\/localhost:6789\/1\?--per-page=30  ]]
}

# CLI #########################################################################

@test "'browse --add <notebook>:<item-selector>' renders the 'add' form with populated content and selector filename field." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    sleep 1
  }

  run "${_NB}" browse                                 \
    "Example Notebook:Example Folder/Example File.md" \
    --add --print                                     \
    --title     "Example Title"                       \
    --content   "Example content."                    \
    --tags      tag1,tag2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                  ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*Example\ Notebook.*\ .*:.*\ .*1  ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/Example%20Notebook:?--per-page=.*&--columns=.*\">Example Notebook</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/Example%20Notebook:Example%20Folder/Example%20File.md?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"

  printf "%s\\n" "${output}" | grep -q \
"cols=\".*\"># Example Title${_NEWLINE}${_NEWLINE}#tag1 #tag2${_NEWLINE}${_NEWLINE}Example content.${_NEWLINE}</textarea>"

  printf "%s\\n" "${output}" | grep -q -v \
"<input type=\"hidden\" name=\"--title\""
}

@test "'browse --add <item-selector>' renders the 'add' form with populated content." {
  {
    "${_NB}" init

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/Example\ File.md --add --print  \
    --title     "Example Title"                                       \
    --content   "Example content."                                    \
    --tags      tag1,tag2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:Example%20Folder/Example%20File.md?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"

  printf "%s\\n" "${output}" | grep -q \
"cols=\".*\"># Example Title${_NEWLINE}${_NEWLINE}#tag1 #tag2${_NEWLINE}${_NEWLINE}Example content.${_NEWLINE}</textarea>"

  printf "%s\\n" "${output}" | grep -q -v \
"<input type=\"hidden\" name=\"--title\""
}

@test "'browse --add <folder-selector>/<filename>' includes <folder-selector>/<filename> in form action." {
  # TODO: review behavior
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/Example\ File.md --add --print  \
    --title     "Example Title"                                       \
    --content   "Example content."                                    \
    --tags      tag1,tag2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:Example%20Folder/Example%20File.md?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"

  printf "%s\\n" "${output}" | grep -q \
"cols=\".*\"># Example Title${_NEWLINE}${_NEWLINE}#tag1 #tag2${_NEWLINE}${_NEWLINE}Example content.${_NEWLINE}</textarea>"

  printf "%s\\n" "${output}" | grep -q -v \
"<input type=\"hidden\" name=\"--title\""
}

@test "'browse --add <folder-selector>/' includes add options as pre-filled content hidden form fields." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/Example\ File.md --add --print  \
    --title     "Example Title"                                       \
    --content   "Example content."                                    \
    --tags      tag1,tag2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                                  ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*Example\ Folder ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:Example%20Folder/Example%20File.md?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"

  printf "%s\\n" "${output}" | grep -q \
"cols=\".*\"># Example Title${_NEWLINE}${_NEWLINE}#tag1 #tag2${_NEWLINE}${_NEWLINE}Example content.${_NEWLINE}</textarea>"

  printf "%s\\n" "${output}" | grep -q -v \
"<input type=\"hidden\" name=\"--title\""
}

@test "'browse --add <selector>' opens the add page in the browser." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --add --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:Example%20Folder/?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"
}

# option parameters ###########################################################

@test "GET to --add URL with option parameters adds hidden form fields." {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--add&--example&-x&abcdefg&--sample=demo-value"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0    ]]

  # Prints output:

  [[    "${lines[0]}"  =~ HTTP/1.0\ 200\ OK                               ]]
  [[    "${lines[1]}"  =~ Date:\ .*                                       ]]
  [[    "${lines[2]}"  =~ Expires:\ .*                                    ]]
  [[    "${lines[3]}"  =~ Server:\ nb                                     ]]
  [[    "${lines[4]}"  =~ Content-Type:\ text/html                        ]]

  [[    "${output}"    =~ action=\"/home:\?--add                          ]]

  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"--example\"\>  ]]
  [[    "${output}"    =~ \<input\ type=\"hidden\"\ name=\"-x\"\>         ]]
  [[    "${output}"    =~ \
\<input\ type=\"hidden\"\ name=\"--sample\"\ value=\"demo-value\"\>       ]]

  [[ !  "${output}"    =~ \<input\ type=\"hidden\"\ name=\"abcdefg\"\>    ]]
}

# GET #########################################################################

@test "GET to --add URL with --columns parameter uses value for textarea, form URL parameters, and header links." {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--add&--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                ]]

  # Does not create file:

  [[ -z "$(ls "${NB_DIR}/home/")"         ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                     ]]
  [[ "${lines[1]}"  =~  Date:\ .*                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                           ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html              ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1  ]]

  printf "%s\\n" "${output}" | grep -q \
    "href=\"http://localhost:6789/?--per-page=30&--columns=20\"><span class=\"dim\">❯</span>nb</a> "

  printf "%s\\n" "${output}" | grep -q "cols=\"17\">"
  printf "%s\\n" "${output}" | grep -q \
    "<form${_NEWLINE}action=\"/home:?--add&--per-page=30--columns=20"

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"
}

@test "GET to --add URL without --columns parameter uses default value for textarea." {
  {
    "${_NB}" init

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                ]]

  # Does not create file:

  [[ -z "$(ls "${NB_DIR}/home/")"         ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                     ]]
  [[ "${lines[1]}"  =~  Date:\ .*                             ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                          ]]
  [[ "${lines[3]}"  =~  Server:\ nb                           ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html              ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\"67\">"

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"
}

@test "GET to --add URL prints form without creating note." {
  {
    "${_NB}" init

    (ncat                                 \
      --exec "${_NB} browse --respond"    \
      --listen                            \
      --source-port "6789"                \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--add"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                ]]

  # Does not create file:

  [[ -z "$(ls "${NB_DIR}/home/")"         ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1

  printf "git log --stat:\\n%s\\n" "$(git log --stat)"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Add'

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html                  ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1      ]]

  printf "%s\\n" "${output}" | grep -q \
"<form${_NEWLINE}action=\"/home:?--add"

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"
}
