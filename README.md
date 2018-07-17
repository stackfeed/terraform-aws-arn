# Terraform AWS ARNs generation module

This module is intended to be a helper for ARN identifiers generation. It's especially handy for generating a list of ARNs when specifying principals in a Policy.

**Note**: currently this module module is used to generate IAM ARNs.

## Variables

| Name | Description | Default |
|---|---|---|
| **enabled** | Set to false to prevent the module from creating any resources. | `true` |
| **partition** | The partition that the resource is in. | `"aws"` |
| **service** | The service namespace that identifies the AWS product (for example: iam, s3). | **Required** |
| **region** | The region the resource resides in. | `""` |
| **account_id** | The ID of the AWS account that owns the resources. | `""` |
| **resource_path** | Resource path to use by default (ex. user/MyORG/MyUnit/). Note that it **must explicitly contain** the resource type.| `""` |
| **resources** | The list of resource short names for which the full ARN resource identifiers will be generated. | **Required** |

## Usage

The bellow example is quite self-explanatory, have a look a the following module configuration and it's output:

```hcl
module "iam" {
  source        = "git::https://github.com/stackfeed/terraform-aws-arn?ref=master"
  service       = "iam"
  resource_path = "user/MyORG/MyUnit/"

  resources = [
    "hello",
    "user/ahha",
    "group/myGroup",
    "role/world"
  ]
}
```

The expected output of the module with such configuration will look like:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_id = 1233456789012
arns = [
    arn:aws:iam::1233456789012:group/myGroup,
    arn:aws:iam::1233456789012:role/world,
    arn:aws:iam::1233456789012:user/ahha,
    arn:aws:iam::1233456789012:user/myorg/myunit/hello
]
names = [
    myGroup,
    world,
    ahha,
    hello
]
partition = aws
paths = [
    group/myGroup,
    role/world,
    user/ahha,
    user/myorg/myunit/hello
]
region =
service = iam
types = [
    group,
    role,
    user,
    user
]
```
