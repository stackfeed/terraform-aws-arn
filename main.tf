locals {
  service_needs_region = []
  account_id           = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
  selected_region      = "${coalesce(var.region, data.aws_region.current.name)}"

  region   = "${contains(local.service_needs_region, var.service) ? local.selected_region : ""}"
  arn_base = "${format("arn:%v:%v:%v:%v", var.partition, var.service, local.region, local.account_id)}"

  resources_use_path = "${
    formatlist(
      "${local.arn_base}:${var.resource_path}%v",
      matchkeys(
        data.null_data_source.select.*.outputs.name,
        data.null_data_source.select.*.outputs.use_path, list("true")
      )
    )}"

  resources = "${
    formatlist(
      "${local.arn_base}:%v",
      matchkeys(
        data.null_data_source.select.*.outputs.name,
        data.null_data_source.select.*.outputs.use_path, list("false")
      )
    )}"

  arns = "${sort(concat(local.resources_use_path, local.resources))}"

  type_regex = "/(.*:){5}(.*?)[:/].*/"
  name_regex = "/(.*:){5}([^:/]*[:/])*/"
  path_regex = "/(.*:){5}/"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "null_data_source" "select" {
  count = "${length(var.resources) * var.enabled}"

  inputs {
    name = "${var.resources[count.index]}"

    use_path = "${
      length(split("/", var.resources[count.index])) +
      length(split(":", var.resources[count.index])) == 2
    }"
  }
}

resource "null_resource" "prevent" {
  count = "${contains(data.null_data_source.select.*.outputs.use_path, "true") ? 1 : 0}"

  triggers {
    resource_path = "${var.resource_path}"
  }

  provisioner "local-exec" {
    command = "[ '${var.resource_path}' != '' ] || { echo 'You must provide var.resource_path'; exit 1; }"
  }
}

data "null_data_source" "resource" {
  count = "${length(var.resources) * var.enabled}"

  inputs {
    name = "${replace(local.arns[count.index], local.name_regex, "")}"
    path = "${replace(local.arns[count.index], local.path_regex, "")}"
    type = "${replace(local.arns[count.index], local.type_regex, "$2")}"
  }
}
