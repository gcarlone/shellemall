#!/bin/bash

FILENAME="/tmp/my-public-ip-addr.dat"
TELEGRAM_BOT_TOKEN=

# Resolve current public IP
IP=$( dig +short myip.opendns.com @resolver1.opendns.com )

# if we don't have a file, start from scratch
if [ ! -f "$FILENAME" ] ; then
  oldIP=``

# otherwise read the value from the saved IP address
else
  oldIP=`cat $FILENAME`
fi

# if needed, notify telegram bot and save current IP
if [ "$oldIP" != "$IP" ] ; then
  chatId=`curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates | jq '.result[0].message.chat.id'`

  curl --silent --output /dev/null --show-error --fail -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id="$chatId" -d text="$HOSTNAME detected an IP Address change: $IP" -d disable_notification=true

  echo "${IP}" > $FILENAME
fi

