#!/bin/bash
set -e

COLOR_NC="\e[39m"
COLOR_BLUE="\e[34m"
COLOR_GREEN="\e[32m"

if [[ -z "${CONTAINER_NAME}" ]]; then
echo -en "Container Name: ${COLOR_BLUE}"
read CONTAINER_NAME
echo -en "${COLOR_NC}"
fi
if [[ -z "${FULL_NAME}" ]]; then
echo -en "Your full name: ${COLOR_BLUE}"
read FULL_NAME
echo -en "${COLOR_NC}"
fi
if [[ -z "${USERNAME}" ]]; then
echo -en "UNIX username: ${COLOR_BLUE}"
read USERNAME
echo -en "${COLOR_NC}"
fi
if [[ -z "${PASSWORD}" ]]; then
echo -n "Password for that user (Not Echoed): "
read -s PASSWORD
echo
fi

LOG=$CONTAINER_NAME-create.log

echo -e "\nWill create new LXC container named ${COLOR_BLUE}'$CONTAINER_NAME'${COLOR_NC} containing user ${COLOR_BLUE}'$USERNAME'${COLOR_NC} set with password."
echo -e "Logging to '$LOG'\n"

# Create the container
echo -n "Creating container..."
lxc-create -n $CONTAINER_NAME -t /usr/share/lxc/templates/lxc-centos > "${LOG}" 2>&1
echo -e " ${COLOR_GREEN}created${COLOR_NC}"

# Enable root account
sed -i "s/root:\*/root:/" /var/lib/lxc/$CONTAINER_NAME/rootfs/etc/shadow > "${LOG}" 2>&1
echo "Root user ${COLOR_GREEN}created${COLOR_NC}"

# Start container
echo -n "Starting container..."
lxc-start -d -n $CONTAINER_NAME > "${LOG}" 2>&1

# Wait for the container to start
sleep 10s
echo -e " ${COLOR_GREEN}started${COLOR_NC}"

# Make user
lxc-attach -n $CONTAINER_NAME -- useradd -m -s /bin/bash -c "$FULL_NAME" $USERNAME
lxc-attach -n $CONTAINER_NAME -- echo "$USERNAME:$PASSWORD" | chpasswd
echo -e "Created ${COLOR_BLUE}$USERNAME${COLOR_NC} and set password"

echo -e "${COLOR_GREEN}Finished${COLOR_NC}"
