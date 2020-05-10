#!/bin/bash

cacheFilename="/tmp/my-public-ip-addr.dat"
telegramBotToken=""
chatId=""

# Resolve current public IP
IP=$( dig +short myip.opendns.com @resolver1.opendns.com )

# if we don't have a file, start from scratch
if [ ! -f "$cacheFilename" ] ; then
  oldIP=``

# otherwise read the value from the saved IP address
else
  oldIP=`cat $cacheFilename`
fi

# if needed, notify telegram bot and save current IP
if [ "$oldIP" != "$IP" ] ; then
  curl --silent --output /dev/null --show-error --fail -s -X POST https://api.telegram.org/bot$telegramBotToken/sendMessage -d chat_id="$chatId" -d text="$HOSTNAME detected an IP Address change: $IP" -d disable_notification=true

  echo "${IP}" > $cacheFilename
fi

