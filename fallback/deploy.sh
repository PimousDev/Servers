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

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# ---
mode=${1-"prod"}

# ---
cd "$SCRIPT_DIR" || exit

# admin
localPublicFolder=resource/sites/admin/public
if [[ ! -d $localPublicFolder ]]; then
	mkdir -p $localPublicFolder
elif [[ "$(find $localPublicFolder | wc -l)" -gt 0 ]]; then
	rm -r ${localPublicFolder:?}/*
fi
cp -r ../admin/src/* $localPublicFolder
# admin

# TEMP - wordsrain
publicFolder=/home/wordsrain/www/public
localPublicFolder=resource/sites/wordsrain/public
if [[ ! -d $localPublicFolder ]]; then
	mkdir -p $localPublicFolder
elif [[ "$(find $localPublicFolder | wc -l)" -gt 0 ]]; then
	rm -r ${localPublicFolder:?}/*
fi
if [[ -d $publicFolder && "$(find $publicFolder | wc -l)" -gt 0 ]]; then
        cp -r $publicFolder/* $localPublicFolder/
fi
# TEMP - wordsrain

if [[ $mode = "prod" ]]; then
	docker compose up --build -d
else
	docker compose up --build
fi

cd - >/dev/null || exit