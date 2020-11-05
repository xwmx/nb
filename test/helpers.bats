#!/usr/bin/env bats

load test_helper

# `_clear_cache()` ############################################################

@test "'_clear_cache()' clears the cache." {
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

@test "'_file_is_bookmark()' is true for .bookmark.md file." {
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

@test "'_file_is_bookmark()' is true for encrypted .bookmark.md.enc file." {
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

@test "'_file_is_bookmark()' is false for .md file." {
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

@test "'_file_is_bookmark()' is false for encrypted non-bookmark .enc file." {
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

@test "'_file_is_bookmark()' is false for extensionless file." {
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

@test "'_file_is_encrypted()' is true for encrypted .enc file." {
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

@test "'_file_is_encrypted()' is true for encrypted bookmark.md.enc file." {
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

@test "'_file_is_encrypted()' is true for encrypted .not-valid file." {
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

@test "'_file_is_encrypted()' is false for .md file." {
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

@test "'_file_is_encrypted()' is false for extensionless text file." {
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

@test "'_file_is_encrypted()' is true for encrypted extensionless file." {
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

@test "'_file_is_text()' is false for encrypted .enc file." {
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

@test "'_file_is_text()' is true for .md file." {
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

@test "'_file_is_text()' is true for extensionless text file." {
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

@test "'_file_is_text()' is false for encrypted .not-valid file." {
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

@test "'_file_is_text()' is false for encrypted extensionless file." {
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

# `_highlight_syntax_if_available()` ####################################################

@test "'_highlight_syntax_if_available <path>' highlights a file at <path≥." {
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

@test "'_highlight_syntax_if_available <path> --no-color' skips highlighting." {
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

@test "'_highlight_syntax_if_available' highlights piped content." {
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

@test "'_highlight_syntax_if_available() --no-color' skips highlighting piped content." {
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

@test "'_highlight_syntax_if_available <extension>' highlights piped content." {
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

@test "'_highlight_syntax_if_available <extension> --no-color' skips highlighting." {
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
