#!/bin/bash

export DOCKER_FILE=$SCRIPT_DIR/Dockerfile
export DOCKER_IMAGE_REFERENCE=pimousservers/pzds:debian-bookworm
export DOCKER_CONTAINER_NAME=ps-pzds
export DOCKER_DATA_VOLUME_NAME=$DOCKER_CONTAINER_NAME-data

export EXPOSED_PORT=31010
export EXPOSED_PORT_DIRECT=16262