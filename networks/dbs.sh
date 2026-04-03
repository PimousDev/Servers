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

action=${1-"create"}

# ---
case $action in
	"create")
		docker network create \
			--subnet=172.31.0.64/26 \
			--ipv6=false \
			ps_net_dbs
		;;
	"remove"|"rm")
		docker network rm ps_net_dbs
		;;
	*)
		echo "Unknown '$action' action."
		exit
		;;
esac