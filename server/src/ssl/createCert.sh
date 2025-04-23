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
# Creates a SSL certificate signed by a certification authority (CA) or
# self-signed.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 No such CA's certification and/or private key.
#-------------------------------------------------------------------------------

KEY_FILE_FORMAT="%s.key"
CSR_FILE_FORMAT="%s.csr"
CRT_FILE_FORMAT="%s.crt"
CRT_CHAIN_FILE_FORMAT="%s.chain.crt"

OU_SUBJECT_PATTERN="OU = ([^,]+),"

CA_EXTENSION="-extfile /etc/ssl/openssl.cnf -extensions v3_ca"
SS_DAYS=3650
NSS_DAYS=365

COUNTRY="UK"
STATE="Greater London"
LOCALITY="London"
ORGANIZATION="Pimous Dev."
ROOT_DOMAIN_NAME="ca.pimous.dev"
EMAIL_ADDRESS="contact@pimous.dev"

# ---
if [[ $# -lt 2 || $# -gt 4 ]]; then
	echo "Usage: createCert.sh <name> Root" 1>&2
	echo "       createCert.sh <name> <OU> <CN sub-domains> <CA path>" 1>&2
	echo "       createCert.sh <name> Service <CA path> <email>" 1>&2
	echo "       createCert.sh <name> User <CA path> <email>" 1>&2
	exit 2
fi

name=$1
ou=$2
caPath=$name
emailAddress=$EMAIL_ADDRESS
isCA=1
isUser=0

case $ou in
	"Root")
		cn=$ROOT_DOMAIN_NAME
		;;
	"Service" | "User")
		caPath=$3
		cn=$name
		if [[ -n $4 ]]; then emailAddress=$4; fi
		isCA=0
		if [[ $ou = "User" ]]; then isUser=1; fi
		;;
	*)
		cn="$3.$ROOT_DOMAIN_NAME"
		caPath=$4
		;;
esac

# ---
# shellcheck disable=SC2059
keyFile="$(printf "$KEY_FILE_FORMAT" "$name")"
# shellcheck disable=SC2059
csrFile="$(printf "$CSR_FILE_FORMAT" "$name")"
# shellcheck disable=SC2059
crtFile="$(printf "$CRT_FILE_FORMAT" "$name")"
# shellcheck disable=SC2059
crtChainFile="$(printf "$CRT_CHAIN_FILE_FORMAT" "$name")"

# shellcheck disable=SC2059
issuerKeyFile="$(printf "$KEY_FILE_FORMAT" "$caPath")"
# shellcheck disable=SC2059
issuerCRTFile="$(printf "$CRT_FILE_FORMAT" "$caPath")"
# shellcheck disable=SC2059
issuerCRTChainFile="$(printf "$CRT_CHAIN_FILE_FORMAT" "$caPath")"

if [[ ! $keyFile = "$issuerKeyFile" && ! -f $issuerKeyFile ]]; then
	echo "No such CA's private key '$caPath';"
	exit 3
elif [[ ! $crtFile = "$issuerCRTFile" && ! -f $issuerCRTFile ]]; then
	echo "No such CA's certification '$caPath';"
	exit 3
elif [[ ! -f $issuerCRTChainFile ]]; then
	issuerCRTChainFile=$issuerCRTFile
fi

if [[ $ou = "Service" || $ou = "User" ]]; then
	subject="$(openssl x509 -in "$issuerCRTFile" -subject -noout)"

	if [[ $subject =~ $OU_SUBJECT_PATTERN ]]; then ou=${BASH_REMATCH[1]}; fi
fi

# ---
echo "# REMOVING $keyFile, $csrFile and $crtFile files"
rm -v "$keyFile" "$crtFile"

echo "# CREATING $csrFile CERTIFICATION SIGNING REQUEST"
# shellcheck disable=SC2046
openssl req -new \
	$([[ $isUser = 1 ]] && echo "" || echo "-noenc") \
	-subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ou/CN=$cn/emailAddress=$emailAddress" \
	-out "$csrFile" -keyout "$keyFile"
chmod og-rwx "$keyFile"

if [[ $ou = "Root" && $crtFile = "$issuerCRTFile" ]]; then
	echo "# GENERATING $ou CERTIFICATE BY SELF-SIGNING"
	# shellcheck disable=SC2086
	openssl x509 -req -in "$csrFile" -days $SS_DAYS \
		$CA_EXTENSION \
		-key "$keyFile" \
		-out "$crtFile"
else
	if [[ $isCA = 1 ]]; then
		echo "# GENERATING $crtFile CA CERTIFICATE WITH $caPath CA"
	else
		echo "# GENERATING $crtFile CERTIFICATE WITH $caPath CA"
	fi
	# shellcheck disable=SC2046
	openssl x509 -req -in "$csrFile" -days $NSS_DAYS \
		$([[ $isCA = 1 ]] && echo "$CA_EXTENSION" || echo "") \
		-CA "$issuerCRTFile" -CAkey "$issuerKeyFile" \
		-out "$crtFile"

	echo "# WRITING $crtChainFile CERTIFICATE CHAIN"
	cat "$crtFile" "$issuerCRTChainFile" > "$crtChainFile"
fi

echo "# REMOVING $csrFile CERTIFICATION SIGNING REQUEST"
rm -v "$csrFile"