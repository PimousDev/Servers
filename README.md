# Pimous Servers [![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-orange.svg)](COPYING.LESSER)
Pimous Servers is a repository containing the organization and all scripts,
program configurations and docker files used by Pimous Dev.'s server
administrators.

Currently, our servers are hosted at [Infomaniak](https://www.infomaniak.com)
because of their environmental concerns.

> Version: **-**

## Documentation
See [admin.pimous.dev](https://admin.pimous.dev/).

### Technician installation guide
#### First setup
Execute those remotely:
```bash
bash bin/remoteExec.sh <host> debian 1 server/init.sh debian
bash bin/remoteExec.sh <host> debian 1 server/disk.sh <yes|no>
bash bin/remoteExec.sh <host> debian 1 server/docker.sh
```

Copy ssh keys and certificates.

Then, execute those once connected onto the server:
```bash
bash configurate.sh
```

Thus, the server is ready!

## License
Pimous Servers (Organization, Scripts and Docker files)  
Copyright &copy; 2025 - Pimous Dev. (https://www.pimous.dev/)

These programs are free software: you can redistribute them and/or modify them
under the terms of the GNU Lesser General Public License, version 3, as
published by the Free Software Foundation.

The latter are distributed in the hope that they will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU General Public License and the GNU
Lesser General Public License along with the programs (Links:
[GNU GPL v3](COPYING) & [GNU LGPL v3](COPYING.LESSER)). If not, see
https://www.gnu.org/licenses/.

## Administrators
> Xibitol