#!/bin/bash

# This script sends a changelist from perforce to a Discord webhook
# USAGE:
# perforce_discord_webhook.sh <changelist number> <discord webhook link>
#
# This chan be used in conjunction with the p4 triggers, so everytime a new changelist is send, this script is run automatically
# p4 triggers example config:
# Triggers:
#       discord change-commit //depot/... "/bin/bash /home/perforce/perforce_discord_webhook.sh %changelist% https://discordapp.com/api/webhooks/<id>/<auth>"
#
# Note that for the p4 triggers command to work, the linux user running the p4d needs to have access to the script, and the p4 user running "p4 describe" needs read access to the depot.

# Uncomment this to enable debugging
exec &> $(dirname "$0")/output.log

printf ":: Running perforce_discord_webhook.sh\n\n"

OUTPUT=$(p4 describe -s $1)
# echoes the output
# | only select the indented lines (which is basically the description)
# | escapes quotes
# | Converts new lines to \n (so they are sent as proper line breaks in discord)
# collapses all tabs and spaces to a single space
DESC=$(echo "$OUTPUT" | awk '/^[[:blank:]]/' | sed s/[\'\"]/\\\'/g | awk '{printf "%s\\n", $0}' | tr -s [:space:] ' ')

# this selects the user of the commit, which is basicaly the 4th column of the first line of the changelist
USER=$(echo "$OUTPUT" | head -n 1 | cut -d" " -f4)

# builds the embed
EMBED='{ "username":"P4V","avatar_url":"https://i.imgur.com/unlgXvg.png","embeds":[{ "title":"Change '"$1"' by '"$USER"'","color":"701425","fields":[{ "name":"Description","value":"'"$DESC"'","inline":false} ]}]}'

# sends it
printf ":: Sending webhook...\n\n"
curl -H "Content-Type: application/json" \
-X POST \
-d "$EMBED" \
$2

printf "\n\n===== DEBUG =====
:: Linux user:
$(whoami)

:: Linux path:
$(pwd)

:: p4 info:
$(p4 info)

:: output:
$OUTPUT

:: desc:
$DESC

:: user:
$USER

:: embed:
$EMBED

:: Arg 1:
$1

:: Arg 2:
$2
"
