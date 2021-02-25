#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# img tags ####################################################################

@test "'browse' strips <img> tags." {
  {
    "${_NB}" init

    "${_NB}" add                  \
      --title     "Example Title" \
      --content   "$(<<HEREDOC cat
Example image one: ![Example Image One](/not-valid-1.png)

More example ![Example Image Two](/not-valid-2.png) content ![Example Image Three](/not-valid-3.png) here.
HEREDOC
)"
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \<h1\ class=\"header-crumbs\"\>              ]]
  [[    "${output}"    =~  \<p\>Example\ image\ one:\ \</p\>            ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]

  [[ !  "${output}"    =~  \<img                                        ]]
}

# code ########################################################################

@test "'browse' with .bash file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.bash" --content "echo \"hello\""
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                 ]]

  [[ "${output}"    =~  \<h1\ class=\"header-crumbs\"\>     ]]

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/?--per-page=.*"><span class="dim">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
'<span class="dim">·</span> <a.* href="http://localhost:6789/home:?--per-page=.*">home</a\>'

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"         ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ bash\"\> ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;               ]]
}

@test "'browse' with .js file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.js" --content "console.log(\"hello\");"
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                 ]]

  [[ "${output}"    =~  \<h1\ class=\"header-crumbs\"\>     ]]

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/?--per-page=.*"><span class="dim">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
'<span class="dim">·</span> <a.* href="http://localhost:6789/home:?--per-page=.*">home</a\>'

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"         ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ js\"\>   ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;               ]]
}

# .odt ########################################################################

@test "'browse' with .odt file serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
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

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\"><span id=\"anchor\"></span>Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# .docx #######################################################################

@test "'browse' with .docx file serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"                 \
      --title     "Example Title"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"      \
      --title     "Title One"                       \
      --content   "Example content. [[Example Title]]"

    cat "${NB_DIR}/home/Example Folder/File One.md" \
      | pandoc --from markdown --to docx            \
      | "${_NB}" add "Example Folder/File One.docx"

    [[ -f "${NB_DIR}/home/Example Folder/File One.docx" ]]
  }

  run "${_NB}" browse 2/2 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# .org ########################################################################

@test "'browse' with .org file serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.org" \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  # TODO: .org / org mode titles in pandoc HTML output?
  # [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                     ]]

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&amp;--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# markdown ####################################################################

@test "'browse <folder-id>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

@test "'browse <folder-name>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

@test "'browse <item-selector>' properly resolves titled wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Root Title Two]]

More example [[Example Notebook:Example Folder/1]] content [[3/1]] here.
HEREDOC
)"

    "${_NB}" add  "File Two.md"       \
      --title     "Root Title Two"    \
      --content   "Example content."

    "${_NB}" add  "Sample Folder/File One.md"                   \
      --title     "Sample Nested Title Two"                     \
      --content   "Sample nested content one."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Example Nested Title One"                    \
      --content   "Example nested content one."

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" use "Sample Notebook"
  }

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'one: <a.* href="http://localhost:6789/home:2?--per-page.*&--columns=.*">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    'example <a.* href="http://localhost:6789/Example Notebook:1/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q \
    'content <a.* href="http://localhost:6789/home:3/1?--per-page.*&--columns=.*">\[\[3/1\]\]</a> here'
}

@test "'browse <item-selector>' properly resolves titled wiki-style links and skips links with non-resolving selectors." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Root Title Two]]

More example [[Example Notebook:Example Folder/1]] content [[2/1]] here.
HEREDOC
)"

    "${_NB}" add  "File Two.md"       \
      --title     "Root Title Two"    \
      --content   "Example content."

    "${_NB}" add  "Sample Folder/File One.md"                   \
      --title     "Sample Nested Title Two"                     \
      --content   "Sample nested content one."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Example Nested Title One"                    \
      --content   "Example nested content one."

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" use "Sample Notebook"
  }

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'one: <a.* href="http://localhost:6789/home:2?--per-page.*&--columns=.*">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    'example <a.* href="http://localhost:6789/Example Notebook:1/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q 'content \[\[2/1\]\] here'
}

@test "'browse <selector>' properly resolves duplicated wiki-style links." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example link one: [[Example Notebook:Example Folder/1]]

More example [[Example Notebook:Example Folder/1]] content.
HEREDOC
)"

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Nested Title One"                            \
      --content   "Nested content one."
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    'link one: <a.* href="http://localhost:6789/Example Notebook:1/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'


  printf "%s\\n" "${output}" | grep -q -v\
    'example <a.* href="http://localhost:6789/Example Notebook:1/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

@test "'browse <selector>' resolves wiki-style links in a different arrangement." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Root Title One"    \
      --content   "$(<<HEREDOC cat
Example content one [[Sample Folder/Nested Title One]] with more [[Example Notebook:File Two.md]].

More example [[Example Notebook:Example Folder/1]] content.
HEREDOC
)"

    "${_NB}" add  "File Two.md"                   \
      --title     "Root Title Two"                \
      --content   "Root content two."

    "${_NB}" add  "Sample Folder/File One.md"     \
      --title     "Nested Title One"              \
      --content   "Nested content one."

    "${_NB}" add  "Sample Folder/File Two.md"     \
      --title     "Nested Title Two"              \
      --content   "Nested content two."

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:File One.md"  \
      --title     "Root Title One"                \
      --content   "Root content one."

    "${_NB}" add  "Example Notebook:File Two.md"  \
      --title     "Root Title Two"                \
      --content   "Root content two."

    "${_NB}" add  "Example Notebook:Example Folder/File One.md" \
      --title     "Nested Title One"                            \
      --content   "Nested content one."

    "${_NB}" add  "Example Notebook:Example Folder/File Two.md" \
      --title     "Nested Title Two"                            \
      --content   "Nested content two."
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
    '<a.* href="http://localhost:6789/home:3/1?--per-page.*&--columns=.*">\[\[Sample Folder/Nested Title One\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    '<a.* href="http://localhost:6789/Example Notebook:2?--per-page.*&--columns=.*">\[\[Example Notebook:File Two.md\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
    '<a.* href="http://localhost:6789/Example Notebook:3/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'
}
