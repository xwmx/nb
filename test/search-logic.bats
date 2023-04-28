#!/usr/bin/env bats

load test_helper

_setup_search() {
  "${_NB}" init

  "${_NB}" add  "File One.md"   \
    --title     "Title One"     \
    --content   "Sample Content One Sample Phrase."

  "${_NB}" add  "File Two.md"   \
    --title     "Title Two"     \
    --content   "Example Content Two Example Phrase."

  "${_NB}" add  "File Three.md" \
    --title     "Title Three"   \
    --content   "Example Content Three Example Phrase."
}

# -e flag #####################################################################

@test "'search <query1> --and -e <query2> --or -e <query3>' ignores -e flag." {
  {
    _setup_search
  }

  run "${_NB}" search "one" --and -e "two" --or -e "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                       ]]

  [[    "${#lines[@]}"  -eq 7                                                       ]]

  [[    "${lines[0]}"   =~  [.*3.*].*\ .*Title\ Three                               ]]
  [[    "${lines[1]}"   =~  -*-                                                     ]]
  [[    "${lines[2]}"   =~  3.*:.*Example.*\ Content\ Three\ .*Example.*\ Phrase.   ]]

  [[    "${lines[3]}"   =~  [.*2.*].*\ .*Title\ Two                                 ]]
  [[    "${lines[4]}"   =~  -*-                                                     ]]
  [[    "${lines[5]}"   =~  1.*:.*#\ Title\ .*Two                                   ]]
  [[    "${lines[6]}"   =~  3.*:.*Example.*\ Content\ .*Two.*\ .*Example.*\ Phrase. ]]
}

# --not option ################################################################

@test "'search --not <query>' lists items NOT matchin query, omitting content." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"   \
      --title     "Title One"     \
      --content   "Sample Content One Sample Phrase Alpha."

    "${_NB}" add  "File Two.md"   \
      --title     "Title Two"     \
      --content   "Example Content Two Example Phrase Beta."

    "${_NB}" add  "File Three.md" \
      --title     "Title Three"   \
      --content   "Example Content Three Example Phrase Alpha."

    "${_NB}" add  "File Four.md"  \
      --title     "Title Four"    \
      --content   "Example Content Four Example Phrase Beta."
  }

  run "${_NB}" search --not "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                 ]]

  [[    "${#lines[@]}"  -eq 1                                                 ]]

  [[    "${lines[0]}"   =~ [.*1.*].*\ Title\ One                              ]]
  [[ -z "${lines[1]}"                                                         ]]
}

@test "'search --and <query1> --and <query2> --not <query3>' lists items matching query1 AND query2 and NOT query3." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"   \
      --title     "Title One"     \
      --content   "Sample Content One Sample Phrase Alpha."

    "${_NB}" add  "File Two.md"   \
      --title     "Title Two"     \
      --content   "Example Content Two Example Phrase Beta."

    "${_NB}" add  "File Three.md" \
      --title     "Title Three"   \
      --content   "Example Content Three Example Phrase Alpha."

    "${_NB}" add  "File Four.md"  \
      --title     "Title Four"    \
      --content   "Example Content Four Example Phrase Beta."
  }

  run "${_NB}" search --and "example" --and "beta" --not "four"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                 ]]

  [[    "${#lines[@]}"  -eq 3                                                 ]]

  [[    "${lines[0]}"   =~ [.*2.*].*\ Title\ Two                              ]]
  [[    "${lines[1]}"   =~  -*-                                               ]]
  [[    "${lines[2]}"   =~  Example.*\ Content\ .*Two.*\ .*Example.*\ Phrase  ]]
}

# AND / OR query options ######################################################

@test "'search <query1> --and <query2> --or <query3>' lists items matching (query1 OR query3) AND (query2 OR query3)." {
  {
    _setup_search
  }

  run "${_NB}" search "one" --and "two" --or "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                       ]]

  [[    "${#lines[@]}"  -eq 7                                                       ]]

  [[    "${lines[0]}"   =~  [.*3.*].*\ .*Title\ Three                               ]]
  [[    "${lines[1]}"   =~  -*-                                                     ]]
  [[    "${lines[2]}"   =~  3.*:.*Example.*\ Content\ Three\ .*Example.*\ Phrase.   ]]

  [[    "${lines[3]}"   =~  [.*2.*].*\ .*Title\ Two                                 ]]
  [[    "${lines[4]}"   =~  -*-                                                     ]]
  [[    "${lines[5]}"   =~  1.*:.*#\ Title\ .*Two                                   ]]
  [[    "${lines[6]}"   =~  3.*:.*Example.*\ Content\ .*Two.*\ .*Example.*\ Phrase. ]]
}

@test "'search --and <query1> --and <query2> --and <query3>' with no matches prints message." {
  {
    "${_NB}" init

    "${_NB}" add  "File Example One.md"   \
      --title     "Title One"             \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "File Example Two.md"   \
      --title     "Title Two"             \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "File Example Three.md" \
      --title     "Title Three"           \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search --add "no match" --add "unmatching" --add "unmatchable"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 1                                                     ]]

  [[    "${#lines[@]}"  -eq 1                                                     ]]

  [[    "${lines[0]}"   =~  \
          Not\ found\ in\ .*home.*:\ .*no\ match\ \+\ unmatching\ \+\ unmatchable ]]

}

@test "'search --and <query1> --and <query2>' lists items matching query1 AND query2 with matching filename." {
  {
    "${_NB}" init

    "${_NB}" add  "File Example One.md"   \
      --title     "Title One"             \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "File Example Two.md"   \
      --title     "Title Two"             \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "File Example Three.md" \
      --title     "Title Three"           \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search --and "one" --and "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                       ]]

  [[    "${#lines[@]}"  -eq 3                                       ]]

  [[    "${lines[0]}"   =~  \
          [.*1.*].*\ .*File\ .*Example.*\ .*One.*.md\ ·\ Title\ One ]]
  [[    "${lines[1]}"   =~  -*-                                     ]]
  [[    "${lines[2]}"   =~  \
          Filename\ Match:.*\ .*File\ .*Example.*\ .*One.*.md       ]]
}

@test "'search --and <query1> --and <query2>' lists items matching query1 AND query2." {
  {
    _setup_search
  }

  run "${_NB}" search --and "example" --and "two"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                 ]]

  [[    "${#lines[@]}"  -eq 4                                                 ]]

  [[    "${lines[0]}"   =~ [.*2.*].*\ Title\ Two                              ]]
  [[    "${lines[1]}"   =~  -*-                                               ]]
  [[    "${lines[2]}"   =~  \#\ Title\ .*Two                                  ]]
  [[    "${lines[3]}"   =~  Example.*\ Content\ .*Two.*\ .*Example.*\ Phrase  ]]
}

@test "'search <query1> --or <query2>' lists items matching query1 OR query2." {
  {
    _setup_search
  }

  run "${_NB}" search "one" --or "two"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                             ]]

  [[    "${#lines[@]}"  -eq 14                                            ]]

  [[    "${lines[0]}"   =~  [.*1.*].*\ .*File\ .*One.*.md\ ·\ Title\ One  ]]
  [[    "${lines[1]}"   =~  -*-                                           ]]
  [[    "${lines[2]}"   =~  Filename\ Match:.*\ .*File\ .*One.*.md        ]]

  [[    "${lines[3]}"   =~  [.*2.*].*\ .*File\ .*Two.*.md\ ·\ Title\ Two  ]]
  [[    "${lines[4]}"   =~  -*-                                           ]]
  [[    "${lines[5]}"   =~  Filename\ Match:.*\ .*File\ .*Two.*.md        ]]

  [[    "${lines[6]}"   =~  Title\ One                                    ]]
  [[    "${lines[7]}"   =~  -*-                                           ]]
  [[    "${lines[8]}"   =~  \#\ Title\ .*One                              ]]
  [[    "${lines[9]}"   =~  Sample\ Content\ .*One.*\ Sample\ Phrase      ]]

  [[    "${lines[10]}"   =~  Title\ Two                                   ]]
  [[    "${lines[11]}"  =~  -*-                                           ]]
  [[    "${lines[12]}"   =~  \#\ Title\ .*Two                             ]]
  [[    "${lines[13]}"  =~  Example\ Content\ .*Two.*\ Example\ Phrase    ]]
}

# AND / OR query arguments ####################################################

@test "'search <query1> <query2> <query3>' with no matches prints message." {
  {
    "${_NB}" init

    "${_NB}" add  "File Example One.md"   \
      --title     "Title One"             \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "File Example Two.md"   \
      --title     "Title Two"             \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "File Example Three.md" \
      --title     "Title Three"           \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search "no match" "unmatching" "unmatchable"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 1                                                     ]]

  [[    "${#lines[@]}"  -eq 1                                                     ]]

  [[    "${lines[0]}"   =~  \
          Not\ found\ in\ .*home.*:\ .*no\ match\ \+\ unmatching\ \+\ unmatchable ]]

}

@test "'search <query1> <query2>' lists items matching query1 AND query2 with matching filename." {
  {
    "${_NB}" init

    "${_NB}" add  "File Example One.md"   \
      --title     "Title One"             \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "File Example Two.md"   \
      --title     "Title Two"             \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "File Example Three.md" \
      --title     "Title Three"           \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search "one" "example"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                       ]]

  [[    "${#lines[@]}"  -eq 3                                       ]]

  [[    "${lines[0]}"   =~  \
          [.*1.*].*\ .*File\ .*Example.*\ .*One.*.md\ ·\ Title\ One ]]
  [[    "${lines[1]}"   =~  -*-                                     ]]
  [[    "${lines[2]}"   =~  \
          Filename\ Match:.*\ .*File\ .*Example.*\ .*One.*.md       ]]
}

@test "'search <query1> <query2>' lists items matching query1 AND query2." {
  {
    _setup_search
  }

  run "${_NB}" search "example" "two"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                                 ]]

  [[    "${#lines[@]}"  -eq 4                                                 ]]

  [[    "${lines[0]}"   =~ [.*2.*].*\ Title\ Two                              ]]
  [[    "${lines[1]}"   =~  -*-                                               ]]
  [[    "${lines[2]}"   =~  \#\ Title\ .*Two                                  ]]
  [[    "${lines[3]}"   =~  Example.*\ Content\ .*Two.*\ .*Example.*\ Phrase  ]]
}

@test "'search <query1|query2>' lists items matching query1 OR query2." {
  {
    _setup_search
  }

  run "${_NB}" search "one|two"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                                             ]]

  [[    "${#lines[@]}"  -eq 14                                            ]]

  [[    "${lines[0]}"   =~  [.*1.*].*\ .*File\ .*One.*.md\ ·\ Title\ One  ]]
  [[    "${lines[1]}"   =~  -*-                                           ]]
  [[    "${lines[2]}"   =~  Filename\ Match:.*\ .*File\ .*One.*.md        ]]

  [[    "${lines[3]}"   =~  [.*2.*].*\ .*File\ .*Two.*.md\ ·\ Title\ Two  ]]
  [[    "${lines[4]}"   =~  -*-                                           ]]
  [[    "${lines[5]}"   =~  Filename\ Match:.*\ .*File\ .*Two.*.md        ]]

  [[    "${lines[6]}"   =~  Title\ One                                    ]]
  [[    "${lines[7]}"   =~  -*-                                           ]]
  [[    "${lines[8]}"   =~  \#\ Title\ .*One                              ]]
  [[    "${lines[9]}"   =~  Sample\ Content\ .*One.*\ Sample\ Phrase      ]]

  [[    "${lines[10]}"   =~  Title\ Two                                   ]]
  [[    "${lines[11]}"  =~  -*-                                           ]]
  [[    "${lines[12]}"   =~  \#\ Title\ .*Two                             ]]
  [[    "${lines[13]}"  =~  Example\ Content\ .*Two.*\ Example\ Phrase    ]]
}
