## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_deploy_environment" "environment" {
  for_each = local.functions

  display_name            = each.value.function_name
  description             = "${each.value.application_name}/${each.value.function_name} function environment"
  deploy_environment_type = "FUNCTION"
  project_id              = oci_devops_project.devops_project.id
  function_id             = oci_functions_function.function[each.key].id

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
