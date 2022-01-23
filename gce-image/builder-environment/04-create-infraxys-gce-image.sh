#!/usr/bin/env bash

set -euo pipefail;

export VARS_FILE="$(pwd)/temp.auto.tfvars";
export DEFAULT_PROJECT_NAME="infraxys-image-builder";

. ../../env.sh;

if [ ${GOOGLE_CLOUD_SHELL:-false} == "true" ]; then
  enforce_auth_popup;
fi;

get_terraform_outputs;

configure_and_create_infraxys_vm_image;
