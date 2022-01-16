#!/usr/bin/env bash

set -euo pipefail;

export VARS_FILE="$(pwd)/temp.auto.tfvars";
export DEFAULT_PROJECT_NAME="infraxys";

. ./env.sh;

if [ ${DIRECT_RUN:-false} != "true" ]; then
  initialize;
  request_config;
  ensure_packer;
  ensure_terraform;
fi;

run_terraform;
