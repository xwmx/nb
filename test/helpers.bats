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

# `_file_is_bookmark()` #######################################################

@test "\`_file_is_bookmark()\` is true for .bookmark.md file." {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" --content "<https://example.test>"
  }

  run "${_NB}" helpers _file_is_bookmark "${NB_DIR}/home/example.bookmark.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.bookmark.md"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_bookmark()\` is true for encrypted .bookmark.md.enc file." {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" \
      --content "<https://example.test>" --encrypt --password=password
  }

  run "${_NB}" helpers _file_is_bookmark "${NB_DIR}/home/example.bookmark.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.bookmark.md.enc"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_bookmark()\` is false for .md file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "<https://example.test>"
  }

  run "${_NB}" helpers _file_is_bookmark "${NB_DIR}/home/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_bookmark()\` is false for encrypted non-bookmark .enc file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
  }

  run "${_NB}" helpers _file_is_bookmark "${NB_DIR}/home/example.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md.enc"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_bookmark()\` is false for extensionless file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "<https://example.test>"
    "${_NB}" run mv example.md example
    "${_NB}" index reconcile
    "${_NB}" git checkpoint "Rename example."
  }

  run "${_NB}" helpers _file_is_bookmark "${NB_DIR}/home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

# `_file_is_encrypted()` ######################################################

@test "\`_file_is_encrypted()\` is true for encrypted .enc file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md.enc"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_encrypted()\` is true for encrypted bookmark.md.enc file." {
  {
    "${_NB}" init
    "${_NB}" add "example.bookmark.md" \
      --content "<https://example.test>" --encrypt --password=password
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example.bookmark.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.bookmark.md.enc"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_encrypted()\` is true for encrypted .not-valid file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
    "${_NB}" rename example.md.enc example.not-valid --force

    [[ -f "${NB_DIR}/home/example.not-valid" ]]
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example.not-valid"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.not-valid"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_encrypted()\` is false for .md file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_encrypted()\` is false for extensionless text file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
    "${_NB}" run mv example.md example
    "${_NB}" index reconcile
    "${_NB}" git checkpoint "Rename example."
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_encrypted()\` is true for encrypted extensionless file." {
  skip "TODO"
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
    "${_NB}" run mv example.md.enc example
    "${_NB}" index reconcile
    "${_NB}" git checkpoint "Rename example."

    [[ -f "${NB_DIR}/home/example" ]]
  }

  run "${_NB}" helpers file_is_encrypted "${NB_DIR}/home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

# `_file_is_text()` ###########################################################

@test "\`_file_is_text()\` is false for encrypted .enc file." {
  skip "TODO"
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"  --encrypt --password=password
  }

  run "${_NB}" helpers file_is_text "${NB_DIR}/home/example.md.enc"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md.enc"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_text()\` is true for .md file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" helpers file_is_text "${NB_DIR}/home/example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.md"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_text()\` is true for extensionless text file." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
    "${_NB}" run mv example.md example
    "${_NB}" index reconcile
    "${_NB}" git checkpoint "Rename example."
  }

  run "${_NB}" helpers file_is_text "${NB_DIR}/home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_text()\` is false for encrypted .not-valid file." {
  skip "TODO"
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
    "${_NB}" rename example.md.enc example.not-valid --force
  }

  run "${_NB}" helpers file_is_text "${NB_DIR}/home/example.not-valid"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example.not-valid"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
}

@test "\`_file_is_text()\` is false for encrypted extensionless file." {
  skip "TODO"
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example" --encrypt --password=password
    "${_NB}" run mv example.md.enc example
    "${_NB}" index reconcile
    "${_NB}" git checkpoint "Rename example."

    [[ -f "${NB_DIR}/home/example" ]]
  }

  run "${_NB}" helpers file_is_text "${NB_DIR}/home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  file "${NB_DIR}/home/example"

  [[ ${status} -eq 1  ]]
  [[ -z "${output}"   ]]
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

# `_get_content()` #########################################################

@test "\`_get_content()\` returns first line when no title." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
line one
line two
line three
line four
HEREDOC

    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/one.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line one"   ]]
}

@test "\`_get_content()\` returns first line after newlines." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "two.md"


line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/two.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line three" ]]
}

@test "\`_get_content()\` returns first line after code block." {
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

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/three.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  cat "${_NOTEBOOK_PATH}/three.md"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "\`_get_content()\` returns first line after code block and front matter." {
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

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/four.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "\`_get_content()\` returns first line after front matter." {
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

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/five.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                       ]]
  [[ "${output}"  ==  "__first_line:line one" ]]
}

@test "\`_get_content()\` returns nothing with only code block and front matter." {
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

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/four.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0 ]]
  [[ -z "${output}"     ]]
}

@test "\`_get_content()\` returns first line in Org file." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "example.org"


line three
line four
HEREDOC
  }

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/example.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                         ]]
  [[ "${output}"  ==  "__first_line:line three" ]]
}

@test "\`_get_content()\` returns first line in LaTeX file." {
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

  run "${_NB}" helpers get_content "${_NOTEBOOK_PATH}/example.latex"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 0                                       ]]
  [[ "${output}"  ==  "__first_line:\\documentclass{article}" ]]
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
