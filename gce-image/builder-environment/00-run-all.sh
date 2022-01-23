#!/usr/bin/env bash

set -euo pipefail;

export VARS_FILE="$(pwd)/temp.auto.tfvars";
export DEFAULT_PROJECT_NAME="infraxys-image-builder";

. ../../env.sh;

if [ ${GOOGLE_CLOUD_SHELL:-false} == "true" ]; then
  enforce_auth_popup;
fi;

request_config;
ensure_terraform;
run_terraform;
get_terraform_outputs;
create_packer_docker_image;
configure_and_create_infraxys_vm_image;
