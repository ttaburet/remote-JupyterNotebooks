# Perform SSH Login Without Password Using ssh-keygen & ssh-copy-id

You can login to a remote Linux server without entering password using ssh-keygen and ssh-copy-id as explained in this article.

These steps will only take a few seconds to complete.

<ins>Set-up</ins>: for the sake of readability, you'll be *localuser* 👨‍💻 on your *localhost* 💻 trying to connect your *remotehost* 🖥️ as *remoteuser* without typing your password. You only need to replace in the commands the string *remotehost* by the alias or I.P. address of your server.


`ssh-keygen` creates the public and private keys while `ssh-copy-id` copies the local-host’s public key to the remote-host’s authorized_keys file. 
ssh-copy-id also assigns proper permission to the remote-host’s home, `~/.ssh`, and `~/.ssh/authorized_keys`.

### 1. Create public 🔑 and private 🗝️ keys using ssh-key-gen on local-host

From your localhost, open a terminal and enter `ssh-keygen` to creates the public 🔑 and private 🗝️ keys.
If the operation is successful the output should look like this :

```shell-session
localuser@localhost:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/localuser/.ssh/id_rsa): [Press Enter]
Enter passphrase (empty for no passphrase): [Press Enter]
Enter same passphrase again: [Press Enter]
Your identification has been saved in /home/localuser/.ssh/id_rsa
Your public key has been saved in /home/localuser/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:s6N0OwlTDKjDez98kZRwUGZbTYaQUArv+EYC6sigFwA localuser@localhost
The key's randomart image is:
+---[RSA 2048]----+
|E   ..o=*o.+o    |
|.   .oo+oo...    |
|....  o=..       |
| o+. o  =        |
|o .oo ooS.       |
|* ...+o oo       |
|oo.. o+o+o       |
| .   o+o+o       |
|      .o..       |
+----[SHA256]-----+
```

### 2. Copy the public key 🔑 to remote-host using ssh-copy-id

To copy the public key 🔑 to the keys directory 🗂️ authorized by the remote server you just have to type this command in your terminal ( from your localhost ) : `ssh-copy-id -i ~/.ssh/id_rsa.pub remotehost`.
If the operation is successful the output should look like this :

```shell-session
localuser@localhost:~$ ssh-copy-id -i ~/.ssh/id_rsa.pub remoteuser@remotehost
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/localuser.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
remoteuser@remotehost's password: [Press password and press Enter]

Number of key(s) added: 1
#!/bin/bash
Now try logging into the machine, with:   "ssh 'remotehost'"
and check to make sure that only the key(s) you wanted were added.
```

*[Note] : The password of your remote session will be prompted in order to transfer the public key from your computer (localhost) to the remote server.*

### 3. Login to remote-host 🖥️ without entering the password 🎉

If the previous operations went smoothly, now try to connect to the remote server using `ssh remoteuser@remotehost`, you should no longer have to type your password ✅.

```shell-session
localuser@localhost:~$ ssh remoteuser@remotehost
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-88-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon Dec  6 14:54:13 CET 2021

  System load:  0.06                Processes:                  571
  Usage of /:   74.7% of 461.62GB   Users logged in:            1
  Memory usage: 8%                  IPv4 address for dockerY:   X.X.X.X
  Swap usage:   2%                  IPv4 address for enpYYYYYY: X.X.X.X
  Temperature:  33.0 C

 * Super-optimized for small spaces - read how we shrank the memory
   footprint of MicroK8s to make it the smallest full K8s around.

   https://ubuntu.com/blog/microk8s-memory-optimisation

160 updates can be applied immediately.
To see these additional updates run: apt list --upgradable


*** System restart required ***
Last login: Mon Dec  6 14:02:10 2021 from Y.Y.Y.Y
remoteuser@remotehost:~$ 
```

You can now have a cup of coffee ☕ and enjoy not typing your password 8390 times a day.