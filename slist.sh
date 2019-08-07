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
green=$'\e[0;32m'
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
-e                            Open ~/.ssh/config

Using other conf instead of default ~/.ssh/conf
Usage: slist --config-file /tmp/config

Adding new host to ssh config
Usage: slist --add-host <host name> --ip-adr <ip address> --ssh-user <user> --port <port number> --keypath < keyname with path >

Only --add-host and --ip-adr are mandatory to have

Delete host from ssh config
Usage: slist --del-host <host name>

Initialising a template SSH config file
Usage: slist --init <file path>

EOF
exit;
}

# Default main slist page
main() {
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
            line="$(tr '[:upper:]' '[:lower:]' <<< "$line")"
            if [[ $line == *"host "* ]]; then
                replace_string=$(sed 's/host/Server:/g' <<< "$line")
                if [ $colour -eq 34 ]; then
                    colour=$((colour + 1))
                elif [ $colour -eq 35 ]; then
                    colour=$((colour - 1))
                fi
            elif [[ $line == *"hostname "* ]]; then
                replace_string=$(sed 's/hostname/IP:/g' <<< "$line")
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
        line="$(tr '[:upper:]' '[:lower:]' <<< "$line")"
        if [[ $line == *"host "* ]]; then
            replace_string=$(sed 's/host/Server:/g' <<< "$line")
        elif [[ $line == *"hostname "* ]]; then
            replace_string=$(sed 's/hostname/IP:/g' <<< "$line")
        fi

        echo "$replace_string"
    done
    exit;
}

# Function to check if config file exists
check_config_file_exists(){
    if [ ! -f "$config_file" ]; then
        printf "%s\n" "${red} $config_file <-- file does not exist - Please create one. ${end} "
        exit;
    fi
}

# Function to check if last line of conf is empty
check_last_line(){
  last_line=$(tail -1 ${config_file})
  if [ -n "$last_line" ]; then
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

# Function to check if argument is nil
check_arg(){
    val="$1"
    if [[ -z "$val" ]]; then
        value=false
    fi
}

init() {
  filePath="$1"

  if [[ -z "$filePath" ]]; then
    printf "%s\n" "${red}Please provide a file path after --init option! ${end}"
    exit 1
  elif [ -f "$filePath" ]; then
    read -r -p "$filePath already exists. Do you want to overwrite it? [y/n] " ans
    ans="$(tr '[:upper:]' '[:lower:]' <<< "$ans")"

    if [[ $ans == "n" || $ans == "no" ]]; then
      exit 0
    elif [[ $ans == "y" || $ans == "yes" ]]; then
      create_template "$filePath"
    else
      printf "%s\n" "${red}Invalid option! ${end}"
      exit 1
    fi
  else
    create_template "$filePath"
  fi
}

create_template() {
  filePath="$1"

  cat > "$filePath" << EOF
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

  printf "%s\n" "${green}Template SSH config created at $filePath ${end}"
  exit 0
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

while getopts ':hlef:-:' c
do
  case $c in
    -)
      case "$OPTARG" in
        config-file)
          configfile=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          # Exit program if host is empty
          if [[ $value == "false" ]]; then
            printf "%s\n" "${red}Config cannot be empty with --config-file${end}"
            exit 1
          fi
          config_file=$val
          ;;
        add-host)
          add_host=true
          val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          check_arg "$val"
          # Exit program if host is empty
          if [[ $value == "false" ]]; then
            printf "%s\n" "${red}Host cannot be empty ${end}"
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
        init)
          filePath="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          init "$filePath"
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
    e)
      edit=true
      ;;
    *)
      echo "Invalid parameter!"
      echo ""
      help
      ;;
  esac
done

# Loading main slist page if no argument found
if [ $# -eq 0 ] || [[ $configfile == "true" && $3 == "" ]]; then
    clear
    main
fi

if [[ $help == "true" ]]; then
    help
elif [[ $edit == "true" ]]; then
    vi "$config_file"
elif [[ $add_host == "true" ]] && [[ $del_host == "true" ]]; then
    printf "%s\n" "${red}--add-host and --del-host cannot be use at the same time ${end}"
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
