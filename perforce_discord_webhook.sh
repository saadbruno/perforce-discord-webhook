#!/bin/bash

# This script sends a changelist from perforce to a Discord webhook
# USAGE:
# p4_change_discord.sh <changelist number> <discord webhook link>
#
# This chan be used in conjunction with the p4 triggers, so everytime a new changelist is send, this script is run automatically
# p4 triggers example config:
# Triggers:
#       discord change-commit //depot/... "/bin/bash /home/perforce/discord.sh %changelist% https://discordapp.com/api/webhooks/<id>/<auth>"
#
# Note that for the p4 triggers command to work, the linux user running the p4d needs to have access to the script, and the p4 user running "p4 describe" needs read access to the depot.

OUTPUT=$(p4 describe -s $1)

# echoes the output | only select the indented lines (which is basically the description) | Removes special characters | Converts new lines to \n (so they are sent as proper line breaks in discord)
DESC=$(echo "$OUTPUT" | awk '/^[[:blank:]]/' | sed "s/[^a-zA-Z\ \.\,\!\?\-]//g" | awk '{printf "%s\\n", $0}')

# this selects the user of the commit, which is basicaly the 4th column of the first line of the changelist
USER=$(echo "$OUTPUT" | head -n 1 | cut -d" " -f4)

# builds the embed
EMBED='{ "username":"P4V","avatar_url":"https://i.imgur.com/unlgXvg.png","embeds":[{ "title":"Change '"$1"' by '"$USER"'","color":"701425","fields":[{ "name":"Description","value":"'"$DESC"'","inline":false} ]}]}'

# sends it
curl -H "Content-Type: application/json" \
-X POST \
-d "$EMBED" \
$2