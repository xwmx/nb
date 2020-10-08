#!/usr/bin/env bats

load test_helper

# `_clear_cache()` ############################################################

@test "\`_clear_cache()\` clears the cache." {
  {
    "${_NB}" init

    mkdir -p "${NB_DIR}/.cache"

    echo "Example" > "${NB_DIR}/.cache/example"

    [[ -e "${NB_DIR}/.cache" ]]
  }

  run "${_NB}" notebooks add "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                  ]]
  [[ -e "${NB_DIR}/.cache"            ]]
  [[ -z "$(ls -A "${NB_DIR}/.cache")" ]]
}

# `_get_title()` ##############################################################

@test "\`_get_title()\` detects and returns titles." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
# Title One
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "two.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "three.md"
# Title Three
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "four.md"
---
summary: Example Summary
custom: variable
---
# Title Four
line six
line seven
line eight
HEREDOC
    cat <<HEREDOC | "${_NB}" add "five.md"
---
summary: Example Summary
title: Title Five
custom: variable
---
# Second Title Five
line seven
line eight
line nine
HEREDOC
    cat <<HEREDOC | "${_NB}" add "six.md"
---
summary: Example Summary
custom: variable
---
line five
line six
line seven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "seven.md"
Title Seven
===========

line four
line five
line six
HEREDOC
    cat <<HEREDOC | "${_NB}" add "eight.md"
---
summary: Example Summary
custom: variable
---

  Title Eight
  ===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "nine.md"
---
summary: Example Summary
custom: variable
---
Title Nine
===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NB}" add "ten.md"
# Title Ten #
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "eleven.md"
[](https://example.com/example.png)

# Title Eleven
line two
line three
line four
HEREDOC
    # shellcheck disable=SC2006
    cat <<HEREDOC | "${_NB}" add "twelve.md"
[](https://example.com/example.png)

\`\`\`text
# Example In Code Block
\`\`\`

# Title Twelve
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "thirteen.org"
#+TITLE: Example Org Title

line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "fourteen.org"
#+TITLE: Example
#+TITLE: Multi-Line
#+TITLE: Org Title

line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "fourteen.org"
# -*- mode: org; coding: utf-8; -*-
* Header Information                                               :noexport:
#+TITLE: Example
#+TITLE: Multi-Line
#+TITLE: Org Title
#+AUTHOR: Author Name

line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "fifteen.latex"
\documentclass{article}
\usepackage{graphicx}

\begin{document}

\title{Introduction to \LaTeX{}}
\author{Author's Name}

\maketitle

\begin{abstract}
The abstract text goes here.
\end{abstract}

\section{Introduction}
Here is the text of your introduction.

\begin{equation}
    \label{simple_equation}
    \alpha = \sqrt{ \beta }
\end{equation}

\subsection{Subsection Heading Here}
Write your subsection text here.

\begin{figure}
    \centering
    \includegraphics[width=3.0in]{myfigure}
    \caption{Simulation Results}
    \label{simulationfigure}
\end{figure}

\section{Conclusion}
Write your conclusion here.

\end{document}
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-color --reverse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ ${status} -eq 0                                        ]]
  [[ "${lines[0]}"  == "[1]  Title One"                     ]]
  [[ "${lines[1]}"  == "[2]  two.md · \"line one\""         ]]
  [[ "${lines[2]}"  == "[3]  Title Three"                   ]]
  [[ "${lines[3]}"  == "[4]  Title Four"                    ]]
  [[ "${lines[4]}"  == "[5]  Title Five"                    ]]
  [[ "${lines[5]}"  == "[6]  six.md · \"line five\""        ]]
  [[ "${lines[6]}"  == "[7]  Title Seven"                   ]]
  [[ "${lines[7]}"  == "[8]  Title Eight"                   ]]
  [[ "${lines[8]}"  == "[9]  Title Nine"                    ]]
  [[ "${lines[9]}"  == "[10] Title Ten"                     ]]
  [[ "${lines[10]}" == "[11] Title Eleven"                  ]]
  [[ "${lines[11]}" == "[12] Title Twelve"                  ]]
  [[ "${lines[12]}" == "[13] Example Org Title"             ]]
  [[ "${lines[13]}" == "[14] Example Multi-Line Org Title"  ]]
  [[ "${lines[14]}" == "[15] Example Multi-Line Org Title"  ]]
  [[ "${lines[15]}" == "[16] Introduction to \LaTeX{}"      ]]
}

# `_get_unique_basename()` ####################################################

@test "\`_get_unique_basename()\` works for notes" {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" add "example.md" --content "Example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" add "example.md" --content "Example"


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-2.md  ]]
}

@test "\`_get_unique_basename()\` works for encrypted notes" {
  {
    run "${_NB}" init
  }

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ example.md.enc  ]]

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ example-1.md.enc  ]]

  run "${_NB}" add "example.md" --content "Example" \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                    ]]
  [[ "${lines[0]}" =~ example-2.md.enc  ]]
}

@test "\`_get_unique_basename()\` works for bookmarks" {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" --content "<https://example.com>"
  }

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ example-1.bookmark.md ]]

  run "${_NB}" add "example.bookmark.md" --content "<https://example.com>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ example-2.bookmark.md ]]
}

@test "\`_get_unique_basename()\` works for encrypted bookmarks" {
  {
    run "${_NB}" init
  }

  run  "${_NB}" add "example.bookmark.md"   \
      --content "<https://example.com>"     \
      --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ example.bookmark.md.enc ]]

  run "${_NB}" add "example.bookmark.md"  \
    --content "<https://example.com>"     \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ example-1.bookmark.md.enc ]]

  run "${_NB}" add "example.bookmark.md"  \
    --content "<https://example.com>"     \
    --encrypt --password password

  [[ ${status} -eq 0 ]]

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ example-2.bookmark.md.enc ]]
}

@test "\`_get_unique_basename()\` works for encrypted conflicted bookmarks" {
  {
    local _filename="example.bookmark.md"

    run "${_NB}" init
  }

  run  "${_NB}" add "${_filename%%.*}--conflicted-copy.${_filename#*.}"   \
      --content "<https://example.com>"                                   \
      --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                            ]]
  [[ "${lines[0]}" =~ example--conflicted-copy.bookmark.md.enc  ]]

  run "${_NB}" add "example--conflicted-copy.bookmark.md"   \
    --content "<https://example.com>"                       \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                              ]]
  [[ "${lines[0]}" =~ example--conflicted-copy-1.bookmark.md.enc  ]]

  run "${_NB}" add "example--conflicted-copy.bookmark.md"   \
    --content "<https://example.com>"                       \
    --encrypt --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                              ]]
  [[ "${lines[0]}" =~ example--conflicted-copy-2.bookmark.md.enc  ]]
}

# `_highlight_syntax_if_available()` ####################################################

@test "\`_highlight_syntax_if_available <path>\` highlights a file at <path≥." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "# Example"
  }

  run "${_NB}" helpers highlight "${_NOTEBOOK_PATH}/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ -n "${output:-}"             ]]
  [[ "${output}" !=  "# Example"  ]]
}

@test "\`_highlight_syntax_if_available <path> --no-color\` skips highlighting." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "# Example _Title_"
  }

  run "${_NB}" helpers highlight "${_NOTEBOOK_PATH}/example.md" --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ "${output}" ==  "# Example _Title_"  ]]
}

@test "\`_highlight_syntax_if_available\` highlights piped content." {
  {
    "${_NB}" init
  }

  run bash -c "echo \"# Example _Title_\" | \"${_NB}\" helpers highlight"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ -n "${output:-}"                     ]]
  [[ "${output}" !=  "# Example _Title_"  ]]
}

@test "\`_highlight_syntax_if_available() --no-color\` skips highlighting piped content." {
  {
    "${_NB}" init
  }

  run bash -c "echo \"# Example _Title_\" | \"${_NB}\" helpers highlight --no-color"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ "${output}" ==  "# Example _Title_"  ]]
}

@test "\`_highlight_syntax_if_available <extension>\` highlights piped content." {
  {
    "${_NB}" init
  }

  run bash -c "echo \"# Example _Title_\" | \"${_NB}\" helpers highlight 'md'"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ -n "${output:-}"                     ]]
  [[ "${output}" !=  "# Example _Title_"  ]]
}

@test "\`_highlight_syntax_if_available <extension> --no-color\` skips highlighting." {
  {
    "${_NB}" init
  }

  run bash -c "echo \"# Example _Title_\" | \"${_NB}\" helpers highlight 'md' --no-color"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ "${output}" ==  "# Example _Title_"  ]]
}
