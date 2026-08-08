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
# Initialization and essential preparation script of S0.
#-------------------------------------------------------------------------------

AUTH_KEYS_FILE_PATH=/home/%s/.ssh/authorized_keys

# ---
if [[ $# -lt 1 ]]; then
	echo "Usage: init.sh <admin>" 1>&2
	exit 2
fi

adminUser=$1

if ! id -u "$adminUser" &>/dev/null; then
	echo "No such $adminUser admin user."
	exit 1
fi

# ---
echo "# Installing keyrings folder"
install -m 0755 -d /etc/apt/keyrings

echo "# Installing essential packages"
apt update
apt upgrade -y
apt install -y ca-certificates curl xfsprogs \
	--no-install-recommends --no-install-suggests

echo "# Installing special packages"
apt install -y git \
	--no-install-recommends --no-install-suggests

# ---
echo "# Creating new admin user"
echo -n "What is the new admin user? "
read -r user

echo "# Creating $user user for administration"
adduser "$user" --disabled-password 
usermod "$user" --groups users,staff
echo

echo "# Copying authorized_keys file from $adminUser"
# shellcheck disable=SC2059
sshFolder="$(dirname "$(printf "$AUTH_KEYS_FILE_PATH" "$user")")/"

mkdir -p "$sshFolder"
# shellcheck disable=SC2059
cp -fr "$(printf "$AUTH_KEYS_FILE_PATH" "$adminUser")" "$sshFolder" \
	--preserve=all
chown -R "$user:$user" "$sshFolder"
chmod 700 "$sshFolder"