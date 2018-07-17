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
  description = "The ID of the AWS account that owns the resources."
  default     = ""
}

variable "resource_type" {
  description = "Resource type to use by default (resourcetype: or resourcetype/) if it's not the part of a resource name."
  default     = ""
}

variable "resources" {
  description = "The list of resource short names for which the full ARN resource identifiers will be generated."
  type        = "list"
}
