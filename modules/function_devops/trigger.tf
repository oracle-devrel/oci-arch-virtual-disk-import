## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_devops_trigger" "trigger" {
  for_each = { for k, v in local.functions :
    k => v if v.commit_trigger_enabled
  }

  display_name = "${each.value.function_name}_commit_trigger"

  project_id     = oci_devops_project.devops_project.id
  repository_id  = oci_devops_repository.repo[each.key].id
  trigger_source = "DEVOPS_CODE_REPOSITORY"
  depends_on = [
    oci_devops_build_pipeline_stage.trigger_deploy_stage,
    oci_devops_deploy_stage.deploy_stage
  ]

  actions {
    build_pipeline_id = oci_devops_build_pipeline.build_pipeline[each.key].id
    type              = "TRIGGER_BUILD_PIPELINE"
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}