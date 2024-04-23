#!/bin/bash
SendTelegramMessage() {
    local message="${1}"
	rawurlencode "${message}";
    local encodedMessage=${REPLY}
/usr/bin/wget "https://api.telegram.org/bot${TG_API_TOKEN}/sendMessage?chat_id=${TG_CHAT_ID}&text=${encodedMessage}" -o /dev/null -O /dev/null
}
