#!/bin/bash
# Pimous Servers (Scripts and Docker files)
# Copyright &copy; 2025 - Pimous Dev. (https://www.pimous.dev/)
#
# This script is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# The latter are distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# No copy of the license is bundled with the script (As it is posted in a GitHub
# gist). Please see https://www.gnu.org/licenses/.
#-------------------------------------------------------------------------------
# Initialization and preparation script for Infomaniak VPS.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 Choosen disk not found.
#-------------------------------------------------------------------------------

read -r -d '' SFDISK_SCRIPT <<-EOF 
	label: gpt
	unit: sectors
	sector-size: 512
	first-lba: 2048
	last-lba: 524287966

	start=2048, size=524285919, type=933AC7E1-2EB4-4F13-B844-0E14E2AEF915
EOF
read -r -d '' FSTAB_LINE <<-EOF 
	PARTUUID=%s %s %s noatime,nodiratime 0 2\n
EOF

PARTITION_FORMAT=ext4
TEMPORARY_MOUNTS_DIR=/mnt
FINAL_MOUNT_POINT=/home
TEMPORARY_MOUNT_DIR=$TEMPORARY_MOUNTS_DIR/$FINAL_MOUNT_POINT
FSTAB_FILE_PATH=/etc/fstab
AUTH_KEYS_FILE_PATH=/home/%s/.ssh/authorized_keys

# ---
echo "## INSTALLING NEEDED PACKAGES"
sudo apt update
sudo apt install -y ca-certificates curl  \
	--no-install-recommends --no-install-suggests

echo "## INSTALLING SPECIAL PACKAGES"

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
	-o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
	| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y xfsprogs git docker-ce \
	--no-install-recommends --no-install-suggests

# ---
echo "## PARTITIONNING AND MOUNTING DISK"
lsblk
echo -n "Which disk is the data disk? "
read -r disk
disk=/dev/$disk
part="$disk"1

if [[ ! -e $disk ]]; then
	echo "Disk doesn't exist"
	exit 3
fi

echo "## CREATING GPT PARTITION TABLE WITH ONE FULL PARTITION"
echo -n "$SFDISK_SCRIPT" | sudo sfdisk "$disk" --wipe always || exit 2

echo "## FORMATTING TO $PARTITION_FORMAT NEW PARTITIONS"
yes | sudo mkfs -t $PARTITION_FORMAT "$part" || exit 2

echo "## COPYING OLD /home"
sudo mkdir $TEMPORARY_MOUNT_DIR
sudo mount "$part" $TEMPORARY_MOUNT_DIR

sudo cp -fr $FINAL_MOUNT_POINT/. $TEMPORARY_MOUNT_DIR --preserve=all

sudo umount $TEMPORARY_MOUNT_DIR
sudo rmdir $TEMPORARY_MOUNT_DIR

echo "## MOUNTING ON $FINAL_MOUNT_POINT AND UPDATING $FSTAB_FILE_PATH"
sudo mount "$part" $FINAL_MOUNT_POINT

# shellcheck disable=SC2059
printf "$FSTAB_LINE" \
		"$(sudo blkid -s PARTUUID -o value "$part")" \
		$FINAL_MOUNT_POINT \
		$PARTITION_FORMAT \
	| sudo tee -a $FSTAB_FILE_PATH > /dev/null

# ---
echo "## CREATING ADMIN USER"
echo -n "What is the new admin user? "
read -r user

echo "## CREATING THE USER $user FOR ADMINISTRATION"
sudo adduser "$user" --disabled-password 
sudo usermod xibitol --groups users,staff,docker

echo "## COPYING authorized_keys FILE FROM $USER"
# shellcheck disable=SC2059
sudo cp -fr "$(printf "$AUTH_KEYS_FILE_PATH" "$USER")" \
	"$(dirname "$(printf "$AUTH_KEYS_FILE_PATH" "$user")")"
# shellcheck disable=SC2059
sudo chown "$user:$user" "$(printf "$AUTH_KEYS_FILE_PATH" "$user")"