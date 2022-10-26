#!/usr/bin/env bats

load test_helper

# escaping / HTML entities ####################################################

@test "'browse --container' renders filenames and titles with parentheses." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Filename (1).md" --content "Example content one."
    "${_NB}" add  "Example Filename (2).md" --title   "Example Title (2)."
  }

  run "${_NB}" browse --container

  declare _amp='\&'

  printf "\${_amp}:   '%s'\\n" "${_amp}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0                                                   ]]

  [[ !  "${output}"   =~  Example\ Filename\ \(\#40\;1\)\#41\;\.md            ]]
  [[    "${output}"   =~  Example\ Filename\ ${_amp}\#40\;1${_amp}\#41\;\.md  ]]

  [[ !  "${output}"   =~  Example\ Title\ \(\#40\;2\)\#41\;\.                 ]]
  [[    "${output}"   =~  Example\ Title\ ${_amp}\#40\;2${_amp}\#41\;\.       ]]
}

# todos #######################################################################

@test "'browse --container' displays marked-up checkboxes in todo titles." {
  {
    "${_NB}" init

    "${_NB}" add  "Example One.todo.md" --content   "# [x] Example todo one."
    "${_NB}" add  "Example Two.todo.md" --content   "# [ ] Example todo two."
  }

  run "${_NB}" browse --container

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq  0               ]]

  [[    "${output}"   =~  \
\<a\ rel=\"noopener\ noreferrer\"\ href=\"//localhost:6789/home:2\?--columns=.*\&--limit=.*\"         ]]
  [[    "${output}"   =~  \
--columns=.*\&--limit=.*\"\ class=\"list-item\"\>\<span\ class=\"muted\"\>\[\</span\>\<span\          ]]
  [[    "${output}"   =~  \
muted\"\>\[\</span\>\<span\ class=\"identifier\"\>home:2\</span\>\<span\ class=\"muted\"\>]\</span\>  ]]
  [[    "${output}"   =~  \
\</span\>\ \✔️\ \ \<span\ class=\"muted\"\>\[\</span\>\<span\ class=\"identifier\"\>\ \</span\>\<span  ]]
  [[    "${output}"   =~  \
\</span\>\<span\ class=\"muted\"\>\]\</span\>\ Example\ todo\ two\.\</a\>\<br\>                       ]]


  [[    "${output}"   =~  \
\<a\ rel=\"noopener\ noreferrer\"\ href=\"//localhost:6789/home:2\?--columns=.*\&--limit=.*\"         ]]
  [[    "${output}"   =~  \
--columns=.*\&--limit=.*\"\ class=\"list-item\"\>\<span\ class=\"muted\"\>\[\</span\>\<span\          ]]
  [[    "${output}"   =~  \
muted\"\>\[\</span\>\<span\ class=\"identifier\"\>home:1\</span\>\<span\ class=\"muted\"\>]\</span\>  ]]
  [[    "${output}"   =~  \
\</span\>\ \✅\ \<span\ class=\"muted\"\>\[\</span\>\<span\ class=\"identifier\"\>x\</span\>\<span\   ]]
  [[    "${output}"   =~  \
\</span\>\<span\ class=\"muted\"\>\]\</span\>\ Example\ todo\ one\.\</a\>\<br\>                       ]]
}

# notebook: selectors #########################################################

@test "'browse' includes notebook selectors for items in the current notebook." {
  {
    "${_NB}" init

    "${_NB}" add "Example One.md" --content "Example content one."
    "${_NB}" add "Example Two.md" --content "Example content two."

    "${_NB}" add "Sample Folder/Sample One.md" --content "Sample content one."
    "${_NB}" add "Sample Folder/Sample Two.md" --content "Sample content two."
  }

  run "${_NB}" browse --print

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:3\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:2\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:1\</span\>\<span\ class=\"muted\"\>\] ]]

  run "${_NB}" browse Sample\ Folder/ --print

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:Sample${_S}Folder/2\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:Sample${_S}Folder/1\</span\>\<span\ class=\"muted\"\>\] ]]
}

@test "'browse' includes notebook selectors for items in a selected notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example One.md" --content "Example content one."
    "${_NB}" add "Example Notebook:Example Two.md" --content "Example content two."

    "${_NB}" add "Example Notebook:Sample Folder/Sample One.md" --content "Sample content one."
    "${_NB}" add "Example Notebook:Sample Folder/Sample Two.md" --content "Sample content two."
  }

  run "${_NB}" Example\ Notebook:browse --print

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:3\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:2\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:1\</span\>\<span\ class=\"muted\"\>\] ]]

  run "${_NB}" browse Example\ Notebook:Sample\ Folder/ --print

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:Sample${_S}Folder/2\</span\>\<span\ class=\"muted\"\>\] ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:Sample${_S}Folder/1\</span\>\<span\ class=\"muted\"\>\] ]]
}

@test "'browse --query <query>' includes notebook selectors for results in a selected notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Notebook:Example Two.md" --content "Example content."

    "${_NB}" add "Example Notebook:Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Example Notebook:Sample Folder/Sample Two.md" --content "Sample 123 content."
  }

  run "${_NB}" Example\ Notebook:browse --query "123" --print

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  [[    "${status}"   -eq 0 ]]

  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:1\</span\>\<span\ class=\"muted\"\>\]                   ]]
  [[    "${output}" =~  \
\[\</span\>\<span\ class=\"identifier\"\>Example${_S}Notebook:Sample${_S}Folder/2\</span\>\<span\ class=\"muted\"\>\] ]]
}

# .index ######################################################################

@test "'browse' reconciles ancestor .index files with incomplete nested .index file." {
  {
    "${_NB}" init

    mkdir -p "${NB_DIR}/home/Example/Sample/Demo"

    printf "# Title" > "${NB_DIR}/home/Example/Sample/Demo/File.md"

    touch "${NB_DIR}/home/Example/Sample/Demo/.index"

    git -C "${NB_DIR}/home" add --all
    git -C "${NB_DIR}/home" commit -am "Example commit message."

    [[ !  -e "${NB_DIR}/home/Example/.index"              ]]
    [[ !  -e "${NB_DIR}/home/Example/Sample/.index"       ]]
    [[    -e "${NB_DIR}/home/Example/Sample/Demo/.index"  ]]
    [[    -e "${NB_DIR}/home/Example/Sample/Demo/File.md" ]]

    git -C "${NB_DIR}/home" status

    [[ -z "$(git -C "${NB_DIR}/home" status --porcelain)" ]]

    sleep 1
  }

  run "${_NB}" browse "Example/Sample/Demo/" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]

  [[ "${output}"  =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:Example/Sample/Demo/1\</span\>\<span\ class=\"muted\"\>\] ]]

  diff                                                  \
    <(cat "${NB_DIR}/home/Example/.index")              \
    <(printf "Sample\\n")

  diff                                                  \
    <(cat "${NB_DIR}/home/Example/Sample/.index")       \
    <(printf "Demo\\n")

  diff                                                  \
    <(cat "${NB_DIR}/home/Example/Sample/Demo/.index")  \
    <(printf "File.md\\n")

  cd "${NB_DIR}/home" || return 1

  git -C "${NB_DIR}/home" status
  git -C "${NB_DIR}/home" log

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done

  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Reconcile Index'
}

@test "'browse' reconciles root-level .index." {
  {
    "${_NB}" init
    "${_NB}" add "File One.md"    --title "Title One"
    "${_NB}" add "File Two.md"    --title "Title Two"
    "${_NB}" add "File Three.md"  --title "Title Three"

    printf "# Title Four" > "${NB_DIR}/home/File Four.md"

    "${_NB}" git -C "${NB_DIR}/home" add --all
    "${_NB}" git -C "${NB_DIR}/home" commit -am "Example commit message."

    git -C "${NB_DIR}/home" status

    [[ -z "$(git -C "${NB_DIR}/home" status --porcelain)" ]]

    diff                              \
      <(cat "${NB_DIR}/home/.index")  \
      <(cat <<HEREDOC
File One.md
File Two.md
File Three.md
HEREDOC
)

    [[  -e "${NB_DIR}/home/File One.md"    ]]
    [[  -e "${NB_DIR}/home/File Two.md"    ]]
    [[  -e "${NB_DIR}/home/File Three.md"  ]]
    [[  -e "${NB_DIR}/home/File Four.md"   ]]
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                  ]]

  [[ "${output}"    =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:4\</span\>\<span\ class=\"muted\"\>\] ]]

  diff                              \
    <(cat "${NB_DIR}/home/.index")  \
    <(cat <<HEREDOC
File One.md
File Two.md
File Three.md
File Four.md
HEREDOC
)

  git -C "${NB_DIR}/home" log

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done

  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Reconcile Index'
}

@test "'browse' reconciles nested .index." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    printf "# Title Four" > "${NB_DIR}/home/Example Folder/File Four.md"

    diff                                            \
      <(cat "${NB_DIR}/home/Example Folder/.index") \
      <(cat <<HEREDOC
File One.md
File Two.md
File Three.md
HEREDOC
)

    [[  -e "${NB_DIR}/home/Example Folder/File One.md"    ]]
    [[  -e "${NB_DIR}/home/Example Folder/File Two.md"    ]]
    [[  -e "${NB_DIR}/home/Example Folder/File Three.md"  ]]
    [[  -e "${NB_DIR}/home/Example Folder/File Four.md"   ]]
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                 ]]

  [[ "${output}"    =~  href=\"//localhost:6789/home:1/4  ]]
  [[ "${output}"    =~  \
\[\</span\>\<span\ class=\"identifier\"\>home:Example${_S}Folder/4\</span\>\<span\ class=\"muted\"\>\] ]]

  diff                                            \
    <(cat "${NB_DIR}/home/Example Folder/.index") \
    <(cat <<HEREDOC
File One.md
File Two.md
File Three.md
File Four.md
HEREDOC
)

  git -C "${NB_DIR}/home" log

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done

  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Reconcile Index'
}

# HTML <title> ################################################################

@test "'browse <folder>/<folder>/<file>' with local notebook sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init <<< "y${_NEWLINE}"

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                              ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                            ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ local:1/1/1\</title\> ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                          ]]
}

@test "'browse <folder>/ --query <query>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --query "content" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                              ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                            ]]
  [[    "${output}"    =~  \
\<title\>${_ME}\ browse\ home:1\ --query\ \"content\"\</title\>           ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                          ]]
}

@test "'browse <folder>/<folder>/<file>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/Sample\ Folder/Example\ File.md --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                              ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                            ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:1/1/1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                          ]]
}

@test "'browse' sets HTML <title> to CLI command with no selector." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                        ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:\</title\>   ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                      ]]
}

@test "'browse <notebook>:' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                      ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ Example\\\ Notebook:\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                                    ]]
}

@test "'browse <folder>/' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                        ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                      ]]
}

# local notebook ##############################################################

@test "'browse' with no arguments serves the local notebook contents as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init <<< "y${_NEWLINE}"

    "${_NB}" add  "File One.md"       \
      --title     "Title One"         \
      --content   "Example content."

    "${_NB}" add  "File Two.md"       \
      --title     "Title Two"         \
      --content   "Example content."

    "${_NB}" add  "Example Folder"    \
      --type      "folder"

    declare _expected_param_pattern="--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook\&--columns=.*\&--limit=.*"

    sleep 1
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  # header crumbs

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<strong\>.*\<a.*\ href=\"//localhost:6789/\?${_expected_param_pattern}\"\>   ]]
  [[ "${output}"  =~  \
href=\"//localhost:6789/\?${_expected_param_pattern}\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"//localhost:6789/local:\?${_expected_param_pattern}\"\>local\</a\>.*\</nav\>   ]]

  # form

  [[ "${output}"  =~  \
action=\"/local:\?--columns=.*\&--limit=.*\&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook\"  ]]

  [[ "${output}"  =~  \
\<input\ type=\"hidden\"\ name=\"--local\"\ \ \ \ \ value=\"${_TMP_DIR}/Local\ Notebook\"\>     ]]

  # list

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/local:3\?--columns.*\&--limit=.*\&--local=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*local:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\>                   ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/local:2\?--columns.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*local:2.*\].*${_S}Title${_S}Two\</a\>\<br\>                   ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/local:1\?--columns.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*local:1.*\].*${_S}Title${_S}One\</a\>\<br\>                   ]]
}

# columns #####################################################################

@test "GET to container URL with no --columns param and GUI request truncates using the default column value and omits --column param from links." {

  {
    "${_NB}" init

    "${_NB}" add                    \
      "Example File.md"             \
       --content "Example content." \
--title "\
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--gui"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                                        ]]

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home                    ]]

  [[ "${output}"    =~  abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno…  ]]

  printf "%s\\n" "${output}" \
    | grep -q "href=\"//localhost:6789/home:1\" class=\"list-item\""

}

@test "GET to container URL with --columns param truncates using the provided value." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      "Example File.md"             \
       --content "Example content." \
--title "\
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"

    (ncat                                   \
      --exec "${_NB} browse --respond"      \
      --listen                              \
      --source-port "6789"                  \
      2>/dev/null) &

    sleep 1
  }

  run curl -sS -D - "http://localhost:6789/home:?--columns=20"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[    "${status}"  -eq 0                                        ]]

  # Prints output:

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK                         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*                              ]]
  [[ "${lines[3]}"  =~  Server:\ nb                               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html\;\ charset=UTF-8 ]]

  [[ "${output}"    =~  ❯.*nb.*\ .*·.*\ .*home                    ]]

  [[ "${output}"    =~  abcdefghi…                                ]]

  printf "%s\\n" "${output}" \
    | grep -q "href=\"//localhost:6789/home:1?--columns=20&--limit=.*\" class=\"list-item\""
}

# empty #######################################################################

@test "'browse <folder-selector>/' (slash) with empty folder prints message and header." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder" --type "folder"

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0               ]]

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<strong\>\<a.*\ href=\"//localhost:6789/\?--columns=.*\&--limit=.*\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns.*\&--limit=.*\"\>home\</a\>\ .*:.*\              ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1/\?--columns.*\&--limit=.*\"\>Example\ Folder\</a\>\ .*/.*\</nav\> ]]

  [[ "${output}"  =~  0${_NBSP}items. ]]
}

@test "'browse <notebook>:' with empty notebook prints message and header." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0               ]]

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<strong\>\<a.*\ href=\"//localhost:6789/\?--columns.*\&--limit=.*\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"//localhost:6789/Example%20Notebook:\?--columns=.*\&--limit=.*\"\>Example\ Notebook\</a\>.*\</nav\>  ]]

  [[ "${output}"  =~  0${_NBSP}items. ]]
}

# notebooks and folder (containers) ###########################################

@test "'browse' with no arguments serves the current notebook contents as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Title One"         \
      --content   "Example content."

    "${_NB}" add  "File Two.md"       \
      --title     "Title Two"         \
      --content   "Example content."

    "${_NB}" add  "Example Folder"    \
      --type      "folder"

    sleep 1
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<strong\>.*\<a.*\ href=\"//localhost:6789/\?--columns=.*\&--limit=.*\"\> ]]
  [[ "${output}"  =~  \
href=\"//localhost:6789/\?--columns=.*\&--limit=.*\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*\&--limit=.*\"\>home\</a\>.*\</nav\>     ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:3\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*home:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\>        ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:2\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*home:2.*\].*${_S}Title${_S}Two\</a\>\<br\>                    ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*home:1.*\].*${_S}Title${_S}One\</a\>\<br\>                    ]]
}

@test "'browse <folder-selector>/' (slash) serves the list as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  printf "%s\\n" "${output}" | grep       -q  \
"<nav class=\"header-crumbs\">.*<a.* href=\"//localhost:6789/?--columns=.*&--limit=.*\"><span class=\"muted\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep       -q  \
".*·.* <a.* href=\"//localhost:6789/home:?--columns=.*&--limit=.*\">home</a> .*:.*"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/home:1/?--columns=.*&--limit=.*\">Example Folder</a> .*/.*</nav>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/home:1/2?--columns=.*&--limit=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
".*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two</a><br>"

  printf "%s\\n" "${output}" | grep       -q  \
"<a.* href=\"//localhost:6789/home:1/1?--columns=.*&--limit=.*\" class=\"list-item\">"

  printf "%s\\n" "${output}" | grep       -q  \
".*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One</a><br>"
}

@test "'browse <folder-selector>' (no slash) serves the list as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Folder --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
\<nav\ class=\"header-crumbs\"\>\<strong\>\<a.*\ href=\"//localhost:6789/\?--columns=.*\&--limit=.*\"\>\<span\ class=\"muted\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
.*·.*\ \<a.*\ href=\"//localhost:6789/home:\?--columns=.*\&--limit=.*\"\>home\</a\>\ .*:.*\               ]]
  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1/\?--columns=.*\&--limit=.*\"\>Example\ Folder\</a\>\ .*/.*\</nav\>  ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1/2\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>                ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two\</a\>\<br\>                      ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/home:1/1\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>                ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One\</a\>\<br\>                      ]]
}

@test "'browse <notebook>:' serves the notebook contents as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:File One.md"  \
      --title     "Title One"                     \
      --content   "Example content."

    "${_NB}" add  "Example Notebook:File Two.md"  \
      --title     "Title Two"                     \
      --content   "Example content."

    sleep 1
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><strong><a.* href=\"//localhost:6789/?--columns=.*&--limit=.*\"><span class=\"muted\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
".*·.* <a.* href=\"//localhost:6789/Example%20Notebook:?--columns=.*\&--limit=.*\">Example Notebook</a> <span "

  printf "%s\\n" "${output}" | grep -q \
"class=\"muted\">:</span> <a rel=\"noopener noreferrer\" href=\"//localhost:6789/Example Notebook:?--columns=.*&--limit=.*&--add\">+</a></strong></nav>"

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/Example%20Notebook:2\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:2.*\].*${_S}Title${_S}Two\</a\>\<br\>                  ]]

  [[ "${output}"  =~  \
\<a.*\ href=\"//localhost:6789/Example%20Notebook:1\?--columns=.*\&--limit=.*\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:1.*\].*${_S}Title${_S}One\</a\>\<br\>                  ]]
}
