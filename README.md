# Terraform Project: Infrastructure as Code for GKE Cluster

## Overview

This Terraform project provides Infrastructure as Code (IaC) for creating a Google Kubernetes Engine (GKE) cluster, along with other components like TLS keys, GitHub repository, and FluxCD setup.

## Modules

### GKE Cluster

The main module for creating the GKE cluster.

```hcl
module "gke_cluster" {
  source         = "git@github.com:kozyr-dv/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}
```

### TLS Private Key

Generates TLS private keys using HashiCorp's TLS provider.

```hcl
module "tls_private_key" {
  source      = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
}
```

### GitHub Repository

Creates a GitHub repository with an SSH key for FluxCD.

```hcl
module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}
```

### Flux Bootstrap

Sets up FluxCD for continuous delivery.

```hcl
module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.gke_cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}
```

## Terraform Backend

This project uses Google Cloud Storage (GCS) as the backend for storing Terraform state.

```hcl
terraform {
  backend "gcs" {
    bucket = "kdv-secret"
    prefix = "terraform/state"
  }
}
```

## Usage

1. Clone the repository.
2. Configure the necessary variables in your `terraform.tfvars` file.
3. Provide GOOGLE_APPLICATION_CREDENTIALS

    ```bash
    export GOOGLE_APPLICATION_CREDENTIALS="<path to your key>"
    ```
4. Initialize Terraform:

    ```bash
    terraform init
    ```

5. To look at plan use 

    ```bash
    terraform plan -var-file=vars.tfvars
    ```

6. Apply the configuration:

    ```bash
    terraform apply -var-file=vars.tfvars
    ```

## Variables

- `GOOGLE_REGION`: Google Cloud region for the GKE cluster.
- `GOOGLE_PROJECT`: Google Cloud project ID.
- `GKE_NUM_NODES`: Number of nodes in the GKE cluster.
- `algorithm`: Algorithm for TLS keys.
- `ecdsa_curve`: ECDSA curve for TLS keys.
- `GITHUB_OWNER`: GitHub owner/organization.
- `GITHUB_TOKEN`: GitHub personal access token.
- `FLUX_GITHUB_REPO`: GitHub repository name for FluxCD configuration.
