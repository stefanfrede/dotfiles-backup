# Debian 9 server setup

## Add a Limited User Account

Up to this point, you have accessed your server as the root user, which has unlimited privileges and can execute any command–even one that could accidentally disrupt your server.

### Add a user

Create the user. You’ll then be asked to assign the user a password:

```
adduser stefanfrede
```

Add the user to the sudo group so you’ll have administrative privileges:

```
adduser stefanfrede sudo
```

After creating your limited user, disconnect from your server:

```
exit
```

Log back in as your new user. Replace the example IP address with your server’s IP address:

```
ssh stefanfrede@0.0.0.0
```

Now you can administer your server from your new user account instead of `root`. Nearly all superuser commands can be executed with `sudo` (example: `sudo iptables -L -nv`) and those commands will be logged to `/var/log/auth.log`.

## Install a Mosh Server as SSH Alternative

Mosh is available in Debian’s backports repositories. You’ll need to add stretch-backports to your sources.list, update your package information, then install from the backports repository. Here’s how:

```
sudo deb http://deb.debian.org/debian stretch-backports main
```

Run `apt-get update`:

```
sudo apt-get update
```

Install mosh from stretch-backports:

```
sudo apt-get -t stretch-backports install "mosh"
```

Mosh is now installed on your server.

## Harden SSH Access

By default, password authentication is used to connect to your server via SSH. A cryptographic key-pair is more secure because a private key takes the place of a password, which is generally much more difficult to brute-force.

### Create an Authentication Key-pair#

1. This is done on your local computer, **not** your server, and will create a 4096-bit RSA key-pair. 

```
ssh-keygen -m pem -t rsa -b 4096 -C "stefan@frede.info"
```

Press **Enter** to use the default names `id_rsa` and `id_rsa.pub` in `/home/stefanfrede/.ssh` before entering your passphrase.

2. Upload the public key to your server. Replace `0.0.0.0` with your server’s IP address.

#### Linux

```
ssh-copy-id stefanfrede@0.0.0.0
```

#### OSX

On your server (while signed in as your limited user):

```
mkdir -p /home/stefanfrede/.ssh && sudo chmod -R 700 /home/stefanfrede/.ssh/
```

From your local computer:

```
scp ~/.ssh/id_rsa.pub stefanfrede@0.0.0.0:~/.ssh/authorized_keys
```

Finally, you’ll want to set permissions for the public key directory and the key file itself:

```
sudo chmod -R 700 /home/stefanfrede/.ssh && chmod 600 /home/stefanfrede/.ssh/authorized_keys
```

These commands provide an extra layer of security by preventing other users from accessing the public key directory as well as the file itself.

## SSH Daemon Options

**Disallow root logins over SSH.** This requires all SSH connections be by non-root users. Once a limited user account is connected, administrative privileges are accessible either by using `sudo` or changing to a root shell using `su -`.

```
# /etc/ssh/sshd_config
# Authentication:
...
PermitRootLogin no
```

**Disable SSH password authentication.** This requires all users connecting via SSH to use key authentication. Depending on the Linux distribution, the line `PasswordAuthentication` may need to be added, or uncommented by removing the leading `#`.

```
# /etc/ssh/sshd_config
# Change to no to disable tunnelled clear text passwords
PasswordAuthentication no
```

Restart the SSH service to load the new configuration.

```
sudo systemctl restart sshd
```

## Networking Configuration

### IPv4 Firewall Rules

Switch to the root user:

```
sudo su -
```

Update the system:

```
apt update && apt upgrade
```

Flush any pre-existing rules and non-standard chains which may be in the system:

```
iptables -F && iptables -X
```

Install `iptables-persistent` so any iptables rules we make now will be restored on succeeding bootups. When asked if you want to save the current IPv4 and IPv6 rules, choose **No** for both protocols.

```
apt install iptables-persistent
```

Add IPv4 rules: `iptables-persistent` stores its rulesets in the files `/etc/iptables/rules.v4` and `/etc/iptables/rules.v6`. Open the `rules.v4` file and replace everything in it with the information below:

```
# /etc/iptables/rules.v4

# Allow all loopback (lo) traffic and reject anything
# to localhost that does not originate from lo.
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT
-A OUTPUT -o lo -j ACCEPT

# Allow ping and ICMP error returns.
-A INPUT -p icmp -m state --state NEW --icmp-type 8 -j ACCEPT
-A INPUT -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT

# Allow incoming SSH.
-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED --sport 22 -j ACCEPT

# Allow outgoing SSH.
-A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Allow incoming Mosh.
-A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED -m multiport --dport 60000:61000 -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED  -m multiport --sport 60000:61000 -j ACCEPT

# Allow UDP traffic on port 1194.
-A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT

# Allow DNS resolution and limited HTTP/S on eth0.
# Necessary for updating the server and timekeeping.
-A INPUT -i eth0 -p udp -m state --state ESTABLISHED --sport 53 -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED --sport 80 -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED --sport 443 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 80 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 443 -j ACCEPT

# Allow outgoing ip 217.86.193.108 on port 6812 on eht0 to connect with ARIGO Software GmbH > openVPN
-A OUTPUT -o eth0 -p udp -d 217.86.193.108/24 --dport 6812 -m state --state NEW,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p udp --sport 6812 -m state --state ESTABLISHED -j ACCEPT

# Allow outgoing port 6812 on eht0 to connect with ARIGO Software GmbH > Docker
-A OUTPUT -o eth0 -p tcp --dport 5000 -m state --state NEW,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p tcp --sport 5000 -m state --state ESTABLISHED -j ACCEPT

# Allow incoming port 6822 on eht0 to connect with ARIGO Software GmbH > GitLab
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED --sport 6822 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 6822 -j ACCEPT

# Allow traffic on the TUN interface so OpenVPN can communicate with eth0.
-A INPUT -i tun0 -j ACCEPT
-A OUTPUT -o tun0 -j ACCEPT

# Allow traffic on the ens3 interface to enable the server to restart.
-A INPUT -i ens3 -j ACCEPT
-A OUTPUT -o ens3 -j ACCEPT

# Log any packets which don't fit the rules above.
# (optional but useful)
-A INPUT -m limit --limit 3/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 4
-A FORWARD -m limit --limit 3/min -j LOG --log-prefix "iptables_FORWARD_denied: " --log-level 4
-A OUTPUT -m limit --limit 3/min -j LOG --log-prefix "iptables_OUTPUT_denied: " --log-level 4

# then reject them.
-A INPUT -j REJECT
-A FORWARD -j REJECT
-A OUTPUT -j REJECT

COMMIT
# /etc/iptables/rules.v4

```

You will disable IPv6 in the next section, so add an `ip6tables` ruleset to reject all IPv6 traffic:

```
cat >> /etc/iptables/rules.v6 << END
*filter

-A INPUT -j REJECT
-A FORWARD -j REJECT
-A OUTPUT -j REJECT

COMMIT
END
```

Activate the rulesets immediately and verify:

```
iptables-restore < /etc/iptables/rules.v4
ip6tables-restore < /etc/iptables/rules.v6
```

You can see your loaded rules with `sudo iptables -S`.

Load the rulesets into `iptables-persistent`. Answer **Yes** when asked if you want to save the current IPv4 and IPv6 rules.

```
dpkg-reconfigure iptables-persistent
```

### Disable IPv6

If you are exclusively using IPv4 on your VPN, IPv6 should be disabled unless you have a specific reason not to do so.

Add the following kernel parameters for systemd-sysctl to set on boot:

```
cat >> /etc/sysctl.d/99-sysctl.conf << END

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
END
```

Activate them immediately:

```
sysctl -p
```

Comment out the line for IPv6 resolution over localhost in /etc/hosts:

```
# /etc/hosts

# The following lines are desirable for IPv6 capable hosts
# ::1 ip6-localhost ip6-loopback
# fe00::0 ip6-localnet
# ff00::0 ip6-mcastprefix
# ff02::1 ip6-allnodes
# ff02::2 ip6-allrouters
# ff02::3 ip6-allhosts
```

## Setup Fail2ban

### Update the system

```
sudo su -
apt update && apt upgrade -y
shutdown -r now
```

After the system boots up, log back in and switch to root:

```
sudo su -
```

### Install fail2ban

Use `apt` to install the stable version of Fail2ban:

```
apt install fail2ban -y
```

After the installation, the Fail2ban service will start automatically. You can use the following command to show its status:

```
service fail2ban status
```

The default Fail2ban filter settings will be stored in both the `/etc/fail2ban/jail.conf` file and the `/etc/fail2ban/jail.d/defaults-debian.conf` file. Remember that settings in the latter file will override corresponding settings in the former one.

Use the following commands to view more details:

```
cat /etc/fail2ban/jail.conf | less
cat /etc/fail2ban/jail.d/defaults-debian.conf
fail2ban-client status
fail2ban-client status sshd
```

### Configure fail2ban

Since the contents in the two config files above might change in future system updates, you should create a local config file to store your own fail2ban filter rules. Again, the settings in this file will override corresponding settings in the two files mentioned above.

```
vim /etc/fail2ban/jail.d/jail-debian.local
```

Input the following lines:

```
[sshd]
maxentry = 3
```

Save and quit.

Restart the Fail2ban service in order to load the new configuration:

```
service fail2ban restart
```

