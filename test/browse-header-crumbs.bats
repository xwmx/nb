#!/usr/bin/env bats

load test_helper

# .odt ########################################################################

@test "'browse --edit' with .odt file does not display edit link in header crumbs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"                 \
      --title     "Example Title"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"      \
      --title     "Title One"                       \
      --content   "Example content. [[Example Title]]"

    cat "${NB_DIR}/home/Example Folder/File One.md" \
      | pandoc --from markdown --to odt             \
      | "${_NB}" add "Example Folder/File One.odt"

    [[ -f "${NB_DIR}/home/Example Folder/File One.odt" ]]
  }

  run "${_NB}" browse 2/2 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0               ]]

  printf "%s\\n" "${output}" | grep     -q \
"<a.* href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"dim\">·</span> <a.* href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"dim\">:</span> <a.* href=\"http://localhost:6789/home:2/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep     -q \
" <span class=\"dim\">/</span> <span class=\"dim\">2</span>"

  printf "%s\\n" "${output}" | grep -v  -q "edit"
}

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id> --edit' displays header crumbs with linked id and editing message." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header --edit

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <a href=\"http://localhost:6789/home:1/1/?--per-page=.*&--columns=.*\">Sample Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
"</span> <a href=\"http://localhost:6789/home:1/1/1?--per-page=.*&--columns=.*\">1</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
"<span class=\"dim\">·</span> <span class=\"dim\">editing</span></h1>"
}

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

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <span class=\"dim\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <a href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*&--edit\">edit</a></h1>"
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

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <a href=\"http://localhost:6789/home:1/1/?--per-page=.*&--columns=.*\">Sample Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <span class=\"dim\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"dim\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"http://localhost:6789/home:1/1/1?--per-page=.*&--columns=.*&--edit\">edit</a></h1>"
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


  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <span class=\"dim\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"dim\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"http://localhost:6789/home:1/1?--per-page=.*&--columns=.*&--edit\">edit</a></h1>"
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

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <a href=\"http://localhost:6789/home:1/1/?--per-page=.*&--columns=.*\">Sample Folder</a> <span class=\"dim\">/</span></h1>"

  run "${_NB}" browse home:1/1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0  ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\" id=\"nb-home-example-folder-sample-folder\">"
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

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span> "


  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">/</span> <span class=\"dim\">1</span> "

  printf "%s\\n" "${output}" | grep -q \
"1</span> <span class=\"dim\">·</span> <a"

  printf "%s\\n" "${output}" | grep -q \
"<a href=\"http://localhost:6789/home:1/1?--per-page=.*&--columns=.*&--edit\">edit</a></h1>"
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

  printf "%s\\n" "${output}" | grep -q \
"<h1 class=\"header-crumbs\"><a href=\"http://localhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a> <span class=\"dim\">·</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a href=\"http://localhost:6789/home:?--per-page=.*&--columns=.*\">home</a> <span class=\"dim\">:</span> "

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">:</span> <a href=\"http://localhost:6789/home:1/?--per-page=.*&--columns=.*\">Example Folder</a> <span class=\"dim\">/</span></h1>"
}
