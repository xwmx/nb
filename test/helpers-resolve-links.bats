#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'_resolve_links' return status 1 and prints nothing when passed blank argument." {
  {
    "${_NB}" init
  }

  run "${_NB}" helpers resolve_links ""

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 1  ]]
  [[ -z "${output}"         ]]
}

# local #######################################################################

@test "'_resolve_links --browse' with .org resolves local notebook links." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    declare _content=
    _content+="Selector link one: [[local:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description (more)]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="${_NEWLINE}#tag4 #tag5 #tag6 #tag7${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _expected_params="?--per-page=2&--columns=70&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${_TMP_DIR}/Local Notebook"        \
    --type org                          \
    --page 123 --per-page 2             \
    --terminal < "${_TMP_DIR}/Local Notebook/Sample Folder/Sample Nested File One.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: \[\[http://localhost:6789/local:2/1${_expected_params}\]\[\[\[local:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: \[\[http://localhost:6789/local:3${_expected_params}\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: \[\[http://localhost:6789/local:${_expected_params}&--query=%23tag_1\]\[#tag_1\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: \[\[http://localhost:6789/local:${_expected_params}&--query=%23tag-2\]\[#tag-2\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link with description: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\[Example Description (more)\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/local:${_expected_params}&--query=%23tag3\]\[#tag3\]\]$"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/local:${_expected_params}&--query=%23tag4\]\[#tag4\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/local:${_expected_params}&--query=%23tag5\]\[#tag5\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/local:${_expected_params}&--query=%23tag6\]\[#tag6\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/local:${_expected_params}&--query=%23tag7\]\[#tag7\]\]"
}

@test "'_resolve_links --browse' with .html resolves local notebook links." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    declare _content=
    _content+="Selector link one: [[local:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      "${_TMP_DIR}/Local Notebook/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]

    printf "\\n#tag8 #tag9\\n" >> "${_html_file_path}"

    declare _expected_params="?--per-page=2&--columns=70&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${_TMP_DIR}/Local Notebook"        \
    --page 123 --per-page 2 --terminal  < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: <a.* href=\"http://localhost:6789/local:2/1${_expected_params}\">\[\[local:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: <a.* href=\"http://localhost:6789/local:Root Title One${_expected_params}\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: <a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: <a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag3\">#tag3</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag4\">#tag4</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag5\">#tag5</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag6\">#tag6</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag7\">#tag7</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789?url=http%3A%2F%2Fexample.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a.* href=\"http://localhost:6789?url=https%3A%2F%2Ftest.test\">Example Outbound Link Two</a> •</p>"

  printf "%s\\n" "${output}" | grep -q  \
"<a href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag8\">#tag8</a>"

  printf "%s\\n" "${output}" | grep -q  \
"<a href=\"http://localhost:6789/local:${_expected_params}&--query=%23tag9\">#tag9</a>"
}

# <nav> and <code> ############################################################

@test "'_resolve_links --browse' with .html skips nav and code sections." {
  {
    "${_NB}" init


    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "$(cat <<HEREDOC
[[1]]

<nav>
[[2]]
</nav>

[[3]]

<code>
[[4]]
</code>

[[5]]
HEREDOC
)"

    "${_NB}" add  "Root File One.md"    \
      --title     "Root Title One"      \
      --content   "Root content one."

    "${_NB}" add  "Root File Two.md"    \
      --title     "Root Title Two"      \
      --content   "Root content two."

    "${_NB}" add  "Root File Three.md"  \
      --title     "Root Title Three"    \
      --content   "Root content three."

    "${_NB}" add  "Root File Four.md"   \
      --title     "Root Title Four"     \
      --content   "Root content four."

    "${_NB}" add  "Root File Five.md"   \
      --title     "Root Title Five"     \
      --content   "Root content five."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${NB_DIR}/home"                    \
    --page 123 --per-page 2 --terminal < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"<h1 id=\"sample-nested-title-one\">Sample Nested Title One</h1>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a href=\"http://localhost:6789/home:1?--per-page=2&--columns=70\">\[\[1\]\]</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<nav>${_NEWLINE}\[\[2\]\]${_NEWLINE}</nav>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a href=\"http://localhost:6789/home:3?--per-page=2&--columns=70\">\[\[3\]\]</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><code> \[\[4\]\] </code></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a href=\"http://localhost:6789/home:5?--per-page=2&--columns=70\">\[\[5\]\]</a></p>"
}

# .html #######################################################################

@test "'_resolve_links --browse' with .html includes pagination params in tag links." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]

    printf "\\n#tag8 #tag9\\n" >> "${_html_file_path}"
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${NB_DIR}/home"                    \
    --page 123 --per-page 2 --terminal  < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: <a.* href=\"http://localhost:6789/home:2/1?--per-page=2&--columns=70\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: <a.* href=\"http://localhost:6789/home:Root Title One?--per-page=2&--columns=70\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: <a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: <a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag3\">#tag3</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag4\">#tag4</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag5\">#tag5</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag6\">#tag6</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag7\">#tag7</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789?url=http%3A%2F%2Fexample.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a.* href=\"http://localhost:6789?url=https%3A%2F%2Ftest.test\">Example Outbound Link Two</a> •</p>"

  printf "%s\\n" "${output}" | grep -q  \
"<a href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag8\">#tag8</a>"

  printf "%s\\n" "${output}" | grep -q  \
"<a href=\"http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag9\">#tag9</a>"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]], tags, and outbound links in partial .html files to .html links to local web server URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${NB_DIR}/home" < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: <a.* href=\"http://localhost:6789/home:2/1\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: <a.* href=\"http://localhost:6789/home:Root Title One\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: <a.* href=\"http://localhost:6789/home:?--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: <a.* href=\"http://localhost:6789/home:?--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/home:?--query=%23tag3\">#tag3</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789/home:?--query=%23tag4\">#tag4</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--query=%23tag5\">#tag5</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--query=%23tag6\">#tag6</a> "

  printf "%s\\n" "${output}" | grep -q  \
" <a.* href=\"http://localhost:6789/home:?--query=%23tag7\">#tag7</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789?url=http%3A%2F%2Fexample.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a href=\"http://localhost:6789?url=https%3A%2F%2Ftest.test\">Example Outbound Link Two</a> •</p>"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]], tags, and outbound links in standalone .html files to .html links to local web server URLs without altering CSS values." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      --standalone                      \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links    \
    "${NB_DIR}/home"                    \
    --browse < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link one: <a.* href=\"http://localhost:6789/home:2/1\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link two: <a.* href=\"http://localhost:6789/home:Root Title One\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag one: <a.* href=\"http://localhost:6789/home:?--query=%23tag_1\">#tag_1</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag two: <a.* href=\"http://localhost:6789/home:?--query=%23tag-2\">#tag-2</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
      "<p><a.* href=\"http://localhost:6789/home:?--query=%23tag3\">#tag3</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
      "color: \#1a1a1a;"

  printf "%s\\n" "${output}" | grep -q  \
      "<p><a.* href=\"http://localhost:6789/home:?--query=%23tag4\">#tag4</a> "

  printf "%s\\n" "${output}" | grep -q  \
      " <a.* href=\"http://localhost:6789/home:?--query=%23tag5\">#tag5</a> "

  printf "%s\\n" "${output}" | grep -q  \
      " <a.* href=\"http://localhost:6789/home:?--query=%23tag6\">#tag6</a> "

  printf "%s\\n" "${output}" | grep -q  \
      " <a.* href=\"http://localhost:6789/home:?--query=%23tag7\">#tag7</a></p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://localhost:6789?url=http%3A%2F%2Fexample.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a.* href=\"http://localhost:6789?url=https%3A%2F%2Ftest.test\">Example Outbound Link Two</a> •</p>"
}

@test "'_resolve_links' resolves [[wiki-style links]], tags, and outbound links in partial .html files to .html links to local file URLs without linking tags or outbound URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links "${NB_DIR}/home" < "${_html_file_path:-}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link one: <a.* href=\"file://${NB_DIR}/home/Example%20Folder/Example%20Nested%20File%20One.md\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link two: <a.* href=\"file://${NB_DIR}/home/Root%20File%20One.md\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
      "<p>#tag3</p>"

  printf "%s\\n" "${output}" | grep -q  \
      "<p>#tag4 #tag5 #tag6 #tag7</p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://example.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a.* href=\"https://test.test\">Example Outbound Link Two</a> •</p>"
}

@test "'_resolve_links' resolves [[wiki-style links]] in standalone .html files to .html links to local file URLs without linking tags or outbound URLs or altering CSS values." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="#tag4 #tag5 #tag6 #tag7${_NEWLINE}${_NEWLINE}"
    _content+="[Example Outbound Link One](http://example.com) • "
    _content+="[Example Outbound Link Two](https://test.test) • "

    "${_NB}" add  "Sample Folder/Sample Nested File One.md"   \
      --title     "Sample Nested Title One"                   \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."

    declare _html_file_path="${_TMP_DIR}/unlinked.html"
    touch "${_html_file_path:?}"

    cd "${_TMP_DIR}"
    git init &>/dev/null

    pandoc                              \
      --from=markdown                   \
      --to=html                         \
      --output="${_html_file_path}"     \
      --standalone                      \
      "${NB_DIR}/home/Sample Folder/Sample Nested File One.md"

    [[ "$(cat "${_html_file_path}")" =~ \<h1\ id=\"sample-nested-title-one ]]
  }

  run "${_NB}" helpers resolve_links "${NB_DIR}/home" < "${_html_file_path}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link one: <a.* href=\"file://${NB_DIR}/home/Example%20Folder/Example%20Nested%20File%20One.md\">\[\[home:2/1\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Selector link two: <a.* href=\"file://${NB_DIR}/home/Root%20File%20One.md\">\[\[Root Title One\]\]</a> •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q  \
      "Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
      "<p>#tag3</p>"

  printf "%s\\n" "${output}" | grep -q  \
      "color: \#1a1a1a;"

  printf "%s\\n" "${output}" | grep -q  \
      "<p>#tag4 #tag5 #tag6 #tag7</p>"

  printf "%s\\n" "${output}" | grep -q  \
"<p><a.* href=\"http://example.com\">Example Outbound Link One</a> •"

  printf "%s\\n" "${output}" | grep -q  \
"<a.* href=\"https://test.test\">Example Outbound Link Two</a> •</p>"
}

# .org ########################################################################

@test "'_resolve_links --browse' with .org includes pagination params in tag links." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description (more)]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="${_NEWLINE}#tag4 #tag5 #tag6 #tag7${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links    \
    --browse                            \
    "${NB_DIR}/home"                    \
    --type org                          \
    --page 123 --per-page 2             \
    --terminal < "${NB_DIR}/home/Sample Folder/Sample Nested File One.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: \[\[http://localhost:6789/home:2/1?--per-page=2&--columns=70\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: \[\[http://localhost:6789/home:3?--per-page=2&--columns=70\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: \[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag_1\]\[#tag_1\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: \[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag-2\]\[#tag-2\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link with description: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\[Example Description (more)\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag3\]\[#tag3\]\]$"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag4\]\[#tag4\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag5\]\[#tag5\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag6\]\[#tag6\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--per-page=2&--columns=70&--query=%23tag7\]\[#tag7\]\]$"
}

@test "'_resolve_links --browse' resolves [[wiki-style links]] and #tags in .org files to .org links to local web server URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description (more)]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="${_NEWLINE}#tag4 #tag5 #tag6 #tag7${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links    \
      "${NB_DIR}/home"                  \
      --browse                          \
      --type org < "${NB_DIR}/home/Sample Folder/Sample Nested File One.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                 ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: \[\[http://localhost:6789/home:2/1\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: \[\[http://localhost:6789/home:3\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: \[\[http://localhost:6789/home:?--query=%23tag_1\]\[#tag_1\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: \[\[http://localhost:6789/home:?--query=%23tag-2\]\[#tag-2\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link with description: \[\[http://localhost:6789?url=http%3A%2F%2Fexample.com\]\[Example Description (more)\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/home:?--query=%23tag3\]\[#tag3\]\]$"

  printf "%s\\n" "${output}" | grep -q  \
"^\[\[http://localhost:6789/home:?--query=%23tag4\]\[#tag4\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--query=%23tag5\]\[#tag5\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--query=%23tag6\]\[#tag6\]\] "

  printf "%s\\n" "${output}" | grep -q  \
" \[\[http://localhost:6789/home:?--query=%23tag7\]\[#tag7\]\]$"
}

@test "'_resolve_links' resolves [[wiki-style links]] in .org files to .org links to local file URLs." {
  {
    "${_NB}" init

    declare _content=
    _content+="Selector link one: [[home:2/1]] • "
    _content+="Selector link two: [[Root Title One]] • "
    _content+="Tag one: #tag_1 • "
    _content+="Tag two: #tag-2 • "
    _content+="Tag not valid: 123#not-valid-tag • "
    _content+="Org mode link: [[http://example.com]] • "
    _content+="Org mode link with description: [[http://example.com][Example Description (more)]] • "
    _content+="Internal Org mode link: [[#sample]] • "

    _content+="${_NEWLINE}${_NEWLINE}#tag3${_NEWLINE}${_NEWLINE}"
    _content+="${_NEWLINE}#tag4 #tag5 #tag6 #tag7${_NEWLINE}"

    "${_NB}" add  "Sample Folder/Sample Nested File One.org"  \
      --title     "Example Org Mode Title"                    \
      --content   "${_content:-}"

    "${_NB}" add  "Example Folder/Example Nested File One.md" \
      --title     "Example Nested Title One"                  \
      --content   "Example nested content one."

    "${_NB}" add  "Root File One.md"                          \
      --title     "Root Title One"                            \
      --content   "Root content one."
  }

  run "${_NB}" helpers resolve_links    \
    "${NB_DIR}/home"                    \
    --type org < "${NB_DIR}/home/Sample Folder/Sample Nested File One.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"  -eq 0               ]]

  printf "%s\\n" "${output}" | grep -q  \
"Selector link one: \[\[file://${NB_DIR}/home/Example%20Folder/Example%20Nested%20File%20One.md\]\[\[\[home:2/1\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Selector link two: \[\[file://${NB_DIR}/home/Root%20File%20One.md\]\[\[\[Root Title One\]\]\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag one: #tag_1 •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag two: #tag-2 •"

  printf "%s\\n" "${output}" | grep -q  \
"Tag not valid: 123#not-valid-tag •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link: \[\[http://example.com\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Org mode link with description: \[\[http://example.com\]\[Example Description (more)\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"Internal Org mode link: \[\[#sample\]\] •"

  printf "%s\\n" "${output}" | grep -q  \
"^#tag3$"

  printf "%s\\n" "${output}" | grep -q  \
"^#tag4 #tag5 #tag6 #tag7$"
}
