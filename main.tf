locals {
  service_needs_region = []
  account_id           = "${coalesce(var.account_id, data.aws_caller_identity.current.account_id)}"
  selected_region      = "${coalesce(var.region, data.aws_region.current.name)}"

  region   = "${contains(local.service_needs_region, var.service) ? local.selected_region : ""}"
  arn_base = "${format("arn:%v:%v:%v:%v", var.partition, var.service, local.region, local.account_id)}"

  with_arn = "${
    matchkeys(
      data.null_data_source.select_arn.*.outputs.name,
      data.null_data_source.select_arn.*.outputs.has_arn, list("true")
    )}"

  without_arn = "${
    matchkeys(
      data.null_data_source.select_arn.*.outputs.name,
      data.null_data_source.select_arn.*.outputs.has_arn, list("false")
    )}"

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

  arns = "${sort(
    concat(
      local.with_arn,
      local.resources_use_path,
      local.resources,
    )
  )}"

  account_id_regex = "/(.*?:){4}(\\d{12}).*/"
  region_regex     = "/(.*?:){3}(.*?):.*/"

  type_regex = "/(.*:)(.*?)[:/].*/"
  name_regex = "/(.*:)([^:/]*[:/])*/"
  path_regex = "/(.*:)/"
  arn_regex  = "/^(arn):.*/"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "null_data_source" "select_arn" {
  count = "${length(var.resources) * var.enabled}"

  inputs {
    name    = "${var.resources[count.index]}"
    has_arn = "${replace(var.resources[count.index], local.arn_regex, "$1") == "arn"}"
  }
}

data "null_data_source" "select" {
  count = "${length(local.without_arn) * var.enabled}"

  inputs {
    name = "${local.without_arn[count.index]}"

    use_path = "${
      length(split("/", local.without_arn[count.index])) +
      length(split(":", local.without_arn[count.index])) == 2
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
    name       = "${replace(local.arns[count.index], local.name_regex, "")}"
    path       = "${replace(local.arns[count.index], local.path_regex, "")}"
    type       = "${replace(local.arns[count.index], local.type_regex, "$2")}"
    account_id = "${replace(local.arns[count.index], local.account_id_regex, "$2")}"
    region     = "${replace(local.arns[count.index], local.region_regex, "$2")}"
  }
}
