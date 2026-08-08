#!/bin/bash

docker run -v ./admin/src:/usr/share/caddy -p 80:80 --rm caddy:alpine
docker image rm caddy:alpine