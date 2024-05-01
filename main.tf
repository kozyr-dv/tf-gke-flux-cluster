module "gke_cluster" {
  source         = "git@github.com:kozyr-dv/tf-google-gke-cluster.git"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"

  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
}

module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.gke_cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_k8s_sa = true
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
  annotate_k8s_sa     = true
  location            = var.GOOGLE_REGION
  cluster_name        = "main"
}

resource "google_project_iam_member" "github_actions_role" {
  project = var.GOOGLE_PROJECT
  role    = "roles/editor"

  member     = "serviceAccount:${google_service_account.github_actions_sa.email}"
  depends_on = [google_service_account.github_actions_sa]
}

resource "google_service_account" "github_actions_sa" {
  account_id   = var.GITHUB_ACTIONS_SA
  display_name = var.GITHUB_ACTIONS_DISPLAY_NAME
  project      = var.GOOGLE_PROJECT
}

resource "google_iam_workload_identity_pool" "github_actions_pool" {
  workload_identity_pool_id = var.GITHUB_ACTIONS_POOL_ID
  display_name              = var.GITHUB_ACTIONS_POOL_DISPLAY_NAME
  description               = "Identity pool for github pipelines"
  project                   = var.GOOGLE_PROJECT

  depends_on = [google_project_iam_member.github_actions_role, google_service_account.github_actions_sa]
}

module "kms" {
  source          = "github.com/den-vasyliev/terraform-google-kms"
  project_id      = var.GOOGLE_PROJECT
  location        = "global"
  keyring         = "sops-flux"
  keys            = ["sops-keys-flux"]
  prevent_destroy = false
}

terraform {
  backend "gcs" {
    bucket = "kdv-secret"
    prefix = "terraform/state"
  }
}
