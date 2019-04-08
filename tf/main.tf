

module "user-pool-name" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.2.1"
  namespace  = "tmnz"
  stage      = "${var.stage}"
  name       = "pool"
  attributes = ["${var.user}"]
  delimiter  = "_"
#   tags       = "${map("BusinessUnit", "XYZ", "Snapshot", "true")}"
  tags = "${local.common_resource_tags}"
}

resource "aws_cognito_user_pool" "pool" {
  name = "${module.user-pool-name.id}"

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
  attributes = ["${var.user}"]
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

# resource "aws_cognito_identity_provider" "oidc_provider" {
#   user_pool_id  = "${aws_cognito_user_pool.pool.id}"
#   provider_name = "${aws_cognito_user_pool.pool.name}"
#   provider_type = "COGNITO"
  
  
# }

module "identity-pool-name" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.2.1"
  namespace  = "tmnz"
  stage      = "${var.stage}"
  name       = "pool"
  attributes = []
  delimiter  = "_"
#   tags       = "${map("BusinessUnit", "XYZ", "Snapshot", "true")}"
  tags = "${local.common_resource_tags}"
}
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${module.identity-pool-name.id}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = "${aws_cognito_user_pool_client.client.id}"
    provider_name           = "${aws_cognito_user_pool.pool.endpoint}"
    server_side_token_check = false
  }
}


module "user-pool-management-name" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.2.1"
  namespace  = "tmnz"
  stage      = "${var.stage}"
  name       = "pool"
  attributes = []
  delimiter  = "_"
#   tags       = "${map("BusinessUnit", "XYZ", "Snapshot", "true")}"
  tags = "${local.common_resource_tags}"
}

data "aws_iam_policy_document" "cognito_app_group_policy" {
  statement {
    actions = [
      # "cognito-idp:ListUserPools",
      "cognito-idp:ListUsers",
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      # "cognito-idp:AdminAddUserToGroup",
      # "cognito-idp:AdminConfirmSignUp",
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminDeleteUserAttributes",
      # "cognito-idp:AdminDisableProviderForUser",
      "cognito-idp:AdminDisableUser",
      "cognito-idp:AdminEnableUser",
      # "cognito-idp:AdminForgetDevice",
      # "cognito-idp:AdminGetDevice",
      "cognito-idp:AdminGetUser",
      # "cognito-idp:AdminInitiateAuth",
      # "cognito-idp:AdminLinkProviderForUser",
      # "cognito-idp:AdminListDevices",
      # "cognito-idp:AdminListGroupsForUser",
      "cognito-idp:AdminListUserAuthEvents",
      # "cognito-idp:AdminRemoveUserFromGroup",
      "cognito-idp:AdminResetUserPassword",
      # "cognito-idp:AdminRespondToAuthChallenge",
      "cognito-idp:AdminSetUserMFAPreference",
      "cognito-idp:AdminSetUserSettings",
      # "cognito-idp:AdminUpdateAuthEventFeedback",
      # "cognito-idp:AdminUpdateDeviceStatus",
      "cognito-idp:AdminUpdateUserAttributes",
      # "cognito-idp:AdminUserGlobalSignOut",
    ]

    resources = [
      "${aws_cognito_user_pool.pool.arn}",
    ]
  }
}
resource "aws_iam_policy" "manage_cognito_users_policy" {
  name   = "${var.stage}_${var.user}_manage_policy"
  policy = "${data.aws_iam_policy_document.cognito_app_group_policy.json}"
  
}

data "aws_iam_policy_document" "cognito_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "manage_cognito_role" {
  name = "cognito_provider_role"
  assume_role_policy = "${data.aws_iam_policy_document.cognito_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.manage_cognito_role.name}"
  policy_arn = "${aws_iam_policy.manage_cognito_users_policy.arn}"
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.main.id}"

  roles = {
    "authenticated" = "${aws_iam_role.manage_cognito_role.arn}"
    "unauthenticated" = "${aws_iam_role.apps_identity_pool_unauthenticated.arn}"
  }
}

resource "aws_iam_role" "apps_identity_pool_unauthenticated" {
  name = "${var.stage}_${var.user}_identitypool_unauthenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
# we don't allow unauthenticated access, so just set all actions to be denied
resource "aws_iam_role_policy" "apps_identity_pool_unauthenticated" {
  name = "${var.stage}_${var.user}_identitypool_unauthenticated_policy"
  role = "${aws_iam_role.apps_identity_pool_unauthenticated.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
