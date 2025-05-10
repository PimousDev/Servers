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

#shellcheck source=../../bin/dockerUtils.sh
source "bin/dockerUtils.sh"

source "$SCRIPT_DIR"/config.sh

# ---
mode=${1-"prod"}
resourceDir=${2-"$SCRIPT_DIR/../resource"}

# ---
stop $DOCKER_CONTAINER_NAME

removeImage $DOCKER_IMAGE_REFERENCE
buildImage $DOCKER_IMAGE_REFERENCE "$DOCKER_FILE" "$resourceDir"

createVolumes $DOCKER_DATA_VOLUME_NAME

createContainer \
	$DOCKER_CONTAINER_NAME $DOCKER_IMAGE_REFERENCE "$mode" \
	-e POSTGRES_PASSWORD=empty \
	-v $DOCKER_DATA_VOLUME_NAME:/var/lib/postgresql/data \
	-p $EXPOSED_PORT:5432