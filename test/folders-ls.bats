#!/usr/bin/env bats

load test_helper

# $_FOLDER_HEADER_ENABLED
#
# See also: $NB_FOLDER_HEADER in _ls().
_FOLDER_HEADER_ENABLED=0

# _FOLDER_HEADER_ON_EMPTY_ENABLED
#
# See also: $NB_FOLDER_HEADER in _ls().
_FOLDER_HEADER_ON_EMPTY_ENABLED=1

# empty #######################################################################

@test "'ls <folder>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" ls Example\ Folder/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                      ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                  ]]
    [[   "${lines[4]}"  =~  0\ audio\ files\.                     ]]
    [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  else
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  0\ audio\ files\.                     ]]
    [[   "${lines[4]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  fi
}

@test "'ls <id>/ --type' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" ls 1/ --type audio

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                      ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                  ]]
    [[   "${lines[4]}"  =~  0\ audio\ files\.                     ]]
    [[   "${lines[6]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  else
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  0\ audio\ files\.                     ]]
    [[   "${lines[4]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]

  fi
}

@test "'ls <folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                      ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                  ]]
    [[   "${lines[4]}"  =~  0\ items\.                            ]]
    [[   "${lines[10]}" =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  else
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  0\ items\.                            ]]
    [[   "${lines[8]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  fi
}

@test "'ls <id>/' with conflicting id / folder name and empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                      ]]
    [[ ! "${lines[2]}"  =~  ^1                                    ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                  ]]
    [[   "${lines[4]}"  =~  0\ items\.                            ]]
    [[   "${lines[10]}" =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  else
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  0\ items\.                            ]]
    [[   "${lines[8]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  fi
}

@test "'ls <id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                      ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                  ]]
    [[   "${lines[4]}"  =~  0\ items\.                            ]]
    [[   "${lines[10]}" =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  else
    [[   "${status}"    -eq 0                                     ]]
    [[   "${lines[2]}"  =~  0\ items\.                            ]]
    [[   "${lines[8]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/ ]]
  fi
}

@test "'ls <folder>/<folder>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder" --type folder
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                         ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                          ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                      ]]
    [[   "${lines[2]}"  =~  Sample\ Folder                            ]]
    [[   "${lines[4]}"  =~  0\ items\.                                ]]
    [[   "${lines[10]}" =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/1/   ]]
  else
    [[   "${status}"    -eq 0                                         ]]
    [[   "${lines[2]}"  =~  0\ items\.                                ]]
    [[   "${lines[8]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/1/   ]]
  fi
}

@test "'ls <id>/<id>/' with empty folder displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED)) || ((_FOLDER_HEADER_ON_EMPTY_ENABLED))
  then
    [[   "${status}"    -eq 0                                       ]]
    [[   "${lines[2]}"  =~  ^Example\ Folder                        ]]
    [[ ! "${lines[2]}"  =~  ^📂\ Example\ Folder                    ]]
    [[   "${lines[4]}"  =~  0\ items\.                              ]]
    [[   "${lines[10]}" =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/   ]]
  else
    [[   "${status}"    -eq 0                                       ]]
    [[   "${lines[2]}"  =~  0\ items\.                              ]]
    [[   "${lines[8]}"  =~  import\ \(\<path\>\ \|\ \<url\>\)\ 1/   ]]
  fi
}

# limit ###################################################################

@test "'ls <folder>/' exits with 0 and respects limit." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two."
    "${_NB}" add  "three.md"    \
      --title     "root three"  \
      --content   "Content Three."

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/thee.md"  \
      --title     "nested three"            \
      --content   "Content three."

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."

    "${_NB}" set limit 2
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                         ]]
  [[    "${#lines[@]}"  -ge 8                         ]]

  [[    "${lines[0]}"   =~  home                      ]]
  [[    "${lines[1]}"   =~  ------------              ]]
  [[    "${lines[2]}"   =~  4.*📂\ Example\ Folder    ]]
  [[    "${lines[3]}"   =~  3.*root\ three            ]]
  [[    "${lines[4]}"   =~  2\ omitted\.\ 4\ total\.  ]]
  [[    "${lines[5]}"   =~  ------------              ]]
  [[    "${lines[6]}"   =~  nb\ add                   ]]

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -ge 8                                     ]]

  [[    "${lines[0]}"   =~  home                                  ]]
  [[    "${lines[1]}"   =~  ------------                          ]]
  [[    "${lines[2]}"   =~  Example\ Folder/4.*📂\ Sample\ Folder ]]
  [[    "${lines[3]}"   =~  Example\ Folder/3.*nested\ three      ]]
  [[    "${lines[4]}"   =~  2\ omitted\.\ 4\ total\.              ]]
  [[    "${lines[5]}"   =~  ------------                          ]]
  [[    "${lines[6]}"   =~  nb\ add\ 4/                           ]]
}

@test "'ls <folder>/ -s' exits with 0, respects limit, and hides header and footer." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two."
    "${_NB}" add  "three.md"    \
      --title     "root three"  \
      --content   "Content Three."

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/thee.md"  \
      --title     "nested three"            \
      --content   "Content three."

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."

    "${_NB}" set limit 2
  }

  run "${_NB}" ls -s

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                         ]]
  [[    "${#lines[@]}"  -ge 3                         ]]

  [[    "${lines[0]}"   =~  1.*root\ one              ]]
  [[    "${lines[1]}"   =~  2.*root\ two              ]]
  [[    "${lines[2]}"   =~  2\ omitted\.\ 4\ total\.  ]]

  run "${_NB}" ls Example\ Folder/ -s

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -ge 3                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/1.*nested\ one  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/2.*nested\ two  ]]
  [[    "${lines[2]}"   =~  2\ omitted\.\ 4\ total\.        ]]
}

@test "'ls <folder>/ <pattern>...' (space) exits with 0 and ignores limit." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two."
    "${_NB}" add  "three.md"    \
      --title     "root three"  \
      --content   "Content Three."

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/thee.md"  \
      --title     "nested three"            \
      --content   "Content three."

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."

    "${_NB}" set limit 2
  }

  run "${_NB}" ls root

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  3.*root\ three                    ]]
  [[    "${lines[1]}"   =~  2.*root\ two                      ]]
  [[    "${lines[2]}"   =~  1.*root\ one                      ]]

  run "${_NB}" ls Example\ Folder/ one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 1                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/1.*nested\ one    ]]

  run "${_NB}" ls Example\ Folder/ nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/3.*nested\ three  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/2.*nested\ two    ]]
  [[    "${lines[2]}"   =~  Example\ Folder/1.*nested\ one    ]]
  [[ !  "${output}"     =~  omitted                           ]]

  run "${_NB}" list Example\ Folder/ one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 2                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two    ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one    ]]
}

@test "'ls <folder>/<pattern>...' (no space) exits with 0 and ignores limit." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"      \
      --title     "root one"    \
      --content   "Content one."
    "${_NB}" add  "two.md"      \
      --title     "root two"    \
      --content   "Content two."
    "${_NB}" add  "three.md"    \
      --title     "root three"  \
      --content   "Content Three."

    "${_NB}" add  "Example Folder/one.md"   \
      --title     "nested one"              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md"   \
      --title     "nested two"              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/thee.md"  \
      --title     "nested three"            \
      --content   "Content three."

    "${_NB}" add  "Example Folder/Sample Folder/one.md"   \
      --title     "deep one"                              \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md"   \
      --title     "deep two"                              \
      --content   "Content two."
    "${_NB}" add  "Example Folder/Sample Folder/three.md" \
      --title     "deep three"                            \
      --content   "Content three."

    "${_NB}" set limit 2
  }

  run "${_NB}" ls Example\ Folder/one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 1                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/1.*nested\ one    ]]

  run "${_NB}" ls Example\ Folder/nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/3.*nested\ three  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/2.*nested\ two    ]]
  [[    "${lines[2]}"   =~  Example\ Folder/1.*nested\ one    ]]
  [[ !  "${output}"     =~  omitted                           ]]

  run "${_NB}" list Example\ Folder/one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 2                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two    ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one    ]]

  run "${_NB}" list Example\ Folder/one two three

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 3                                 ]]

  [[    "${lines[0]}"   =~  Example\ Folder/3.*nested\ three  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/2.*nested\ two    ]]
  [[    "${lines[2]}"   =~  Example\ Folder/1.*nested\ one    ]]
  [[ !  "${output}"     =~  omitted                           ]]
}

# error handling ##############################################################

@test "'ls <not-valid>/' exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" ls not-valid/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 1             ]]

  [[   "${lines[0]}"  =~ Not\ found:    ]]
  [[   "${lines[0]}"  =~ not-valid/     ]]
  [[   "${#lines[@]}" == 1              ]]
}

@test "'ls <folder>/ <no-match>' (slash, space) exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"
  }

  run "${_NB}" ls Example\ Folder/ no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1                                              ]]
  [[    "${#lines[@]}" -eq 1                                              ]]
  [[    "${lines[0]}"  =~  Not\ found:\ .*Example\ Folder/.*\ .*no-match  ]]
}

@test "'ls <folder>/<no-match>' (slash, no space) exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"
  }

  run "${_NB}" ls Example\ Folder/no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1                                              ]]
  [[    "${#lines[@]}" -eq 1                                              ]]
  [[    "${lines[0]}"  =~  Not\ found:\ .*Example\ Folder/.*\ .*no-match  ]]
}

@test "'ls <folder> <no-match>' (no slash, space) exits with 0 and lists folder match." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"
  }

  run "${_NB}" ls Example\ Folder no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                          ]]
  [[    "${#lines[@]}" -eq 1                          ]]
  [[    "${lines[0]}"  =~  1.*\ 📂\ .*Example\ Folder ]]
}

@test "'ls <notebook>:<folder>/ <no-match>' (slash, space) exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/ no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1                                                    ]]
  [[    "${#lines[@]}" -eq 1                                                    ]]
  [[    "${lines[0]}"  =~  Not\ found:\ .*home:.*Example\ Folder/.*\ .*no-match ]]
}

@test "'ls <notebook>:<folder>/<no-match>' (slash, no space) exits with 1 and prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 1                                                    ]]
  [[    "${#lines[@]}" -eq 1                                                    ]]
  [[    "${lines[0]}"  =~  Not\ found:\ .*home:.*Example\ Folder/.*\ .*no-match ]]
}

@test "'ls <notebook>:<folder> <no-match>' (no slash, space) exits with 0 and lists folder match." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/File One.md"    --title "Title One"
    "${_NB}" add "Example Folder/File Two.md"    --title "Title Two"
    "${_NB}" add "Example Folder/File Three.md"  --title "Title Three"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder no-match

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq 0                                ]]
  [[    "${#lines[@]}" -eq 1                                ]]
  [[    "${lines[0]}"  =~  home:1.*\ 📂\ .*Example\ Folder  ]]
}

# filtering ###################################################################

@test "'ls <folder>/ <pattern>...' (slash) exits with 0 and prints filtered list." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."
  }

  run "${_NB}" ls one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  1.*root\ one                    ]]

  run "${_NB}" ls Example\ Folder/ one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 1                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/1.*nested\ one  ]]

  run "${_NB}" ls Example\ Folder/ nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 2                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one  ]]

  run "${_NB}" list Example\ Folder/ one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 2                               ]]

  [[    "${lines[0]}"   =~  Example\ Folder/2.*nested\ two  ]]
  [[    "${lines[1]}"   =~  Example\ Folder/1.*nested\ one  ]]
}

@test "'ls <notebook>:<folder>/ <pattern>...' (slash) exits with 0 and prints filtered list." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."

    "${_NB}" notebooks add "example-notebook"
    "${_NB}" use "example-notebook"

    [[ "$("${_NB}" notebooks current)" == "example-notebook"    ]]
  }

  run "${_NB}" ls home: one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 1                                   ]]

  [[    "${lines[0]}"   =~  home:1.*root\ one                   ]]

  run "${_NB}" ls home:Example\ Folder/ one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 1                                   ]]

  [[    "${lines[0]}"   =~  home:Example\ Folder/1.*nested\ one ]]

  run "${_NB}" ls home:Example\ Folder/ nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 2                                   ]]

  [[    "${lines[0]}"   =~  home:Example\ Folder/2.*nested\ two ]]
  [[    "${lines[1]}"   =~  home:Example\ Folder/1.*nested\ one ]]

  run "${_NB}" list home:Example\ Folder/ one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 2                                   ]]

  [[    "${lines[0]}"   =~  home:Example\ Folder/2.*nested\ two ]]
  [[    "${lines[1]}"   =~  home:Example\ Folder/1.*nested\ one ]]
}

@test "'ls <folder> <pattern>...' (no slash) exits with 0 and treats folder as selector and filter pattern." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."
  }

  run "${_NB}" list one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 1                       ]]

  [[    "${lines[0]}"   =~  1.*root\ one            ]]
  [[    "${output}"     =~  1.*root\ one            ]]

  run "${_NB}" list Example\ Folder one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 2                       ]]

  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]
  [[    "${lines[1]}"   =~  1.*root\ one            ]]

  run "${_NB}" list Example\ Folder nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 1                       ]]

  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]

  run "${_NB}" list Example\ Folder one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                       ]]
  [[    "${#lines[@]}"  -eq 3                       ]]

  [[    "${lines[2]}"   =~  1.*root\ one            ]]
  [[    "${lines[1]}"   =~  2.*root\ two            ]]
  [[    "${lines[0]}"   =~  3.*📂\ Example\ Folder  ]]
}

@test "'ls <notebook>:<folder> <pattern>...' (no slash) exits with 0 and treats folder as selector and filter pattern." {
  {
    "${_NB}" init

    "${_NB}" add  "one.md"    \
      --title     "root one"  \
      --content   "Content one."
    "${_NB}" add  "two.md"    \
      --title     "root two"  \
      --content   "Content two."

    "${_NB}" add  "Example Folder/one.md" \
      --title     "nested one"            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/two.md" \
      --title     "nested two"            \
      --content   "Content two."

    "${_NB}" add  "Example Folder/Sample Folder/one.md" \
      --title     "deep one"                            \
      --content   "Content one."
    "${_NB}" add  "Example Folder/Sample Folder/two.md" \
      --title     "deep two"                            \
      --content   "Content two."

    "${_NB}" notebooks add "example-notebook"
    "${_NB}" use "example-notebook"

    [[ "$("${_NB}" notebooks current)" == "example-notebook" ]]
  }

  run "${_NB}" list home: one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 1                           ]]

  [[    "${lines[0]}"   =~  home:1.*root\ one           ]]
  [[    "${output}"     =~  home:1.*root\ one           ]]

  run "${_NB}" list home:Example\ Folder one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 2                           ]]

  [[    "${lines[0]}"   =~  home:3.*📂\ Example\ Folder ]]
  [[    "${lines[1]}"   =~  home:1.*root\ one           ]]

  run "${_NB}" list home:Example\ Folder nested

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 1                           ]]

  [[    "${lines[0]}"   =~  home:3.*📂\ Example\ Folder ]]

  run "${_NB}" list home:Example\ Folder one two

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]
  [[    "${#lines[@]}"  -eq 3                           ]]

  [[    "${lines[2]}"   =~  home:1.*root\ one           ]]
  [[    "${lines[1]}"   =~  home:2.*root\ two           ]]
  [[    "${lines[0]}"   =~  home:3.*📂\ Example\ Folder ]]
}

# footer ######################################################################

@test "'<id>/' prints footer with commands scoped to folder id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                         \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"  \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"           \
      --title "Two"

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "\${lines[6]}: '%s'\\n" "${lines[6]}"
  printf "\${lines[8]}: '%s'\\n" "${lines[8]}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0       ]]
    [[   "${lines[8]}"  =~ add\ 1/  ]]
  else
    [[   "${status}"    -eq 0       ]]
    [[   "${lines[6]}"  =~ add\ 1/  ]]
  fi
}

@test "'<folder>/' prints footer with commands scoped to folder id." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                         \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"  \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"           \
      --title "Two"

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "\${lines[6]}: '%s'\\n" "${lines[6]}"
  printf "\${lines[8]}: '%s'\\n" "${lines[8]}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0       ]]
    [[   "${lines[8]}"  =~ add\ 1/  ]]
  else
    [[   "${status}"    -eq 0       ]]
    [[   "${lines[6]}"  =~ add\ 1/  ]]
  fi
}

@test "'notebook:<id>/' prints footer with commands scoped to notebook and folder id." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Notebook One"

    "${_NB}" add "Notebook One:Example Folder/one.md"                         \
      --title "one"
    "${_NB}" add "Notebook One:Example Folder/two.bookmark.md"                \
      --content "<https://example.test>"

    "${_NB}" add "Notebook One:Example Folder/Sample Folder/one.bookmark.md"  \
      --content "<https://example.test>"
    "${_NB}" add "Notebook One:Example Folder/Sample Folder/two.md"           \
      --title "Two"

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" Notebook\ One:1/

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"

  printf "\${lines[6]}: '%s'\\n" "${lines[6]}"
  printf "\${lines[8]}: '%s'\\n" "${lines[8]}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                       ]]
    [[   "${lines[8]}"  =~ add\ Notebook\\\ One:1/  ]]
  else
    [[   "${status}"    -eq 0                       ]]
    [[   "${lines[6]}"  =~ add\ Notebook\\\ One:1/  ]]
  fi
}

@test "'notebook:<folder>/' prints footer with commands scoped to notebook and folder id." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Notebook One"

    "${_NB}" add "Notebook One:Example Folder/one.md"                         \
      --title "one"
    "${_NB}" add "Notebook One:Example Folder/two.bookmark.md"                \
      --content "<https://example.test>"

    "${_NB}" add "Notebook One:Example Folder/Sample Folder/one.bookmark.md"  \
      --content "<https://example.test>"
    "${_NB}" add "Notebook One:Example Folder/Sample Folder/two.md"           \
      --title "Two"

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" Notebook\ One:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "\${lines[6]}: '%s'\\n" "${lines[6]}"
  printf "\${lines[8]}: '%s'\\n" "${lines[8]}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                       ]]
    [[   "${lines[8]}"  =~ add\ Notebook\\\ One:1/  ]]
  else
    [[   "${status}"    -eq 0                       ]]
    [[   "${lines[6]}"  =~ add\ Notebook\\\ One:1/  ]]
  fi
}

# notebook:<id> ###############################################################

@test "'notebook:<id>/<folder>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" home:1/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  [^/]home:Example\ Folder/3      ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'notebook:folder/folder/<id>' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                   \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"     \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"              \
      --title "Two"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.txt" \
      --content "Content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.txt" \
      --content "Content two."

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" home:Example\ Folder/Sample\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]

  [[   "${#lines[@]}" -eq 1                                           ]]

  [[   "${lines[0]}"  =~  [^/]home:Example\ Folder/Sample\ Folder/3   ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                          ]]
  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                 ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                ]]
}

@test "'notebook:folder/<id>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" home:Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  [^/]home:Example\ Folder/3      ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'notebook:<id>' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" home:1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                         ]]

  [[ ! "${lines[0]}"  =~  3\.bookmark\.md           ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒                    ]]
  [[ ! "${lines[1]}"  =~  2\.bookmark\.md           ]]
  [[ ! "${lines[1]}"  =~  🔖                        ]]
  [[ ! "${lines[2]}"  =~  one                       ]]
  [[ ! "${lines[2]}"  =~  🔖                        ]]
  [[ ! "${lines[2]}"  =~  🔒                        ]]

  [[ ! "${lines[0]}"  =~  [^/]home:Example\ Folder  ]]
  [[   "${lines[0]}"  =~  3                         ]]
  [[   "${lines[0]}"  =~  📂                        ]]
  [[   "${lines[0]}"  =~  Example\ Folder           ]]
  [[   "${#lines[@]}" -eq 1                         ]]
}

# ls notebook:<id> ############################################################

@test "'ls notebook:<id>/<folder>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" ls home:1/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  home:Example\ Folder/3          ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'ls notebook:folder/folder/<id>' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                   \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"     \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"              \
      --title "Two"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.txt" \
      --content "Content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.txt" \
      --content "Content two."

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]

  [[   "${#lines[@]}" -eq 1                                           ]]

  [[   "${lines[0]}"  =~  home:Example\ Folder/Sample\ Folder/3       ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                          ]]
  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                 ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                ]]
}

@test "'ls notebook:folder/<id>' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" ls home:Example\ Folder/3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  home:Example\ Folder/3          ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'ls notebook:<id>' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]

  [[ ! "${lines[0]}"  =~  3\.bookmark\.md       ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒                ]]
  [[ ! "${lines[1]}"  =~  2\.bookmark\.md       ]]
  [[ ! "${lines[1]}"  =~  🔖                    ]]
  [[ ! "${lines[2]}"  =~  one                   ]]
  [[ ! "${lines[2]}"  =~  🔖                    ]]
  [[ ! "${lines[2]}"  =~  🔒                    ]]

  [[ ! "${lines[0]}"  =~  home:Example\ Folder  ]]
  [[   "${lines[0]}"  =~  3                     ]]
  [[   "${lines[0]}"  =~  📂                    ]]
  [[   "${lines[0]}"  =~  Example\ Folder       ]]
  [[   "${#lines[@]}" -eq 1                     ]]
}

# ls notebook:folder ###################################################################

@test "'ls notebook:folder/folder/folder' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                   \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"     \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"              \
      --title "Two"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.txt" \
      --content "Content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.txt" \
      --content "Content two."

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder/Demo\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]

  [[   "${#lines[@]}" -eq 1                                           ]]

  [[   "${lines[0]}"  =~  home:Example\ Folder/Sample\ Folder/3       ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                          ]]
  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                 ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                ]]
}

@test "'ls notebook:folder/folder' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  home:Example\ Folder/3          ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'ls notebook:folder' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                     ]]

  [[ ! "${lines[0]}"  =~  3\.bookmark\.md       ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒                ]]
  [[ ! "${lines[1]}"  =~  2\.bookmark\.md       ]]
  [[ ! "${lines[1]}"  =~  🔖                    ]]
  [[ ! "${lines[2]}"  =~  one                   ]]
  [[ ! "${lines[2]}"  =~  🔖                    ]]
  [[ ! "${lines[2]}"  =~  🔒                    ]]

  [[ ! "${lines[0]}"  =~  home:Example\ Folder  ]]
  [[   "${lines[0]}"  =~  3                     ]]
  [[   "${lines[0]}"  =~  📂                    ]]
  [[   "${lines[0]}"  =~  Example\ Folder       ]]
  [[   "${#lines[@]}" -eq 1                     ]]
}

# ls notebook:<id>/ ###########################################################

@test "'ls notebook:folder/folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'ls notebook:folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" ls home:Example\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[   "${lines[7]}"  =~ Demo                                 ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[   "${lines[5]}"  =~ Demo                                 ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[8]}"  =~ add ]]
  fi
}

@test "'ls notebook:<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'notebook:<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "example-1.md"
    "${_NB}" add "example-2.md"
    "${_NB}" add "example-3.md"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password


    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" home:4/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

# ls notebook:folder/ ###########################################################

@test "'ls notebook:folder/folder/folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder/Demo\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'ls notebook:folder/folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
}

  run "${_NB}" ls home:Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[   "${lines[7]}"  =~ Demo                                 ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[   "${lines[5]}"  =~ Demo                                 ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[8]}"  =~ add ]]
  fi
}

@test "'ls notebook:folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password

    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" ls home:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "example-1.md"
    "${_NB}" add "example-2.md"
    "${_NB}" add "example-3.md"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password


    "${_NB}" notebooks add "one"
    "${_NB}" use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" home:Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

# ls <id>/ ####################################################################

@test "'ls folder/folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/three.bookmark.md" \
      --content "<https://example.test>"                                      \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ ----                                 ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'ls folder/<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder" --type folder

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[   "${lines[7]}"  =~ Demo                                 ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[   "${lines[5]}"  =~ Demo                                 ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[8]}"  =~ add ]]
  fi
}

@test "'ls <id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" ls 1/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'<id>/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "example-1.md"
    "${_NB}" add "example-2.md"
    "${_NB}" add "example-3.md"

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" 4/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

# ls folder ###################################################################

@test "'ls folder/folder/folder' exits with 0 and prints the folder/folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"                   \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md"     \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"              \
      --title "Two"

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/one.txt" \
      --content "Content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/two.txt" \
      --content "Content two."
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder/Demo\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                           ]]

  [[   "${#lines[@]}" -eq 1                                           ]]

  [[   "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/3            ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder/Demo\ Folder ]]
  [[   "${lines[0]}"  =~  📂                                          ]]
  [[ ! "${lines[0]}"  =~  Sample\ Folder/Demo\ Folder                 ]]
  [[   "${lines[0]}"  =~  Demo\ Folder                                ]]
}

@test "'ls folder/folder' exits with 0 and prints the folder/folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"               \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/one.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/two.md"          \
      --title "Two"
  }

  run "${_NB}" ls Example\ Folder/Sample\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                               ]]

  [[   "${#lines[@]}" -eq 1                               ]]

  [[   "${lines[0]}"  =~  Example\ Folder/3               ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  📂                              ]]
  [[ ! "${lines[0]}"  =~  Example\ Folder/Sample\ Folder  ]]
  [[   "${lines[0]}"  =~  Sample\ Folder                  ]]
}

@test "'ls folder' exits with 0 and prints the folder list item." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/1.md"          \
      --title "one"
    "${_NB}" add "Example Folder/2.bookmark.md" \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/3.bookmark.md" \
      --content "<https://example.test>"        \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                 ]]

  [[ ! "${lines[0]}"  =~  3\.bookmark\.md   ]]
  [[ ! "${lines[0]}"  =~  🔖\ 🔒            ]]
  [[ ! "${lines[1]}"  =~  2\.bookmark\.md   ]]
  [[ ! "${lines[1]}"  =~  🔖                ]]
  [[ ! "${lines[2]}"  =~  one               ]]
  [[ ! "${lines[2]}"  =~  🔖                ]]
  [[ ! "${lines[2]}"  =~  🔒                ]]

  [[   "${lines[0]}"  =~  3                 ]]
  [[   "${lines[0]}"  =~  📂                ]]
  [[   "${lines[0]}"  =~  Example\ Folder   ]]
  [[   "${#lines[@]}" -eq 1                 ]]
}

# ls folder/ ##################################################################

@test "'ls folder/' exits with 0 and lists files in folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/three.bookmark.md" \
      --content "<https://example.test>"            \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'ls folder/folder/' exits with 0 and lists files in folder/folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/file 1.md"  --content "Example content one."
    "${_NB}" add "Example Folder/file 2.md"  --content "Example content two."
    "${_NB}" add "Example Folder/file 3.md"  --content "Example content three."

    "${_NB}" add "Example Folder/Sample Folder/one.md"            \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"   \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md" \
      --content "<https://example.test>"                          \
      --encrypt --password=password
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[ ! "${lines[4]}"  =~ three                                ]]
    [[ ! "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[ ! "${lines[5]}"  =~ two                                  ]]
    [[ ! "${lines[5]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[4]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[5]}"  =~ file\ 3                              ]]
    [[   "${lines[6]}"  =~ file\ 2                              ]]
    [[   "${lines[7]}"  =~ file\ 1                              ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[ ! "${lines[2]}"  =~ three                                ]]
    [[ ! "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[ ! "${lines[3]}"  =~ two                                  ]]
    [[ ! "${lines[3]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[3]}"  =~ file\ 3                              ]]
    [[   "${lines[4]}"  =~ file\ 2                              ]]
    [[   "${lines[5]}"  =~ file\ 1                              ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[8]}"  =~ add ]]
  fi

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~ three                                ]]
    [[   "${lines[4]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[5]}"  =~ two                                  ]]
    [[   "${lines[5]}"  =~ 🔖                                   ]]
    [[   "${lines[6]}"  =~ one                                  ]]
    [[ ! "${lines[6]}"  =~ 🔖                                   ]]
    [[ ! "${lines[6]}"  =~ 🔒                                   ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ three                                ]]
    [[   "${lines[2]}"  =~ 🔖\ 🔒                               ]]
    [[   "${lines[3]}"  =~ two                                  ]]
    [[   "${lines[3]}"  =~ 🔖                                   ]]
    [[   "${lines[4]}"  =~ one                                  ]]
    [[ ! "${lines[4]}"  =~ 🔖                                   ]]
    [[ ! "${lines[4]}"  =~ 🔒                                   ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}

@test "'ls folder/folder/folder/' exits with 0 and lists files in folder/folder/folder in reverse order." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/file 1.md" --content "Example content one."
    "${_NB}" add "Example Folder/file 2.md" --content "Example content two."
    "${_NB}" add "Example Folder/file 3.md" --content "Example content three."

    "${_NB}" add "Example Folder/Sample Folder/one.md"                        \
      --title "one"
    "${_NB}" add "Example Folder/Sample Folder/two.bookmark.md"               \
      --content "<https://example.test>"
    "${_NB}" add "Example Folder/Sample Folder/three.bookmark.md"             \
      --content "<https://example.test>"                                      \
      --encrypt --password=password

    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document One.md"   \
      --content "Example content one."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document Two.md"   \
      --content "Example content two."
    "${_NB}" add "Example Folder/Sample Folder/Demo Folder/Document Three.md" \
      --content "Example content three."
  }

  run "${_NB}" ls Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[ ! "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[ ! "${lines[4]}"  =~  three                               ]]
    [[ ! "${lines[4]}"  =~  🔖\ 🔒                              ]]
    [[ ! "${lines[5]}"  =~  two                                 ]]
    [[ ! "${lines[5]}"  =~  🔖                                  ]]
    [[ ! "${lines[6]}"  =~  one                                 ]]
    [[ ! "${lines[6]}"  =~  🔖                                  ]]
    [[ ! "${lines[6]}"  =~  🔒                                  ]]
    [[   "${lines[4]}"  =~  Sample\ Folder                      ]]
    [[   "${lines[5]}"  =~  file\ 3                             ]]
    [[   "${lines[6]}"  =~  file\ 2                             ]]
    [[   "${lines[7]}"  =~  file\ 1                             ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[ ! "${lines[2]}"  =~  three                               ]]
    [[ ! "${lines[2]}"  =~  🔖\ 🔒                              ]]
    [[ ! "${lines[3]}"  =~  two                                 ]]
    [[ ! "${lines[3]}"  =~  🔖                                  ]]
    [[ ! "${lines[4]}"  =~  one                                 ]]
    [[ ! "${lines[4]}"  =~  🔖                                  ]]
    [[ ! "${lines[4]}"  =~  🔒                                  ]]
    [[   "${lines[2]}"  =~  Sample\ Folder                      ]]
    [[   "${lines[3]}"  =~  file\ 3                             ]]
    [[   "${lines[4]}"  =~  file\ 2                             ]]
    [[   "${lines[5]}"  =~  file\ 1                             ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[0]}"  =~ add ]]
  fi

  run "${_NB}" ls Example\ Folder/Sample\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[ ! "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~  Demo\ Folder                        ]]
    [[   "${lines[5]}"  =~  three                               ]]
    [[   "${lines[5]}"  =~  🔖\ 🔒                              ]]
    [[   "${lines[6]}"  =~  two                                 ]]
    [[   "${lines[6]}"  =~  🔖                                  ]]
    [[   "${lines[7]}"  =~  one                                 ]]
    [[ ! "${lines[7]}"  =~  🔖                                  ]]
    [[ ! "${lines[7]}"  =~  🔒                                  ]]
    [[   "${lines[8]}"  =~ ----                                 ]]
    [[   "${lines[9]}"  =~ add ]] || [[   "${lines[10]}" =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~  Demo\ Folder                        ]]
    [[   "${lines[3]}"  =~  three                               ]]
    [[   "${lines[3]}"  =~  🔖\ 🔒                              ]]
    [[   "${lines[4]}"  =~  two                                 ]]
    [[   "${lines[4]}"  =~  🔖                                  ]]
    [[   "${lines[5]}"  =~  one                                 ]]
    [[ ! "${lines[5]}"  =~  🔖                                  ]]
    [[ ! "${lines[5]}"  =~  🔒                                  ]]
    [[   "${lines[6]}"  =~ ----                                 ]]
    [[   "${lines[7]}"  =~ add ]] || [[   "${lines[8]}"  =~ add ]]
  fi

  run "${_NB}" ls Example\ Folder/Sample\ Folder/Demo\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  if ((_FOLDER_HEADER_ENABLED))
  then
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]
    [[   "${lines[2]}"  =~ ^Example\ Folder                     ]]
    [[ ! "${lines[2]}"  =~ ^📂\ Example\ Folder                 ]]
    [[   "${lines[2]}"  =~ Sample\ Folder                       ]]
    [[   "${lines[2]}"  =~ Demo\ Folder                         ]]
    [[   "${lines[3]}"  =~ ----                                 ]]
    [[   "${lines[4]}"  =~  Document\ Three.md                  ]]
    [[   "${lines[5]}"  =~  Document\ Two.md                    ]]
    [[   "${lines[6]}"  =~  Document\ One.md                    ]]
    [[   "${lines[7]}"  =~ ----                                 ]]
    [[   "${lines[8]}"  =~ add ]] || [[   "${lines[9]}"  =~ add ]]
  else
    [[   "${status}"    -eq 0                                   ]]

    [[   "${lines[0]}"  =~ home                                 ]]
    [[   "${lines[1]}"  =~ -----                                ]]

    [[   "${lines[2]}"  =~  Document\ Three.md                  ]]
    [[   "${lines[3]}"  =~  Document\ Two.md                    ]]
    [[   "${lines[4]}"  =~  Document\ One.md                    ]]
    [[   "${lines[5]}"  =~ ----                                 ]]
    [[   "${lines[6]}"  =~ add ]] || [[   "${lines[7]}"  =~ add ]]
  fi
}
