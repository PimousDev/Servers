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
# Helps creating SSL certificate signing requests or SSL certificates signed by
# a certificate authority (CA) or self-signed, for both end-entities or other
# CAs. Default values corresponds to Pimous Dev. CA's hierarchy.
#
# @throw 1 Unkown error.
# @throw 2 Bad usage.
# @throw 3 Unknown action.
# @throw 4 No such CA's certificate and/or private key.
# @throw 5 No such certificate signing request.
# @throw 6 Errors while executing openssh.
#-------------------------------------------------------------------------------

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
printError(){
	echo "createCert: $1" 1>&2

	return "${2:-1}"
}
printUsage(){
	echo "Usage: createCert req <name> Root" 1>&2
	echo "                   |  <name> <OU> <CN sub-domains>" 1>&2
	echo "                   |  <name> <Service|User> <CA path> [<email>] [--pass]" 1>&2
	echo "                   |  <name> <OU> <C> <S> <L> <O> <email>" 1>&2
	echo "       createCert sign <name> [<CA path> [--ca]]" 1>&2

	return 2
}

getKeyFile(){ printf "%s.key" "$1"; }
getRequestFile(){ printf "%s.csr" "$1"; }
getCertFile(){ printf "%s.crt" "$1"; }
getCertChainFile(){ printf "%s.chain.crt" "$1"; }

createRequest(){
	name=$1
	c=$COUNTRY
	st=$STATE
	l=$LOCALITY
	o=$ORGANIZATION
	ou=$2
	emailAddress=$EMAIL_ADDRESS

	caPath=
	hasPass=0

	# ---
	if [[ $# -eq 7 ]]; then
		c=$3
		st=$4
		l=$5
		o=$6
  		cn=$name
		emailAddress=$7
	else
		case $ou in
			"Root")
				cn=$ROOT_DOMAIN_NAME
				;;
			"Service" | "User")
				if [[ $# -lt 3 || $# -gt 5 ]]; then
					printUsage
					return
				fi

				cn=$name
				if [[ $4 == "--pass" || $5 == "--pass" ]]; then hasPass=1; fi
				if [[ -n $4 && $4 != "--pass" ]]; then emailAddress=$4; fi

				crt=$(getCertFile "$3")
				if [[ -f $crt ]]; then
					subject="$(openssl x509 -in "$crt" -subject -noout)"

					if [[ $subject =~ $OU_SUBJECT_PATTERN ]]; then
						ou=${BASH_REMATCH[1]};
					fi
				else
					printError "No such CA certificate ($crt)." 4
					return
				fi
				;;
			*)
				if [[ $# -ne 3 ]]; then
					printUsage
					return
				fi

				cn="$3.$ROOT_DOMAIN_NAME"
				;;
		esac
	fi

	# ---
	keyFile=$(getKeyFile "$name")
	csrFile=$(getRequestFile "$name")
	crtFile=$(getCertFile "$name")

	# ---
	echo "# REMOVING $keyFile, $csrFile AND $crtFile FILES"
	rm -v "$keyFile" "$csrFile"

	echo "# CREATING $csrFile CERTIFICATION SIGNING REQUEST"
	# shellcheck disable=SC2046
	if ! openssl req -new \
		$([[ $hasPass = 1 ]] && echo "" || echo "-noenc") \
		-subj "/C=$c/ST=$st/L=$l/O=$o/OU=$ou/CN=$cn/emailAddress=$emailAddress" \
		-out "$csrFile" -keyout "$keyFile"
	then return 6; fi

	chmod og-rwx "$keyFile"
}
signRequest(){
	name=$1
	caPath=$name
	isCA=1

	if [[ $# -ge 2 ]]; then
		caPath=$2
		isCA=$([[ $3 = "--ca" ]] && echo 1 || echo 0)
	fi

	# ---
	csrFile=$(getRequestFile "$name")
	crtFile=$(getCertFile "$name")
	crtChainFile="$(getCertChainFile "$name")"

	issuerKeyFile=$(getKeyFile "$caPath")
	issuerCRTFile=$(getCertFile "$caPath")
	issuerCRTChainFile=$(getCertChainFile "$caPath")

	if [[ ! -f $csrFile ]]; then
		printError "No such certificate signing request ($csrFile);" 5
		return
	elif [[ ! -f $issuerKeyFile ]]; then
		printError "No such CA's private key ($issuerKeyFile);" 4
		return
	elif [[ $crtFile != "$issuerCRTFile" ]]; then
		if [[ ! -f $issuerCRTFile ]]; then
			echo "No such CA's certificate '$caPath';" 4
			return
		elif [[ ! -f $issuerCRTChainFile ]]; then
			issuerCRTChainFile=$issuerCRTFile
		fi
	fi

	# ---
	echo "# REMOVING $crtFile AND $crtChainFile FILES"
	rm -v "$crtFile" "$crtChainFile"

	if [[ $isCA = 1 && $crtFile = "$issuerCRTFile" ]]; then
		echo "# GENERATING $crtFile CA CERTIFICATE BY SELF-SIGNING"
		# shellcheck disable=SC2086
		if ! openssl x509 -req -in "$csrFile" -days $SS_DAYS \
			$CA_EXTENSION \
			-key "$issuerKeyFile" \
			-out "$crtFile"
		then return 6; fi
	else
		if [[ $isCA ]]; then
			echo "# GENERATING $crtFile CA's CERTIFICATE WITH $caPath CA"
		else
			echo "# GENERATING $crtFile CERTIFICATE WITH $caPath CA"
		fi
		# shellcheck disable=SC2046
		if ! openssl x509 -req -in "$csrFile" -days $NSS_DAYS \
			$([[ $isCA = 1 ]] && echo "$CA_EXTENSION" || echo "") \
			-CA "$issuerCRTFile" -CAkey "$issuerKeyFile" \
			-out "$crtFile"
		then return 6; fi

		echo "# WRITING $crtChainFile CERTIFICATE CHAIN"
		cat "$crtFile" "$issuerCRTChainFile" > "$crtChainFile"
	fi

	return 0
}

# ---
_main(){
	if [[ $# -lt 1 ]]; then
		printUsage
		return
	fi

	action=$1

	args=()
	for i in $(seq 2 $#); do
		args+=("${!i}")
	done

	case $action in
		"req")
			if [[ ( $# -lt 3 || $# -gt 6 ) && $# -ne 8 ]]; then
				printUsage
				return
			fi

			createRequest "${args[@]}"
			;;
		"sign")
			if [[ $# -lt 2 || $# -gt 4 ]]; then
				printUsage
				return
			fi

			signRequest "${args[@]}"
			;;
		*)
			printError "Unknown '$action' action."
			printUsage
			return 3
			;;
	esac

	return
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	_main "$@"
fi
