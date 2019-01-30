#!/bin/bash
#
# Version	Author		Remarks
# 1.1		Alvin		Make script more robust to wrong entries
#
###################################################################################################

list_path=/tmp/serverslist.lst

list=`cat ~/.ssh/config | grep "Host " | awk '{print $2}'`

main() {
	rm -f $list_path
	num=1
	colour=34
	for line in $list
	do
		echo -ne "$num $line \n" >>  $list_path
		printf -- "\033[${colour}m %s %s \033[0m\n" "$num" "$line"
		num=$(($num + 1))
        	if [ $colour -eq 34 ]; then
			colour=$((colour + 1))
		elif [ $colour -eq 35 ]; then
			colour=$((colour - 1))
		fi
	done

	echo -e "\nServer to connect:"
	read cs

        if [[ -z $cs ]]; then
		clear
                echo "Enter a number"
                main
        fi

        if [[ $cs == *[a-zA-Z]* ]]; then
		clear
                echo "Not a number"
                main
        fi

        num=$(($num - 1))

        if [ $cs -gt $num ]; then
		clear
                echo "Number of out of range"
                main
        fi


	host=`grep "^$cs " ${list_path} | awk '{print $2}'`
	ssh $host
	exit
}

main
