variable "GOOGLE_REGION" {
  description = "Google Cloud region for GKE cluster"
  type        = string
}

variable "GOOGLE_PROJECT" {
  description = "Google Cloud project for GKE cluster"
  type        = string
}

variable "GKE_NUM_NODES" {
  description = "Number of nodes for GKE cluster"
  type        = number
}

variable "algorithm" {
  description = "Algorithm for TLS private key"
  type        = string
}

variable "ecdsa_curve" {
  description = "ECDSA curve for TLS private key"
  type        = string
}

variable "GITHUB_OWNER" {
  description = "GitHub repository owner"
  type        = string
}

variable "GITHUB_TOKEN" {
  description = "GitHub personal access token"
  type        = string
}

variable "FLUX_GITHUB_REPO" {
  description = "GitHub repository name for Flux"
  type        = string
}

variable "GITHUB_ACTIONS_SA" {
  description = "GitHub Actions Service Account ID"
}

variable "GITHUB_ACTIONS_DISPLAY_NAME" {
  description = "GitHub Actions Service Account Display Name"
}

variable "GITHUB_ACTIONS_POOL_ID" {
  description = "GitHub Actions Pool ID"
}

variable "GITHUB_ACTIONS_POOL_DISPLAY_NAME" {
  description = "GitHub Actions Pool Display Name"
}
