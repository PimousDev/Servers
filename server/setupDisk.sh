#!/bin/bash
# Pimous Servers (Scripts and Docker files)
# Copyright &copy; 2026 - Pimous Dev. (https://www.pimous.dev/)
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
# Setup script of our data disk. sfdisk script may be from variables.
#
# @throw 1 Unknown error.
# @throw 2 Bad usage.
# @throw 3 Disk not found.
# @throw 3 Partition not found.
#-------------------------------------------------------------------------------

SFDISK_SCRIPT=$(cat << EOF
label: gpt
unit: sectors
sector-size: 512
first-lba: 2048
last-lba: 524287966

start=2048, size=20971520, type=933AC7E1-2EB4-4F13-B844-0E14E2AEF915, name="Home"
start=20973568, size=503314398, type=933AC7E1-2EB4-4F13-B844-0E14E2AEF915, name="Docker"
EOF
)

# ---
setupPartition(){
	label=$1
	format=$2
	mountPoint=$3

	echo "# Formating $label partition to $format..."
	part=$(blkid -t PARTLABEL="$label" -o device)

	if [[ ! -e $part ]]; then
		echo "Partition doesn't exist... ($part)."
		exit 3
	fi

	yes | mkfs -t "$format" "$part" || exit 1

	if [[ -d $mountPoint ]]; then
		echo "# Detected existing $mountPoint, copying into new $label partition..."

		mkdir -p /mnt/tmp
		mount "$part" /mnt/tmp

		cp -fr "$mountPoint/." /mnt/tmp --preserve=all

		umount /mnt/tmp
		rmdir /mnt/tmp
	fi

	echo "# Mounting $label on $mountPoint and updating fstab..."
	mkdir "$mountPoint"
	mount "$part" "$mountPoint"

	printf "PARTUUID=%s %s %s noatime,nodiratime 0 2" \
			"$(blkid -t LABEL="$label" -s PARTUUID -o value "$part")" \
			"$mountPoint" \
			"$format" \
		> /etc/fstab
}

# ---
echo "# Partitioning and mounting data disk..."
lsblk
echo -n "Which disk is the data disk? "
read -r disk
disk=/dev/$disk

if [[ ! -e $disk ]]; then
	echo "Disk doesn't exist ($disk)."
	exit 3
fi

echo "# Creating gpt partition table..."
sfdisk "$disk" --wipe always <<< "$SFDISK_SCRIPT" || exit 1

# ---
setupPartition "Home" ext4 /home
setupPartition "Docker" ext4 /var/lib/docker

# ---
echo "# Done."