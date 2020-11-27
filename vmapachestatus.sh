#!/bin/bash
#https://www.securityinet.com/restarting-plesk-services-using-command-line/
#https://stackoverflow.com/questions/36590643/bash-script-to-check-if-apache-server-is-up-and-running
#SCript is designed to run on CentOS 6, please update if running on a different verion

#####TESTING LOCALLY######

SERVER=$(hostname)
WEBHOOK=""#Insert Slack webhook here
DOMAIN="jardsit.com"

generate_post_data_first()
{
  cat <<EOF
  {
	   "text": "$SERVER apache server down... attempting restart..." }
  }
EOF
}

generate_post_data_fail()
{
  cat <<EOF
	{ 
		"text": "$SERVER apache still down, requires attention!" 
	}
EOF
}

generate_post_data_success()
{
  cat <<EOF
	{ 
		"text": "$SERVER apache server restarted successfully"
	}
EOF
}

check_status(){
	httpcode=$(curl -L -s -m 30 -o /dev/null -w "%{http_code}" $DOMAIN)
	[ $httpcode == 200 ]
}


if ! check_status > /dev/null
then
    # web server down, restart the server
    echo $SERVER "apache server down"
	echo "Attepmting to restart..."
	curl -X POST -H "Content-Type: application/json" -d "$(generate_post_data_first)" $WEBHOOK   
	service httpd restart > /dev/null
    sleep 2

    #checking if apache restarted or not
    if ! check_status $DOMAIN> /dev/null
    then
	echo "$SERVER apache server still down"
	curl -X POST -H "Content-Type: application/json" -d "$(generate_post_data_fail)" $WEBHOOK 
    else
	echo "$SERVER apache server restarted successfully"
	curl -X POST -H "Content-Type: application/json" -d "$(generate_post_data_success)" $WEBHOOK 

    fi
fi











#####TESTING REMOTELY######
#declare -A domains
#domains=([x0]="www.jardsit.com" [x1]="jardsit.com/no")


check_status(){
	domain=$1
	httpcode=$(curl -L -s -o /dev/null -w "%{http_code}" $1)
	[ $httpcode == 200 ]
}


#for server in "${!domains[@]}"
#do
#	echo "Checking ${domains[$server]}" 
#	if check_status ${domains[$server]}
#	then
#	echo "$server is Up!"
#	else 
#	echo "$server is Down!"
#	fi

#done
