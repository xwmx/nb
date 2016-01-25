#!/usr/bin/env bats

load test_helper

@test "\`env\` exits with status 0." {
  run "$_NOTES" env
  [ $status -eq 0 ]
}

@test "\`env\` prints \`\$NOTES_DIR\`." {
  run "$_NOTES" env
  [[ "${lines[0]}" =~ NOTES_DIR ]]
}

@test "\`env\` prints \`\$NOTES_DIR\` assigned to tmp/.notes." {
  run "$_NOTES" env
  [[ "${lines[0]}" =~ tmp/.notes ]]
}

@test "\`env\` prints \`\$NOTES_DATA_DIR\`." {
  run "$_NOTES" env
  [[ "${lines[1]}" =~ NOTES_DATA_DIR ]]
}

@test "\`env\` prints \`\$NOTES_DATA_DIR\` assigned to tmp/.notes/data." {
  run "$_NOTES" env
  [[ "${lines[1]}" =~ tmp/.notes/data ]]
}

@test "\`env\` prints \`\$NOTES_AUTO_SYNC\`." {
  run "$_NOTES" env
  [[ "${lines[2]}" =~ NOTES_AUTO_SYNC ]]
}

@test "\`env\` prints \`\$NOTES_AUTO_SYNC\` with a value of 0." {
  run "$_NOTES" env
  [[ "${lines[2]}" =~ 0$ ]]
}

@test "\`env\` prints \`\$NOTESRC_PATH\`." {
  run "$_NOTES" env
  [[ "${lines[3]}" =~ NOTESRC_PATH ]]
}

@test "\`env\` prints \`\$NOTESRC_PATH\` assigned to tmp/.notesrc." {
  run "$_NOTES" env
  [[ "${lines[3]}" =~ tmp/.notesrc ]]
}
