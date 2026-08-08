#!/bin/bash
# Pimous Servers (Scripts and Docker files)
# Copyright &copy; 2026 - Pimous Dev. (https://www.pimous.dev/)
#
# These programs are free software: you can redistribute them and/or modify them
# under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# The latters are distributed in the hope that they will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License and the GNU
# Lesser General Public License along with the programs. If not,
# see https://www.gnu.org/licenses/.
#-------------------------------------------------------------------------------
# Initialization and preparation script for Infomaniak VPS.
#
# @throw 1 Unknown error.
# @throw 2 Bad usage.
# @throw 3 No such old user.
#-------------------------------------------------------------------------------

AUTH_KEYS_FILE_PATH=/home/%s/.ssh/authorized_keys

# ---
adminUser=$1

if ! id -u "$adminUser" &>/dev/null; then
	echo "No such $adminUser admin user."
	exit 3
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

echo "# Copying authorized_keys file from $adminUser"
# shellcheck disable=SC2059
sshFolder="$(dirname "$(printf "$AUTH_KEYS_FILE_PATH" "$user")")/"

mkdir -p "$sshFolder"
# shellcheck disable=SC2059
cp -fr "$(printf "$AUTH_KEYS_FILE_PATH" "$adminUser")" "$sshFolder" \
	--preserve=all
chown -R "$user:$user" "$sshFolder"
chmod 700 "$sshFolder"