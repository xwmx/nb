#!/usr/bin/env bats

load test_helper

export _IMOGI="🌄"
export NB_SERVER_PORT=6789

# pdf items ###################################################################

@test "'browse' with local notebook renders pdf item in an '<iframe>'." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    declare _filename="example.pdf"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/local/${_filename}"
    _raw_url_pattern+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                        ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                     ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>    ]]

  [[    "${output}"    =~  \
\<iframe\ src=\"${_raw_url_pattern}\"\ width=\"100%\"\ height=\"700px\"\>\</iframe\>  ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

@test "'browse' renders pdf item in an '<iframe>'." {
  {
    "${_NB}" init

    declare _filename="example.pdf"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/home/${_filename}"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                        ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                     ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>    ]]

  [[    "${output}"    =~  \
\<iframe\ src=\"${_raw_url_pattern}\"\ width=\"100%\"\ height=\"700px\"\>\</iframe\>  ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

# audio items #################################################################

@test "'browse' with local notebook renders audio item as '<audio>' element." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    declare _filename="nb.mp3"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/local/${_filename}"
    _raw_url_pattern+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                      ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                   ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>  ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<audio\ controls\>     ]]
  [[    "${output}"    =~  \
media-item\"\>${_NEWLINE}.*\<audio\ controls\>${_NEWLINE}.*\<source\ src=           ]]
  [[    "${output}"    =~  \
\<source\ src=\"${_raw_url_pattern}\"\ type=\"audio/mpeg\"\>                        ]]
  [[    "${output}"    =~  \
type=\"audio/mpeg\"\>${_NEWLINE}.*\</audio\>${_NEWLINE}.*\</div\>                   ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

@test "'browse' renders audio item as '<audio>' element." {
  {
    "${_NB}" init

    declare _filename="nb.mp3"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/home/${_filename}"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                      ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                   ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>  ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<audio\ controls\>     ]]
  [[    "${output}"    =~  \
media-item\"\>${_NEWLINE}.*\<audio\ controls\>${_NEWLINE}.*\<source\ src=           ]]
  [[    "${output}"    =~  \
\<source\ src=\"${_raw_url_pattern}\"\ type=\"audio/mpeg\"\>                        ]]
  [[    "${output}"    =~  \
type=\"audio/mpeg\"\>${_NEWLINE}.*\</audio\>${_NEWLINE}.*\</div\>                   ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

# video items #################################################################

@test "'browse' with local notebook renders video item as '<video>' element." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    declare _filename="nb.mp4"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/local/${_filename}"
    _raw_url_pattern+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                      ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                   ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>  ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<video\ width=\"320\"  ]]
  [[    "${output}"    =~  \
${_NEWLINE}.*\<video\ width=\"320\"\ height=\"240\"\ controls\>${_NEWLINE}          ]]
  [[    "${output}"    =~  \
controls\>${_NEWLINE}.*\<source\ src=\"${_raw_url_pattern}\"\ type=\"video/mp4\"\>  ]]
  [[    "${output}"    =~  \
type=\"video/mp4\"\>${_NEWLINE}.*\</video\>${_NEWLINE}.*\</div\>                    ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

@test "'browse' renders video item as '<video>' element." {
  {
    "${_NB}" init

    declare _filename="nb.mp4"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/${_filename}"

    declare _raw_url_pattern="http://localhost:6789/--original/home/${_filename}"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                        ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                      ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                   ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>  ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<video\ width=\"320\"  ]]
  [[    "${output}"    =~  \
${_NEWLINE}.*\<video\ width=\"320\"\ height=\"240\"\ controls\>${_NEWLINE}          ]]
  [[    "${output}"    =~  \
controls\>${_NEWLINE}.*\<source\ src=\"${_raw_url_pattern}\"\ type=\"video/mp4\"\>  ]]
  [[    "${output}"    =~  \
type=\"video/mp4\"\>${_NEWLINE}.*\</video\>${_NEWLINE}.*\</div\>                    ]]

  [[    "${output}"    =~  \
\<p\ align=\"center\"\ class=\"media\-caption\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\>   ]]
  [[    "${output}"    =~  \
\<a.*\ href=\"${_raw_url_pattern}\"\>${_NEWLINE}.*${_filename}${_NEWLINE}.*\</a\>${_NEWLINE}.*\</p\>  ]]
}

# HTML <title> ################################################################

@test "'browse <folder>/<folder>/<id>' with local notebook sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add  "Example Folder/Sample Folder/Example File.md"          \
      --content "Example content."

    sleep 1
  }

  run "${_NB}" browse "Example Folder/Sample Folder/1" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                              ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                            ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ local:1/1/1\</title\> ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                          ]]
}

@test "'browse <id>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                        ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                      ]]
}

@test "'browse <folder>/<folder>/<id>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/Example File.md" --content "Example content."

    sleep 1
  }

  run "${_NB}" browse "Example Folder/Sample Folder/1" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                              ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                            ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ home:1/1/1\</title\>  ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                          ]]
}

@test "'browse <notebook>:<folder>/<folder>/<filename>' sets HTML <title> to CLI command." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:Example Folder/Sample Folder/Example File.md" \
      --content "Example content."

    sleep 1
  }

  run "${_NB}" browse "Example Notebook:Example Folder/Sample Folder/1" --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                          ]]
  [[    "${output}"    =~  \<title\>${_ME}\ browse\ Example\\\ Notebook:1/1/1\</title\> ]]
  [[ !  "${output}"    =~  \<title\>nb\</title\>                                        ]]
}

# image URLs ##################################################################

@test "'browse' with local notebook rewrites image paths to --original URLs." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add                    \
      --filename  "Example File.md" \
      --content   "$(<<HEREDOC cat
# Example Title

Example ![](nb.png) content ![](Example Folder/nb.png).

More ![](https://example.test/example.png) demo content ![](http://example.test/sample.png).
HEREDOC
)"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"

    "${_NB}" add folder "Example Folder"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png" Example\ Folder/

    [[ -f "${_TMP_DIR}/Local Notebook/nb.png"                 ]]
    [[ -f "${_TMP_DIR}/Local Notebook/Example Folder/nb.png"  ]]

    declare _raw_url_pattern_one="http://localhost:6789/--original/local/nb.png"
    _raw_url_pattern_one+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    declare _raw_url_pattern_two="http://localhost:6789/--original/local/Example%20Folder/nb.png"
    _raw_url_pattern_two+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                    ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                 ]]
  [[    "${output}"    =~  \
\<p\>Example\ \<img\ src=\"${_raw_url_pattern_one}\"\ \/\>\ content\              ]]
  [[    "${output}"    =~  \
\/\>\ content\ \<img\ src=\"${_raw_url_pattern_two}\"\ /\>.\</p\>                 ]]
  [[    "${output}"    =~  \
\<p\>\More\ \<img\ src=\"https://example.test/example.png\"\ \/\>\ demo\ content  ]]
  [[    "${output}"    =~  \
\/\>\ demo\ content\ \<img\ src=\"http://example.test/sample.png\"\ /\>.\</p\>    ]]
}

@test "'browse' rewrites image paths to --original URLs." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      --filename  "Example File.md" \
      --content   "$(<<HEREDOC cat
# Example Title

Example ![](nb.png) content ![](Example Folder/nb.png).

More ![](https://example.test/example.png) demo content ![](http://example.test/sample.png).
HEREDOC
)"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"

    "${_NB}" add folder "Example Folder"

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png" Example\ Folder/

    [[ -f "${NB_DIR}/home/nb.png"                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/nb.png"  ]]

    declare _raw_url_pattern_one="http://localhost:6789/--original/home/nb.png"
    declare _raw_url_pattern_two="http://localhost:6789/--original/home/Example%20Folder/nb.png"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                    ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                 ]]
  [[    "${output}"    =~  \
\<p\>Example\ \<img\ src=\"${_raw_url_pattern_one}\"\ \/\>\ content\              ]]
  [[    "${output}"    =~  \
\/\>\ content\ \<img\ src=\"${_raw_url_pattern_two}\"\ /\>.\</p\>                 ]]
  [[    "${output}"    =~  \
\<p\>\More\ \<img\ src=\"https://example.test/example.png\"\ \/\>\ demo\ content  ]]
  [[    "${output}"    =~  \
\/\>\ demo\ content\ \<img\ src=\"http://example.test/sample.png\"\ /\>.\</p\>    ]]
}

# image items #################################################################

@test "'browse' with local notebook renders image item as '<img>' element." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"

    declare _raw_url_pattern="http://localhost:6789/--original/local/nb.png"
    _raw_url_pattern+="\?--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                        ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                     ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>    ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\> ]]
  [[    "${output}"    =~  \
${_raw_url_pattern}\"\>${_NEWLINE}.*\<img\ src=\"${_raw_url_pattern}\"\                           ]]
  [[    "${output}"    =~  \
\"${_raw_url_pattern}\"\ alt=\"${_IMOGI}\ nb.png\"\ /\>${_NEWLINE}.*\</a\>${_NEWLINE}.*\</div\>    ]]
}

@test "'browse' renders image item as '<img>' element." {
  {
    "${_NB}" init

    "${_NB}" import "${NB_TEST_BASE_PATH}/fixtures/nb.png"

    declare _raw_url_pattern="http://localhost:6789/--original/home/nb.png"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                                          ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                                        ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>                     ]]
  [[    "${output}"    =~  \</span\>\ \<a.*\ href=\"${_raw_url_pattern}\"\>↓\</a\>    ]]

  [[    "${output}"    =~  \
\<div\ align=\"center\"\ class=\"media-item\"\>${_NEWLINE}.*\<a.*\ href=\"${_raw_url_pattern}\"\> ]]
  [[    "${output}"    =~  \
${_raw_url_pattern}\"\>${_NEWLINE}.*\<img\ src=\"${_raw_url_pattern}\"\                           ]]
  [[    "${output}"    =~  \
\"${_raw_url_pattern}\"\ alt=\"${_IMOGI}\ nb.png\"\ /\>${_NEWLINE}.*\</a\>${_NEWLINE}.*\</div\>   ]]
}

# <img> stripping #############################################################

@test "'browse' strips <img> tags after '## Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename  "Example File.bookmark.md"  \
      --title     "Example Title"             \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](not-valid-1.png)

## Content

More example ![Example Image Two](not-valid-2.png) content ![Example Image Three](not-valid-3.png) here.
HEREDOC
)"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>       ]]
  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\".*not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\> ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

@test "'browse' strips <img> tags after '## Page Content' heading." {
  {
    "${_NB}" init

    "${_NB}" add                              \
      --filename  "Example File.bookmark.md"  \
      --title     "Example Title"             \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](not-valid-1.png)

## Page Content

More example ![Example Image Two](not-valid-2.png) content ![Example Image Three](not-valid-3.png) here.
HEREDOC
)"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>       ]]
  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\".*not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\> ]]
  [[    "${output}"    =~  \<p\>More\ example\ \ content\ \ here.\</p\> ]]
}

@test "'browse' renders <img> tags anywhere in non-bookmark items." {
  {
    "${_NB}" init

    "${_NB}" add                    \
      --filename  "Example File.md" \
      --title     "Example Title"   \
      --content   "$(<<HEREDOC cat
<https://example.test>

## Description

Example image one: ![Example Image One](not-valid-1.png)

## Content

More example ![Example Image Two](not-valid-2.png) content ![Example Image Three](not-valid-3.png) here.
HEREDOC
)"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                      ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                    ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\> ]]
  [[    "${output}"    =~  \
\<p\>Example\ image\ one:\ \<img\ src=\".*not-valid-1.png\"\ alt=\"Example\ Image\ One\"\ /\>\</p\> ]]
  [[    "${output}"    =~  \
\<p\>More\ example\ \<img\ src=\".*not-valid-2.png\"\ alt=\"Example\ Image\ Two\"\ /\>\ content\    ]]
  [[    "${output}"    =~  \
\ content\ \<img\ src=\".*not-valid-3.png\"\ alt=\"Example\ Image\ Three\"\ /\>\ here.\</p\>        ]]

}

# local notebook ##############################################################

@test "'browse <folder-id>/<id>' with local notebook serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  {
    "${_NB}" init

    mkdir -p "${_TMP_DIR}/Local Notebook"
    cd "${_TMP_DIR}/Local Notebook"

    "${_NB}" notebooks init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1

    declare _expected_params="?--per-page=.*&--columns=.*&--local=${_TMP_DIR//$'/'/%2F}%2FLocal%20Notebook"
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/local:Example Title${_expected_params}\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# .pdf ########################################################################

@test "'browse' with .pdf file and 'pdftotext' enabled serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  hash "pdftotext" 2>/dev/null || skip
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"                         \
      --title     "Example Title"                           \
      --content   "Example content."

    "${_NB}" import                                         \
      "${NB_TEST_BASE_PATH}/fixtures/Example File.pdf"      \
      "Example Folder/"

    [[ -f "${NB_DIR}/home/Example Folder/Example File.pdf"  ]]

    sleep 1
  }

  # TODO: improve
  NB_BROWSE_PDF_TO_TEXT_ENABLED=1 run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<p>Example PDF File"

  printf "%s\\n" "${output}" | grep -q \
"<a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*\">\[\[home:1\]\]</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*&--query=%23tag1\">\#tag1</a>"

  printf "%s\\n" "${output}" | grep -q \
"<a.* href=\"http://localhost:6789/home:1?--per-page=.*&--columns=.*&--query=%23tag2\">\#tag2</a>"
}

# nb --browse / nb -b #########################################################

@test "'nb --browse <folder-id>/<id>' serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1
  }

  run "${_NB}" --browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

@test "'nb -b <folder-id>/<id>' serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1
  }

  run "${_NB}" -b 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# edge cases ##################################################################

@test "'browse <folder-id>/<id>' serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs without altering home link." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<a.* href=\"http://localhost:6789/?--per-page.*&--columns.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# syntax highlighting #########################################################

@test "'browse <item>' includes syntax highlighting." {
  {
    "${_NB}" init

    "${_NB}" add "example.rb" --content  "puts \"Hello World\""

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    ==  0                                            ]]
  [[    "${output}"    =~  \<\!DOCTYPE\ html\>                          ]]

  [[    "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>       ]]

  [[    "${output}"    =~  pre\ \>\ code.sourceCode                     ]]

  [[    "${output}"    =~  \
\<div\ class=\"sourceCode\"\ id=\"cb1\"\>\<pre\ class=\"sourceCode\ rb\"\>\<code\  ]]

  [[    "${output}"    =~  \<code\ class=\"sourceCode\ ruby\"\>         ]]

  [[    "${output}"    =~  \
\<span\ class=\"fu\"\>puts\</span\>\ \<span\ class=\"st\"\>\&quot\;Hello\ World\&quot\;\</span\> ]]
}

# code ########################################################################

@test "'browse' with .bash file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.bash" --content "echo \"hello\""

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                       ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                     ]]

  [[ "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>  ]]

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/?--per-page=.*"><span class="dim">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
'<span class="dim">·</span> <a.* href="http://localhost:6789/home:?--per-page=.*">home</a\>'

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"             ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ bash\"\>     ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;                   ]]
}

@test "'browse' with .js file serves file in a code block." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.js" --content "console.log(\"hello\");"

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                       ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                     ]]

  [[ "${output}"    =~  \<nav\ class=\"header-crumbs\"\>\<h1\>  ]]
  [[ "${output}"    =~  header-crumbs.*↓                        ]]

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/?--per-page=.*"><span class="dim">❯</span>nb</a>'

  printf "%s\\n" "${output}" | grep -q \
'<span class="dim">·</span> <a.* href="http://localhost:6789/home:?--per-page=.*">home</a\>'

  [[ "${output}"    =~  \<div\ class=\"sourceCode\"             ]]
  [[ "${output}"    =~  \<pre\ class=\"sourceCode\ js\"\>       ]]
  [[ "${output}"    =~  \&quot\;hello\&quot\;                   ]]
}

# .odt ########################################################################

@test "'browse' with .odt file serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
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

    sleep 1
  }

  run "${_NB}" browse 2/2 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]


  [[ "${output}"    =~  header-crumbs.*↓    ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\"><span id=\"anchor\"></span>Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# .docx #######################################################################

@test "'browse' with .docx file serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
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

    sleep 1
  }

  run "${_NB}" browse 2/2 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"    =~  header-crumbs.*↓    ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# .org ########################################################################

@test "'browse' with .org file serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.org" \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"    =~  header-crumbs.*↓    ]]

  # TODO: .org / org mode titles in pandoc HTML output?
  # [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>                     ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:1?--per-page=.*&amp;--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

# markdown ####################################################################

@test "'browse <folder-id>/<id>' serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"

    sleep 1
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"    =~  header\-crumbs.*↓   ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

@test "'browse <folder-name>/<id>' serves the rendered HTML page with [[wiki-style links]] resolved to internal web server URLs." {
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

  [[ "${output}"    =~  header-crumbs.*↓    ]]

  printf "%s\\n" "${output}" | grep -q \
"<h1 id=\"title-one\">Title One</h1>"

  printf "%s\\n" "${output}" | grep -q \
"<p>Example content. <a.* href=\"http://localhost:6789/home:Example Title?--per-page=.*&--columns=.*\">"

  printf "%s\\n" "${output}" | grep -q \
"\[\[Example Title\]\]</a></p>"
}

@test "'browse <item-selector>' properly resolves titled [[wiki-style links]]." {
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

    sleep 1
  }

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
'one: <a.* href="http://localhost:6789/home:Root Title Two?--per-page.*&--columns=.*">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
'example <a.* href="http://localhost:6789/Example Notebook:Example Folder/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q \
'content <a.* href="http://localhost:6789/home:3/1?--per-page.*&--columns=.*">\[\[3/1\]\]</a> here'
}

@test "'browse <item-selector>' properly resolves titled [[wiki-style links]] and skips links with non-resolving selectors." {
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

    sleep 1
  }

  run "${_NB}" browse home:1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
'one: <a.* href="http://localhost:6789/home:Root Title Two?--per-page.*&--columns=.*">\[\[Root Title Two\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
'example <a.* href="http://localhost:6789/Example Notebook:Example Folder/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a> content'

  printf "%s\\n" "${output}" | grep -q \
'content <a.* href="http://localhost:6789/home:2/1?--per-page.*&--columns=.*">\[\[2/1\]\]</a> here'
}

@test "'browse <selector>' properly resolves duplicated [[wiki-style links]] in HTML." {
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

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
'link one: <a.* href="http://localhost:6789/Example Notebook:Example Folder/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'


  printf "%s\\n" "${output}" | grep -q -v\
'example <a.* href="http://localhost:6789/Example Notebook:Example Folder/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'
}

@test "'browse <selector>' resolves [[wiki-style links]] in a different arrangement in HTML." {
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

    sleep 1
  }

  run "${_NB}" browse 1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/home:Sample Folder/Nested Title One?--per-page.*&--columns=.*">\[\[Sample Folder/Nested Title One\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/Example Notebook:File Two.md?--per-page.*&--columns=.*">\[\[Example Notebook:File Two.md\]\]</a>'

  printf "%s\\n" "${output}" | grep -q \
'<a.* href="http://localhost:6789/Example Notebook:Example Folder/1?--per-page.*&--columns=.*">\[\[Example Notebook:Example Folder/1\]\]</a>'
}
