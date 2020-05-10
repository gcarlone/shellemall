#!/bin/bash

# GoDaddy API Specification at
# https://developer.godaddy.com/getstarted
# https://developer.godaddy.com/keys

telegramChatId=""
telegramBotToken=""

mydomain=""
myhostname="@"

gdapikey="api_key:key_secret"

logdest="/var/log/godaddy-ddns-updates.log"

# Resolve current public IP
# alternative: mygdip=`curl -s "https://api.ipify.org"`
myIP=$( dig +short myip.opendns.com @resolver1.opendns.com )

# Retrieve GoDaddy DNS IP for hostname
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}"`
gdIP=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`

if [ "$gdIP" == "UNABLE_TO_AUTHENTICATE" ] ; then
  echo "`date '+%Y-%m-%d %H:%M:%S'` - Unable to Authenticate" >> $logdest

  curl --silent --output /dev/null --show-error --fail -s -X POST https://api.telegram.org/bot$telegramBotToken/sendMessage -d chat_id="$telegramChatId" -d text="$HOSTNAME is unable to Authenticate to GoDaddy API"

# if needed, update GoDaddy DNS IP for hostname
elif [ "$gdIP" != "$myIP" ] ; then
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myIP}\"}]"

  echo "`date '+%Y-%m-%d %H:%M:%S'` - Changed GoDaddy DNS IP on ${myhostname}.${mydomain} from ${gdIP} to ${myIP}" >> $logdest

  # notify telegram bot
  curl --silent --output /dev/null --show-error --fail -s -X POST https://api.telegram.org/bot$telegramBotToken/sendMessage -d chat_id="$telegramChatId" -d text="$HOSTNAME detected an IP change, GoDaddy DNS IP has been updated from $gdIPto $myIP"
fi
