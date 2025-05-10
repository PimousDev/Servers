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

FROM caddy:2.10.0-builder-alpine AS builder

RUN xcaddy build \
	--with github.com/caddyserver/jsonc-adapter
	#--with github.com/dunglas/frankenphp/caddy

FROM caddy:2.10.0-alpine

ENV CYCONFIG=/etc/caddy
ENV CYROOT=/usr/share/caddy
ENV CYLOG=/var/log/caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

COPY Caddyfile.json $CYCONFIG

RUN rm $CYROOT/index.html
COPY sites $CYROOT

RUN mkdir -p $CYLOG

EXPOSE 31001

CMD ["sh", "-c", \
	"caddy run --config $CYCONFIG/Caddyfile.json --adapter jsonc" \
]