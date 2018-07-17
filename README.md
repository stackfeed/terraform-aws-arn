# Terraform AWS ARNs generation module

This module is intended to be a helper for ARN identifiers generation. It's especially handy for generating a list of ARNs when specifying principals in a Policy.

**Note**: currently this module module is used to generate IAM ARNs.

## Variables

| Name | Description | Default |
|---|---|---|
| **partition** | The partition that the resource is in. | `aws` |
| **service** | The service namespace that identifies the AWS product (for example: iam, s3). | **Required** |
| **region** | The region the resource resides in. | `""` |
| **account_id** | The ID of the AWS account that owns the resources. | `""` |
| **resource_type** | Resource type to use by default (resourcetype: or resourcetype/) if it's not the part of a resource name. | `""` |
| **resources** | The list of resource short names for which the full ARN resource identifiers will be generated. | **Required** |

## Usage

The bellow example is quite self-explanatory, have a look a the following module configuration and it's output:

```hcl
module "iam" {
  source = "git::https://github.com/stackfeed/terraform-aws-arn?ref=master"
  service = "iam"
  resource_type = "user/"
  resources = [
    "hello",
    "user/ahha",
    "john",
    "role/world"
  ]
}

output "arns" {
  value = "${module.iam.arns}"
}
```

The expected result after applying the above configuration will look like:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

arns = [
    arn:aws:iam::123456789012:group/myGroup,
    arn:aws:iam::123456789012:role/world,
    arn:aws:iam::123456789012:user/ahha,
    arn:aws:iam::123456789012:user/hello
]
```
