## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_deploy_pipeline" "deploy_pipeline" {
  for_each = local.functions

  project_id   = oci_devops_project.devops_project.id
  description  = "${each.value.function_name} deploy pipeline"
  display_name = "${each.value.function_name}-deploy-pipeline"

  deploy_pipeline_parameters {
    items {
      name          = "BUILDRUN_HASH"
      default_value = "latest"
      description   = "Tag for the docker image."
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
