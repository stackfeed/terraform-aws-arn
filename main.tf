locals {
  service_needs_region = []
  account_id           = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
  selected_region      = "${coalesce(var.region, data.aws_region.current.name)}"

  region   = "${contains(local.service_needs_region, var.service) ? local.selected_region : ""}"
  arn_base = "${format("arn:%v:%v:%v:%v", var.partition, var.service, local.region, local.account_id)}"

  resources_use_type = "${
    formatlist(
      "${local.arn_base}:${var.resource_type}%v",
      matchkeys(
        data.null_data_source.select.*.outputs.name,
        data.null_data_source.select.*.outputs.use_type, list("true")
      )
    )}"

  resources = "${
    formatlist(
      "${local.arn_base}:%v",
      matchkeys(
        data.null_data_source.select.*.outputs.name,
        data.null_data_source.select.*.outputs.use_type, list("false")
      )
    )}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "null_data_source" "select" {
  count = "${length(var.resources)}"

  inputs {
    name = "${var.resources[count.index]}"

    use_type = "${
      length(split("/", var.resources[count.index])) +
      length(split(":", var.resources[count.index])) == 2
    }"
  }
}

resource "null_resource" "prevent" {
  count = "${contains(data.null_data_source.select.*.outputs.use_type, "true") ? 1 : 0}"

  triggers {
    resource_type = "${var.resource_type}"
  }

  provisioner "local-exec" {
    command = "[ '${var.resource_type}' != '' ] || { echo 'You must provide var.resource_type'; exit 1; }"
  }
}
