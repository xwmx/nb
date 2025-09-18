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

_search_all_setup() {
  _setup_search

  "${_NB}" notebooks add one
  "${_NB}" use one

  "${_NB}" add  "example.md"    \
    --title     "Example Title" \
    --content   "Example Phrase"

  "${_NB}" notebooks add two
  "${_NB}" use two

  "${_NB}" add  "example.md"    \
    --title     "Example Title" \
    --content   "Example Phrase"

  "${_NB}" notebooks archive two

  [[ -e "${NB_DIR}/two/.archived" ]]
}

# --replace ###################################################################

# TODO
# @test "'search <pattern> --replace <replacement>' exits with status 0 and replaces <pattern> with <replacement>." {
#   {
#     "${_NB}" init

#     "${_NB}" add "File One.md"    --content "Content one. #tag3"
#     "${_NB}" add "File Two.md"    --content "Content two. #tag1"
#     "${_NB}" add "File Three.md"  --content "Content three. tag1 #tag2"
#     "${_NB}" add "File Four.md"   --content "Content #tag1 four. #tag2"
#     "${_NB}" add "File Five.md"   --content "Content tag2 five."
#     "${_NB}" add "File Six.md"    --content "Content six. #tag2"
#     "${_NB}" add "File Seven.md"  --content "Content #tag2 Seven. #tag3 #tag1"
#   }

#   run "${_NB}" search \#tag2 --replace \#example

#   printf "\${status}:   '%s'\\n" "${status}"
#   printf "\${output}:   '%s'\\n" "${output}"
#   printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

#   [[    "${status}"     -eq 0             ]]

#   # TODO


#   # updates files

#   diff                                    \
#     <(cat "${NB_DIR}/home/File One.md")   \
#     <(printf "Content one. #tag3")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Two.md")   \
#     <(printf "Content two. #tag1")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Three.md") \
#     <(printf "Content three. tag1 #example")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Four.md")  \
#     <(printf "Content #tag1 four. #example")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Five.md")  \
#     <(printf "Content tag2 five.")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Six.md")   \
#     <(printf "Content six. #example")

#   diff                                    \
#     <(cat "${NB_DIR}/home/File Seven.md") \
#     <(printf "Content #example Seven. #tag3 #tag1")
# }

# encoding ####################################################################

@test "'search <query>' with non-ASCII filename and query succeeds." {
  {
    "${_NB}" init

    # NOTE: filename is in decomposed format for normalization testing.
    "${_NB}" add            \
        --content   "#тест" \
        --filename  "тестовый.md"
  }

  run "${_NB}" search "#тест"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                         ]]

  [[    "${#lines[@]}"  -eq 3                         ]]

  [[    "${lines[0]}"   =~  .*[.*1.*].*\ тестовый.md  ]]
  [[    "${lines[1]}"   =~  -*-                       ]]
  [[    "${lines[2]}"   =~  1.*:.*\#тест              ]]
}

# --type <type> ###############################################################

@test "'search <query> --type note' only searches items of type note." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
        --content   "# Example File One Content"    \
        --filename  "File One.md"

    "${_NB}" add                                    \
        --content   "<http://example.test/>"        \
        --filename  "File Two.bookmark.md"

    "${_NB}" add                                    \
        --content   "# Example File Three Content"  \
        --filename  "File Three.md"

    "${_NB}" add                                    \
        --content   "<http://example.test/>"        \
        --filename  "File Four.bookmark.md"
  }

  run "${_NB}" search "example" --type note

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  # printf "\${lines[0]}: '%s'\\n" "${lines[0]}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                       ]]

  [[    "${#lines[@]}"  -eq 6                       ]]

  [[    "${lines[0]}"   =~  Example\ File\ One      ]]
  [[    "${lines[1]}"   =~  -*-                     ]]
  [[    "${lines[2]}"   =~  Example.*\ File\ One    ]]

  [[ !  "${output}"     =~ example.*\.test          ]]
}

@test "'search <query> --type text' only searches items of type text." {
  {
    "${_NB}" init

    "${_NB}" add                                    \
        --content   "# Example File One Content"    \
        --filename  "File One.md"

    "${_NB}" add                                    \
        --content   "<http://example.test/>"        \
        --filename  "File Two.bookmark.md"

    "${_NB}" add                                    \
        --content   "# Example File Three Content"  \
        --filename  "File Three.md"

    "${_NB}" add                                    \
        --content   "<http://example.test/>"        \
        --filename  "File Four.bookmark.md"
  }

  run "${_NB}" search "example" --type text

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  # printf "\${lines[0]}: '%s'\\n" "${lines[0]}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                       ]]

  [[    "${#lines[@]}"  -eq 12                      ]]

  [[    "${lines[0]}"   =~  File\ Four.bookmark.md  ]]
  [[    "${lines[1]}"   =~  -*-                     ]]
  [[    "${lines[2]}"   =~  example.*\.test         ]]
}

@test "'search <query> --type <type>' only searches items of type <type>." {
  {
    _setup_search

    "${_NB}" rename "File Two.md" --to-todo --force
  }

  run "${_NB}" search "example" --type todo

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                             ]]

  [[    "${#lines[@]}"  -eq 3                                             ]]

  [[    "${lines[0]}"   =~  Title\ Two                                    ]]
  [[    "${lines[1]}"   =~  -*-                                           ]]
  [[    "${lines[2]}"   =~  Example.*\ Content\ Two\ .*Example.*\ Phrase  ]]
}

# filename handling ###########################################################

@test "'search <query>' with uncommon filename exits with status 0 and prints output." {
  {
    _setup_search

    "${_NB}" rename "File One.md" "File [] One.md"  --force
    "${_NB}" rename "File Two.md" "File ] Two.md"   --force
  }

  run "${_NB}" search "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  File\ \[\]\ One.md                      ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

# temporary files #############################################################

@test "'search' skips common temporary files." {
  {
    "${_NB}" init

    "${_NB}" add "File One.md"    --content "Content one. example-query"
    "${_NB}" add "File Two.md"    --content "Content two. sample-query"

    declare _temp_filenames=(
      "Example Temp One.md~"
      "#Example Temp Two.md#"
      "Example Temp Three.md.swp"
      "Example Temp Four.md.swap"
      ".#Example Temp Five.md"
    )

    declare __filename=
    for     __filename in "${_temp_filenames[@]:-}"
    do
      printf "sample-query\\n" >> "${NB_DIR}/home/${__filename:-}"
    done
  }

  run "${_NB}" search "sample-query"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                   ]]
  [[    "${#lines[@]}"  -eq 3                                   ]]

  [[    "${lines[0]}"   =~  \
.*[.*2.*].*\ File\ Two.md\ \·\ \"Content\ two.\ sample-query\"  ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$            ]]
  [[    "${lines[2]}"   =~  \
1.*:.*Content\ two.\ .*sample-query                             ]]
}

# binary ######################################################################

@test "'search <query>' prints single match message when matching binary content." {
  {
    "${_NB}" init
    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/example.pdf"
  }

  run "${_NB}" search "a"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0                                       ]]
  [[    "${#lines[@]}"  -eq 6                                       ]]

  [[    "${lines[0]}"   =~  .*\[.*1.*\].*\ 📄\ .*ex.*a.*mple.pdf    ]]
  [[    "${lines[1]}"   =~  ^.*------------------.*$                ]]
  [[    "${lines[2]}"   =~  Filename\ Match:.*\ .*ex.*a.*mple.pdf   ]]
  [[    "${lines[3]}"   =~  .*\[.*1.*\].*\ 📄\ .*ex.*a.*mple.pdf    ]]
  [[    "${lines[4]}"   =~  ^.*------------------.*$                ]]
  [[    "${lines[5]}"   =~  Binary\ file\ matches.                  ]]
  [[ -z "${lines[6]}"                                               ]]
}

# `search` ####################################################################

@test "'search' with no arguments exits with status 1 and prints help information." {
  {
    _setup_search
  }

  run "${_NB}" search

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1           ]]

  [[ "${lines[0]}"  =~  Usage.*\:   ]]
  [[ "${lines[1]}"  =~  nb\ search  ]]
}

# notebook: selectors #########################################################

@test "'search <query> --notebook-selectors' includes notebook selectors for results in the current notebook." {
  {
    "${_NB}" init

    "${_NB}" add "Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Two.md" --content "Example content."

    "${_NB}" add "Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Sample Folder/Sample Two.md" --content "Sample 123 content."
  }

  run "${_NB}" search "123" -l --notebook-selectors

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  \
.*\[.*home:1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"  ]]

  [[    "${lines[1]}" =~  \
.*\[.*home:Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\" ]]
}

@test "'search <query>' does not include notebook selectors for results in the current notebook." {
  {
    "${_NB}" init

    "${_NB}" add "Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Two.md" --content "Example content."

    "${_NB}" add "Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Sample Folder/Sample Two.md" --content "Sample 123 content."
  }

  run "${_NB}" search "123" -l

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  \
.*\[.*1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"       ]]
  [[ !  "${lines[0]}" =~  \
.*\[.*home:1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"  ]]

  [[    "${lines[1]}" =~  \
.*\[.*Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\"      ]]
  [[ !  "${lines[1]}" =~  \
.*\[.*home:Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\" ]]
}

@test "'search notebook: <query> --notebook-selectors' includes notebook selectors for results in selected notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Notebook:Example Two.md" --content "Example content."

    "${_NB}" add "Example Notebook:Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Example Notebook:Sample Folder/Sample Two.md" --content "Sample 123 content."
  }

  run "${_NB}" Example\ Notebook:search "123" -l --notebook-selectors

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  \
.*\[.*1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"       ]]
  [[ !  "${lines[0]}" =~  \
.*\[.*home:1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"  ]]

  [[    "${lines[1]}" =~  \
.*\[.*Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\"      ]]
  [[ !  "${lines[1]}" =~  \
.*\[.*home:Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\" ]]
}

@test "'search notebook: <query>' includes notebook selectors for results in selected notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Notebook:Example Two.md" --content "Example content."

    "${_NB}" add "Example Notebook:Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Example Notebook:Sample Folder/Sample Two.md" --content "Sample 123 content."
  }

  run "${_NB}" Example\ Notebook:search "123" -l

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"               ]]
  [[    "${lines[1]}" =~  \
.*\[.*Example\ Notebook:Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\"  ]]
}

@test "'search <query> -la' includes notebook selectors for all results." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add "Example Notebook:Example One.md" --content "Example 123 content."
    "${_NB}" add "Example Notebook:Example Two.md" --content "Example content."

    "${_NB}" add "Example Notebook:Sample Folder/Sample One.md" --content "Sample content."
    "${_NB}" add "Example Notebook:Sample Folder/Sample Two.md" --content "Sample 123 content."


    "${_NB}" add "Demo One.md" --content "Demo 123 content."
    "${_NB}" add "Demo Two.md" --content "Demo content."

    "${_NB}" add "Test Folder/Test One.md" --content "Test content."
    "${_NB}" add "Test Folder/Test Two.md" --content "Test 123 content."
  }

  run "${_NB}" search "123" -la

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0 ]]

  [[    "${lines[0]}" =~  \
.*\[.*Example\ Notebook:1.*\].*\ Example\ One.md\ ·\ \"Example\ 123\ content.\"               ]]
  [[    "${lines[1]}" =~  \
.*\[.*Example\ Notebook:Sample\ Folder/2.*\].*\ Sample\ Two.md\ ·\ \"Sample\ 123\ content.\"  ]]
  [[    "${lines[2]}" =~  \
.*\[.*home:1.*\].*\ Demo\ One.md\ ·\ \"Demo\ 123\ content.\"              ]]
  [[    "${lines[3]}" =~  \
.*\[.*home:Test\ Folder/2.*\].*\ Test\ Two.md\ ·\ \"Test\ 123\ content.\" ]]
}

# aliases #####################################################################

@test "'q <query>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" q "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  \.md                                    ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

@test "'grep <query>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" grep "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  \.md                                    ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

# `search <no match>` #########################################################

@test "'search <query>' with no matches exits with status 1 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search "no match"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                       ]]
  [[ "${#lines[@]}" -eq 1                                       ]]

  [[ "${lines[0]}"  =~  Not\ found\ in.*home.*:\ .*no\ match.*  ]]
}

@test "'search <query>...' with no matches exits with status 1 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search "no match" "matchless" "wont be found"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                                               ]]
  [[ "${#lines[@]}" -eq 1                                               ]]

  [[ "${lines[0]}"  =~  \
        Not\ found\ in.*home.*:\ .*no\ match|matchless|wont\ be\ found  ]]
}

# `search <one match> [--path] [--list]` ######################################

@test "'search <one match>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  \.md                                    ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

@test "'search <one match>' includes emoji indicator." {
  {
    _setup_search

    "${_NB}" add                            \
      --filename  "example.bookmark.md"     \
      --content   "<http://example.test/>"  \
      --title     "Example Title"
  }

  run "${_NB}" search "example.test" --no-color

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                   ]]

  [[ !  "${lines[0]}" =~  example.bookmark.md ]]
  [[    "${lines[0]}" =~  Example\ Title      ]]
  [[    "${lines[0]}" =~  \]\ 🔖              ]]
  [[    "${lines[1]}" =~  -*-                 ]]
  [[    "${lines[2]}" =~  example.test        ]]
}

@test "'search <one match> --path' exits with status 0 and prints path." {
  {
    _setup_search
  }

  run "${_NB}" search "sample phrase" --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${lines[0]}"  =~  ${NB_DIR}/home/File\ One\.md  ]]
  [[ "${#lines[@]}" -eq 1                             ]]
}

@test "'search <one match> --list' exits with status 0 and prints listing." {
  {
    _setup_search
  }

  run "${_NB}" search "sample phrase" --list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"     -eq 0                           ]]

  [[ !  "${lines[0]}"   =~  \.md                        ]]
  [[    "${lines[0]}"   =~  [.*1.*].*\ Title\ One       ]]

  [[    "${#lines[@]}"  -eq 1                           ]]
}

@test "'search <one filename match>' exits with status 0 and prints output." {
  {
    "${_NB}" init

    "${_NB}" add  "1-example.md"  \
      --title     "One"           \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "sample.md"     \
      --title     "Two"           \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "third.md"      \
      --title     "Three"         \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search '1-example.md'

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ "${status}"    -eq 0                                   ]]

  [[ "${lines[0]}"  =~  [.*1.*].*\ .*1-example.md.*\ ·\ One ]]
  [[ "${lines[1]}"  =~  -*-                                 ]]
  [[ "${lines[2]}"  =~  Filename\ Match:\ .*1-example.md    ]]
}

# -q / --query option #########################################################

@test "'search -q <query>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search -q "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  \.md                                    ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

@test "'search --query <query>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search --query "sample phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                                       ]]

  [[ !  "${lines[0]}" =~  \.md                                    ]]
  [[    "${lines[0]}" =~  Title\ One                              ]]
  [[    "${lines[1]}" =~  -*-                                     ]]
  [[    "${lines[2]}" =~  Sample\ Content\ One\ .*Sample\ Phrase  ]]
}

# `search` spacing and alignment ##############################################

@test "'search --list' / 'search -l' includes extra spacing to align with max notebook id length." {
  {
    _setup_search

    "${_NB}" add                            \
      --filename  "example-1.bookmark.md"   \
      --content   "<http://example.test/>"  \
      --title     "Example Title One"

    for ((_i=0; _i < 11; _i++))
    do
      "${_NB}" add "note ${_i}"
    done

    "${_NB}" add                            \
      --filename  "example-2.bookmark.md"   \
      --content   "<http://example.test/>"  \
      --title     "Example Title Two"
  }

  run "${_NB}" search "example.test" --no-color --list

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}" -eq 0                             ]]

  [[    "${output}" =~  \]\ 🔖\ Example\ Title\ Two   ]]
  [[    "${output}" =~  \]\ \ 🔖\ Example\ Title\ One ]]

  [[ !  "${output}" =~  bookmark.md                   ]]
}

@test "'search' (no '--list' / '-l') does not include extra spacing." {
  {
    _setup_search

    "${_NB}" add                            \
      --filename  "example-1.bookmark.md"   \
      --content   "<http://example.test/>"  \
      --title     "Example Title One"

    for ((_i=0; _i < 11; _i++))
    do
      "${_NB}" add "note ${_i}"
    done

    "${_NB}" add                            \
      --filename  "example-2.bookmark.md"   \
      --content   "<http://example.test/>"  \
      --title     "Example Title Two"
  }

  run "${_NB}" search "example.test" --no-color

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"   -eq 0                           ]]

  [[    "${output}"   =~  \]\ 🔖\ Example\ Title\ Two ]]

  [[    "${lines[1]}" =~  -*-                         ]]
  [[    "${lines[2]}" =~  example.test                ]]

  [[    "${output}"   =~  \]\ 🔖\ Example\ Title\ One ]]
  [[ !  "${output}"   =~  \]\ \ 🔖                    ]]

  [[    "${lines[4]}" =~  -*-                         ]]
  [[    "${lines[5]}" =~  example.test                ]]
}

# `search <multiple matches> [--path] [--list]` ###############################

@test "'search <multiple matches>' exits with status 0 and prints output." {
  {
    _setup_search
  }

  run "${_NB}" search "example phrase"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[    "${status}"   -eq 0                       ]]

  [[ !  "${lines[0]}" =~  \.md                    ]]
  [[    "${lines[0]}" =~  Title\ Two|Title\ Three ]]
  [[    "${lines[1]}" =~  -*-                     ]]
  [[    "${lines[2]}" =~  Example\ Phrase         ]]

  [[ !  "${lines[3]}" =~  \.md                    ]]
  [[    "${lines[3]}" =~  Title\ Two|Title\ Three ]]
  [[    "${lines[4]}" =~  -*-                     ]]
  [[    "${lines[5]}" =~  Example\ Phrase         ]]

  [[    "${lines[0]}" !=  "${lines[3]}"           ]]
}

@test "'search <multiple matches> --path' exits with 0 and prints paths." {
  {
    _setup_search
  }

  run "${_NB}" search "example phrase" --path

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ "${status}"    -eq 0                               ]]

  [[ "${output}"    =~  ${NB_DIR}/home/File\ Two\.md    ]]
  [[ "${output}"    =~  ${NB_DIR}/home/File\ Three\.md  ]]

  [[ "${#lines[@]}" -eq 2                               ]]
}

@test "'search <multiple matches> --list' exits with 0 and prints listings." {
  {
    _setup_search
  }

  run "${_NB}" search "example phrase" --list

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[    "${status}"     -eq 0             ]]

  [[ !  "${output}"     =~  \.md          ]]
  [[    "${output}"     =~  Title\ Two    ]]
  [[    "${output}"     =~  Title\ Three  ]]

  [[    "${#lines[@]}"  -eq 2             ]]
}

@test "'search <multiple filename match>' exits with status 0 and prints output." {
  {
    "${_NB}" init

    "${_NB}" add  "1-example.md"  \
      --title     "Title One"     \
      --content   "Sample Content One Sample Phrase."

    "${_NB}" add  "sample.md"     \
      --title     "Title Two"     \
      --content   "Example Content Two Example Phrase."

    "${_NB}" add  "2-example.md"  \
      --title     "Title Three"   \
      --content   "Example Content Three Example Phrase."
  }

  run "${_NB}" search "example.md"

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ "${status}"    -eq 0               ]]

  [[ "${lines[0]}"  =~  example.md      ]]
  [[ "${lines[0]}"  =~  1               ]]
  [[ "${lines[0]}"  =~  Title\ One      ]]
  [[ "${lines[1]}"  =~  -*-             ]]
  [[ "${lines[2]}"  =~  Filename\ Match ]]
  [[ "${lines[2]}"  =~  example.md      ]]
  [[ "${lines[2]}"  =~  1               ]]

  [[ "${lines[3]}"  =~  example.md      ]]
  [[ "${lines[3]}"  =~  2               ]]
  [[ "${lines[3]}"  =~  Title\ Three    ]]
  [[ "${lines[4]}"  =~  -*-             ]]
  [[ "${lines[5]}"  =~  Filename\ Match ]]
  [[ "${lines[5]}"  =~  example.md      ]]
  [[ "${lines[5]}"  =~  2               ]]
}

@test "'search' output includes indicators." {
  {
    _setup_search

  cat <<HEREDOC | "${_NB}" add "fourth.bookmark.md"
# Bookmark Title

<https://example.com/>

demo phrase
HEREDOC
  }

  run "${_NB}" search "demo phrase"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${lines[3]}:   '%s'\\n"  "${lines[3]}"

  [[    "${status}"   -eq 0                   ]]

  [[    "${output}"   =~  🔖\ Bookmark\ Title ]]
}

# `search --bookmarks` #################################################

@test "'search --bookmarks' exits with status 0 and prints output." {
  {
    _setup_search

  cat <<HEREDOC | "${_NB}" add "fourth.bookmark.md"
# four

<https://example.com/>

Example Phrase
HEREDOC
  cat <<HEREDOC | "${_NB}" add "fifth.bookmark.md"
# five

<https://example.com/>

Sample Phrase
HEREDOC
  cat <<HEREDOC | "${_NB}" add "sixth.bookmark.md"
# six

<https://example.com/>

Example Phrase
HEREDOC
    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search "example phrase" --bookmarks

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${_filename}:  '%s'\\n" "${_filename}"
  printf "\${lines[3]}:   '%s'\\n"  "${lines[3]}"

  [[    "${status}"   -eq 0                     ]]

  [[ !  "${lines[0]}" =~  \.md                  ]]
  [[    "${lines[0]}" =~  four|six              ]]
  [[    "${lines[1]}" =~  -*-                   ]]
  [[    "${lines[2]}" =~  Example\ Phrase       ]]

  [[ !  "${lines[3]}" =~  \.md                  ]]
  [[    "${lines[3]}" =~  four|six              ]]
  [[    "${lines[4]}" =~  -*-                   ]]
  [[    "${lines[5]}" =~  Example\ Phrase       ]]

  [[    "${lines[0]}" != "${lines[3]}"          ]]
}

# `search <query> --all [--path]` #############################################

@test "'search <query> --all' exits with status 0 and prints output." {
  {
    _search_all_setup
  }

  run "${_NB}" search "example phrase" --all

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"
  "${_NB}" notebooks --paths --unarchived
  "${_NB}" notebooks --paths --unarchived
  "${_NB}" two:notebooks status

  [[    "${status}"     -eq 0                             ]]

  [[ !  "${output}"     =~  \.md                          ]]

  [[    "${output}"     =~  [.*home:3.*].*\ Title\ Three  ]]
  [[    "${lines[1]}"   =~  -*-                           ]]
  [[    "${lines[2]}"   =~  Example\ Phrase               ]]

  [[    "${output}"     =~  [.*home:2.*].*\ Title\ Two    ]]
  [[    "${lines[4]}"   =~  -*-                           ]]
  [[    "${lines[5]}"   =~  Example\ Phrase               ]]

  [[    "${output}"     =~  [.*one:1.*].*\ Example\ Title ]]
  [[    "${lines[7]}"   =~  -*-                           ]]
  [[    "${lines[8]}"   =~  Example\ Phrase               ]]

  [[    "${#lines[@]}"  -eq 9                             ]]
}

@test "'search <query> -a' exits with status 0 and prints output." {
  {
    _search_all_setup
  }

  run "${_NB}" search "example phrase" -a

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                             ]]

  [[ !  "${output}"     =~  \.md                          ]]

  [[    "${output}"     =~  [.*home:3.*].*\ Title\ Three  ]]
  [[    "${lines[1]}"   =~  -*-                           ]]
  [[    "${lines[2]}"   =~  Example\ Phrase               ]]

  [[    "${output}"     =~  [.*home:2.*].*\ Title\ Two    ]]
  [[    "${lines[4]}"   =~  -*-                           ]]
  [[    "${lines[5]}"   =~  Example\ Phrase               ]]

  [[    "${output}"     =~  [.*one:1.*].*\ Example\ Title ]]
  [[    "${lines[7]}"   =~  -*-                           ]]
  [[    "${lines[8]}"   =~  Example\ Phrase               ]]

  [[    "${#lines[@]}"  -eq 9                             ]]
}

@test "'search <no matching query> --all' exits with status 1 and prints output." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NB}" search 'no match' --all

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ "${status}"  -eq 1                 ]]

  [[ "${output}"  =~  Not\ found        ]]
  [[ "${output}"  =~  in\ any\ notebook ]]
  [[ "${output}"  =~  no\ match         ]]
}

@test "'search <multiple matches> --all --path' exits with 0 and prints paths." {
  {
    _search_all_setup
  }

  run "${_NB}" search "example phrase" --all --path

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ "${status}"    -eq 0                             ]]

  [[ "${#lines[@]}" -eq 3                             ]]

  [[ "${output}"    =~  ${NB_DIR}/home/File\ Three.md ]]
  [[ "${output}"    =~  ${NB_DIR}/home/File\ Two.md   ]]
  [[ "${output}"    =~  ${NB_DIR}/one/example.md      ]]
}

@test "'search <no matching query> --all --path' exits with 1 and and prints output." {
  {
    _search_all_setup
  }

  run "${_NB}" search "no match" --all --path

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ "${status}"  -eq 1                 ]]

  [[ "${output}"  =~  Not\ found        ]]
  [[ "${output}"  =~  in\ any\ notebook ]]
  [[ "${output}"  =~  no\ match         ]]
}

# `search <query> [--all]` local ##############################################

@test "'search <query>' in local notebook exits with status 0 and prints output." {
  {
    _search_all_setup

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    "${_NB}" add  "example-1.md"      \
      --title     "Example Title One" \
      --content   "Example Phrase"

    "${_NB}" add  "example-2.md"      \
      --title     "Example Title Two"
  }

  run "${_NB}" search "example phrase"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[    "${status}"     -eq 0                   ]]

  [[    "${lines[0]}"   =~  1                   ]]
  [[ !  "${lines[0]}"   =~  example-1.md        ]]
  [[    "${lines[0]}"   =~  Example\ Title\ One ]]
  [[    "${lines[1]}"   =~  -*-                 ]]
  [[    "${lines[2]}"   =~  Example\ Phrase     ]]

  [[    "${#lines[@]}"  -eq 3                   ]]
}

@test "'search <query> --all' in local notebook exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null
    "${_NB}" notebooks init "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    "${_NB}" add  "example-1.md"    \
      --title     "Local Title One" \
      --content   "Example Phrase"

    "${_NB}" add  "example-2.md"    \
      --title     "Local Title Two"
  }

  run "${_NB}" search "example phrase" --all

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"
  printf "\${lines[0]}:   '%s'\\n" "${lines[0]}"
  printf "\${lines[1]}:   '%s'\\n" "${lines[1]}"
  printf "\${lines[2]}:   '%s'\\n" "${lines[2]}"
  printf "\${lines[3]}:   '%s'\\n" "${lines[3]}"
  printf "\${lines[4]}:   '%s'\\n" "${lines[4]}"
  printf "\${lines[5]}:   '%s'\\n" "${lines[5]}"
  printf "\${lines[6]}:   '%s'\\n" "${lines[6]}"
  printf "\${lines[7]}:   '%s'\\n" "${lines[7]}"
  printf "\${lines[8]}:   '%s'\\n" "${lines[8]}"

  [[    "${status}"     -eq 0                                   ]]

  [[ !  "${lines[0]}"   =~  \.md                                ]]

  [[    "${lines[0]}"   =~  [.*local:1.*].*\ Local\ Title\ One  ]]
  [[    "${lines[1]}"   =~  -*-                                 ]]
  [[    "${lines[2]}"   =~  Example\ Phrase                     ]]

  [[    "${output}"     =~  [.*home:3.*].*\ Title\ Three        ]]
  [[    "${lines[4]}"   =~  -*-                                 ]]
  [[    "${lines[5]}"   =~  Example\ Phrase                     ]]

  [[    "${output}"     =~  [.*home:2.*].*\ Title\ Two          ]]
  [[    "${lines[7]}"   =~  -*-                                 ]]
  [[    "${lines[8]}"   =~  Example\ Phrase                     ]]

  [[    "${output}"     =~  [.*one:1.*].*\ Example\ Title       ]]
  [[    "${lines[10]}"  =~  -*-                                 ]]
  [[    "${lines[11]}"  =~  Example\ Phrase                     ]]

  [[    "${#lines[@]}"  -eq 12                                  ]]
}

# help ########################################################################

@test "'help search' exits with status 0." {
  run "${_NB}" help search

  [[ "${status}" -eq 0 ]]
}

@test "'help search' prints help information." {
  run "${_NB}" help search

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*\:   ]]
  [[ "${lines[1]}" =~ nb\ search  ]]
}
