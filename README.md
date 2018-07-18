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
| **resource_path** |Resource base path to use by default (ex. MyORG/MyUnit/). Note that path starts with no separator, but must end with it. | `""` |
| **resources** | The list of resource short names for which the full ARN resource identifiers will be generated. | **Required** |

## Usage

Module is to generate resources ARNs and providing the details on each resource name, path, type. You have to provide a list of resources to this module in the format: `type[:/]short_path` or `type[:/]full_path`. Examples:

```
# type/short_path
user/name
role/name

# type/full_path
user/MyORG/MyUnit/name
```

Also you can provide a full ARN (Amazon Resource Name), i.e. any string starting with `arn:`, for these kind of resource identifiers no generation will take place.

For the short resource identifiers of the described format above the ARN generation will take place using the provided configuration such as *partition*, *service*, *region* and *account_id*.

Note that you can also provide **resource_path** which will be substituted as a prefix during generation **only if you've given a resource in the short path format**.

Bellow have a look at the sample configuration and its output.

```hcl
module "iam" {
  source        = "git::https://github.com/stackfeed/terraform-aws-arn?ref=master"
  service       = "iam"
  resource_path = "myorg/myunit/"
  account_id    = "132578140418"

  resources = [
    "user/hello",
    "user/ahha",
    "group/explict/myGroup",
    "role/world",
    "arn:aws:iam::132578140418:user/test"
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
    arn:aws:iam::132578140418:group/explict/myGroup,
    arn:aws:iam::132578140418:role/myorg/myunit/world,
    arn:aws:iam::132578140418:user/myorg/myunit/ahha,
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
paths = [
    /explict/,
    /myorg/myunit/,
    /myorg/myunit/,
    /myorg/myunit/,
    /
]
regions = [
    ,
    ,
    ,
    ,
    
]
types = [
    group,
    role,
    user,
    user,
    user
]
```
