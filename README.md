# slist

![alt text](https://github.com/GovTechSG/slist/blob/master/slist.png?raw=true)

![version](https://img.shields.io/github/release/GovTechSG/slist.svg?style=flat) [![CI](https://github.com/GovTechSG/slist/actions/workflows/actions.yml/badge.svg)](https://github.com/GovTechSG/slist/actions/workflows/actions.yml)

slist is a tool to list your servers in ssh config and ssh into it.\
This only works on Unix machines.\
slist aims to solve the problem of users having to remember aliases or IP addresses of all their servers.\
slist reads the aliases in the ~/.ssh/config file and list them in the terminal.

## Setting it up

```bash
$ cd <path_of_choice>
$ git clone https://github.com/GovTechSG/slist.git
$ chmod +x slist.sh

# Use full path of slist.sh for symlink to work
$ ln -s <path_of_choice>/slist.sh /usr/local/bin/slist
$ slist
```

## SSH Config File Format

```bash
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
```

## Usage

Usage: slist [-fhl]
             [--add-host host_name --ip-adr ip_address [--ssh-user user --port port_number --keypath keyname_with_path]]
             [--del-host host_name]

```bash
-f <keyword>                    Keyword to filter
-h                              Display help
-l                              List servers with ip addresses
-l -f <keyword>                 Filter list work <keyword>
-e                              Open and edit ~/.ssh/config
--add-host <host_name>          Add a new host to the SSH config file. Must be used together with --ip-adr option
--ip-adr <ip_address>           Add a new IP address to the SSH config file. Must be used together with --add-host option
--ssh-user <user>               Add a new SSH user to SSH config file. Must be used together with --add-host and --ip-adr options
--port <port_number>            Add a new port number to SSH config file. Must be used together with --add-host and --ip-adr options
--keypath <keyname_with_path>   Add a new key file to SSH config file. Must be used together with --add-host and --ip-adr options
--del-host <host_name>          Delete a host from the SSH config file
--file                   To use other config file
--init <file_path>              To initialize a template SSH config file
```

## Changing colours theme for slist

To make persistent color change to slist theme.\
If you are using bash shell, add below 2 lines to .bashrc or .profile or .bash_profile.\
If you are using zsh shell, add below 2 lines to .zshrc.\

export color_theme1=cyan\
export color_theme2=yellow

Supported colors:
black red green yellow blue pink cyan white

## Screenshots

![Optional Text](../master/screenshots/slist.png)
![Optional Text](../master/screenshots/filter.png)

## Developer Guide

### Running Tests

To run tests in tests/slist_test.sh you will need to install [shunit2](https://github.com/kward/shunit2)

```bash
# To install shunit2 on MacOS
$ brew install shunit2

# To install shunit2 on Fedora/RHEL/CentOS/EPEL
$ yum install shunit2

# To install shunit2 on Ubuntu
$ apt-get install shunit2

# To run tests
$ ./tests/slist_test.sh
```

### Contributing Your Code

If you would like to contribute to this repo, please open an issue, fork the repo, implement your code and tests and create a PR

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
