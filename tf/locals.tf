locals {
  common_resource_tags = {
    Project    = "angular-auth-cognito"
    Repo       = "n/a"
    Stage      = "${var.stage}"
    DeployedBy = "${var.user}"
    CostCenter = "Technology/CI"
  }
}