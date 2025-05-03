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

# ---
mode=${1-"prod"}
resourceDir=${2-"$SCRIPT_DIR/../resource/pgsql"}

# ---
echo "# STOPPING CONTAINER ($DOCKER_CONTAINER_NAME) ..."
if docker container inspect $DOCKER_CONTAINER_NAME &>/dev/null; then
	docker container stop $DOCKER_CONTAINER_NAME
else
	echo "$DOCKER_CONTAINER_NAME wasn't started."
fi

echo "# DELETING OLD IMAGE ($DOCKER_IMAGE_REFERENCE) ..."
docker image rm -f $DOCKER_IMAGE_REFERENCE

echo "# BUILDING IMAGE ($DOCKER_IMAGE_REFERENCE) ..."
docker build -t $DOCKER_IMAGE_REFERENCE -f "$DOCKER_FILE" \
	--progress=plain \
	"$resourceDir"

echo "# CREATING VOLUME ($DOCKER_DATA_VOLUME_NAME and $DOCKER_LOG_VOLUME_NAME) ..."
if ! docker volume inspect $DOCKER_DATA_VOLUME_NAME &>/dev/null; then
	docker volume create $DOCKER_DATA_VOLUME_NAME 1>/dev/null
else
	echo "$DOCKER_DATA_VOLUME_NAME volume already exist."
fi

if ! docker volume inspect $DOCKER_LOG_VOLUME_NAME &>/dev/null; then
	docker volume create $DOCKER_LOG_VOLUME_NAME 1>/dev/null
else
	echo "$DOCKER_LOG_VOLUME_NAME volume already exist."
fi

echo "# RUNNING CONTAINER ($DOCKER_CONTAINER_NAME; With image $DOCKER_IMAGE_REFERENCE) ..."
docker run "$([[ $mode == "debug" ]] && echo "-it" || echo "-d")" \
	-e POSTGRES_PASSWORD=empty \
	-v $DOCKER_DATA_VOLUME_NAME:/var/lib/postgresql/data \
	-v $DOCKER_LOG_VOLUME_NAME:/var/log/postgresql \
	-p $EXPOSED_PORT:5432 \
	--name $DOCKER_CONTAINER_NAME --rm \
	$DOCKER_IMAGE_REFERENCE