#!/usr/bin/env bats

load test_helper

# <title> #####################################################################

@test "'_render --title <title>' sets HTML '<title></title>' to <title>." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File One.md"   \
      --title     "Example Title One"     \
      --content   "Example content one."
  }

  run "${_NB}" helpers render             \
    "${NB_DIR}/home/Example File.md"      \
    --title "Example HTML Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                      ]]
  [[    "${output}"    =~  \<title\>Example\ HTML\ Title\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                    ]]
}

@test "'_render' without '--title' sets HTML '<title></title>' to default." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File One.md"   \
      --title     "Example Title One"     \
      --content   "Example content one."
  }

  run "${_NB}" helpers render             \
    "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>    ]]
  [[    "${output}"    =~  \<title\>nb\</title\>  ]]
}

@test "'_render --title <title> --pandoc' sets HTML '<title></title>' to <title>." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File One.md"   \
      --title     "Example Title One"     \
      --content   "Example content one."
  }

  run "${_NB}" helpers render             \
    "${NB_DIR}/home/Example File.md"      \
    --pandoc                              \
    --title "Example HTML Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                      ]]
  [[    "${output}"    =~  \<title\>Example\ HTML\ Title\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                    ]]
}

@test "'_render --pandoc' without '--title' sets HTML '<title></title>' to default." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File One.md"   \
      --title     "Example Title One"     \
      --content   "Example content one."
  }

  run "${_NB}" helpers render             \
    "${NB_DIR}/home/Example File.md"      \
    --pandoc

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>    ]]
  [[    "${output}"    =~  \<title\>nb\</title\>  ]]
}

# img tags ####################################################################

@test "'_render --pandoc' with markdown file preserves <img> tags after '## Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](/not-valid-1.png)

## Page Content

More example ![Example Image Two](/not-valid-2.png) content ![Example Image Three](/not-valid-3.png) here.
HEREDOC
)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.md" --pandoc


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\"/not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\>  ]]
  [[    "${output}"    =~  \
\<p\>More\ example\ \<img\ src=\"/not-valid-2.png\"\ alt=\"Example\ Image\ Two\"\ /\>\ content\     ]]
  [[    "${output}"    =~  \
\ content\ \<img\ src=\"/not-valid-3.png\"\ alt=\"Example\ Image\ Three\"\ /\>\ here.\</p\>         ]]
}

@test "'_render --bookmark --pandoc' with markdown file strips <img> tags after '## Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](/not-valid-1.png)

## Page Content

More example ![Example Image Two](/not-valid-2.png) content ![Example Image Three](/not-valid-3.png) here.
HEREDOC
)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.md" --bookmark --pandoc


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\"/not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\>  ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

@test "'_render --bookmark --pandoc' with markdown file strips <img> tags after '## Page Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](/not-valid-1.png)

## Page Content

More example ![Example Image Two](/not-valid-2.png) content ![Example Image Three](/not-valid-3.png) here.
HEREDOC
)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.md" --bookmark --pandoc


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\"/not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\>  ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

@test "'_render --bookmark' with html file strips <img> tags after '## Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.html" \
      --content   "$(<<HEREDOC cat
<p><a href="https://example.test" class="uri">https://example.test</a></p>
<h2 id="description">Description</h2>
<p>Example image one: <img src="/not-valid-1.png" alt="Example Image One" /></p>
<h2 id="content">Content</h2>
<p>More example <img src="/not-valid-2.png" alt="Example Image Two" /> content <img src="/not-valid-3.png" alt="Example Image Three" /> here.</p>
HEREDOC
)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.html" --bookmark


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\"/not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\>  ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

@test "'_render --bookmark' with html file strips <img> tags after '## Page Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.html" \
      --content   "$(<<HEREDOC cat
<p><a href="https://example.test" class="uri">https://example.test</a></p>
<h2 id="description">Description</h2>
<p>Example image one: <img src="/not-valid-1.png" alt="Example Image One" /></p>
<h2 id="page-content">Page Content</h2>
<p>More example <img src="/not-valid-2.png" alt="Example Image Two" /> content <img src="/not-valid-3.png" alt="Example Image Three" /> here.</p>
HEREDOC
)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.html" --bookmark


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\"/not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\>  ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

# code ########################################################################

@test "'_render' with .js file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.js" --content "console.log(\"hello\");"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.js"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                     ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>   ]]

  [[ "${output}"    =~  \<code\>              ]]
  [[ "${output}"    =~  \</code\>             ]]
  [[ "${output}"    =~  \"hello\"             ]]
}

@test "'_render --pandoc' with .js file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.js" --content "console.log(\"hello\");"
  }

  run "${_NB}" helpers render --pandoc "${NB_DIR}/home/Example File.js"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                 ]]

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"         ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ js\"\>   ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;               ]]
}

@test "'_render --pandoc' with .bash file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.bash" --content "echo \"hello\""
  }

  run "${_NB}" helpers render --pandoc "${NB_DIR}/home/Example File.bash"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                 ]]

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"         ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ bash\"\> ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;               ]]
}

# with pandoc #################################################################

@test "'_render --pandoc' prints complete HTML document with piped input." {
  echo "<span class=\"sample-class\">Example content.</span>" | {
    run "${_NB}" helpers render --pandoc

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"  -eq 0 ]]

    printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
    printf "%s\\n" "${output}" | grep -q "<head>"
    printf "%s\\n" "${output}" | grep -q "<body>"
    printf "%s\\n" "${output}" | grep -q "</body>"
    printf "%s\\n" "${output}" | grep -q "</body>"

    printf "%s\\n" "${output}" | grep -q \
      "<span class=\"sample-class\">Example content.</span>"
  }
}

@test "'_render --pandoc' prints complete HTML document with string input." {
  run "${_NB}" helpers render  --pandoc \
    "<span class=\"sample-class\">Example content.</span>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<span class=\"sample-class\">Example content.</span>"
}

@test "'_render --pandoc' prints markdown document converted to HTML with file input." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --title     "Example Title" \
      --content   "Example content with *formatting* and [a link](https://example.test)"
  }

  run "${_NB}" helpers render  --pandoc "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<h1 id=\"example-title\">Example Title</h1>"
  printf "%s\\n" "${output}" | grep -q \
    "Example content with <em>formatting</em> and <a rel=\"noopener noreferrer\" href=\"https://example.test\">a link</a>"
}

# without pandoc ##############################################################

@test "'_render' prints complete HTML document with piped input." {
  echo "<span class=\"sample-class\">Example content.</span>" | {
    run "${_NB}" helpers render

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"  -eq 0 ]]

    printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
    printf "%s\\n" "${output}" | grep -q "<head>"
    printf "%s\\n" "${output}" | grep -q "<body>"
    printf "%s\\n" "${output}" | grep -q "</body>"
    printf "%s\\n" "${output}" | grep -q "</body>"

    printf "%s\\n" "${output}" | grep -q \
      "<span class=\"sample-class\">Example content.</span>"
  }
}

@test "'_render' prints complete HTML document with string input." {
  run "${_NB}" helpers render \
    "<span class=\"sample-class\">Example content.</span>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "<span class=\"sample-class\">Example content.</span>"
}

@test "'_render' prints raw markdown document with file input." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" \
      --title     "Example Title" \
      --content   "Example content with *formatting* and [a link](https://example.test)"
  }

  run "${_NB}" helpers render "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q "<!DOCTYPE html>"
  printf "%s\\n" "${output}" | grep -q "<head>"
  printf "%s\\n" "${output}" | grep -q "<body>"
  printf "%s\\n" "${output}" | grep -q "</body>"
  printf "%s\\n" "${output}" | grep -q "</body>"

  printf "%s\\n" "${output}" | grep -q \
    "# Example Title"
  printf "%s\\n" "${output}" | grep -q \
    "Example content with \*formatting\* and \[a link\](https://example.test)"
}
