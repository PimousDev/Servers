#!/bin/bash

export DOCKER_FILE=$SCRIPT_DIR/Dockerfile

export DOCKER_IMAGE_REFERENCE=pimousservers/fallback:2.10.0-alpine
export DOCKER_CONTAINER_NAME=ps-fallback

export DOCKER_CONFIG_VOLUME_NAME=$DOCKER_CONTAINER_NAME-config
export DOCKER_DATA_VOLUME_NAME=$DOCKER_CONTAINER_NAME-data
export EXPOSED_PORT=31001