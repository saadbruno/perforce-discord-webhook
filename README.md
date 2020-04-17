# Perforce Discord Webhook
This is a script that posts a message to Discord every time a new changelist is submitted from the Perforce version control system.

## Requirements:
1. This was only tested with p4d running on a linux system (Ubuntu 18.04)
2. The Perforce user needs access read access to the depot, so it can access the `p4 describe` command (more info below)
3. You need a [Discord Webhook](https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks) set up
4. You need access to edit the `p4 triggers` on the server

## Installation:
### 1. Setting up p4 access on the command line
Perforce triggers run as the same linux user as the Perforce server is running. It's usually the `perforce` user, but you can double check by running `ps aux | grep p4d`

So for the script to work, the `perforce` user needs to be able to run `p4 describe` successfully. To do that, the steps are as following:
1. Log in as the `perforce` user on the terminal by running `sudo su perforce` (followed by `bash` if needed).
2. Set your Perforce login by running
```
p4 set P4PORT=your.server.hostname:1666
p4 set P4USER=your.username
p4 login
```
Followed by your password. It's easier if the user set up in this step has no session timeout, so you don't have to log in over and over. You can change that in the p4 admin app. (See suggestion below)

#### Note on p4ctl
If you're using p4ctl to manage your servers, the user set in the p4ctl config must be the same as set on item 1.2 (in the `p4 set P4USER=your.username` command)

To check that, either check the `/etc/perforce/p4dctl.conf` file or the `/etc/perforce/p4dctl.conf.d/` directory containing your server configuration file. More info [here](https://www.perforce.com/perforce/r16.1/manuals/p4sag/appendix.p4dctl.html).

### 2. Setting up the script
That's the easy part.
1. Clone the repo, or [download the script](https://raw.githubusercontent.com/saadbruno/perforce-discord-webhook/master/perforce_discord_webhook.sh) and save it somewhere where the perforce user (or whatever user your server is running) has access to.
2. Make sure the script is executable by running `chmod u+x perforce_discord_webhook.sh`

At this point, you should already be able to run the script manually with `./perforce_discord_webhook.sh <changelist number> <discord webhook link>`

### 3. Setting up the trigger
Perforce has a Triggers system, where you can configure the server to do actions based on triggers. We are gonna create a trigger that runs this script every time a cahngelist is submitted successfully

1. on a terminal run `p4 triggers`. This will open the server triggers editor.
2. Add a new trigger with these settings:
```
Triggers:
	discord change-commit //depot/... "/bin/bash <perforce_discord_webhook.sh location> %changelist% <discord webhook link>
```
And replace the location and the webhook links according to your setup. Example:
```
	discord change-commit //depot/... "/bin/bash /home/perforce/perforce_discord_webhook.sh %changelist% https://discordapp.com/api/webhooks/<id>/<auth>"
```
You can also customize this to trigger only on specific directories by changing the `//depot/...` bit.

**Note:** It is really important to keep the tab before the trigger line, otherwise the server will not recognize it.

[p4 triggers documentation](https://www.perforce.com/manuals/v18.1/cmdref/index.html#CmdRef/p4_triggers.html)  
You can also run `p4 help triggers` for more info

***

At this point, everything should be working as intended! Submit a new changelist and check it out!

*** 

### Suggestion: user management
In item 1.2 it was mentioned that it's easier if the user running the `p4 describe` command doesn't have a timeout so you don't need to reauthenticate from time to time.

For security reasons, it is better to set up a user that has only read access to the depot, and can only be used from the localhost. 
1. On the P4Admin app, create a new group with `unset` session time out
2. Create a new user and assign it to that group.
3. On the permissions tab, add the following line:
| Access Level | User / Group | Name | Host | Folder / File |
| --- | --- | --- | --- | --- |
| read | user | <username> | 127.0.0.1 | //depot/... |

This will mean this new user will have no session timeout, but will only be able to read the depot, and from the localhost.
