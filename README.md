# Secure your Debian 9 server

## Add a Limited User Account
https://www.linode.com/docs/security/securing-your-server/#add-a-limited-user-account

To add a new user log in to your server  via SSH. Replace the `0.0.0.0` with
your server’s IP address:

```shell
ssh root@0.0.0.0
```

### Add a user

A standard Debian Server installation does not include sudo by default. If you
don’t already have sudo, you’ll need to install it before going further.

1. Create the user. You’ll then be asked to assign the user a password:

    ```shell
    adduser stefanfrede
    ```

2. Add the user to the `sudo` group so you’ll have administrative privileges:

    ```shell
    adduser stefanfrede sudo
    ```

3. After creating your limited user, disconnect from your server:

    ```shell
    exit
    ```

4. Log back in as your new user. Replace the `0.0.0.0` with your server’s IP
   address:

    ```shell
    ssh stefanfrede@0.0.0.0
    ```

Now you can administer your server from your new user account instead of `root`.
Nearly all superuser commands can be executed with `sudo` (example: `sudo
iptables -L -nv`) and those commands will be logged to `/var/log/auth.log`.

## Install a Mosh Server as SSH Alternative

https://www.linode.com/docs/networking/ssh/install-mosh-server-as-ssh-alternative-on-linux/

Mosh is available in Debian’s backports repositories. You’ll need to add
stretch-backports to your sources.list, update your package information, then
install from the backports repository. Here’s how:

1. Edit `/etc/apt/sources.list` and add the following line:

    ```shell
    deb http://deb.debian.org/debian stretch-backports main
    ```

2. Run `sudo apt-get update`:

3. Install mosh from stretch-backports:

    ```shell
    sudo apt-get -t stretch-backports install "mosh"
    ```

Mosh is now installed on your server.

## Harden SSH Access

https://www.linode.com/docs/security/securing-your-server/#harden-ssh-access

By default, password authentication is used to connect to your server via SSH. A
cryptographic key-pair is more secure because a private key takes the place of a
password, which is generally much more difficult to brute-force.

### Create an Authentication Key-pair#

1. This is done on your local computer, **not** your server, and will create a
   4096-bit RSA key-pair.

    **Linux/OSX**

    ```shell
    ssh-keygen -m pem -t rsa -b 4096 -C "stefan@frede.info"
    ```

    Press **Enter** to use the default names `id_rsa` and `id_rsa.pub` in
    `/home/stefanfrede/.ssh` before entering your passphrase.

2. Upload the public key to your server. Replace `0.0.0.0` with your server’s IP
   address.

    **Linux**

    ```shell
    ssh-copy-id stefanfrede@0.0.0.0
    ```

    **OSX**

    On your server (while signed in as `stefanfrede`):

    ```shell
    mkdir -p /home/stefanfrede/.ssh && sudo chmod -R 700 /home/stefanfrede/.ssh/
    ```

    From your local computer:

    ```shell
    scp ~/.ssh/id_rsa.pub stefanfrede@0.0.0.0:~/.ssh/authorized_keys
    ```

3. Secure the public key directory and the key file itself on you server:

    ```shell
    sudo chmod -R 700 /home/stefanfrede/.ssh && chmod 600 /home/stefanfrede/.ssh/authorized_keys
    ```

    These commands provide an extra layer of security by preventing other users from accessing the public key directory as well as the file itself.

## SSH Daemon Options

https://www.linode.com/docs/security/securing-your-server/#ssh-daemon-options

1. **Disallow root logins over SSH.** This requires all SSH connections be by
   non-root users. Once a limited user account is connected, administrative
   privileges are accessible either by using `sudo` or changing to a root shell
   using `su -`.

    */etc/ssh/sshd_config*

    ```shell
# Authentication:
    ...
    PermitRootLogin no
    ```

2. **Disable SSH password authentication.** This requires all users connecting
   via SSH to use key authentication. Depending on the Linux distribution, the
   line `PasswordAuthentication` may need to be added, or uncommented by
   removing the leading `#`.

    */etc/ssh/sshd_config*

    ```shell
    # Change to no to disable tunnelled clear text passwords
    PasswordAuthentication no
    ```

3. Restart the SSH service to load the new configuration.

    ```shell
    sudo systemctl restart sshd
    ```

## Networking Configuration

https://www.linode.com/docs/networking/vpn/set-up-a-hardened-openvpn-server/

### IPv4 Firewall Rules

1. Switch to the root user:

    ```shell
    sudo su -
    ```

2. Update the system:

    ```shell
    apt update && apt upgrade -y
    ```

3. Flush any pre-existing rules and non-standard chains which may be in the system:

    ```shell
    iptables -F && iptables -X
    ```

4. Install `iptables-persistent` so any iptables rules we make now will be
   restored on succeeding bootups. When asked if you want to save the current
   IPv4 and IPv6 rules, choose **No** for both protocols.

    ```shell
    apt install iptables-persistent
    ```

5. Add IPv4 rules: `iptables-persistent` stores its rulesets in the files
   `/etc/iptables/rules.v4` and `/etc/iptables/rules.v6`. Open the `rules.v4`
   file and replace everything in it with the information below:

    */etc/iptables/rules.v4*

    ```shell
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
    ```

6. You will disable IPv6 in the next section, so add an `ip6tables` ruleset to
   reject all IPv6 traffic:

    ```shell
    cat >> /etc/iptables/rules.v6 << END
    *filter

    -A INPUT -j REJECT
    -A FORWARD -j REJECT
    -A OUTPUT -j REJECT

    COMMIT
    END
    ```

7. Activate the rulesets immediately and verify:

    ```shell
    iptables-restore < /etc/iptables/rules.v4
    ip6tables-restore < /etc/iptables/rules.v6
    ```

    You can see your loaded rules with `sudo iptables -S`.

8. Load the rulesets into `iptables-persistent`. Answer **Yes** when asked if
   you want to save the current IPv4 and IPv6 rules.

    ```shell
    dpkg-reconfigure iptables-persistent
    ```

### Disable IPv6

If you are exclusively using IPv4 on your VPN, IPv6 should be disabled.

1. Add the following kernel parameters for `systemd-sysctl` to set on boot:

    ```shell
    cat >> /etc/sysctl.d/99-sysctl.conf << END

    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1
    net.ipv6.conf.eth0.disable_ipv6 = 1
    END
    ```

2. Activate them immediately:

    ```shell
    sysctl -p
    ```

3. Comment out the line for IPv6 resolution over localhost in `/etc/hosts`:

    */etc/hosts*

    ```shell
    # The following lines are desirable for IPv6 capable hosts
    # ::1 ip6-localhost ip6-loopback
    # fe00::0 ip6-localnet
    # ff00::0 ip6-mcastprefix
    # ff02::1 ip6-allnodes
    # ff02::2 ip6-allrouters
    # ff02::3 ip6-allhosts
    ```

## Setup Fail2ban

https://www.linode.com/docs/security/using-fail2ban-for-security/

### Install fail2ban

1. Ensure your system is up to date:

    ```shell
    apt-get update && apt-get upgrade -y
    ```

2. Install Fail2ban:

    ```
    apt install fail2ban -y
    ```

    The service will automatically start. You can use the following command to
    show its status:

    ```
    service fail2ban status
    ```

    The default Fail2ban filter settings will be stored in both the
    `/etc/fail2ban/jail.conf` file and the
    `/etc/fail2ban/jail.d/defaults-debian.conf` file. Remember that settings in
    the latter file will override corresponding settings in the former one.

    Use the following commands to view more details:

    ```
    cat /etc/fail2ban/jail.conf | less
    cat /etc/fail2ban/jail.d/defaults-debian.conf
    fail2ban-client status
    fail2ban-client status sshd
    ```

### Configure fail2ban

1. Since the contents in the two config files above might change in future
   system updates, you should create a local config file to store your own
   fail2ban filter rules. Again, the settings in this file will override
   corresponding settings in the two files mentioned above.

    ```
    vim /etc/fail2ban/jail.d/jail-debian.local
    ```

2. Input the following lines:

    ```
    [sshd]
    maxentry = 3
    ```

3. Save and quit.

4. Restart the Fail2ban service in order to load the new configuration:

    ```
    service fail2ban restart
    ```

