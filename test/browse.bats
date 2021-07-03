#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# conflicting folder and notebook names #######################################

@test "'browse <folder-id>' with conflicting folder and notebook names renders folder." {
  {
    "${_NB}" init

    "${_NB}" add "Example Conflicting Name/Example Folder File.md"  \
      --content "Example folder file content."

    "${_NB}" notebooks add "Example Conflicting Name"
    "${_NB}" notebooks use "Example Conflicting Name"

    "${_NB}" add  "Example Notebook File.md"                        \
      --content   "Example notebook file content."

    "${_NB}" notebooks use "home"

    [[   -f "${NB_DIR}/home/Example Conflicting Name/Example Folder File.md"  ]]
    [[   -f "${NB_DIR}/Example Conflicting Name/Example Notebook File.md"     ]]

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>       ]]
  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\           ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/\?--per-page=.*\"\>Example\ Conflicting\ Name\</a\>\ .*/.*\</h1\>  ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/1\?--per-page=.*\"\ class=\"list-item\"\>.*\[.*Example${_S}Conflicting${_S}Name/1.*\].*   ]]
  [[ "${output}"  =~  \
class=\"list-item\"\>.*\[.*Example${_S}Conflicting${_S}Name/1.*\].*${_S}Example${_S}Folder${_S}File.md${_S}·  ]]
  [[ "${output}"  =~  \
${_S}Example${_S}Folder${_S}File.md${_S}·${_S}\"Example${_S}folder.*\</a\>\<br\>                              ]]
}

# --original ##################################################################

@test "GET to --original URL with .svg file serves original svg file as 'Content-Type: image/svg+xml'." {
  {
    "${_NB}" init

    cat <<HEREDOC > "${_TMP_DIR}/example.svg"
<svg width="100" height="100">
  <circle cx="50" cy="50" r="40"
  stroke="red" stroke-width="4" fill="blue" />
</svg>
HEREDOC

    "${_NB}" import "${_TMP_DIR}/example.svg"

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${_TMP_DIR}/example.svg" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D -                                           \
    "http://localhost:6789/--original/home/example.svg"       \
    -o "${_TMP_DIR}/download.svg"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]

  [[ "${output}"  =~  Content-Type:\ image/svg\+xml           ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size} ]]

  diff                                                        \
    <(wc -c <"${_TMP_DIR}/download.svg")                      \
    <(wc -c <"${_TMP_DIR}/example.svg")

  diff                                                        \
    <(_get_hash "${_TMP_DIR}/download.svg")                   \
    <(_get_hash "${_TMP_DIR}/example.svg")
}

@test "GET to --original URL with .png file serves original png file as 'Content-Type: image/png'." {
  {
    "${_NB}" init

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_TEST_BASE_PATH}/fixtures/nb.png" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D -                                           \
    "http://localhost:6789/--original/home/nb.png"            \
    -o "${_TMP_DIR}/nb.png"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]

  [[ "${output}"  =~  Content-Type:\ image/png                ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size} ]]

  diff                                                        \
    <(wc -c <"${_TMP_DIR}/nb.png")                            \
    <(wc -c <"${NB_TEST_BASE_PATH}/fixtures/nb.png")

  diff                                                        \
    <(_get_hash "${_TMP_DIR}/nb.png")                         \
    <(_get_hash "${NB_TEST_BASE_PATH}/fixtures/nb.png")
}

@test "GET to --original URL with .pdf file serves original pdf file as 'Content-Type: application/pdf'." {
  {
    "${_NB}" init

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.pdf"

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_TEST_BASE_PATH}/fixtures/nb.pdf" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D -                                           \
    "http://localhost:6789/--original/home/example.pdf"       \
    -o "${_TMP_DIR}/example.pdf"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                       ]]

  [[ "${output}"  =~  Content-Type:\ application/pdf          ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size} ]]

  diff                                                        \
    <(wc -c <"${_TMP_DIR}/example.pdf")                       \
    <(wc -c <"${NB_TEST_BASE_PATH}/fixtures/example.pdf")

  diff                                                        \
    <(_get_hash "${_TMP_DIR}/example.pdf")                    \
    <(_get_hash "${NB_TEST_BASE_PATH}/fixtures/example.pdf")
}

@test "GET to --original URL with .html extension serves original html file as 'Content-Type: text/plain; charset=UTF-8'." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.html"  \
      --title     "Example Title"                     \
      --content   "<!DOCTYPE html><html><head></head><body>Example</body></html>"

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_DIR}/home/Example Folder/Example File.html" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/--original/home/Example%20Folder/Example%20File.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                       ]]

  [[ "${output}"  =~  Content-Type:\ text/plain\;\ charset=UTF-8              ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size}                 ]]

  [[ "${output}"  =~  \#\ Example\ Title                                      ]]
  [[ "${output}"  =~  \
\<!DOCTYPE\ html\>\<html\>\<head\>\</head\>\<body\>Example\</body\>\</html\>  ]]
}

@test "GET to --original URL with .md extension serves original markdown file with html content as 'Content-Type: text/plain; charset=UTF-8'." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.md"  \
      --title     "Example Title"                   \
      --content   "<html><head></head><body>Example</body></html>"

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_DIR}/home/Example Folder/Example File.md" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/--original/home/Example%20Folder/Example%20File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]

  [[ "${output}"  =~  Content-Type:\ text/plain\;\ charset=UTF-8  ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size}     ]]

  [[ "${output}"  =~  \#\ Example\ Title                          ]]
  [[ "${output}"  =~  \
\<html\>\<head\>\</head\>\<body\>Example\</body\>\</html\>        ]]
}

@test "GET to --original URL serves file with no newlines." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.md"  \
      --title     "Example Title"

    printf "# Example Title" > "${NB_DIR}/home/Example Folder/Example File.md"

    "${_NB}" git checkpoint

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_DIR}/home/Example Folder/Example File.md" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS --verbose -D - \
    "http://localhost:6789/--original/home/Example%20Folder/Example%20File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]

  [[ "${output}"  =~  Content-Type:\ text/plain\;\ charset=UTF-8  ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size}     ]]

  [[ "${output}"  =~  \#\ Example\ Title                          ]]
}

@test "GET to --original URL serves original markdown file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.md"  \
      --title       "Example Title"                 \
      --content     "Example content."

    declare _original_file_size=
    _original_file_size="$(
      wc -c <"${NB_DIR}/home/Example Folder/Example File.md" | xargs
    )"

    (ncat                               \
      --exec "${_NB} browse --respond"  \
      --listen                          \
      --source-port "6789"              \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/--original/home/Example%20Folder/Example%20File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                           ]]

  [[ "${output}"  =~  Content-Type:\ text/plain\;\ charset=UTF-8  ]]
  [[ "${output}"  =~  Content-Length:\ ${_original_file_size}     ]]

  [[ "${output}"  =~  \#\ Example\ Title                          ]]
  [[ "${output}"  =~  Example\ content.                           ]]
}

# title #######################################################################

@test "'browse' sets HTML title." {
  {
    "${_NB}" init

    sleep 1
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                  ]]

  [[    "${output}"  =~  '<title>nb browse home:</title>'   ]]
  [[ !  "${output}"  =~  'h1 class="title"'                 ]]
  [[ !  "${output}"  =~  'title-block-header'               ]]
}

# css / styles ################################################################

@test "'browse' includes application styles." {
  {
    "${_NB}" init

    sleep 1
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0         ]]

  [[ "${output}"  =~  'html {'  ]]
}

# conflicting folder id / name ################################################

@test "'browse <folder>/' with conflicting id / folder name renders links to ids and labels to names." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]

    sleep 1
  }

  run "${_NB}" browse 1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>             ]]
  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<h1\>.*\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>       ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\                 ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:1/\?--per-page=.*\"\>Example\ Folder\</a\>\ .*/.*\</h1\>     ]]

  [[ "${output}"  =~  0\ items. ]]

  run "${_NB}" browse 2/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<h1\>\<a.*\ href=\"http://localhost:6789/\?--per-page=.*\"\>\<span\  ]]
  [[ "${output}"  =~  \
\<span\ class=\"dim\"\>❯\</span\>nb\</a\>                               ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"http://localhost:6789/home:\?--per-page=.*\"\>home\</a\>\ .*:.*\   ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2/\?--per-page=.*\"\>1\</a\>\ .*/.*\</h1\>     ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"http://localhost:6789/home:2/1\?--per-page=.*\"\ class=\"list-item\"\>.*\[.*1/1.*\].*       ]]
  [[ "${output}"  =~  \
class=\"list-item\"\>.*\[.*1/1.*\].*${_S}File${_S}One.md${_S}·${_S}\"Example${_S}content\.\"\</a\>\<br\>  ]]
}

# headers #######################################################################

@test "'browse <selector> --print --headers' prints response headers." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    sleep 1
  }

  run "${_NB}" browse 1 --print --headers

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                         ]]
  [[ "${#lines[@]}" ==  5                                         ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]
}
