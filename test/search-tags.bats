#!/usr/bin/env bats

load test_helper

# tags ########################################################################

@test "'search -t tag1 --and -t tag2,'#tag3' exits with status 0 and prints matches as an AND query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag3 #tag1"
  }

  run "${_NB}" search -t tag1 --and -t tag2,'#tag3'

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                             ]]
  [[    "${#lines[@]}"  -eq 3                                             ]]

  [[    "${lines[0]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ \·\ \"Content\ #tag2\ Seven.\ #tag3\ #tag1\" ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$                      ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag3.*\ .*#tag1                      ]]
}

@test "'search -t tag1 --or -t tag2,'#tag3' exits with status 0 and prints matches as an OR query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag1"
  }

  run "${_NB}" search -t tag1 --or -t tag2,'#tag3'

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 18                                    ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ #tag1\ four.\ #tag2\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag1.*\ four.\ .*#tag2                          ]]

  [[    "${lines[3]}"   =~  \
.*[.*1.*].*\ File\ One.md\ ·\ \"Content\ one.\ #tag3\"            ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ one.\ .*#tag3                                      ]]

  [[    "${lines[6]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ ·\ \"Content\ #tag2\ Seven.\ #tag1\" ]]
  [[    "${lines[7]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[8]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag1                         ]]

  [[    "${lines[9]}"   =~  \
.*[.*6.*].*\ File\ Six.md\ ·\ \"Content\ six.\ #tag2\"            ]]
  [[    "${lines[10]}"  =~  ^.*------------------.*$              ]]
  [[    "${lines[11]}"  =~  \
1.*:.*Content\ six.\ .*#tag2                                      ]]

  [[    "${lines[12]}"  =~  \
.*[.*3.*].*\ File\ Three.md\ ·\ \"Content\ three.\ tag1\ #tag2\"  ]]
  [[    "${lines[13]}"  =~  ^.*------------------.*$              ]]
  [[    "${lines[14]}"  =~  \
1.*:.*Content\ three.\ tag1\ .*#tag2                              ]]

  [[    "${lines[15]}"  =~  \
.*[.*2.*].*\ File\ Two.md\ ·\ \"Content\ two.\ #tag1\"            ]]
  [[    "${lines[16]}"  =~  ^.*------------------.*$              ]]
  [[    "${lines[17]}"  =~  \
1.*:.*Content\ two.\ .*#tag1                                      ]]
}

@test "'search -t tag1 --or --tags tag2 exits with status 0 and prints matches as an OR query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one.   #tag3"
    "${_NB}" add "File Two.md"    --content "Content two.   #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1"
    "${_NB}" add "File Four.md"   --content "Content four.  #tag1"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six.   #tag2"
  }

  run "${_NB}" search -t tag1 --or --tags tag2

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                 ]]
  [[    "${#lines[@]}"  -eq 9                                 ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ four.\ \ #tag1\"   ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$          ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ four.\ \ .*#tag1                               ]]
  [[    "${lines[3]}"   =~  \
.*[.*6.*].*\ File\ Six.md\ ·\ \"Content\ six.\ \ \ #tag2\"    ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$          ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ six.\ \ .*#tag2                                ]]
  [[    "${lines[6]}"   =~  \
.*[.*2.*].*\ File\ Two.md\ ·\ \"Content\ two.\ \ \ #tag1\"    ]]
  [[    "${lines[7]}"   =~  ^.*------------------.*$          ]]
  [[    "${lines[8]}"   =~  \
1.*:.*Content\ two.\ \ .*#tag1                                ]]
}

@test "'search -t tag1 -t tag2 exits with status 0 and prints matches as an AND query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag1"
  }

  run "${_NB}" search -t tag1 -t tag2

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 6                                     ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ #tag1\ four.\ #tag2\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag1.*\ four.\ .*#tag2                          ]]
  [[    "${lines[3]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ ·\ \"Content\ #tag2\ Seven.\ #tag1\" ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag1                         ]]
}

@test "'search --tags tag1,'#tag2' exits with status 0 and prints matches as an AND query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag1"
  }

  run "${_NB}" search --tags tag1,'#tag2'

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 6                                     ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ #tag1\ four.\ #tag2\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag1.*\ four.\ .*#tag2                          ]]
  [[    "${lines[3]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ ·\ \"Content\ #tag2\ Seven.\ #tag1\" ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag1                         ]]
}

@test "'search --tag \"tag1\" --tag \"tag2\"' (no #) exits with status 0 and prints matches as an AND query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag1"
  }

  run "${_NB}" search --tag "tag1" --tag "tag2"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 6                                     ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ #tag1\ four.\ #tag2\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag1.*\ four.\ .*#tag2                          ]]
  [[    "${lines[3]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ ·\ \"Content\ #tag2\ Seven.\ #tag1\" ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag1                         ]]
}

@test "'search --tag \"#tag1\" --tag \"#tag2\"' (yes #) exits with status 0 and prints matches as an AND query." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. #tag3"
    "${_NB}" add "File Two.md"    --content "Content two. #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
    "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
    "${_NB}" add "File Five.md"   --content "Content five."
    "${_NB}" add "File Six.md"    --content "Content six. #tag2"
    "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag1"
  }

  run "${_NB}" search --tag "#tag1" --tag "#tag2"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                     ]]
  [[    "${#lines[@]}"  -eq 6                                     ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ #tag1\ four.\ #tag2\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ .*#tag1.*\ four.\ .*#tag2                          ]]
  [[    "${lines[3]}"   =~  \
.*[.*7.*].*\ File\ Seven.md\ ·\ \"Content\ #tag2\ Seven.\ #tag1\" ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$              ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ .*#tag2.*\ Seven.\ .*#tag1                         ]]
}

@test "'search --tag \"tag\"' (no #) exits with status 0 and prints matches." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one.   #tag3"
    "${_NB}" add "File Two.md"    --content "Content two.   #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1"
    "${_NB}" add "File Four.md"   --content "Content four.  #tag1"
    "${_NB}" add "File Five.md"   --content "Content five.  #tag2"
    "${_NB}" add "File Six.md"    --content "Content six.   #tag2"
  }

  run "${_NB}" search --tag "tag1"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 6                               ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ four.\ \ #tag1\" ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ four.\ \ .*#tag1                             ]]
  [[    "${lines[3]}"   =~  \
.*[.*2.*].*\ File\ Two.md\ ·\ \"Content\ two.\ \ \ #tag1\"  ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ two.\ \ .*#tag1                              ]]
}

@test "'search --tag \"#tag\"' (yes #) exits with status 0 and prints matches." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one.   #tag3"
    "${_NB}" add "File Two.md"    --content "Content two.   #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1"
    "${_NB}" add "File Four.md"   --content "Content four.  #tag1"
    "${_NB}" add "File Five.md"   --content "Content five.  #tag2"
    "${_NB}" add "File Six.md"    --content "Content six.   #tag2"
  }

  run "${_NB}" search --tag "#tag1"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 6                               ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ four.\ \ #tag1\" ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ four.\ \ .*#tag1                             ]]
  [[    "${lines[3]}"   =~  \
.*[.*2.*].*\ File\ Two.md\ ·\ \"Content\ two.\ \ \ #tag1\"  ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ two.\ \ .*#tag1                              ]]
}

@test "'search \"#tag\"' exits with status 0 and prints matches." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one.   #tag3"
    "${_NB}" add "File Two.md"    --content "Content two.   #tag1"
    "${_NB}" add "File Three.md"  --content "Content three. tag1"
    "${_NB}" add "File Four.md"   --content "Content four.  #tag1"
    "${_NB}" add "File Five.md"   --content "Content five.  #tag2"
    "${_NB}" add "File Six.md"    --content "Content six.   #tag2"
  }

  run "${_NB}" search "#tag1"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                               ]]
  [[    "${#lines[@]}"  -eq 6                               ]]

  [[    "${lines[0]}"   =~  \
.*[.*4.*].*\ File\ Four.md\ \·\ \"Content\ four.\ \ #tag1\" ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ four.\ \ .*#tag1                             ]]
  [[    "${lines[3]}"   =~  \
.*[.*2.*].*\ File\ Two.md\ ·\ \"Content\ two.\ \ \ #tag1\"  ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$        ]]
  [[    "${lines[5]}"   =~  \
1.*:.*Content\ two.\ \ .*#tag1                              ]]
}
