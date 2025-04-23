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
# Generates all Pimous Dev. CA, Service and User certificates using
# createCert.sh script.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 No such script createCert.sh.
#-------------------------------------------------------------------------------

# ---
if [[ ! $# -eq 1 ]]; then
	echo "Usage: genPimousdevCerts.sh <createCert.sh path>" 1>&2
	exit 2
fi

createCertScript=$(realpath "$1")

if [[ ! -f $createCertScript ]]; then
	echo "No such script $createCertScript;"
	exit 3
fi

createCert(){
	bash "$createCertScript" "${@}"
}

# ---
echo "## ROOT CA pimousdev"
createCert pimousdev Root

## Databases
echo "## DATABASE CA pimousdev-db AND SERVICES"
mkdir db
cd db || exit 1

createCert pimousdev-db Database db ../pimousdev

### PostgreSQL
mkdir pgsql
cd pgsql || exit 1
createCert s0-ps-pgsql Service ../pimousdev-db
cd .. || exit 1

cd .. || exit 1

## Users
echo "## USR CA pimousdev-usr AND USERS"
mkdir usr
cd usr || exit 1

createCert pimousdev-usr Usr usr ../pimousdev

### Xibitol
mkdir xibitol
cd xibitol || exit 1
createCert xibitol User ../pimousdev-usr xibitol@pimous.dev
cd .. || exit 1

cd .. || exit 1