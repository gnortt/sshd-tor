#!/usr/bin/env bash

set -e

function _check_dependencies {
    for pkg in "$@"; do
        if ! dpkg-query -W --showformat='${Status}\n' "${pkg}" | grep 'install ok' 1> /dev/null; then
            _confirm_action "Missing dependency ${pkg}, install now?" && apt -y update && apt -y install "$pkg"
            return 1
        fi
    done
}

function _confirm_action {
    while true; do
        read -r -p "$* [Y/n]: " yn

        case $yn in
            [Yy]*) return 0;;  
            [Nn]*) return 1;;
            *) return 0;;
        esac
    done
}

case "$1" in
    install)
        _check_dependencies "openssl openssh-server tor"

        cp debian/sshd-tor.sshd-tor.service /lib/systemd/system/sshd-tor.service
        cp etc/tor/torrc.sshd-tor /etc/tor/torrc.sshd-tor
        
        mkdir -p /etc/sshd-tor
        cp etc/sshd-tor/sshd_config /etc/sshd-tor/sshd_config

        ./debian/postinst configure
    ;;

    uninstall)
        _confirm_action "Disable and remove sshd-tor service?" || return 0

        systemctl stop sshd-tor
        systemctl disable sshd-tor
        
        rm /lib/systemd/system/sshd-tor.service
        rm -rf /etc/sshd-tor
        rm -rf /var/lib/tor/sshd-service

        ./debian/postinst purge

        _confirm_action "Disable and remove tor package?" || return 0

        systemctl stop tor
        systemctl disable tor

        apt -y --purge remove tor
        rm -rf /etc/tor
    ;;

    builddeb)
        _check_dependencies "debhelper build-essential"
        
        dpkg-buildpackage -us -uc -tc -b
    ;;

    help|-h|--help|-H|*)
        echo "usage: $0 install | uninstall | builddeb"
    ;;
esac

exit 0
