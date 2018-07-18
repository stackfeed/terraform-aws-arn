# Terraform AWS ARNs generation module

This module is intended to be a helper for ARN identifiers generation. It's especially handy for generating a list of ARNs for the IAM service for example when a list of principals is required.

**Note**: currently this module module is used to generate IAM ARNs.

## Variables

| Name | Description | Default |
|---|---|---|
| **enabled** | Set to false to prevent the module from creating any resources. | `true` |
| **partition** | The partition that the resource is in. | `"aws"` |
| **service** | The service namespace that identifies the AWS product (for example: iam, s3). | **Required** |
| **region** | The region the resource resides in. | `""` |
| **account_id** | Default account ID used for generated ARNs. If not set caller account ID is used. | `""` |
| **resource_path** | Resource path to use by default (ex. user/MyORG/MyUnit/). Note that it **must explicitly contain** the resource type.| `""` |
| **resources** | The list of resource short names for which the full ARN resource identifiers will be generated. | **Required** |

## Usage

Module generates full ARNs for a given set of resources based on parameters such as account_id, service etc. Resources might be specified in three following forms:

 - **shortname**  - `hello`.
 - **resource_path** - `user/ahha`, `group/myGroup` etc.
 - **full ARN** - an ARN identifier must start with **arn:**. No actual generation will take place.

```hcl
module "iam" {
  source        = "git::https://github.com/stackfeed/terraform-aws-arn?ref=master"
  service       = "iam"
  resource_path = "user/MyORG/MyUnit/"
  account_id    = "132578140418"

  resources = [
    "hello",
    "user/ahha",
    "group/myGroup",
    "role/world",
    "arn:aws:iam::132578140418:user/test",
  ]
}
```

The expected output of the module with such configuration will look like:

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

account_ids = [
    132578140418,
    132578140418,
    132578140418,
    132578140418,
    132578140418
]
arns = [
    arn:aws:iam::132578140418:group/myGroup,
    arn:aws:iam::132578140418:role/world,
    arn:aws:iam::132578140418:user/ahha,
    arn:aws:iam::132578140418:user/myorg/myunit/hello,
    arn:aws:iam::132578140418:user/test
]
names = [
    myGroup,
    world,
    ahha,
    hello,
    test
]
partition = aws
paths = [
    group/myGroup,
    role/world,
    user/ahha,
    user/myorg/myunit/hello,
    user/test
]
regions = [
    ,
    ,
    ,
    ,
    
]
service = iam
types = [
    group,
    role,
    user,
    user,
    user
]
```
