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

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

FSTAB_LINE="PARTUUID=%s %s %s noatime,nodiratime 0 2"

SFDISK_SCRIPT_FILE=data.sfdisk
HOME_PARTITION_LABEL=Home

PARTITION_FORMAT=ext4
TEMPORARY_MOUNTS_DIR=/mnt
FINAL_MOUNT_POINT=/home
TEMPORARY_MOUNT_DIR=$TEMPORARY_MOUNTS_DIR/$FINAL_MOUNT_POINT
FSTAB_FILE_PATH=/etc/fstab
AUTH_KEYS_FILE_PATH=/home/%s/.ssh/authorized_keys

# ---
resourceDir=${2-"$SCRIPT_DIR/../resource"}

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
sudo apt install -y xfsprogs git docker-ce docker-buildx-plugin \
	--no-install-recommends --no-install-suggests

# ---
echo "## PARTITIONNING AND MOUNTING DISK"
lsblk
echo -n "Which disk is the data disk? "
read -r disk
disk=/dev/$disk

if [[ ! -e $disk ]]; then
	echo "Disk doesn't exist ($disk)."
	exit 3
fi

echo "## CREATING GPT PARTITION TABLE WITH ONE FULL PARTITION"
sfdisk "$disk" --wipe always < "$resourceDir/$SFDISK_SCRIPT_FILE" || exit 1
part=$(blkid -t LABEL="$HOME_PARTITION_LABEL" -o device)

if [[ ! -e $part ]]; then
	echo "Newly created partition doesn't exist... ($part)."
	exit 1
fi

echo "## FORMATTING TO $PARTITION_FORMAT NEW PARTITION"
yes | mkfs -t $PARTITION_FORMAT "$part" || exit 1

echo "## COPYING OLD $FINAL_MOUNT_POINT"
mkdir $TEMPORARY_MOUNT_DIR
mount "$part" $TEMPORARY_MOUNT_DIR

cp -fr $FINAL_MOUNT_POINT/. $TEMPORARY_MOUNT_DIR --preserve=all

umount $TEMPORARY_MOUNT_DIR
rmdir $TEMPORARY_MOUNT_DIR

echo "## MOUNTING ON $FINAL_MOUNT_POINT AND UPDATING $FSTAB_FILE_PATH"
mount "$part" $FINAL_MOUNT_POINT

# shellcheck disable=SC2059
printf "$FSTAB_LINE" \
		"$(blkid -t LABEL="Xibitol"  -s PARTUUID -o value "$part")" \
		$FINAL_MOUNT_POINT \
		$PARTITION_FORMAT \
	> $FSTAB_FILE_PATH

# ---
echo "## CREATING ADMIN USER"
echo -n "What is the new admin user? "
read -r user

echo "## CREATING THE USER $user FOR ADMINISTRATION"
adduser "$user" --disabled-password 
usermod xibitol --groups users,staff,docker

echo "## COPYING authorized_keys FILE FROM $USER"
# shellcheck disable=SC2059
cp -fr "$(printf "$AUTH_KEYS_FILE_PATH" "$USER")" \
	"$(dirname "$(printf "$AUTH_KEYS_FILE_PATH" "$user")")"
# shellcheck disable=SC2059
chown "$user:$user" "$(printf "$AUTH_KEYS_FILE_PATH" "$user")"