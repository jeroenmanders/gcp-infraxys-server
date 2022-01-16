#!/usr/bin/env bash

set -euo pipefail;

TERRAFORM_VERSION="1.1.3";
TERRAFORM="/tmp/terraform-$TERRAFORM_VERSION";

function initialize() {
  echo "Listing service accounts to force the authorization popup to show.";
  gcloud alpha billing accounts list;
}

function request_config() {
  local VARS_FILE="temp.auto.tfvars";
  [[ -f "$VARS_FILE" ]] && echo "Removing file '$VARS_FILE'. Current contents:" && cat $VARS_FILE && rm -f $VARS_FILE;

  echo
  echo "Building and running the config collector ..."

  cd config-collector;
  go run . --port 8080 --web-host "$WEB_HOST"
  cd -;
  [[ ! -f "$VARS_FILE" ]] && "File '$VARS_FILE' wasn't created. Aborting. You can re-run setup.sh if desired." && exit 1;
  echo "Configuration step finished.";
}

function ensure_terraform() {
    local zip_file="terraform_${TERRAFORM_VERSION}_linux_amd64.zip";
    local url="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$zip_file"

    [[ -f "$TERRAFORM" ]] && echo "$TERRAFORM already exists. Using it instead of downloading a new binary." && return;

    local temp_dir="$(mktemp -d -p /tmp)";

    echo "Downloading $zip_file to /tmp.";
    curl -sLo $temp_dir/$zip_file $url;

    echo "Extracting archive.";
    unzip $temp_dir/$zip_file -d $temp_dir;
    mv $temp_dir/terraform $TERRAFORM;
    rm -Rf $temp_dir;

    echo "Using Terraform:";
    $TERRAFORM --version;
}

function run_terraform() {
  local PLAN_FILE=/tmp/plan.out;

  echo "Launching Terraform commands.";
  $TERRAFORM init;
  $TERRAFORM plan -out=$PLAN_FILE;

  read -p "Validate the plan and press enter to apply it. Press CTRL-C to abort. No changes have been made until now.";

  $TERRAFORM apply $PLAN_FILE

  echo "TODO: copy the state to the Terraform project and configure cloud tasks to automatically plan when new pushes are done to the repo"


}

initialize;
request_config;
ensure_terraform;
run_terraform;
