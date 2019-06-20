# slist
![](https://img.shields.io/github/release/GovTechSG/slist.svg?style=flat)

slist is a tool to list your servers in ssh config and ssh into it.<br/>
This only works on Unix machines.<br/>
slist aims to solve the problem of users having to remember aliases or IP addresses of all their servers.<br/>
slist reads the aliases in the ~/.ssh/config file and list them in the terminal.

## Setting it up
```
cd <path_of_choice>
git clone https://github.com/GovTechSG/slist.git
chmod +x slist.sh
# Use full path of slist.sh for symlink to work
ln -s <path_of_choice>/slist.sh /usr/local/bin/slist
slist
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


## Screenshots
![Optional Text](../screenshots/slist.png)

## Usage
Usage: slist [-fhl]
```
-f <keyword>                  Keyword to filter
-h                            Display help
-l                            List servers with ip addresses
-l -f <keyword>               Filter list work <keyword>
```
