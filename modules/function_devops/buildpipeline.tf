## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_devops_build_pipeline" "build_pipeline" {
  for_each = local.functions

  project_id = oci_devops_project.devops_project.id

  description  = "${each.value.function_name} function build pipeline"
  display_name = "${each.value.function_name}-build-pipeline"

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
