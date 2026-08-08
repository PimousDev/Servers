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
#-------------------------------------------------------------------------------

DOCKER_KEYRING_FILE=/etc/apt/keyrings/docker.asc

echo "# Adding docker apt sources"
curl -fsSL https://download.docker.com/linux/debian/gpg \
	-o $DOCKER_KEYRING_FILE
sudo chmod a+r $DOCKER_KEYRING_FILE

printf "deb [arch=%s signed-by=%s] https://download.docker.com/linux/debian %s stable" \
		"$(dpkg --print-architecture)" \
		$DOCKER_KEYRING_FILE \
		"$(. /etc/os-release && echo "$VERSION_CODENAME")" \
	> /etc/apt/sources.list.d/docker.list

sudo apt update

echo "# Installing docker"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
	--no-install-recommends --no-install-suggests

# ---
echo "# Adding admin user to docker group"
echo -n "What is the admin user? "
read -r user

usermod "$user" --append --groups docker