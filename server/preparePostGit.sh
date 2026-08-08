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

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# ---
echo "# Configuring ssh"

groupadd ssh-allowed
groupadd sftp-allowed

mkdir /home/sftphomes
chmod 710 /home/sftphomes
chown root:sftp-allowed /home/sftphomes

cp "$SCRIPT_DIR/resource/sshd_config.d"/* /etc/ssh/sshd_config.d/

systemctl restart sshd

# ---
echo "# Configuring syslog"
#apt install -y rsyslog --no-install-recommends --no-install-suggests