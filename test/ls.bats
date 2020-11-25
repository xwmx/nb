#!/usr/bin/env bats

load test_helper

_setup_ls() {
  "${_NB}" init
  cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
  cat <<HEREDOC | "${_NB}" add "second.md"
# two
line two
line three
line four
HEREDOC
  cat <<HEREDOC | "${_NB}" add "third.md"
# three
line two
line three
line four
HEREDOC
}

# --no-header / --no-footer ###################################################

@test "'ls --no-header' does not include header." {
  {
    _setup_ls

    "${_NB}" notebooks add "example-notebook"
  }

  run "${_NB}" ls --no-header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq   0                 ]]
  [[    "${output}"   =~    two               ]]
  [[ !  "${output}"   =~    example-notebook  ]]
  [[    "${output}"   =~    ❯                 ]]
}

@test "'ls --no-footer' does not include footer." {
  {
    _setup_ls

    "${_NB}" notebooks add "example-notebook"
  }

  run "${_NB}" ls --no-footer

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq   0                 ]]
  [[    "${output}"   =~    two               ]]
  [[    "${output}"   =~    example-notebook  ]]
  [[ !  "${output}"   =~    ❯                 ]]
}

# `scoped:ls` #################################################################

@test "'scoped:ls' exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "one.md" --title "one"
    "${_NB}" one:add "two.md" --title "two"
    "${_NB}" one:add "three.md" --title "three"
    _files=($(ls "${NB_DIR}/one/"))
  }

  NB_FOOTER=0 NB_HEADER=0 run "${_NB}" one:ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ one:3   ]]
  [[ "${lines[0]}" =~ three   ]]
  [[ "${lines[1]}" =~ one:2   ]]
  [[ "${lines[1]}" =~ two     ]]
  [[ "${lines[2]}" =~ one:1   ]]
  [[ "${lines[2]}" =~ one     ]]
}

@test "'scoped:ls' with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  NB_FOOTER=0 NB_HEADER=0 run "${_NB}" one:ls
  [[ ${status} -eq 0 ]]

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 items.

Add a note:
  $(_color_primary 'nb one:add')
Add a bookmark:
  $(_color_primary 'nb one: <url>')
Import a file:
  $(_color_primary 'nb one:import (<path> | <url>)')
Help information:
  $(_color_primary 'nb help')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

@test "'scoped:ls' escapes multi-word notebook name." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "multi word"
  }

  NB_FOOTER=0 NB_HEADER=0 run "${_NB}" multi\ word:ls
  [[ ${status} -eq 0 ]]

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 items.

Add a note:
  $(_color_primary 'nb multi\ word:add')
Add a bookmark:
  $(_color_primary 'nb multi\ word: <url>')
Import a file:
  $(_color_primary 'nb multi\ word:import (<path> | <url>)')
Help information:
  $(_color_primary 'nb help')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

@test "'scoped:ls --bookmarks' with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  NB_FOOTER=0 NB_HEADER=0 run "${_NB}" one:ls --bookmarks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 bookmarks.

Add a bookmark:
  $(_color_primary 'nb one: <url>')
Help information:
  $(_color_primary 'nb help bookmark')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

@test "'scoped:ls --documents' with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  NB_FOOTER=0 NB_HEADER=0 run "${_NB}" one:ls --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 document files.

Import a file:
  $(_color_primary 'nb one:import (<path> | <url>)')
Help information:
  $(_color_primary 'nb help import')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

# footer ######################################################################

@test "'ls' includes footer." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0    ]]
  [[ "${lines[6]}" =~ ❯ ]]
}

@test "'NB_FOOTER=0 ls' does not include footer." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  NB_FOOTER=0 run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0      ]]
  [[ ! "${lines[6]}" =~ ❯ ]]
}

@test "'ls' footer includes command names." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status}      -eq 0                 ]]
  [[ "${lines[6]}"  =~  ❯                 ]]
  [[ "${lines[6]}"  =~  nb\ add           ]]
  [[ "${lines[6]}"  =~  nb\ \<url\>       ]]
  [[ "${lines[6]}"  =~  nb\ edit\ \<id\>  ]]
}

@test "'ls' footer scopes command names to a selected notebook." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))

    "${_NB}" notebooks add "example"
    "${_NB}" use example

    [[ "$("${_NB}" notebooks current)" == "example" ]]
  }

  run "${_NB}" home:ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status}      -eq 0                     ]]
  [[ "${lines[6]}"  =~  ❯                     ]]
  [[ "${lines[6]}"  =~  nb\ add\ home:        ]]
  [[ "${lines[6]}"  =~  nb\ home:\ \<url\>    ]]
  [[ "${lines[6]}"  =~  nb\ edit\ home:\<id\> ]]
}

@test "'ls' footer escapes multi-word selected notebook names." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))

    "${_NB}" notebooks add "example"
    "${_NB}" use example
    "${_NB}" notebooks rename home "multi word"

    _notebooks=(
      "example"
      "multi word"
    )

    diff                                      \
      <("${_NB}" notebooks --no-color)        \
      <(printf "%s\\n" "${_notebooks[@]:-}")

    [[ "$("${_NB}" notebooks current)" == "example" ]]
  }

  run "${_NB}" multi\ word:ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}      -eq 0                               ]]
  [[ "${lines[6]}"  =~  ❯                               ]]
  [[ "${lines[6]}"  =~  nb\ add\ multi\\\ word:         ]]
  [[ "${lines[6]}"  =~  nb\ multi\\\ word:\ \<url\>     ]]
  [[ "${lines[6]}"  =~  nb\ edit\ multi\\\ word:\<id\>  ]] ||
    [[ "${lines[7]}"  =~  nb\ edit\ multi\\\ word:\<id\>  ]]
}

# header ######################################################################

@test "'ls' includes header." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${lines[0]}" =~ home  ]]
}

@test "'NB_HEADER=0 ls' does not include header." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  NB_HEADER=0 run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0          ]]
  [[ ! "${lines[0]}" =~ home  ]]
}

@test "'ls' header does not escape multi-word notebook names." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))

    "${_NB}" notebooks add "example"
    "${_NB}" use example
    "${_NB}" notebooks rename home "multi word"

    _notebooks=(
      "example"
      "multi word"
    )

    diff                                      \
      <("${_NB}" notebooks --no-color)        \
      <(printf "%s\\n" "${_notebooks[@]:-}")

    [[ "$("${_NB}" notebooks current)" == "example" ]]
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ example     ]]
  [[ "${lines[0]}" =~ multi\ word ]]
}

@test "'ls' header shows added and deleted notebook." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  [[ ! "${lines[0]}" =~ example ]]
  [[ "${lines[0]}" =~ home      ]]

  run "${_NB}" notebooks add example

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ example ]]
  [[ "${lines[0]}" =~ home    ]]

  run "${_NB}" notebooks delete home --force

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ example ]]
  [[ ! "${lines[0]}" =~ home  ]]
}

@test "'ls' header shows externally added and deleted notebook." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  [[ ! "${lines[0]}" =~ example ]]
  [[ "${lines[0]}" =~ home      ]]

  mkdir "${NB_DIR}/example"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ example ]]
  [[ "${lines[0]}" =~ home    ]]

  mv "${NB_DIR}/example" "${_TMP_DIR}/"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  [[ ! "${lines[0]}" =~ example ]]
  [[ "${lines[0]}" =~ home      ]]
}

# `ls` ########################################################################

@test "'ls' exits with 0 and lists files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ home    ]]
  [[ "${lines[1]}" =~ ----    ]]
  [[ "${lines[2]}" =~ three   ]]
  [[ "${lines[3]}" =~ two     ]]
  [[ "${lines[4]}" =~ one     ]]
}

@test "'ls' exits with 0 and includes archive count." {
  {
    _setup_ls
    "${_NB}" notebooks add one
    "${_NB}" one:notebook archive
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ home                  ]]
  [[ "${lines[0]}" =~ .\ \[1\ archived\]    ]]
  [[ "${lines[1]}" =~ -------------------   ]]
  [[ "${lines[2]}" =~ three                 ]]
  [[ "${lines[3]}" =~ two                   ]]
  [[ "${lines[4]}" =~ one                   ]]
}

@test "'ls' with local includes it in notebook list." {
  {
    _setup_ls
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ local         ]]
  [[ "${lines[0]}" =~ home          ]]
  [[ "${lines[1]}" =~ ------------  ]]
  [[ "${lines[2]}" =~ 0\ items\.    ]]
}

# `ls -e [<excerpt length>]` ##################################################

@test "'ls -e <excerpt length>' exits with 0 and displays excerpts." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -e 5

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 18  ]]
}

# `ls -n <number>`, ls --limit <number>, ls --<number> ########################

@test "'ls -n 0' exits with 0 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -n 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 6                       ]]
  [[ "${lines[2]}" =~ 3\ omitted\.\ 3\ total\.  ]]
}

@test "'ls -n 1' exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -n 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 7                       ]]
  [[ "${lines[2]}" =~ three                     ]]
  [[ "${lines[3]}" =~ 2\ omitted\.\ 3\ total\.  ]]
}

@test "'ls -n 2' exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -n 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 8                       ]]
  [[ "${lines[2]}" =~ three                     ]]
  [[ "${lines[3]}" =~ two                       ]]
  [[ "${lines[4]}" =~ 1\ omitted\.\ 3\ total\.  ]]
}

@test "'ls -n 3' exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -n 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

@test "'ls --limit 3' exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls -n 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

@test "'ls --3' exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

# `ls -s` / `ls --sort` / `ls -r` / `ls --reverse` ############################

@test "'ls --sort' sorts items." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 3           ]]
  [[ "${lines[0]}" =~ title\ one    ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[1]}" =~ title\ two    ]]
  [[ "${lines[1]}" =~ [*2*]         ]]
  [[ "${lines[2]}" =~ title\ three  ]]
  [[ "${lines[2]}" =~ [*3*]         ]]
}

@test "'ls --sort --reverse' reverse sorts items." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls --sort --reverse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 3           ]]
  [[ "${lines[0]}" =~ title\ three  ]]
  [[ "${lines[0]}" =~ [*3*]         ]]
  [[ "${lines[1]}" =~ title\ two    ]]
  [[ "${lines[1]}" =~ [*2*]         ]]
  [[ "${lines[2]}" =~ title\ one    ]]
  [[ "${lines[2]}" =~ [*1*]         ]]
}

@test "'ls --sort' retains limit." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC

  "${_NB}" set limit 2
  }

  run "${_NB}" ls --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" -eq 3                   ]]
  [[ "${lines[0]}" =~ title\ one            ]]
  [[ "${lines[0]}" =~ [*1*]                 ]]
  [[ "${lines[1]}" =~ title\ two            ]]
  [[ "${lines[1]}" =~ [*2*]                 ]]
  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

# `ls -a` / `ls --all` ########################################################

_setup_ls_all() {
  "${_NB}" init

  for (( _i=1; _i<31; _i++ ))
  do
    cat <<HEREDOC | "${_NB}" add "${_i}.md"
# ${_i}
line two
line three
line four
HEREDOC
  done
}

@test "'ls --2' exits with 0 and lists 2 items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls --2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ '30'  ]]
  [[ "${lines[3]}" =~ '29'  ]]
}

@test "'ls' exits with 0 and lists 20 items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" -eq 26        ]]
  [[ "${lines[2]}"  =~ '30'       ]]
  [[ "${lines[3]}"  =~ '29'       ]]
  [[ "${lines[21]}" =~ '11'       ]]
  [[ "${lines[22]}" =~ 'omitted'  ]]
}

@test "'ls -a' exits with 0 and lists all items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls -a

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 35  ]]
  [[ "${lines[2]}"  =~ '30' ]]
  [[ "${lines[3]}"  =~ '29' ]]
  [[ "${lines[21]}" =~ '11' ]]
  [[ "${lines[22]}" =~ '10' ]]
  [[ "${lines[32]}" =~ \-\- ]]
}

@test "'ls --all' exits with 0 and lists all items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls --all

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 35  ]]
  [[ "${lines[2]}"  =~ '30' ]]
  [[ "${lines[3]}"  =~ '29' ]]
  [[ "${lines[21]}" =~ '11' ]]
  [[ "${lines[22]}" =~ '10' ]]
  [[ "${lines[32]}" =~ \-\- ]]
}

# `ls <selector>` #############################################################

@test "'ls <selector>' exits with 0 and displays the selector." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls 1 --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 1           ]]
  [[ "${lines[0]}" =~ first.md      ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[0]}" =~ ${_files[0]}  ]]
}

@test "'ls <query selector>' exits with 0 and displays the selectors." {
  {
    _setup_ls
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls 'r' --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 2           ]]
  [[ "${lines[0]}" =~ third.md      ]]
  [[ "${lines[0]}" =~ [*3*]         ]]
  [[ "${lines[0]}" =~ ${_files[2]}  ]]
  [[ "${lines[1]}" =~ first.md      ]]
  [[ "${lines[1]}" =~ [*1*]         ]]
  [[ "${lines[1]}" =~ ${_files[0]}  ]]
}

@test "'ls <multi-word selector>' successfully filters list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add 'first.md'
# example plum
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'second.md'
# example pluot
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'third.md'
# sample pear
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'fourth.md'
# sample plum
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls 'example plum' --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0            ]]
  [[ "${#lines[@]}" -eq 1       ]]
  [[ "${lines[0]}" =~ first.md  ]]
  [[ "${lines[0]}" =~ [*1*]     ]]
}

@test "'ls <multiple> <selectors>' successfully filters list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add 'first.md'
# example plum
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'second.md'
# example pluot
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'third.md'
# sample pear
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'fourth.md'
# sample plum
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls example plum --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0            ]]
  [[ "${#lines[@]}" -eq 3       ]]
  [[ "${lines[0]}" =~ fourth.md ]]
  [[ "${lines[0]}" =~ [*4*]     ]]
  [[ "${lines[1]}" =~ second.md ]]
  [[ "${lines[1]}" =~ [*2*]     ]]
  [[ "${lines[2]}" =~ first.md  ]]
  [[ "${lines[2]}" =~ [*1*]     ]]
}

@test "'ls <invalid-selector>' exits with 1 and displays a message." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                ]]
  [[ "${#lines[@]}" -eq 1           ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
  [[ "${lines[0]}" =~ not-valid     ]]
}

@test "'ls <notebook>' exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -ge 7           ]]
  [[ "${lines[3]}" =~ one\ example  ]]
  [[ "${lines[3]}" =~ [*1*]         ]]
}

@test "'ls <notebook>:' (with colon) exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -ge 7           ]]
  [[ "${lines[3]}" =~ one\ example  ]]
  [[ "${lines[3]}" =~ [*1*]         ]]
}

@test "'ls <notebook> --sort' exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 2           ]]
  [[ "${lines[0]}" =~ one\ example  ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
}

# `ls --type` #################################################################

@test "'ls --document' exits with 0 and displays a list of documents." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ second.doc  ]]
  [[ "${lines[0]}" =~ 2           ]]
}

@test "'ls --documents' exits with 0 and displays a list of documents." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ second.doc  ]]
  [[ "${lines[0]}" =~ 2           ]]
}

@test "'ls --document' exits with 0 and displays empty list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" == 5                    ]]
  [[ "${lines[0]}" =~ 0\ document\ files\.  ]]
}


@test "'ls --documents' exits with 0 and displays empty list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" == 5                    ]]
  [[ "${lines[0]}" =~ 0\ document\ files\.  ]]
}

@test "'ls --js' exits with 0, displays empty list, and retains trailing 's'." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls --js

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                  ]]
  [[ "${#lines[@]}" == 5              ]]
  [[ "${lines[0]}" =~ 0\ js\ files\.  ]]
}

@test "'ls <selection> --type' filters by type." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "example.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls example --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ example.doc ]]
  [[ "${lines[0]}" =~ 3           ]]
}

@test "'ls <selection> --<invalid>' prints message." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "example.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls example --not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ example     ]]
  [[ "${lines[0]}" =~ Type        ]]
  [[ "${lines[0]}" =~ not-valid   ]]
}

@test "'ls <selection> --documents' with no matches prints message." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "example.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" ls matchless-query --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                  ]]
  [[ "${#lines[@]}" == 1              ]]
  [[ "${lines[0]}" =~ Not\ found      ]]
  [[ "${lines[0]}" =~ matchless-query ]]
  [[ "${lines[0]}" =~ Type            ]]
  [[ "${lines[0]}" =~ document        ]]
}

@test "'<notebook>: <selection> --documents' with no matches prints message." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "example.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "sample.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "example.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "sample.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" example: matchless-query --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                          ]]
  [[ "${#lines[@]}" == 1                      ]]
  [[ "${lines[0]}" =~ Not\ found              ]]
  [[ "${lines[0]}" =~ example:matchless-query ]]
  [[ "${lines[0]}" =~ Type                    ]]
  [[ "${lines[0]}" =~ document                ]]
}
