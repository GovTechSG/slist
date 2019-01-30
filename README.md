# slist
slist is a tool to list your servers in ssh config and ssh into it. This only works on Unix machines.
slist aims to solve the problem of users having to remember aliases or IP addresses of all their servers.
slist reads the aliases in the ~/.ssh/config file and list them in the terminal.

## Setting it up
```
cd <path_of_choice>
git clone https://github.com/GovTechSG/slist.git
chmod +x slist.sh
ln -s <path_of_choice>/slist.sh /usr/local/bin/slist
slist
```
