locals {
  service_needs_region = []

  account_id = "${
    coalesce(var.account_id, element(
      concat(data.aws_caller_identity.current.*.account_id, list("")), 0)
    )}"

  selected_region = "${
    coalesce(var.region, element(
      concat(data.aws_region.current.*.name, list("")), 0)
    )}"

  region   = "${contains(local.service_needs_region, var.service) ? local.selected_region : ""}"
  arn_base = "${format("arn:%v:%v:%v:%v", var.partition, var.service, local.region, local.account_id)}"

  resources_with_arn = "${
    matchkeys(
      data.null_data_source.select.*.outputs.name,
      data.null_data_source.select.*.outputs.has_arn, list("true")
    )}"

  resources = "${
    matchkeys(
      data.null_data_source.select.*.outputs.name,
      data.null_data_source.select.*.outputs.has_arn, list("false")
    )}"

  generated = "${formatlist("${local.arn_base}:%v", data.null_data_source.generated.*.outputs.path)}"

  all = "${sort(concat(local.resources_with_arn, local.generated))}"

  account_id_regex    = "/(.*?:){4}(\\d{12}).*/"
  region_regex        = "/(.*?:){3}(.*?):.*/"
  insert_path_regex   = "/^(([^:/]*)[:/])([^:/]*)$/"
  insert_path_replace = "$$1${var.resource_path}$$2"

  type_regex = "/(.*:)(.*?)[:/].*/"
  name_regex = "/(.*:)([^:/]*[:/])*/"
  path_regex = "/(.*:)[^:/]*(.*[:/]).*/"
}

data "aws_caller_identity" "current" {
  count = "${signum(length(local.resources))}"
}

data "aws_region" "current" {
  count = "${signum(length(local.resources))}"
}

data "null_data_source" "select" {
  count = "${length(var.resources) * var.enabled}"

  inputs {
    name    = "${var.resources[count.index]}"
    has_arn = "${replace(var.resources[count.index], "/^(arn):.*/", "$1") == "arn"}"
  }
}

data "null_data_source" "generated" {
  count = "${length(local.resources) * var.enabled}"

  inputs {
    path = "${
      replace(
        replace(
          local.resources[count.index], local.insert_path_regex, "$1 $3"
        ), "/ /", "${var.resource_path}"
      )}"
  }
}

data "null_data_source" "resource" {
  count = "${length(var.resources) * var.enabled}"

  inputs {
    name       = "${replace(local.all[count.index], local.name_regex, "")}"
    path       = "${replace(local.all[count.index], local.path_regex, "$2")}"
    type       = "${replace(local.all[count.index], local.type_regex, "$2")}"
    account_id = "${replace(local.all[count.index], local.account_id_regex, "$2")}"
    region     = "${replace(local.all[count.index], local.region_regex, "$2")}"
  }
}
