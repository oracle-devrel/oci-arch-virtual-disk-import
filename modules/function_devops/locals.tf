## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


locals {
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_objectstorage_namespace.os_namespace, "namespace")
  function_image_tags = {
    for k, v in oci_devops_build_run.test_build_run :
    k => coalesce([for entry in v.build_outputs[0].exported_variables[0].items : lookup(entry, "name") == "BUILDRUN_HASH" ? lookup(entry, "value") : ""]...)
  }
  applications = {
    for k, v in var.applications:
      k => {
        application_name = v.application_name
        subnet_ocids     = lookup(v, "subnet_ocids", [])
        nsg_ids          = lookup(v, "nsg_ids", [])
        env_variables    = lookup(v, "env_variables", {})
      }
  }
  functions = {
    for k, v in var.functions:
      k => {
        function_name           = v.function_name
        application_name        = v.application_name
        default_branch          = lookup(v, "default_branch", "main")
        repository_type         = lookup(v, "repository_type", "HOSTED")
        repository_url          = lookup(v, "repository_url", "")
        external_connection     = lookup(v, "external_connection", "")
        trigger_schedule_type   = lookup(v, "trigger_schedule_type", "CUSTOM")
        trigger_custom_schedule = lookup(v, "trigger_custom_schedule", "FREQ=MINUTELY;INTERVAL=3;")
        memory_in_mbs           = lookup(v, "memory_in_mbs", "256")
        timeout_in_seconds      = lookup(v, "timeout_in_seconds", 30)
        commit_trigger_enabled  = lookup(v, "commit_trigger_enabled", true)
        function_code_zip       = lookup(v, "function_code_zip", "")
        env_variables           = lookup(v, "env_variables", {})
      }
  }
}
