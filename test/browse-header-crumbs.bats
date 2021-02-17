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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \<span\ class=\"dim\"\>:\</span\>\ \<span\ class=\"dim\"\>1\</span\>\</h1\>                                                            ]]
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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>:\</span\>\ \<a\ href=\"http://localhost:6789/home:1/\?--page=.*\"\>Example\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\        ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>/\</span\>\ \<a\ href=\"http://localhost:6789/home:1/1/\?--page=.*\"\>Sample\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\       ]]
  [[ "${output}"    =~ \<span\ class=\"dim\"\>/\</span\>\ \<span\ class=\"dim\"\>1\</span\>\</h1\>                                                            ]]
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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>:\</span\>\ \<a\ href=\"http://localhost:6789/home:1/\?--page=.*\"\>Example\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\        ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>/\</span\>\ \<span\ class=\"dim\"\>1\</span\>\</h1\>                                                                                 ]]
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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>:\</span\>\ \<a\ href=\"http://localhost:6789/home:1/\?--page=.*\"\>Example\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\        ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>/\</span\>\ \<a\ href=\"http://localhost:6789/home:1/1/\?--page=.*\"\>Sample\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\</h1\> ]]

  run "${_NB}" browse home:1/1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                                                            ]]
  [[ "${output}"    =~ \<h1\ class=\"header-crumbs\"\ id=\"nb-home-example-folder-sample-folder\"\> ]]
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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>:\</span\>\ \<a\ href=\"http://localhost:6789/home:1/\?--page=.*\"\>Example\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\        ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>/\</span\>\ \<span\ class=\"dim\"\>1\</span\>\</h1\>                                                                                 ]]
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
\<h1\ class=\"header-crumbs\"\>\<a\ href=\"http://localhost:6789/\?--page.*\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ \<span\ class=\"dim\"\>·\</span\>\  ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>·\</span\>\ \<a\ href=\"http://localhost:6789/home:\?--page=.*\"\>home\</a\>\ \<span\ class=\"dim\"\>:\</span\>\                     ]]
  [[ "${output}"    =~ \
\ \<span\ class=\"dim\"\>:\</span\>\ \<a\ href=\"http://localhost:6789/home:1/\?--page=.*\"\>Example\ Folder\</a\>\ \<span\ class=\"dim\"\>/\</span\>\</h1\>  ]]
}
