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

FROM postgres:17.4-alpine3.21

ENV PGUSER=postgres
ENV PGHOME=/var/lib/postgresql
ENV PGCONFIG=/etc/postgresql
ENV ENTRYPOINT_DIR=/docker-entrypoint-initdb.d
ENV PGLOG=/var/log/postgresql

RUN mkdir -p $PGCONFIG $PGLOG
RUN chown -R $PGUSER:$PGUSER $PGLOG

COPY --chown=$PGUSER:$PGUSER --chmod=0600 *.crt *.key $PGHOME

COPY postgresql.conf $PGCONFIG
COPY pg_hba.conf $PGCONFIG

COPY *.sql *.sh $ENTRYPOINT_DIR

CMD ["postgres", \
	"-debug", \
	"-c", "config_file=/etc/postgresql/postgresql.conf", \
	"-c", "hba_file=/etc/postgresql/pg_hba.conf" \
]