#! /bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

if [ "$#" -eq 1 ]; then
    PATH_conf=$1
elif [ "$#" -gt 1 ]; then
    echo "${ORANGE}[WARNING]${NC}: This script takes at most one argument."
    #exit 1
else
    PATH_conf="./remote.conf" #Must be changed
fi

if [ ! -f "$PATH_conf" ]; then
    echo "$PATH_conf does not exist."
    exit 1
fi

echo "Using configuration file : $PATH_conf"

. "./"${PATH_conf}

REMOTE_USER="$remote_user"
REMOTE_HOST="$remote_host"
PORT_X="$port_X"
PORT_Y="$port_Y"
SERVERNAME="$servername"
PATH_JUPYTER="$path_jupyter"
PATH_REMOTE_PROJECT="$path_remote_folder"

#Remove old ssh tunnels
if (ps -lef|grep "$SERVERNAME"|grep ssh|grep -v grep) > /dev/null 2>&1
then
    echo "${GREEN}[STOP]${NC}: local ssh process"
    ps -lef|grep "$SERVERNAME"|grep ssh|grep -v grep|awk '{print $4}' |xargs kill -9 #-n1 /bin/bash -c 'echo "PID: $@"; kill -9 "$@";' ''
fi

#Check remotehost ssh connection
timeout 10 ssh -q "$REMOTE_USER"@"$REMOTE_HOST" exit
SSH_check=$?

if [ "$SSH_check" -eq 0 ]; then
    echo "${GREEN}[Ok]${NC}: ssh connection"
else
    echo "${RED}[FAILED]${NC}: ssh connection, error code : ${RED}[${SSH_check}]${NC}"
    exit 1
fi

#Checking if remotehost jupyternotebook is already launched
if (ssh -q "$REMOTE_USER"@"$REMOTE_HOST" "ps -lef|grep 'jupyter-notebook --no-browser --port=$PORT_X'|grep -v 'grep'") > /dev/null 2>&1
then
    echo "${GREEN}[OK]${NC}: a jupyter-notebook process is already running on $REMOTE_HOST"
else
    #Launch remotehost jupyter headless notebook
    echo "${ORANGE}[WARNING]${NC}: no jupyter-notebook process is running on $REMOTE_HOST"
    echo "${ORANGE}[WARNING]${NC}: launching jupyter-notebook on $REMOTE_HOST"
    ssh "$REMOTE_USER"@"$REMOTE_HOST" "$PATH_JUPYTER --no-browser --port=$PORT_Y &> /dev/null &"
    sleep 10 #Sleep for 10s
    
    #Check if remotehost jupyternotebook is now launched
    if (ssh -q "$REMOTE_USER"@"$REMOTE_HOST" "ps -lef|grep 'jupyter-notebook --no-browser --port=$PORT_X'|grep -v 'grep'") > /dev/null 2>&1
    then
        echo "${GREEN}[OK]${NC}: a jupyter-notebook process is now running on $REMOTE_HOST"
    else
        echo "${RED}[WARNING]${NC}: it seems that jupyter-notebook failed to launch on $REMOTE_HOST, try to connect manually on $REMOTE_HOST and launch a headless jupyter-notebook using '$PATH_JUPYTER --no-browser --port=$PORT_X'"
    fi
fi
 
#Create SSH tunnel
ssh -N -f -M -L "localhost:$port_Y:localhost:$port_X" "$REMOTE_USER"@"$REMOTE_HOST" "$SERVERNAME"

sleep 5

if (ps -lef|grep "$SERVERNAME"|grep ssh|grep -v grep) > /dev/null 2>&1
then
    echo "${GREEN}[Ok]${NC}: SSH tunnel is now running"
else
    echo "${RED}[FAILED]${NC}: SSH tunnel"
    exit 1
fi

while true; do
    clear
    echo    "=============================="
    echo    "|           Menu             |"
    echo    "=============================="
    echo    
    echo    "1. Open default web browser"
    echo    "2. Pull remote folder to local current folder"
    echo    "3. Push local current folder to remote"
    echo    "4. Synchronization : Pull (new data from remote) and push (local changes to remote)"
    echo    "Enter q to exit."
    echo
    echo    "Enter your selection"

    read answer
    case "$answer" in
        1)  xdg-open http://localhost:"$PORT_Y" > /dev/null 2>&1;;

        2)  rsync -azP "$REMOTE_USER"@"$REMOTE_HOST":"$PATH_REMOTE_PROJECT" .;;
        
        3)  rsync -azP ./ "$REMOTE_USER"@"$REMOTE_HOST":"$PATH_REMOTE_PROJECT";;

        4)  rsync -azP "$REMOTE_USER"@"$REMOTE_HOST":"$PATH_REMOTE_PROJECT" .
            rsync -azP ./ "$REMOTE_USER"@"$REMOTE_HOST":"$PATH_REMOTE_PROJECT";;

        q)  if (ps -lef|grep "$SERVERNAME"|grep ssh|grep -v grep) > /dev/null 2>&1
            then
                ps -lef|grep "$SERVERNAME"|grep ssh|grep -v grep|awk '{print $4}'|xargs kill -9
            fi
            exit 0;;
    esac
    echo "Enter return to continue \c"
    read input
done

exit 0