variable "user" {
  type        = "string"
  description = "user that ran the deploy"
}
variable "stage" {
  type        = "string"
  description = ""
  default = "development"
}