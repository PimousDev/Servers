#!/bin/bash

export DOCKER_FILE=$SCRIPT_DIR/Dockerfile
export DOCKER_IMAGE_REFERENCE=pimousservers/pgsql:17.4-alpine3.21
export DOCKER_CONTAINER_NAME=ps-pgsql
export DOCKER_DATA_VOLUME_NAME=$DOCKER_CONTAINER_NAME-data

export EXPOSED_PORT=31003