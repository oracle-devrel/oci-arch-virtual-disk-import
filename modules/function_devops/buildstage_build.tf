## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_build_pipeline_stage" "build_pipeline_stage" {
  for_each = local.functions

  build_pipeline_id = oci_devops_build_pipeline.build_pipeline[each.key].id
  build_pipeline_stage_predecessor_collection {
    #Required
    items {
      #Required
      id = oci_devops_build_pipeline.build_pipeline[each.key].id
    }
  }
  build_pipeline_stage_type = "BUILD"

  #Optional
  build_source_collection {

    #Optional
    items {
      #Required
      connection_type = "DEVOPS_CODE_REPOSITORY"

      #Optional
      branch = each.value.default_branch

      name           = oci_devops_repository.repo[each.key].name
      repository_id  = oci_devops_repository.repo[each.key].id
      repository_url = oci_devops_repository.repo[each.key].http_url
    }
  }


  display_name                       = "build"
  description                        = "build stage"
  image                              = "OL7_X86_64_STANDARD_10"
  stage_execution_timeout_in_seconds = 3600
  wait_criteria {
    #Required
    wait_duration = "waitDuration"
    wait_type     = "ABSOLUTE_WAIT"
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}