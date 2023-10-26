## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "oci_artifacts_container_repository" "container_repository" {
  for_each = local.functions

  compartment_id = var.compartment_ocid
  display_name   = "${each.value.application_name}/${each.value.function_name}"
  #Optional
  is_public = false

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}


resource "oci_devops_deploy_artifact" "container_image" {
  for_each = local.functions

  #Required
  argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
  deploy_artifact_source {
    #Required
    deploy_artifact_source_type = "OCIR"

    #Optional
    image_uri = "${local.ocir_docker_repository}/${local.ocir_namespace}/${oci_artifacts_container_repository.container_repository[each.key].display_name}:$${BUILDRUN_HASH}"
  }

  deploy_artifact_type = "DOCKER_IMAGE"
  project_id           = oci_devops_project.devops_project.id

  #Optional
  display_name = "${each.value.function_name}-container-artifact"

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
