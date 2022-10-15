# sshd-tor

An easy installer for a *secondary* SSH daemon service *exclusively accessible via tor* as a *v3 hidden service* on debian based systems. The benefits of a tor SSH hidden service are reliable NAT traversal and emergency access in cases where inbound firewalls are unpredicatable, or VPN connections are unreliable.

The installer and configuration files are updated to work with the most recent Debian stable (currently **11/Bullseye**).

## Requirements

To install the sshd-tor service, you need:

* A debian/apt based distribution
* systemd
* openssh-server
* tor

To build the `.deb` package you will also need:

* build-essentials
* debhelper

You should be familiar with tor, openssh, and allow loopback traffic on `127.0.0.1`.

## Installation

To install, as `root` or using `sudo`:

```
    ./make.sh install
```

Alternatively, make a `.deb`:

```
    ./make.sh builddeb
    dpkg -i sshd-tor_x.x.x_amd64.deb
    apt --fix-broken install
```

**Note:** You will want to save the `SERVICE DETAILS` and `CLIENT CONFIG` output in a safe place.

## Usage

After installation on the server you will need to modify the __client__ system:

- Add `ClientOnionAuthDir /etc/tor/onions` to `/etc/tor/torrc`
- Create `/etc/tor/onions`
- Create `server_name.auth_private` in `/etc/tor/onions`
- Set the correct owner `chown -R debian-tor:debian-tor /etc/tor/onions`
- Add a host entry to `~/.ssh/config`

## Uninstallation

To uninstall, as `root` or using `sudo`:

```
    ./make.sh uninstall
```

If installed from a `.deb` package:

```
    apt remove sshd-tor
```

## Assumptions

The `openssh-server` configuration is opinionated and makes a number of assumptions:

- The installed version of openssh-server is sufficciently modern to support ssh-ed25519, curve25519-sha256@libssh.org, chacha20-poly1305@openssh.com and hmac-sha2-256-etm@openssh.com. These host key, MAC, cipher, and key exchange algorithms are used exclusively.
- The `root` account has a public key configured in `~/.ssh/authorized_keys`. Modify `PermitRootLogin` and `PasswordAuthentication` in `/etc/sshd-tor/sshd_config` if this is not the case.
- Only `root` is permitted to log in. Modify `AllowUsers` in `/etc/sshd-tor/sshd_config` if this is not the case.

Tor configuration files assume tor has not been installed or configured previously. An existing server `torrc` will be moved to `torrc.old`.