#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# --original ##################################################################

@test "GET to --original URL serves file with no newlines." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.md"  \
      --title     "Example Title"

    printf "# Example Title" > "${NB_DIR}/home/Example Folder/Example File.md"

    "${_NB}" git checkpoint

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

  [[ "${status}"  -eq 0                         ]]

  [[ "${output}"  =~  Content-Type:\ text/plain ]]

  [[ "${output}"  =~  \#\ Example\ Title        ]]
}

@test "GET to --original URL serves original markdown file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Example File.md"  \
      --title       "Example Title"                 \
      --content     "Example content."

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

  [[ "${status}"  -eq 0                         ]]

  [[ "${output}"  =~  Content-Type:\ text/plain ]]

  [[ "${output}"  =~  \#\ Example\ Title        ]]
  [[ "${output}"  =~  Example\ content.         ]]
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

  [[    "${status}"  -eq 0                    ]]

  [[    "${output}"  =~  '<title>nb</title>'  ]]
  [[ !  "${output}"  =~  'h1 class="title"'   ]]
  [[ !  "${output}"  =~  'title-block-header' ]]
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
\<a.*\ href=\"http://localhost:6789/home:2/1\?--per-page=.*\"\ class=\"list-item\"\>.*\[.*1/1.*\].*   ]]
  [[ "${output}"  =~  \
class=\"list-item\"\>.*\[.*1/1.*\].*${_S}File${_S}One.md\</a\>\<br\>    ]]
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

  [[ "${status}"    ==  0                         ]]
  [[ "${#lines[@]}" ==  5                         ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*              ]]
  [[ "${lines[3]}"  =~  Server:\ nb               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html  ]]
}
