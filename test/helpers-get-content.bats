#!/usr/bin/env bats

load test_helper

# `_get_content()` ##############################################################

@test "'_get_content()' prints first line when there are two lines." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" \
      --content "Example line one.${_NEWLINE}Example line two."
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                ]]
  [[    "${output}"  ==  "__first_line:Example line one." ]]
}

@test "'_get_content()' prints first line when there is only one line." {
  {
    "${_NB}" init
    "${_NB}" add "Example File.md" --content "Example single line."
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/Example File.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]
  [[    "${output}"  ==  "__first_line:Example single line."  ]]
}

@test "'_get_content()' skips folders." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/Example Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}" -eq 0 ]]
  [[ -z "${output}"       ]]
}

@test "'_get_content() --title' does not return first line when no .org title." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.org"
# Markdown Title in .org File

line three (line two is blank)
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/one.org" --title

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0               ]]
  [[ -z "${output}"                      ]]
  [[ !  "${output}"  =~  __first_line    ]]
  [[ !  "${output}"  =~  Markdown\ Title ]]
}

@test "'_get_content() --title' detects and returns titles." {
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
    cat <<HEREDOC | "${_NB}" add "fifteen.org"
# -*- mode: org; coding: utf-8; -*-
* Header Information                                               :noexport:
#+TITLE: Example
#+TITLE: Multi-Line
#+TITLE: Org Title
#+AUTHOR: Author Name

line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sixteen.latex"
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
    _files=($(ls "${NB_DIR}/home/"))
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

@test "'_get_content()' returns first line when no title." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
line one
line two
line three
line four
HEREDOC

    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/one.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line one"   ]]
}

@test "'_get_content()' returns first line after newlines." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "two.md"


line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/two.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line three" ]]
}

@test "'_get_content()' returns first line after code block." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "three.md"
\`\`\`example
example=code
\`\`\`

line one
line two
line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/three.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${NB_DIR}/home/three.md"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "'_get_content()' returns first line after code block and front matter." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "four.md"
---
front: matter
---

\`\`\`example
example=code
\`\`\`

line one
line two
line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/four.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "'_get_content()' returns first line after front matter." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "five.md"
---
front: matter
---

line one
line two
line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/five.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "'_get_content()' returns nothing with only code block and front matter." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "four.md"
---
front: matter
---

\`\`\`example
example=code
\`\`\`

HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/four.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0 ]]
  [[ -z "${output}"     ]]
}

@test "'_get_content()' returns first line in Org file." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.org"


line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${NB_DIR}/home/example.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line three" ]]
}

@test "'_get_content()' returns first line in LaTeX file." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.latex"


\documentclass{article}
\usepackage{graphicx}

\begin{document}

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
}

  run "${_NB}" helpers get_content "${NB_DIR}/home/example.latex"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                       ]]
  [[ "${output}"  ==  "__first_line:\\documentclass{article}" ]]
}
