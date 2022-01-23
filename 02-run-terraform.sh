#!/usr/bin/env bash

set -euo pipefail;

export VARS_FILE="$(pwd)/temp.auto.tfvars";
export DEFAULT_PROJECT_NAME="infraxys";

. ./env.sh;

if [ ${GOOGLE_CLOUD_SHELL:-false} == "true" ]; then
  enforce_auth_popup;
fi;

run_terraform;
