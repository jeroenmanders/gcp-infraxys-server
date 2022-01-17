#!/usr/bin/env bash

set -euo pipefail;

export VARS_FILE="$(pwd)/temp.auto.tfvars";
export DEFAULT_PROJECT_NAME="infraxys-image-builder";

. ../../env.sh;

#if [ ${DIRECT_RUN:-false} != "true" ]; then
  initialize;
  request_config;
  ensure_terraform;
#fi;

run_terraform;


project_id="$(terraform output --json | jq -r '.project_id .value')"
service_account_email="$(terraform output --json | jq -r '.service_account_email .value')"

cd packer/packer-image
gcloud builds submit --project "$project_id" .
cd -

cd packer/infraxys-image
gcloud builds submit --project "$project_id" --config=cloudbuild.yaml \
  --substitutions=_PKR_VAR_ZONE="us-central1-a",_PKR_VAR_PROJECT_ID="$project_id,_PKR_VAR_SERVICE_ACCOUNT_EMAIL=$service_account_email"


# export PKR_VAR_project_id="$project_id";
# export PKR_VAR_zone="us-central1-a";

# packer build .
