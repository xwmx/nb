#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# --no-template ###############################################################

@test "'add --template \"\"' with path NB_DEFAULT_TEMPLATE assigned in .nbrc and blank <template> creates note without template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC

    printf "export NB_DEFAULT_TEMPLATE=\"%s\"\\n" "${_template_path}" >> "${NBRC_PATH}"
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    --template ""                       \
    "Argument content two." <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#one #two #three

Argument content one. Argument content two.

Example option content.

Example piped content.
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add --template \"\"' with blank <template> creates note without template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    --template ""                       \
    "Argument content two." <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#one #two #three

Argument content one. Argument content two.

Example option content.

Example piped content.
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add --template <template> --no-template' with path <template> creates note without template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two."             \
    --template "${_template_path}"      \
    --no-template <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#one #two #three

Argument content one. Argument content two.

Example option content.

Example piped content.
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add --no-template' with path NB_DEFAULT_TEMPLATE assigned in .nbrc creates note without template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC

    printf "export NB_DEFAULT_TEMPLATE=\"%s\"\\n" "${_template_path}" >> "${NBRC_PATH}"
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two."             \
    --no-template <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#one #two #three

Argument content one. Argument content two.

Example option content.

Example piped content.
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# NB_DEFAULT_TEMPLATE #########################################################

@test "'add' with string NB_DEFAULT_TEMPLATE assigned in .nbrc creates note based on template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${NBRC_PATH}"
export NB_DEFAULT_TEMPLATE="\
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}"
HEREDOC
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two." <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# - Example Template Title - Example Title

$(date +"%Y-%m-%d")

## Full Content

Argument content one. Argument content two.

Example option content.

Example piped content.

## Selector Content

Argument content one. Argument content two.

## Option Content

Example option content.

## Piped Content

Example piped content.

## Tag List

#one #two #three
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with path NB_DEFAULT_TEMPLATE assigned in .nbrc creates note based on template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC

    printf "export NB_DEFAULT_TEMPLATE=\"%s\"\\n" "${_template_path}" >> "${NBRC_PATH}"
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two." <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# - Example Template Title - Example Title

$(date +"%Y-%m-%d")

## Full Content

Argument content one. Argument content two.

Example option content.

Example piped content.

## Selector Content

Argument content one. Argument content two.

## Option Content

Example option content.

## Piped Content

Example piped content.

## Tag List

#one #two #three
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# --template ##################################################################

@test "'add --template <template>' with path <template> creates note based on template." {
  {
    "${_NB}" init

    declare _template_path="${_TMP_DIR}/example-template"

    cat <<HEREDOC > "${_template_path}"
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two."             \
    --template "${_template_path}" <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# - Example Template Title - Example Title

$(date +"%Y-%m-%d")

## Full Content

Argument content one. Argument content two.

Example option content.

Example piped content.

## Selector Content

Argument content one. Argument content two.

## Option Content

Example option content.

## Piped Content

Example piped content.

## Tag List

#one #two #three
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add --template <template>' with string <template> creates note based on template." {
  {
    "${_NB}" init
  }

  run "${_NB}" add                      \
    "Argument content one."             \
    --content "Example option content." \
    --tags    one,two,three             \
    --title   "Example Title"           \
    "Argument content two."             \
    --template "$(cat <<HEREDOC
{{title_prefix}} - Example Template Title - {{title}}

{{date +"%Y-%m-%d"}}

## Full Content

{{content}}

## Selector Content

{{selector_content}}

## Option Content

{{option_content}}

## Piped Content

{{piped_content}}

## Tag List

{{tags}}
HEREDOC
    )" <<< "Example piped content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                        ]]

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  printf "File content: '%s'\\n" "$(cat "${NB_DIR}/home/example_title.md")"

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# - Example Template Title - Example Title

$(date +"%Y-%m-%d")

## Full Content

Argument content one. Argument content two.

Example option content.

Example piped content.

## Selector Content

Argument content one. Argument content two.

## Option Content

Example option content.

## Piped Content

Example piped content.

## Tag List

#one #two #three
HEREDOC
)

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}
