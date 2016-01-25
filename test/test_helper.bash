setup() {
  # `$_NOTES`
  #
  # The location of the `notes` script being tested.
  export _NOTES="${BATS_TEST_DIRNAME}/../notes"

  export NOTES_DIR="${BATS_TEST_DIRNAME}/tmp/.notes"
  export NOTESRC_PATH="${BATS_TEST_DIRNAME}/tmp/.notesrc"
}
