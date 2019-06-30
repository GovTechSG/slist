#!/bin/bash
#
# Version	Author		Remarks
# 1.1		Alvin		Make script more robust to wrong entries
# 1.2		Alvin		Add argument for listing server name with ip addresses
#				        Add exit method by typing "exit" or "EXIT"
#				        Add filtering of listing and main
###################################################################################################

list_path=/tmp/serverslist.lst
config_file=~/.ssh/config

# Coloring
red=$'\e[1;31m'
end=$'\e[0m'

# Function for printing usage
usage() { echo "Usage: $0 [-p <filer word>]" 1>&2; exit 1; }

# Function for printing help page
help() {
cat << EOF
Usage: slist [-hl]|[-f <keyword>]

-f <keyword>                  Keyword to filter
-h                            Display help
-l                            List servers with ip addresses
-l -f <keyword>               Filter list work <keyword>

Adding new host to ssh config
Usage: slist --add-host <host name> --ip-adr <ip address> --ssh-user <user> --port <port number> --keypath < keyname with path >

Only --add-host and --ip-adr are mandatory to have

Delete host from ssh confg
Usage: slist --del-host <host name>

EOF
exit;
}

# Default main slist page
main() {
    check_config_file_exists
    list=$(< $config_file grep "Host " | awk '{print $2}')
    rm -f $list_path
    num=1
    colour=34

    set -f
    for line in $list
    do
        if [[ $line != "*" ]]; then
            echo -ne "$num $line \n" >>  $list_path
            printf -- "\033[${colour}m %s %s \033[0m\n" "$num" "$line"
            num=$((num + 1))
            if [ $colour -eq 34 ]; then
                colour=$((colour + 1))
            elif [ $colour -eq 35 ]; then
                colour=$((colour - 1))
            fi
        fi
    done
    set +f

    echo -e "\nServer to connect:"
    read -r cs

    if [[ -z $cs ]]; then
        clear
        echo "Enter a number"
        main
    fi

    if [[ $cs == "exit" ]] || [[ $cs == "EXIT" ]]; then
        exit
    fi

    if [[ $cs == *[a-zA-Z]* ]]; then
        clear
        echo "Not a number"
        main
    fi

    num=$((num - 1))

    if [ "$cs" -gt $num ] || [ "$cs" -le 0 ]; then
        clear
        echo "Number of out of range"
        main
    fi

    host=$(grep "^$cs " ${list_path} | awk '{print $2}')
    ssh "$host"
    exit
}

# Filter hostname page of slist
filter() {
    list=$(< $config_file grep "Host " | awk '{print $2}')
    rm -f $list_path
    num=1
    colour=34

    set -f
    for line in $list
    do
        if [[ $line != "*" ]]; then
            if [[ "$line" == *"$keyword"* ]]; then
                echo -ne "$num $line \n" >>  $list_path
                printf -- "\033[${colour}m %s %s \033[0m\n" "$num" "$line"
                num=$((num + 1))

                if [ $colour -eq 34 ]; then
                    colour=$((colour + 1))
                elif [ $colour -eq 35 ]; then
                    colour=$((colour - 1))
                fi
            fi
        fi
    done
    set +f

    echo -e "\nServer to connect:"
    read -r cs

    if [[ -z $cs ]]; then
        clear
        echo "Enter a number"
        filter
    fi

    if [[ $cs == "exit" ]] || [[ $cs == "EXIT" ]]; then
        exit
    fi

    if [[ $cs == *[a-zA-Z]* ]]; then
        clear
        echo "Not a number"
        filter
    fi

    num=$((num - 1))

    if [ "$cs" -gt $num ] || [ "$cs" -le 0 ]; then
        clear
        echo "Number of out of range"
        filter
    fi

    host=$(grep "^$cs " ${list_path} | awk '{print $2}')
    ssh "$host"
    exit
}

# Listing ip address for slist
list() {
    colour=34
    < $config_file grep Host | while read -r line;
    do
        if [[ $line != *"*"* ]]; then
            if [[ $line == *"Host "* ]]; then
                replace_string=$(sed 's/Host/Server:/g' <<< "$line")
                if [ $colour -eq 34 ]; then
                    colour=$((colour + 1))
                elif [ $colour -eq 35 ]; then
                    colour=$((colour - 1))
                fi
            elif [[ $line == *"HostName "* ]]; then
                replace_string=$(sed 's/HostName/IP:/g' <<< "$line")
            fi
            printf -- "\033[${colour}m %s %s \033[0m\n" "$replace_string"
        fi
    done
    exit;
}

# Filtering ip address page of slist
flist() {
    < $config_file grep Host | while read -r line;
    do
        if [[ $line == *"Host "* ]]; then
            replace_string=$(sed 's/Host/Server:/g' <<< "$line")
        elif [[ $line == *"HostName "* ]]; then
            replace_string=$(sed 's/HostName/IP:/g' <<< "$line")
        fi

        echo "$replace_string"
    done
    exit;
}

# Function to check if config file exists
check_config_file_exists(){
    if [ -f "$config_file" ]; then
        echo "$config_file exist"
    else 

        printf "%s\n" "${red} $config_file <-- file does not exist - Please create one. ${end} "
        exit;
    fi
}

# Function to check if last line of conf is empty
check_last_line(){
  last_line=$(tail -1 ${config_file})
  if [ ! -z "$last_line" ]; then
      echo "" >> "$config_file"
  fi
}

# Function to check if hostname already exists
check_host_exists(){
  host_exist=false
  match=$1
  host_check=$(sed '/^Host/!d' $config_file | awk "/$match/ "'{ print $2 }')
  for line in $host_check; do
      if [[ $line == "$match" ]]; then

          host_exist=true
          break
      fi
  done
}

# Loading main slist page if no argument found
if [ $# -eq 0 ]; then
    clear
    main
fi

# Function to check if argument is nil
check_arg(){
    val="$1"
    if [[ -z "$val" ]]; then
        value=false
    fi
}

# Start of slist
check_config_file_exists

list=false
filter=false
help=false
add_host=false
ip_adr=false
del_host=false

# Not mandatory fields. Will use default or no value if bolean is false
ssh_user=false
port=false
key_path=false

while getopts ':hlf:-:' c
do
  case $c in
    -)
      case "$OPTARG" in
        add-host)
          add_host=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          # Exist program if host is empty
          if [[ $value == "false" ]]; then
            echo "Host cannot be empty"
            exit 1
          fi
          host=$val
          ;;
        ip-adr)
          ip_adr=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          if [[ $value == "false" ]]; then
            ip_adr=false
          fi
          ip="$val"
          ;;
        ssh-user)
          ssh_user=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          if [[ $value == "false" ]]; then
            ssh_user=false
          fi
          user="$val"
          ;;
        port)
          add_port=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          if [[ $value == "false" ]]; then
            add_port=false
          fi
          port="$val"
          ;;
        keypath)
          key_path=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          if [[ $value == "false" ]]; then
            key_path=false
          fi
          key="$val"
          ;;
        del-host)
          del_host=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          if [[ $value == "false" ]]; then
            del_host=false
            echo "Host cannot be empty"
          fi
          host="$val"
          ;;
        *)
          echo "Illegal option --$OPTARG" >&2; exit 2 ;;
      esac;;
    h)
      help=true
      ;;
    l)
      list=true
      ;;
    f)
      filter=true
      keyword=$OPTARG
      ;;
    *)
      echo "Invalid parameter!"
      echo ""
      help
      ;;
  esac
done
 
if [[ $help == "true" ]]; then
    help
elif [[ $add_host == "true" ]] && [[ $del_host == "true" ]]; then
    echo "--add-host and --del-host cannot be use at the same time"
    exit 3
elif [[ $del_host == "true" ]]; then
    check_host_exists "$host"
    if [[ $host_exist == "false" ]]; then
        echo "Host does not exist"
        exit 0
    fi
    echo -e "\nDelete host ${host}? [y/n]"
    read -r confirm
    if [[ $confirm == "y" ]] || [[ $confirm == "yes" ]]; then
        sed -i.bak "/Host $host/",'/^$/d' config
        eo="$?"
        if [ $eo -ne 0 ]; then
            echo "Host could not be remove. Please do manual removal from ~/.ssh/config."
            exit 3
        fi
        echo "${host} had been removed" 
        exit 0
    fi
elif [[ $add_host == "true" ]]; then
    check_host_exists "$host"
    # Check if host already exist
    if [[ $host_exist == "true" ]]; then
        echo "Host with the same name already exist"
        exit 0
    fi
    # Prompt for ip address argument was not pass
    if [[ $ip_adr == "false" ]]; then
        echo -e "\nEnter IP address or hostname for host ${host}"
        read -r ip
    fi
    # Update config file
    if [[ $host_exist == "false" ]]; then
        check_last_line
        echo "Host ${host}" >> "$config_file"
        if [[ $ssh_user == "true" ]]; then
            echo "  User ${user}" >> "$config_file"
        fi
        echo "  Hostname ${ip}" >> "$config_file"
        if [[ $key_path == "true" ]]; then
            echo "  IdentityFile ${key}" >> "$config_file"
        fi
        if [[ $add_port == "true" ]]; then
            echo "  Port ${port}" >> "$config_file"
        fi
    fi
# Logic ensure that options ip-adr, ssh-user, port and keypath should not be call without add-host
elif [[ $add_host == "false" ]] && [[ $ip_adr == "true" ]] || [[ $ssh_user == "true" ]] || [[ $add_port == "true" ]] || [[ $key_path == "true" ]]; then
    help
elif [[ $list == "true" ]] && [[ $filter == "false" ]] && [[ $help == "false" ]]; then
    clear
    list
    exit
elif [[ $filter == "true" ]] && [[ $list == "false" ]] && [[ $help == "false" ]]; then
    clear
    filter
elif [[ $filter == "true" ]] && [[ $list == "true" ]] && [[ $help == "false" ]]; then
    clear
    colour=34
    flist | grep -A1 "$keyword" | grep -v "\-\-" | while read -r line;
    do
        if [[ $line == *"Server"* ]]; then
            if [ $colour -eq 34 ]; then
                colour=$((colour + 1))
            elif [ $colour -eq 35 ]; then
                colour=$((colour - 1))
            fi
        fi

        printf -- "\033[${colour}m %s %s \033[0m\n" "$line"
    done
fi
