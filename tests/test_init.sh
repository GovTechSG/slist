#! /bin/bash
# file: tests/test_init.sh

# Set up test environment before any tests are run
oneTimeSetUp() {
  shopt -s expand_aliases
  alias slist='$PWD/slist.sh'

  # Coloring
  red=$'\e[1;31m'
  green=$'\e[0;32m'
  end=$'\e[0m'

  mkdir -p ~/.ssh
  touch ~/.ssh/config
}

test_filePath_not_provided() {
  output=$(slist --init)
  expected="${red}Please provide a file path after --init option! ${end}"

  ${_ASSERT_EQUALS_} '"File path not provided"' "'$expected'" "'$output'"
}

# Test file exists but do not overwrite
test_no_overwrite_filePath() {
  filePath=test_file
  touch $filePath

  output=$(slist --init test_file <<< "NO")
  exit_code="$?"

  ${_ASSERT_EQUALS_} 0 "'$exit_code'"

  rm -rf test_file
}

# Test file exists and overwrite
test_overwrite_filePath() {
  filePath=test_file
  echo "Hello" > $filePath
  output=$(cat $filePath)

  ${_ASSERT_EQUALS_} '"Before overwrite"' "'Hello'" "'$output'"

  cat > expected_file << EOF
# If you have a jump host
Host jumpHost
  User <your_user>
  HostName <ip_address>
  Port 22
  IdentityFile <path_to_private_key>

Host <your_host>
  User <your_user>
  HostName <ip_address>
  ProxyCommand ssh -A jumpHost nc %h %p   # If you want to use the jumpHost to connect to the host
  Port 22
  IdentityFile <path_to_private_key>

Host <your_host2>
  User <your_user2>
  HostName <ip_address2>
  Port 22
  IdentityFile <path_to_private_key>
EOF

  output=$(slist --init test_file <<< "YES")
  exit_code="$?"
  file_content=$(cat $filePath)
  expected_file_content=$(cat expected_file)
  expected="${green}Template SSH config created at $filePath ${end}"

  ${_ASSERT_EQUALS_} "'$expected_file_content'" "'$file_content'"
  ${_ASSERT_EQUALS_} "'$expected'" "'$output'"
  ${_ASSERT_EQUALS_} 0 "'$exit_code'"

  rm -rf test_file
  rm -rf expected_file
}

test_invalid_overwrite_option() {
  filePath=test_file
  touch $filePath

  output=$(slist --init test_file <<< "a")
  exit_code="$?"
  expected="${red}Invalid option! ${end}"

  ${_ASSERT_EQUALS_} "'$expected'" "'$output'"
  ${_ASSERT_EQUALS_} 1 "'$exit_code'"

  rm -rf test_file
}

# Load shUnit2.
. shunit2