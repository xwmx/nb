#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "'index' with folder path reconciles ancestors indexes if .index doesn't exist." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

# add #########################################################################

@test "'index add <filename>' with folder path adds an item to the folder index and does not reconcile ancestors." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Add existing files to the folder index:

    {
      printf "one.bookmark.md\\n"
      printf "two.bookmark.md\\n"
    } >> "${NB_DIR}/home/Example Folder/Sample Folder/.index"

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"                               ]]
    [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
    [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
    [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
  }

  run "${_NB}" index add "three.bookmark.md" "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0  ]]
  [[ -z "${output}"     ]]

  # .index is not reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is not generated in ancestor:

  [[ ! -e "${NB_DIR}/home/Example Folder/.index" ]]

  # item is added to the index:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

@test "'index add <filename>' with non-existent filename and folder path returns error and does not reconcile .index or ancestors." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Add existing files to the folder index:

    {
      printf "one.bookmark.md\\n"
      printf "two.bookmark.md\\n"
    } >> "${NB_DIR}/home/Example Folder/Sample Folder/.index"

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"                               ]]
    [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
    [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
    [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
    [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ new.bookmark.md    ]]
  }

  run "${_NB}" index add "new.bookmark.md" "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1                ]]
  [[ "${output}" =~ File\ not\ found: ]]

  # .index is not reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[   -e "${NB_DIR}/home/.index"                          ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is not generated in ancestor:

  [[ ! -e "${NB_DIR}/home/Example Folder/.index" ]]

  # .index is not reconciled in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
  [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ new.bookmark.md    ]]
}

# get_basename ################################################################

@test "'index get_basename' with folder path prints the filename for an id." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    sleep 1

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC

    sleep 1

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                          ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index get_basename 2 "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ two.bookmark.md$  ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md   ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md   ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md ]]
}

# get_id #########################################################################

@test "'index get_id <filename>' with folder path prints the filename for an id." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index get_id two.bookmark.md "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0      ]]
  [[ "${lines[0]}" == "2" ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

# get_max_id ##################################################################

@test "'index get_max_id' with folder path prints the filename for an id." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index get_max_id "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0      ]]
  [[ "${lines[0]}" == "3" ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

# delete ######################################################################

@test "'index delete <filename>' with folder path deletes <filename> from the index." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index delete "two.bookmark.md" "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat


  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder and two.bookmark.md is deleted:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
  ls "${NB_DIR}/home/Example Folder/Sample Folder"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

# show ########################################################################

@test "'index show' with folder path prints the index." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index show "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is generated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]

  # output is the same as the content of .index

  [[ ${status} -eq 0                                                                ]]
  [[ "${output}"  == "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"  ]]
}

# update ######################################################################

@test "'index update <old> <new>' with folder updates the index." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  run "${_NB}" index update \
    two.bookmark.md         \
    new-name.md             \
    "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]

  # .index is reconciled in notebook root:

  cat "${NB_DIR}/home/.index"

  [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
  [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

  # .index is generated in ancestor:

  [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  # .index is updated in folder:

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ ! "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ new-name.md        ]]
  [[   "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]
}

# verify ######################################################################

@test "'index verify' with folder verifies a valid index." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/1.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/2.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/3.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                             ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/1.bookmark.md"  ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/2.bookmark.md"  ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/3.bookmark.md"  ]]

    # Reconcile all .indexes in the path:

    run "${_NB}" index reconcile                        \
      "${NB_DIR}/home/Example Folder/Sample Folder"  \
      --ancestors > /dev/null

    # .index is reconciled in notebook root:

    cat "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
    [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

    # .index is generated in ancestor:

    [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
    [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

    # .index is generated in folder:

    cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
    ls "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" == \
         "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" ]]
  }

  run "${_NB}" index verify "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]

  # .index still reflects folder contents:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" == \
       "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" ]]
}

@test "'index verify' with folder returns 1 with invalid index." {
  {
    "${_NB}" init

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/1.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/2.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    sleep 1
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/3.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                             ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/1.bookmark.md"  ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/2.bookmark.md"  ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/3.bookmark.md"  ]]

    # Reconcile all .indexes in the path:

    run "${_NB}" index reconcile                    \
      "${NB_DIR}/home/Example Folder/Sample Folder" \
      --ancestors > /dev/null


    # .index is reconciled in notebook root:

    cat "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder ]]
    [[ "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md ]]

    # .index is generated in ancestor:

    [[   -e "${NB_DIR}/home/Example Folder/.index"                       ]]
    [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

    # .index is generated in folder:

    cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"
    ls "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" == \
         "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" ]]

    # Overwrite entries in folder index:

    printf "" > "${NB_DIR}/home/Example Folder/Sample Folder/.index"

    [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" != \
         "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")" ]]
  }

  run "${_NB}" index verify "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  [[ ${status} -eq 1                  ]]
  [[ "${output}"  =~ Index\ corrupted ]]

  # .index is not updated:

  [[ -z "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" != \
       "$(ls "${NB_DIR}/home/Example Folder/Sample Folder")"            ]]
}

