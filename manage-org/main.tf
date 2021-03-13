terraform {
  required_providers {
    tfe = {
      version = "~> 0.24.0"
    }
  }
}

locals {
  tf_org = "cloud01"
}

variable "vcs_identifier" { default = "fanovilla/cloud-infra" }
variable "vcs_oauth_token_id" {} # https://www.terraform.io/docs/cloud/vcs/index.html

resource "tfe_workspace" "managed_ad" {
  name              = "managed_ad"
  organization      = local.tf_org
  working_directory = "manage-org"
  vcs_repo {
    identifier     = var.vcs_identifier
    oauth_token_id = var.vcs_oauth_token_id
  }
}