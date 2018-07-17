output "arns" {
  value = "${sort(concat(local.resources_use_path, local.resources))}"
}
