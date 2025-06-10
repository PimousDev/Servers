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

FROM steamcmd/steamcmd:debian-bookworm AS pzds

ARG DSROOT=/srv/pzds
ARG DSUSER=pzds

# Game
RUN steamcmd \
	+force_install_dir $DSROOT \
	+login anonymous \
	+app_update 380870 validate \
	+quit

# Unprivileged user
RUN	groupadd -r $DSUSER
RUN useradd -r -g $DSUSER --home-dir=$DSROOT $DSUSER

RUN mkdir -p $DSROOT
RUN chown -R $DSUSER:$DSUSER $DSROOT

USER $DSUSER
EXPOSE 16261/udp 16262/udp

FROM pzds AS ekatpzds

ARG DSNAME=EKAT-PZDS
ARG DSCONFIG_FOLDER=$DSROOT/Zomboid/Server/

COPY --chown=$DSUSER:$DSUSER $DSNAME.ini $DSCONFIG_FOLDER

ENV DSROOT=${DSROOT}
ENTRYPOINT ["/srv/pzds/start-server.sh", \
	"-servername", "EKAT-PZDS" \
]