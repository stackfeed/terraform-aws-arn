output "arns" {
  value = "${local.all}"
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

output "account_ids" {
  value = "${data.null_data_source.resource.*.outputs.account_id}"
}

output "regions" {
  value = "${data.null_data_source.resource.*.outputs.region}"
}
