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
# A script for SSH remote execution.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 No such command bash file.
#-------------------------------------------------------------------------------

SCRIPT_DESTINATION_DIR=/tmp

# ---
args=("$@")

if [[ $# -lt 3 ]]; then
	echo "Usage: remoteExec.sh <ip> <user> <command> [args...]" 1>&2
	exit 2
fi

ip=$1
user=$2
command=$3
cmdArgs=()

for i in $(seq 3 "$(($# - 1))"); do
	cmdArgs+=("${args[$i]}")
done

if [[ ! -f $command ]]; then
	echo "No such $command bash file." 1>&2
	exit 3
fi

# ---
remoteAuthority="$user@$ip"
destFile="$SCRIPT_DESTINATION_DIR/$(basename "$command")"

echo "# Sending $command script to $ip with user $user..."
scp "$command" "$remoteAuthority:$destFile"
# shellcheck disable=SC2029
ssh "$remoteAuthority" "chmod u+x $destFile"

if [[ ${#cmdArgs[@]} -gt 0 ]]; then
	echo "# Executing sent $command with argument(s) '${cmdArgs[*]}'..."
else
	echo "# Executing sent $command..."
fi
# shellcheck disable=SC2029
ssh "$remoteAuthority" "exec $destFile ${cmdArgs[*]}"