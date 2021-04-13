#!/usr/bin/env bats

load test_helper

# selectors ###################################################################

@test "'notebooks author <notebook-name>: --email <email> --name <name>' updates the local email and name in <notebook-path>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" notebooks author   \
    "Example Notebook:"           \
    --email "local@example.test"  \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/Example Notebook" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/Example Notebook" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks author <notebook-name> --email <email> --name <name>' updates the local email and name in <notebook-path>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" notebooks author   \
    "Example Notebook"            \
    --email "local@example.test"  \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/Example Notebook" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/Example Notebook" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks author <notebook-path> --email <email> --name <name>' updates the local email and name in <notebook-path>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" notebooks author   \
    "${NB_DIR}/Example Notebook"  \
    --email "local@example.test"  \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/Example Notebook" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/Example Notebook" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/Example Notebook" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*Example\ Notebook             ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" notebooks use "Example Notebook"

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

# notebooks author email and name prompts #####################################

@test "'notebooks author' prompts update the local email and name." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author \
    <<< "y${_NEWLINE}local@example.test${_NEWLINE}Example Local Name${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 10  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[4]}"  =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[5]}"  =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[6]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[7]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[8]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[9]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks author' prompts update the local email." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author \
    <<< "y${_NEWLINE}local@example.test${_NEWLINE}${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 10  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[4]}"  =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[5]}"  =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[6]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[7]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[8]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[9]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: %s <local@example.test>\\n" "${_global_name}")
}

@test "'notebooks author' prompts update the local name." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author \
    <<< "y${_NEWLINE}${_NEWLINE}Example Local Name${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 10  ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  [[ "${lines[4]}"  =~ \
Enter\ a\ new\ value,\ .*unset.*\ to\ use\ the\ global\ value,                ]]
  [[ "${lines[5]}"  =~ or\ leave\ blank\ to\ keep\ the\ current\ value\.      ]]

  [[ "${lines[6]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[7]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[8]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[9]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <%s>\\n" "${_global_email}")
}

# notebooks author --email and --name #########################################

@test "'notebooks author --email <email> --name <name>' updates the local email and name." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author   \
    --email "local@example.test"  \
    --name  "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 12  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[8]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[9]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[10]}" =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[11]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <local@example.test>\\n")
}

@test "'notebooks author --email <email>' updates the local email." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author --email "local@example.test" <<< "y${_NEWLINE}"

  printf "\${status}:     '%s'\\n" "${status}"
  printf "\${output}:     '%s'\\n" "${output}"
  printf "\${#lines[@]}:  '%s'\\n" "${#lines[@]}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 11  ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*email.*:\ local@example.test                  ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: %s <local@example.test>\\n" "${_global_name}")
}

@test "'notebooks author --name <name>' updates the local name." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author --name "Example Local Name" <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0   ]]
  [[ "${#lines[@]}" -eq 11  ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
  [[ "${lines[4]}"  =~ Update:                                                ]]
  [[ "${lines[5]}"  =~ [^-]-------[^-]                                        ]]
  [[ "${lines[6]}"  =~ local\ .*name.*:\ \ Example\ Local\ Name               ]]
  [[ "${lines[7]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[8]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[9]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[10]}" =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]

  "${_NB}" add "Example File.md" --content "Example content."

  diff                                            \
    <("${_NB}" git log -1 --stat | sed -n '2 p')  \
    <(printf "Author: Example Local Name <%s>\\n" "${_global_email}")
}

# notebooks author --unset ####################################################

@test "'notebooks author --unset --email' unsets only email and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --unset --email

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 5 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -n "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  [[ "${lines[0]}"  =~ Unsetting\ local\ email\.                              ]]
  [[ "${lines[1]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[2]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[3]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[4]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]
}

@test "'notebooks author --unset --name' unsets only name and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --unset --name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 5 ]]

  [[ -n "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Unsetting\ local\ name\.                               ]]
  [[ "${lines[1]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[2]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[3]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[4]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

@test "'notebooks author --unset' with local email unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email  "local@example.test"
  }

  run "${_NB}" notebooks author --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 5 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Unsetting\ local\ email\.                              ]]
  [[ "${lines[1]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[2]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[3]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[4]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

@test "'notebooks author --unset' with local name unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 5 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Unsetting\ local\ name\.                               ]]
  [[ "${lines[1]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[2]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[3]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[4]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

@test "'notebooks author --unset' with full local author unsets and prints global values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 6 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Unsetting\ local\ email\.                              ]]
  [[ "${lines[1]}"  =~ Unsetting\ local\ name\.                               ]]
  [[ "${lines[2]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[3]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[4]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[5]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

@test "'notebooks author --unset' with no local author prints global values." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author --unset

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 4 ]]

  [[ -z "$(git -C "${NB_DIR}/home" config --local user.email  || :)" ]]
  [[ -z "$(git -C "${NB_DIR}/home" config --local user.name   || :)" ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Updated\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

# notebooks author ############################################################

@test "'notebooks author' with local email prints local value with global name." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email  "local@example.test"
  }

  run "${_NB}" notebooks author --skip-prompt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 4 ]]

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}

@test "'notebooks author' with local name prints local value with global email." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --skip-prompt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 4 ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]
}

@test "'notebooks author' with full local author prints local values." {
  {
    "${_NB}" init

    git -C "${NB_DIR}/home" config --local user.email "local@example.test"
    git -C "${NB_DIR}/home" config --local user.name  "Example Local Name"
  }

  run "${_NB}" notebooks author --skip-prompt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 4 ]]

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*local.*\):\ \ local@example.test        ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*local.*\):\ \ Example\ Local\ Name     ]]
}

@test "'notebooks author' with no local author prints global values." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks author --skip-prompt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${#lines[@]}" -eq 4 ]]

  declare _global_email=
  _global_email="$(git -C "${NB_DIR}/home" config --global user.email)"

  declare _global_name=
  _global_name="$(git -C "${NB_DIR}/home" config --global user.name)"

  [[ "${lines[0]}"  =~ Current\ author\ for:\ .*home                          ]]
  [[ "${lines[1]}"  =~ [^-]-------------------[^-]                            ]]
  [[ "${lines[2]}"  =~ .*email.*\ \(.*global.*\):\ ${_global_email}           ]]
  [[ "${lines[3]}"  =~ .*name.*\ \ \(.*global.*\):\ ${_global_name//' '/\\ }  ]]
}
