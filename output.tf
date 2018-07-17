output "arns" {
  value = "${local.arns}"
}

output "names" {
  value = "${data.null_data_source.resource.*.outputs.name}"
}

output "paths" {
  value = "${data.null_data_source.resource.*.outputs.path}"
}

output "types" {
  value = "${data.null_data_source.resource.*.outputs.type}"
}

output "account_id" {
  value = "${local.account_id}"
}

output "service" {
  value = "${var.service}"
}

output "partition" {
  value = "${var.partition}"
}

output "region" {
  value = "${local.region}"
}
