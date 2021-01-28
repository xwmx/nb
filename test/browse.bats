#!/usr/bin/env bats

load test_helper

# browse ######################################################################

@test "'browse <selector>' serves the rendered HTML page." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                    ]]
  [[ "${output}"    =~ \<\!DOCTYPE\ html\>  ]]
}
