#!/usr/bin/env bats

load test_helper

# alias #######################################################################

@test "'f add <name>' adds folder with <name>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"     ]]
  }

  run "${_NB}" f add "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                      ]]
  [[      "${output}"   =~ Added:\ .*[.*1.*].*\ .*Example\ Folder ]]
  [[ -d   "${NB_DIR}/home/Example Folder"                         ]]
}

# add ########################################################################

@test "'folders add' with no name prints help." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/folder"             ]]
  }

  run "${_NB}" folders add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
  [[ ! -e "${NB_DIR}/home/folder"               ]]
}

@test "'folders a' with no name prints help." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/folder"             ]]
  }

  run "${_NB}" folders add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
  [[ ! -e "${NB_DIR}/home/folder"               ]]
}

@test "'folders +' with no name prints help." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/folder"             ]]
  }

  run "${_NB}" folders add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
  [[ ! -e "${NB_DIR}/home/folder"               ]]
}

@test "'folders add <name>' adds folder with <name>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"     ]]
  }

  run "${_NB}" folders add "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                      ]]
  [[      "${output}"   =~ Added:\ .*[.*1.*].*\ .*Example\ Folder ]]
  [[ -d   "${NB_DIR}/home/Example Folder"                         ]]
}

@test "'folders a <name>' adds folder with <name>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"     ]]
  }

  run "${_NB}" folders a "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                      ]]
  [[      "${output}"   =~ Added:\ .*[.*1.*].*\ .*Example\ Folder ]]
  [[ -d   "${NB_DIR}/home/Example Folder"                         ]]
}

@test "'folders + <name>' adds folder with <name>." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"     ]]
  }

  run "${_NB}" folders + "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                      ]]
  [[      "${output}"   =~ Added:\ .*[.*1.*].*\ .*Example\ Folder ]]
  [[ -d   "${NB_DIR}/home/Example Folder"                         ]]
}

# delete ######################################################################

@test "'folders delete' with no name prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" folders delete

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
}

@test "'folders d' with no name prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" folders d

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
}

@test "'folders -' with no name prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" folders -

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
}

@test "'folders rm' with no name prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" folders rm

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                    ]]
  [[      "${lines[0]}" =~ Usage                ]]
  [[      "${lines[1]}" =~ nb\ folders\ add     ]]
  [[      "${lines[2]}" =~ nb\ folders\ delete  ]]
}

@test "'folders delete <name>' with non-folder prints message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    [[ -e "${NB_DIR}/home/Example File.md"      ]]
  }

  run "${_NB}" folders delete "Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                                            ]]
  [[      "${output}"   =~ !.*\ Not\ a\ folder:\ .*Example\ File.md     ]]
  [[   -e "${NB_DIR}/home/Example File.md"                              ]]
}

@test "'folders delete <name>' with no matching folder <name> prints message." {
  {
    "${_NB}" init

    [[ ! -e "${NB_DIR}/home/Example Folder"       ]]
  }

  run "${_NB}" folders delete "Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 1                                    ]]
  [[      "${output}"   =~ !.*\ Not\ found:\ .*Example\ Folder  ]]
}

@test "'folders delete <name>' with existing folder deletes folder." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"

    [[ -e "${NB_DIR}/home/Example Folder"       ]]
  }

  run "${_NB}" folders delete "Example Folder" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                              ]]
  [[      "${output}"   =~ Deleted:\ \ .*[.*1.*].*\ 📂\ .*Example\ Folder ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                                 ]]
}

@test "'folders d <name>' with existing folder deletes folder." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"

    [[ -e "${NB_DIR}/home/Example Folder"       ]]
  }

  run "${_NB}" folders d "Example Folder" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                              ]]
  [[      "${output}"   =~ Deleted:\ \ .*[.*1.*].*\ 📂\ .*Example\ Folder ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                                 ]]
}

@test "'folders - <name>' with existing folder deletes folder." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"

    [[ -e "${NB_DIR}/home/Example Folder"       ]]
  }

  run "${_NB}" folders - "Example Folder" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                              ]]
  [[      "${output}"   =~ Deleted:\ \ .*[.*1.*].*\ 📂\ .*Example\ Folder ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                                 ]]
}

@test "'folders rm <name>' with existing folder deletes folder." {
  {
    "${_NB}" init

    "${_NB}" add folder "Example Folder"

    [[ -e "${NB_DIR}/home/Example Folder"       ]]
  }

  run "${_NB}" folders rm "Example Folder" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}"   == 0                                              ]]
  [[      "${output}"   =~ Deleted:\ \ .*[.*1.*].*\ 📂\ .*Example\ Folder ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                                 ]]
}

# list / default ##############################################################

@test "'folders' with no folders displays message." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."
  }

  run "${_NB}" folders

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  0\ folders\.                          ]]
}

@test "'folders' with folders in current notebook lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"
  }

  run "${_NB}" folders

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  .*[.*1.*].*\ 📌\ 📂\ Demo\ Folder     ]]
  [[   "${lines[1]}"  =~  .*[.*5.*].*\ 📂\ Sample\ Folder       ]]
  [[   "${lines[2]}"  =~  .*[.*3.*].*\ 📂\ Example\ Folder      ]]
}

@test "'folders ls' with folders in current notebook lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"
  }

  run "${_NB}" folders ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  .*[.*1.*].*\ 📌\ 📂\ Demo\ Folder     ]]
  [[   "${lines[1]}"  =~  .*[.*5.*].*\ 📂\ Sample\ Folder       ]]
  [[   "${lines[2]}"  =~  .*[.*3.*].*\ 📂\ Example\ Folder      ]]
}

@test "'folders list' with folders in current notebook lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"
  }

  run "${_NB}" folders list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                     ]]
  [[   "${lines[0]}"  =~  .*[.*1.*].*\ 📌\ 📂\ Demo\ Folder     ]]
  [[   "${lines[1]}"  =~  .*[.*5.*].*\ 📂\ Sample\ Folder       ]]
  [[   "${lines[2]}"  =~  .*[.*3.*].*\ 📂\ Example\ Folder      ]]
}

@test "'folders <notebook>:' with folders in <notebook> lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
  }

  run "${_NB}" folders home:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  .*[.*home:1.*].*\ 📌\ 📂\ Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  .*[.*home:5.*].*\ 📂\ Sample\ Folder    ]]
  [[   "${lines[2]}"  =~  .*[.*home:3.*].*\ 📂\ Example\ Folder   ]]
}

@test "'folders ls <notebook>:' with folders in <notebook> lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
  }

  run "${_NB}" folders ls home:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  .*[.*home:1.*].*\ 📌\ 📂\ Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  .*[.*home:5.*].*\ 📂\ Sample\ Folder    ]]
  [[   "${lines[2]}"  =~  .*[.*home:3.*].*\ 📂\ Example\ Folder   ]]

  run "${_NB}" folders home: ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  .*[.*home:1.*].*\ 📌\ 📂\ Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  .*[.*home:5.*].*\ 📂\ Sample\ Folder    ]]
  [[   "${lines[2]}"  =~  .*[.*home:3.*].*\ 📂\ Example\ Folder   ]]
}

@test "'folders list <notebook>:' with folders in <notebook> lists folders." {
  {
    "${_NB}" init

    "${_NB}" add folder "Demo Folder"

    "${_NB}" pin "Demo Folder"

    sleep 1

    "${_NB}" add "File One.md" --content "Example content one."

    "${_NB}" add folder "Example Folder"

    sleep 1

    "${_NB}" add "File Two.md" --content "Example content two."

    sleep 1

    "${_NB}" add folder "Sample Folder"

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"
  }

  run "${_NB}" folders list home:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  .*[.*home:1.*].*\ 📌\ 📂\ Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  .*[.*home:5.*].*\ 📂\ Sample\ Folder    ]]
  [[   "${lines[2]}"  =~  .*[.*home:3.*].*\ 📂\ Example\ Folder   ]]

  run "${_NB}" folders home: list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${status}"    -eq 0                                       ]]
  [[   "${lines[0]}"  =~  .*[.*home:1.*].*\ 📌\ 📂\ Demo\ Folder  ]]
  [[   "${lines[1]}"  =~  .*[.*home:5.*].*\ 📂\ Sample\ Folder    ]]
  [[   "${lines[2]}"  =~  .*[.*home:3.*].*\ 📂\ Example\ Folder   ]]
}
