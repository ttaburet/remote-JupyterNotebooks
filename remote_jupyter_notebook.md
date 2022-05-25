<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.11.0/styles/default.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.11.0/highlight.min.js"></script>

<script>
function highlightCode() {
    var pres = document.querySelectorAll("pre>code");
    for (var i = 0; i < pres.length; i++) {
        hljs.highlightBlock(pres[i]);
    }
}
highlightCode();
</script>

</body>
</html>

# Running a Jupyter notebook from a remote server

For my researches, I often work with remote servers to run deep learning models, heavy CPU computations or files transfers on remote machines much more powerful than my modest laptop 🦾.

When writing papers or reports, I regularly use the jupyter notebook environment on my laptop to produce the figures resulting from the calculations made on these remote machines.

A long time ago, the pipeline I used was as follows:

- Carrying out the calculations on the server 🙃,
- Download of the results from the server to my laptop 😐,
- Processing of the results to obtain the plots 🙄,
- Keep writing my report 😮‍💨.

Not particularly effective, huh 😬?

In order to take care of my workflow I was tempted by the idea of using only my laptop as a control console, where through a jupyter notebook I could perform the computations and create my plots by only using the computation power of a remote server.
The resulting pipeline eliminates the need to process the data locally (to make the plots). Thus, I would only have to download my figures from the server to my laptop to integrate them into my article/report.

💡 The core idea is to run a "headless" notebook from your server, but display the graphical user interface (GUI) in the web browser of your local machine. The libraries, hardware and all backend related elements are up to your remote machine, but the GUI is seen from your laptop.


🚩 To ease the implementation of this solution, you'll find 3 sub-articles that will help you to set up a quick ssh connection (without having to type your password), create a file listing the dependencies of your notebook and a script to synchronize your files between your laptop and your server.

🚩 It is also possible to use this article as a take-away solution, in this case : needless to say, make sure that Jupyter notebook and all its dependencies are installed in both machines.

<ins>Set-up</ins>: let’s define the local host `localhost` 💻 and the remote host as `remotehost` 🖥️ respectively. 
In the same logic, the respective users of these two machines will be called `localuser` and `remoteuser`.

I strongly advise you to set up ssh authentication via keygen to avoid typing your password every 30 seconds. Here is a [web page](https://gitlab.univ-lr.fr/ttaburet/tips-and-tricks/-/blob/main/ssh.m
d) to help you do this (in less than a minute) :

<pre><code>This is a code block.
</code></pre>


### 1. Running Jupyter Notebook from remote machine

Firsts things first, log-in to your remote machine the usual way you do :

```shell-session
localuser@localhost:~$ ssh remoteuser@remotehost
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Dec  6 14:02:09 CET 2021

  System load:  0.0                 Processes:                  569
  Usage of /:   74.7% of 461.62GB   Users logged in:            0
  Memory usage: 8%                  IPv4 address for dockerY:   X.X.X.X
  Swap usage:   2%                  IPv4 address for enpZZZZZ: X.X.X.X
  Temperature:  36.0 C

 * Super-optimized for small spaces - read how we shrank the memory
   footprint of MicroK8s to make it the smallest full K8s around.

   https://ubuntu.com/blog/microk8s-memory-optimisation

160 updates can be applied immediately.
To see these additional updates run: apt list --upgradable


*** System restart required ***
Last login: Mon Dec  6 13:56:32 2021 from X.X.X.X
remoteuser@remotehost:~$
```
  
Once the console shows, in type the following:
```shell-session
remoteuser@remotehost:~$ jupyter notebook --no-browser --port=XXXX

# Note: Change XXXX to the port of your choice. Usually, the default is 8888. 
# You can try 8889 or 8890 as well.
```

- `jupyter notebook`: simply fires up your notebook,
- `--no-browser`: this starts the notebook without opening a browser to run this “headless” notebook,
- `--port=XXXX`: this sets the port for starting your notebook where the default is 8888. When it’s occupied, it finds the next available port.


On your remotehost, the notebook daemon is now running at the port XXXX that you specified.

### 2. Forward port XXXX to PORT YYYY and listen to it

You can access the notebook from your remote machine over SSH by setting up a SSH tunnel: forward port XXXX to port YYYY of your machine so that you can listen and run it from your browser (learn more about port forwarding [here](https://en.wikipedia.org/wiki/Port_forwarding)). To achieve this, we write the following command:

```shell-session
localuser@localhost:~$ ssh -N -f -L localhost:YYYY:localhost:XXXX remoteuser@remotehost
```

- `ssh`: your handy ssh command. See man page for more info or visit [this page](https://man.openbsd.org/ssh)
- `-N`: suppresses the execution of a remote command. Pretty much used in port forwarding.
- `-f`: this requests the ssh command to go to background before execution. This is useful if ssh is going to ask for passwords or passphrases, but the user wants it in the background.
- `-L`: this argument requires an input in the form of local_socket:remote_socket. Here, we’re specifying our port as YYYY which will be binded to the port XXXX from your remote connection.

### 3. Fire-up Jupyter Notebook on localhost

To open up the Jupyter notebook from your remote machine on your local machine, simply start your browser and type the following in your address bar: `localhost:YYYY`.

The reason why we’re opening it at port YYYY and not at port XXXX is because the latter is already being forwarded to the former. Port XXXX and YYYY can be the "same" number (not the same port, technically) because they are from different machines.

If you’re successful 👌, you should see the typical Jupyter Notebook home screen in the directory where you ran the command in the first step. At the same time, if you look in your remotehost's terminal, you should see some log actions happening as you perform some tasks.

🚩 In your first connection, you may be prompted to enter an Access Token 🔓 as typical to most Jupyter notebooks. 
Usually, I’d just copy-paste it from my terminal, but to make things easier for you, you can set-up your own notebook password (more infos [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#automatic-password-setup)) using this command :

```shell-session
localuser@localhost:~$ jupyter notebook password
Enter password:  ****
Verify password: ****
```

### 4. Making life easy for yourself 🧠

Both of this procedure are independant but the last one is the most efficient on a long project with always the same remote computer.
Whichever method you choose and even if you choose not to proceed with either of these two methods, I strongly advise you to set up a password-free ssh connection by using key sharing.


#### 4.1 The not that complete way:

OpenSSH provides client-side configuration which lead to a more hassle-free way of tunneling notebooks.
This one involves updating your SSH config file. You can usually find it in `$HOME/.ssh/config`.

The `~/.ssh` directory is automatically created when the user runs the ssh command for the first time. If the directory doesn’t exist on your system, create it using the command below:
```shell-session
localuser@localhost:~$ mkdir -p ~/.ssh && chmod 700 ~/.ssh
```
By default, the SSH configuration file may not exist, so you may need to create it (using the touch command for instance):
```shell-session
localuser@localhost:~$ touch ~/.ssh/config
```
This file must be readable and writable only by the user and not accessible by others:
```shell-session
localuser@localhost:~$ chmod 600 ~/.ssh/config
```

Now, open your config file:
```shell-session
localuser@localhost:~$ nano ~/.ssh/config
```

And add the following section :
`
Host notebooks
    HostName host
    User myuser
    LocalForward YYYY localhost:XXXX
`
where:

- `notebooks`: an arbitrary "label" for the connection you’ll make
- `HostName`: the username of the host that will connect aka `remotehost`
- `User`: the identity of the user that will connect or `remoteuser`
- `LocalForward`: specifies a connection that will forward the traffic to the remote machine

Given that, it’s now possible for us to connect as myuser@host in our remote server by just typing this command:

```shell-session
localuser@localhost:~$ ssh -Nf notebooks
```

🏁 To summarize the procedure:

- Step 1 : Starting remote jupyter daemon. Connect to the remote host through ssh and launch a headless jupyter notebook instance in background or using "screen" (to make it persistant) : `remoteuser@remotehost:~$ jupyter notebook --no-browser --port=XXXX`,
- Step 2 : Create ssh tunnel. On your localhost set up the ssh tunnel : `localuser@localhost:~$ ssh -Nf notebooks`,
- Step 3 : Fire up the notebook. On your localhost type the following in your address bar: `localhost:YYYY`.

#### 4.2 The MVP way:
🏴‍☠️ To go even further : it is possible to make this a little bit easier, such as casting all theses three steps using a single CLI command, a configuration and a shell script.
Whichever method you use and even if you choose not to continue with either of these two methods, I strongly advise you to set up a password-free ssh connection by using key sharing.

First, you need to locate your remote jupyter-notebook executable location by using `which `

```shell-session
remoteuser@remotehost:~$ which jupyter-notebook
```

Its output : `remotehost_jupyterpath` should be looking like this `/home/remoteuser/.local/bin/jupyter-notebook` depending or your python settings.

In your project folder, use the following commands to create your configuration file, your shell script and your "\data" folder (which you can synchronize with your server to retrieve your results).

__Folders creation:__
```shell-session
localuser@localhost:~$ mkdir Project
localuser@localhost:~$ cd Project
localuser@localhost:~/Project$ mkdir data
```

__Configuration file creation:__ Change `remoteuser`, `remotehost`, `XXXX`, `YYYY` and `remotehost_jupyterpath` with the values you chosen (I usually set XXXX=8889 and YYYY=8888):
```shell-session
localuser@localhost:~$ touch remote.conf
localuser@localhost:~$ nano remote.conf

remote_user='remoteuser'
remote_host='remotehost'

port_X=XXXX
port_Y=YYYY

servername='remoteJupyterNotebooks'

path_jupyter='remotehost_jupyterpath'
```
_PS : Don't forget the `' '`._


__Shell script copying__: Nothing but copy pasting here !
```shell-session
localuser@localhost:~$ touch remoteNotebooks.sh
localuser@localhost:~$ nano remoteNotebooks.sh

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

#Remove old ssh tunnels
if (ps -lef|grep "$SERVERNAME"|grep -v grep) > /dev/null 2>&1
then
    echo "${GREEN}[STOP]${NC}: local ssh process"
    ps -lef|grep "$SERVERNAME"|grep -v grep|awk '{print $4}'|xargs pkill -9 #-n1 /bin/bash -c 'echo "PID: $@"; kill -9 "$@";' ''
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

if (ps -lef|grep "$SERVERNAME"|grep -v grep) > /dev/null 2>&1
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
    echo    "2. Sync local and remote /data folder (do not work atm)"
    echo    "Enter q to exit."
    echo
    echo    "Enter your selection"

    read answer
    case "$answer" in
        1)  xdg-open http://localhost:"$PORT_Y" > /dev/null 2>&1;;
        
        2)  echo;;

        q)  if (ps -lef|grep "$SERVERNAME"|grep -v grep) > /dev/null 2>&1
            then
                ps -lef|grep "$SERVERNAME"|grep -v grep|awk '{print $4}'|xargs pkill -9
            fi
            exit 0;;
    esac
    echo "Enter return to continue \c"
    read input
done

exit 0
``` 

Now, save the changes and you're all set !

While you remote host is available, you should now be able to fire up your remote jupyter server, create a bridge to it and open jupyter-notebooks interface from your default web browser only by using `localuser@localhost:~/Project$ sh remoteNotebook.sh <your configuration file path>`.

---
##### Progress of the article
- [x] Perform SSH Login Without Password
- [ ] Automatically create requirements.txt
- [ ] Automatically install dependancies from laptop's code to server
- [ ] Fast file synchronization between laptop and server using RSYNC
