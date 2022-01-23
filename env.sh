#!/usr/bin/env bash

TERRAFORM_VERSION="1.1.4";

PACKER_VERSION="1.7.8";
PACKER="/tmp/terraform-$PACKER_VERSION";

function enforce_auth_popup() {
  echo "Listing service accounts to force the authorization popup to show.";
  gcloud alpha billing accounts list;
}

function request_config() {
  [[ -f "$VARS_FILE" ]] && echo "Removing file '$VARS_FILE'. Current contents:" && cat $VARS_FILE && rm -f $VARS_FILE;

  echo
  echo "Building and running the config collector ..."

  if [ -d "config-collector" ]; then
    cd config-collector;
  elif [ -d "../../config-collector" ]; then
    cd ../../config-collector;
  else
    echo "Unable to find the config-collector directory. Aborting." >&2;
    exit 1;
  fi;
  go run . --port 8080 --web-host "${WEB_HOST:-localhost}";
  cd -;
  [[ ! -f "$VARS_FILE" ]] && "File '$VARS_FILE' wasn't created. Aborting. You can re-run setup.sh if desired." && exit 1;
  echo "Configuration step finished.";
}

function ensure_terraform() {
    local zip_file="terraform_${TERRAFORM_VERSION}_linux_amd64.zip";
    local url="https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/$zip_file"

    if [ $(which "terraform") ]; then
      local active_version="$(terraform --version -json | jq -r '.terraform_version')";
      [[ "$active_version" == "$TERRAFORM_VERSION" ]] && export TERRAFORM="$(which terraform)" && echo "Terraform $TERRAFORM_VERSION is already active." && return;
    fi;

    export TERRAFORM="/tmp/terraform-$TERRAFORM_VERSION";
    [[ -f "$TERRAFORM" ]] && echo "$TERRAFORM already exists. Using it instead of downloading a new binary." && return;

    local temp_dir="$(mktemp -d)";

    echo "Downloading $zip_file to $temp_dir/$zip_file.";
    curl -sLo $temp_dir/$zip_file $url;

    echo "Extracting archive.";
    unzip $temp_dir/$zip_file -d $temp_dir;
    mv $temp_dir/terraform $TERRAFORM;
    rm -Rf $temp_dir;

    echo "Using Terraform:";
    $TERRAFORM --version;
}

function ensure_packer() {
    local zip_file="packer_${PACKER_VERSION}_linux_amd64.zip";
    local url="https://releases.hashicorp.com/packer/$PACKER_VERSION/$zip_file"

    [[ -f "$PACKER" ]] && echo "$PACKER already exists. Using it instead of downloading a new binary." && return;

    local temp_dir="$(mktemp -d)";

    echo "Downloading $zip_file to $temp_dir/$zip_file.";
    curl -sLo $temp_dir/$zip_file $url;

    echo "Extracting archive.";
    unzip $temp_dir/$zip_file -d $temp_dir;
    mv $temp_dir/packer $PACKER;
    rm -Rf $temp_dir;

    echo "Using Packer:";
    $PACKER --version;
}

function run_terraform() {
  local PLAN_FILE=/tmp/plan.out;

  ensure_terraform;

  echo "Launching Terraform commands.";
  $TERRAFORM init;
  $TERRAFORM plan -out=$PLAN_FILE;

  echo
  echo "Please validate above plan.";
  read -p "Press enter to apply it. Press CTRL-C to abort. No changes have been made until now.";

  $TERRAFORM apply $PLAN_FILE

  echo "TODO: copy the state to the Terraform project and configure cloud tasks to automatically plan when new pushes are done to the repo"
}

function get_terraform_outputs() {
  echo "Retrieving Terraform outputs in $(pwd).";
  export project_id="$(terraform output --json | jq -r '.project_id .value')"
  export subnet="$(terraform output --json | jq -r '.packer_subnet_id .value')"
  export service_account_email="$(terraform output --json | jq -r '.service_account_email .value')"
  export cloudbuild_pool="$(terraform output --json | jq -r '.cloudbuild_pool .value')"
  export region="$(terraform output --json | jq -r '.region .value')"
}

function create_packer_docker_image() {
  echo -e "\nSubmit build Packer Docker image Cloud Build job.\n"
  cd packer/packer-image
  gcloud builds submit --project "$project_id" .
  cd -
}

function configure_and_create_infraxys_vm_image() {
  echo -e "\nSubmet build Infraxys VM Image with Packer Cloud Build job.\n"
  cd packer/infraxys-image
  gcloud builds submit --project "$project_id" --config=cloudbuild.yaml --timeout=60m \
    --worker-pool="$cloudbuild_pool" --region "$region" \
    --substitutions=_PKR_VAR_ZONE="europe-west1-b",_PKR_VAR_SUBNET="$subnet",_PKR_VAR_PROJECT_ID="$project_id,_PKR_VAR_SERVICE_ACCOUNT_EMAIL=$service_account_email"
}
