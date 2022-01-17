#!/usr/bin/env bash

set -euo pipefail;

exec > >(tee -a /var/log/infraxys-install.log | logger -s -t infraxys-install) 2>&1

id
pwd
