variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "partition" {
  description = "The partition that the resource is in."
  default     = "aws"
}

variable "service" {
  description = "The service namespace that identifies the AWS product (for example: iam, s3)"
  type        = "string"
}

variable "region" {
  description = "The region the resource resides in."
  default     = ""
}

variable "account_id" {
  description = "The account ID used for generated ARNs. If not set caller account ID is used."
  default     = ""
}

variable "resource_path" {
  description = "Resource path to use by default (ex. user/MyORG/MyUnit/)."
  default     = ""
}

variable "resources" {
  description = "The list of resource short names for which the full ARN resource identifiers will be generated."
  type        = "list"
}
