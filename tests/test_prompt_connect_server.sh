#! /bin/bash
# file: tests/test_prompt_connect_server.sh

# Set up test environment before any tests are run
oneTimeSetUp() {
  shopt -s expand_aliases
  alias slist='$PWD/slist.sh'

  mkdir -p ~/.ssh
  touch ~/.ssh/config

  touch test_config_file

  TERM=screen
}

test_prompt_connect_server() {
  output=$(slist --file test_config_file <<< "exit")
  echo "$output" > result
  # Only take second line as the 1st line is the an escape sequence as a result of clear command
  got=$(tail -1 result)
  expected="Server to connect:"

  ${_ASSERT_EQUALS_} "'$expected'" "'$got'"
}

oneTimeTearDown() {
  rm -rf test_config_file
  rm -rf result
}

# Load shUnit2.
. shunit2