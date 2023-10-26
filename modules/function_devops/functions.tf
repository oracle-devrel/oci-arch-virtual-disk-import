# ## Copyright (c) 2023, Oracle and/or its affiliates.
# ## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_functions_application" "app" {
  for_each = local.applications

  compartment_id = var.compartment_ocid
  display_name   = each.value.application_name

  network_security_group_ids = each.value.nsg_ids
  subnet_ids = (length(each.value.subnet_ocids) > 0 ?
    each.value.subnet_ocids :
    var.fnsubnet_OCID != "" ?
    [var.fnsubnet_OCID] :
    [oci_core_subnet.fnsubnet[0].id]
  )

  config = each.value.env_variables

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}


resource "oci_functions_function" "function" {
  # depends_on     = [oci_devops_build_pipeline_stage.test_deliver_artifact_stage]

  for_each = local.functions

  application_id = oci_functions_application.app[each.value.application_name].id
  display_name   = each.value.function_name

  image              = "${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.container_repository[each.key].display_name}:${local.function_image_tags[each.key]}"
  memory_in_mbs      = each.value.memory_in_mbs
  timeout_in_seconds = each.value.timeout_in_seconds

  config = each.value.env_variables

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"], image]
  }
}

resource "oci_logging_log" "applications_log" {
  for_each = local.applications

  display_name       = "${each.value.application_name}_fnInvokeLog"
  log_group_id       = oci_logging_log_group.application_log_group[each.key].id
  log_type           = "SERVICE"
  retention_duration = var.project_logging_config_retention_period_in_days

  configuration {
    compartment_id = var.compartment_ocid

    source {
      category    = "invoke"
      resource    = oci_functions_application.app[each.key].id
      service     = "functions"
      source_type = "OCISERVICE"
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
