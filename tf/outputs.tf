output "clientId" {
    value = "${aws_cognito_user_pool_client.client.id}"
}

output "issuer" {
    value= "https://${aws_cognito_user_pool.pool.endpoint}"
}