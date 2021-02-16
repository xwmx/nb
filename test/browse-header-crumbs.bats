#!/usr/bin/env bats

load test_helper

# header crumbs ###############################################################

@test "'browse <notebook>:<file-id>' displays header crumbs with id with file." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Example Title"     \
      --content   "Example content."
  }

  run "${_NB}" browse home:1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ .*1.*                                                                   ]]
}

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id>' displays header crumbs with id with file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
  [[ "${output}"    =~ \ .*/.*\ \[Sample\ Folder\]\(http://localhost:6789/home:1/1/\?--page=.*\)\ .*/.* ]]
  [[ "${output}"    =~ \ .*/.*\ .*1.*                                                                   ]]
}

@test "'browse <notebook>:<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
}

@test "'browse <notebook>:<folder-id>/<folder-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" use "Example Notebook"
  }

  run "${_NB}" browse home:1/1/ --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
  [[ "${output}"    =~ \ .*/.*\ \[Sample\ Folder\]\(http://localhost:6789/home:1/1/\?--page=.*\)\ .*/.* ]]

  run "${_NB}" browse home:1/1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                ]]

  [[ "${output}"    =~ \<h1\ class=\"header-crumbs\"\>  ]]
}

@test "'browse <notebook-path>/<folder>/<filename>' displays header crumbs with folder and id for file." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder/File One.md" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0  ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
  [[ "${output}"    =~ \ .*/.*\ .*1.*                                                                   ]]
}

@test "'browse <notebook-path>/<folder>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\?--page.*\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
}
