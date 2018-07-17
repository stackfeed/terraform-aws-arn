output "arns" {
  value = "${sort(concat(local.resources_use_type, local.resources))}"
}
