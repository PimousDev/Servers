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

source "$SCRIPT_DIR"/config.sh

LOGS_ARCHIVE="$DOCKER_LOG_VOLUME_NAME"s_"$(date +%Y-%m-%d_%H%M%S)".tar

# ---
echo "# EXPORTING LOGS TO $LOGS_ARCHIVE ($DOCKER_LOG_VOLUME_NAME VOLUME) ..."
docker run \
	-v "$(pwd)":/export -v $DOCKER_LOG_VOLUME_NAME:/var/log/postgresql/ \
	--rm \
	alpine:3.21 \
	tar -cv -f /export/"$LOGS_ARCHIVE" /var/log/postgresql/