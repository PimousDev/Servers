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
# Generates all Pimous Dev. CA, Service and User certificates using our ssl.sh
# helper script.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 No such script ssl.sh.
#-------------------------------------------------------------------------------

# ---
if [[ ! $# -eq 1 ]]; then
	echo "Usage: genPimousdevCerts.sh <ssl.sh path>" 1>&2
	exit 2
fi

sslScript=$(realpath "$1")

if [[ ! -f $sslScript ]]; then
	echo "No such script $sslScript;"
	exit 3
fi

ssl(){
	bash "$sslScript" "$@"
}

# ---
echo "## ROOT CA pimousdev"
ssl req pimousdev Root
ssl sign pimousdev

## Databases
echo "## DATABASE CA pimousdev-db AND SERVICES"
mkdir db
cd db || exit 1

ssl req pimousdev-db Database db
ssl sign pimousdev-db ../pimousdev --ca

### PostgreSQL
mkdir pgsql
cd pgsql || exit 1
ssl req s0-ps-pgsql Service ../pimousdev-db
ssl sign s0-ps-pgsql ../pimousdev-db
cd .. || exit 1

cd .. || exit 1

## Users
echo "## USR CA pimousdev-usr"
mkdir usr
cd usr || exit 1

ssl req pimousdev-usr Usr usr
ssl sign pimousdev-usr ../pimousdev --ca

cd .. || exit 1

# ---
echo "## REMOVING *.csr FILES"
find ./ -name "*.csr" -type f -exec rm -v {} \;