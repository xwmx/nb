#!/usr/bin/env bats

load test_helper

# @test "'helpers get_folder_id_selector()' resolves name to folder id selectors." {
#   {
#     "${_NB}" init
#     "${_NB}" add "Example Folder/File Example.md"
#     "${_NB}" add "Sample Folder/File Sample.md"

#     "${_NB}" move "Sample Folder" "1" --force

#     [[ -d "${NB_DIR}/home/Example Folder" ]]
#     [[ -d "${NB_DIR}/home/1"              ]]
#   }

#   run "${_NB}" helpers get_folder_id_selector 1

#   printf "\${status}: '%s'\\n" "${status}"
#   printf "\${output}: '%s'\\n" "${output}"

#   [[ "${status}"  -eq 0                   ]]
#   [[ "${output}"  ==  "2"                 ]]
# }
