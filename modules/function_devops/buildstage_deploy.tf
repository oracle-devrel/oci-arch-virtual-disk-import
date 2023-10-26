## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_build_pipeline_stage" "trigger_deploy_stage" {

  depends_on = [oci_devops_build_run.test_build_run]

  for_each = local.functions

  #Required
  build_pipeline_id = oci_devops_build_pipeline.build_pipeline[each.key].id

  build_pipeline_stage_predecessor_collection {
    #Required
    items {
      #Required
      id = oci_devops_build_pipeline_stage.deliver_artifact_stage[each.key].id
    }
  }

  build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"

  deploy_pipeline_id             = oci_devops_deploy_pipeline.deploy_pipeline[each.key].id
  display_name                   = "trigger-deploy"
  description                    = "trigger deploy stage"
  is_pass_all_parameters_enabled = true

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}