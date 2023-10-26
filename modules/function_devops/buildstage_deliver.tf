## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_devops_build_pipeline_stage" "deliver_artifact_stage" {

  for_each = local.functions
  #Required
  build_pipeline_id = oci_devops_build_pipeline.build_pipeline[each.key].id

  build_pipeline_stage_predecessor_collection {
    #Required
    items {
      #Required
      id = oci_devops_build_pipeline_stage.build_pipeline_stage[each.key].id
    }
  }

  build_pipeline_stage_type = "DELIVER_ARTIFACT"

  deliver_artifact_collection {

    #Optional
    items {
      #Optional

      artifact_name = "output_container_image"
      artifact_id   = oci_devops_deploy_artifact.container_image[each.key].id

    }
  }
  display_name = "deliver"
  description  = "deliver stage"

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}