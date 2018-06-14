#!/bin/sh

# Created by Ian Spence (@ecnepsnai on GithHub)
# https://github.com/ecnepsnai/lxc-scripts

function lxc_info() {
    cd /var/lib/lxc
    echo "Container            State        IP             "
    echo "-------------------------------------------------"
    for CONTAINER in *; do
        CONTAINER_INFO=$(mktemp)
        lxc-info -n $CONTAINER > $CONTAINER_INFO

        STATE=$(grep "State:" $CONTAINER_INFO | tr -s " " | cut -d " " -f2)
        IP=$(grep "IP:" $CONTAINER_INFO | tr -s " " | cut -d " " -f2)

        printf "%-20s %-12s %-15s\n" $CONTAINER $STATE $IP

        rm -f $CONTAINER_INFO
    done
}

function lxc_start() {
    CONTAINER=$1
    lxc-start -d -n $CONTAINER
    echo "Started $CONTAINER in background."
}

function lxc_stop() {
    CONTAINER=$1
    lxc-stop -W -n $CONTAINER
    echo "Stopping $CONTAINER in background."
}

function lxc_reboot() {
    CONTAINER=$1
    echo "Rebooting $CONTAINER..."
    lxc-stop -r -n $CONTAINER
}

function lxc_edit() {
    CONTAINER=$1
    "${EDITOR:-vi}" /var/lib/lxc/$CONTAINER/config
}

CMD=$1
case $CMD in
list)
    lxc_info
    ;;
start)
    lxc_start $2
    ;;
stop)
    lxc_stop $2
    ;;
reboot)
    lxc_reboot $2
    ;;
edit)
    lxc_edit $2
    ;;
esac
