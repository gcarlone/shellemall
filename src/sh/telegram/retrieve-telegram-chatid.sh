#!/bin/bash

read -s -p "Please enter the Telegram Bot Token: " telegramBotToken
echo

chatId=`curl -s -X POST https://api.telegram.org/bot$telegramBotToken/getUpdates | jq '.result[0].message.chat.id'`

echo "ChatId is $chatId"
