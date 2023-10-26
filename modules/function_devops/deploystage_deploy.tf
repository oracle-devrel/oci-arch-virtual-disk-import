## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_deploy_stage" "deploy_stage" {
  for_each = local.functions

  deploy_pipeline_id = oci_devops_deploy_pipeline.deploy_pipeline[each.key].id

  deploy_stage_predecessor_collection {
    items {
      id = oci_devops_deploy_pipeline.deploy_pipeline[each.key].id
    }
  }
  deploy_stage_type = "DEPLOY_FUNCTION"


  description  = "${each.value.application_name}/${each.value.function_name} function deploy stage"
  display_name = "${each.value.function_name}-deploy-stage"

  function_deploy_environment_id  = oci_devops_deploy_environment.environment[each.key].id
  function_timeout_in_seconds     = each.value.timeout_in_seconds
  max_memory_in_mbs               = each.value.memory_in_mbs
  docker_image_deploy_artifact_id = oci_devops_deploy_artifact.container_image[each.key].id

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
