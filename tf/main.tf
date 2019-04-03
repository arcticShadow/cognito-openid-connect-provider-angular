

module "cognito-pool-name" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.2.1"
  namespace  = "tmnz"
  stage      = "${var.stage}"
  name       = "pool"
  attributes = []
  delimiter  = "_"
#   tags       = "${map("BusinessUnit", "XYZ", "Snapshot", "true")}"
  tags = "${local.common_resource_tags}"
}

resource "aws_cognito_user_pool" "pool" {
  name = "${module.cognito-pool-name.id}"

  admin_create_user_config = {
    allow_admin_create_user_only = true
  }

  password_policy = {
    minimum_length = 8
    require_lowercase = true
    require_uppercase = true
    require_symbols = false
    require_numbers = false
  }
  tags = "${local.common_resource_tags}"
}

module "cognito-pool-client-name" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.2.1"
  namespace  = "tmnz"
  stage      = "${var.stage}"
  name       = "pool"
  attributes = []
  delimiter  = "_"
#   tags       = "${map("BusinessUnit", "XYZ", "Snapshot", "true")}"
  tags = "${local.common_resource_tags}"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${module.cognito-pool-client-name.id}"

  user_pool_id = "${aws_cognito_user_pool.pool.id}"

#   explicit_auth_flows    = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile"]
  callback_urls = [
      "http://localhost:4200"
  ]
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "gt-portal"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}