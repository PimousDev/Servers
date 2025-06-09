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
# Installation script of docker-ce on prepared Infomaniak VPS.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 "Docker" partition not found.
#-------------------------------------------------------------------------------

DOCKER_PARTITION_LABEL=Docker

FSTAB_LINE_FORMAT="PARTUUID=%s %s %s noatime,nodiratime 0 2"
DOCKER_SOURCE_FORMAT="deb [arch=%s signed-by=%s] https://download.docker.com/linux/debian %s stable"

PARTITION_FORMAT=ext4
FINAL_MOUNT_POINT=/var/lib/docker
FSTAB_FILE_PATH=/etc/fstab
DOCKER_APT_SOURCE_FILE=/etc/apt/sources.list.d/docker.list
DOCKER_KEYRING_FILE=/etc/apt/keyrings/docker.asc

# ---
echo "{\"data-root\":\"$FINAL_MOUNT_POINT\"}"

# ---
echo "## FORMATTING TO $PARTITION_FORMAT DOCKER PARTITION"
part=$(blkid -t LABEL="$DOCKER_PARTITION_LABEL" -o device)

if [[ ! -e $part ]]; then
	echo "Partition doesn't exist... ($part)."
	exit 3
fi

yes | mkfs -t $PARTITION_FORMAT "$part" || exit 1

echo "## MOUNTING ON $FINAL_MOUNT_POINT AND UPDATING $FSTAB_FILE_PATH"
mkdir $FINAL_MOUNT_POINT
mount "$part" $FINAL_MOUNT_POINT

# shellcheck disable=SC2059
printf "$FSTAB_LINE_FORMAT" \
		"$(blkid -t LABEL="$DOCKER_PARTITION_LABEL" -s PARTUUID -o value "$part")" \
		$FINAL_MOUNT_POINT \
		$PARTITION_FORMAT \
	> $FSTAB_FILE_PATH

echo "## ADDING DOCKER APT SOURCES"
curl -fsSL https://download.docker.com/linux/debian/gpg \
	-o $DOCKER_KEYRING_FILE
sudo chmod a+r $DOCKER_KEYRING_FILE

# shellcheck disable=SC2059
printf "$DOCKER_SOURCE_FORMAT" \
		"$(dpkg --print-architecture)" \
		$DOCKER_KEYRING_FILE \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" \
	> $DOCKER_APT_SOURCE_FILE

sudo apt update

echo "## INSTALLING DOCKER"
sudo apt install -y xfsprogs git docker-ce docker-buildx-plugin \
	--no-install-recommends --no-install-suggests