## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_id" "run" {
  byte_length = 2
}


resource "oci_devops_build_run" "test_build_run" {
  for_each = local.functions

  depends_on = [oci_devops_build_pipeline_stage.deliver_artifact_stage,
  ]

  #Required
  build_pipeline_id = oci_devops_build_pipeline.build_pipeline[each.key].id

  #Optional
  display_name = "build_run_${each.value.function_name}_${random_id.run.hex}"

  lifecycle {
    ignore_changes = [build_run_progress]
  }
}

