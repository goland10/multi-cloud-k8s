############################################
# Secure GitHub Actions Runner VM on GCP
# - No public IP
# - Private GKE access
# - Minimal IAM
# - Firewall rule for IAP tunnel
# - gcloud with GKE auth plugin and kubectl installed
# - Cloud NAT for internet access
############################################
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

############################
# Service Account
############################

resource "google_service_account" "runner" {
  account_id   = "github-actions-runner"
  display_name = "GitHub Actions Runner"
}

# Minimal permissions for GKE deploys
resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

############################
# Network (existing VPC)
############################

data "google_compute_network" "vpc" {
  name = var.network
}

data "google_compute_subnetwork" "subnet" {
  name   = var.subnet
  region = var.region
}

############################
# Cloud NAT (for private subnet internet access)
############################

resource "google_compute_router" "nat_router" {
name = "gha-runner-nat-router"
network = data.google_compute_network.vpc.name
region = var.region
}


resource "google_compute_router_nat" "nat" {
name = "gha-runner-nat"
router = google_compute_router.nat_router.name
region = var.region
nat_ip_allocate_option = "AUTO_ONLY"
source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

############################
# Firewall: IAP tunnel inbound
############################

resource "google_compute_firewall" "iap_tunnel_ingress" {
name = "gha-runner-iap-ingress"
network = data.google_compute_network.vpc.name

direction = "INGRESS"
allow {
protocol = "tcp"
ports = ["22"]
}

target_service_accounts = [google_service_account.runner.email]
source_ranges = ["35.235.240.0/20"] # IAP TCP forwarding range
}

############################
# Firewall: outbound only
############################

resource "google_compute_firewall" "runner_egress" {
  name    = "gha-runner-egress"
  network = data.google_compute_network.vpc.name

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_service_accounts = [google_service_account.runner.email]
}

############################
# Compute Engine VM
############################

resource "google_compute_instance" "runner" {
  name         = "gha-runner"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["github-runner"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 30
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.self_link
    # NO public IP
  }

  service_account {
    email  = google_service_account.runner.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -xe
    exec > /var/log/startup-script.log 2>&1

    apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release jq

    # Install Google Cloud SDK and GKE auth plugin
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update && apt-get install google-cloud-cli  google-cloud-sdk-gke-gcloud-auth-plugin  kubectl
    
    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Create runner directory
    mkdir -p /opt/actions-runner
    cd /opt/actions-runner

    # Download the latest runner package
    $ curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
    # Optional: Validate the hash
    $ echo "5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7  actions-runner-linux-x64-2.331.0.tar.gz" | shasum -a 256 -c
    # Extract the installer
    $ tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz

    # Create the runner and start the configuration experience
    $ ./config.sh --url https://github.com/goland10/multi-cloud-k8s --token BFKUS7YCJZFPNVF6R3VCOZTJRKAUMCopied!# Last step, run it!
    $ ./run.sh
  EOT
}

############################
# Variables
############################

variable "project_id" { default = "github-actions-terraform-k8s" }
variable "region" { default = "europe-west1" }
variable "zone" { default = "europe-west1-b"  }
variable "network" { default = "dev-01"}
variable "subnet" {default = "dev-01-subnet"}

############################
# Outputs
############################

output "runner_service_account" {
  value = google_service_account.runner.email
}
