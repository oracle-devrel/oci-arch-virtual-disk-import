## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_events_rule" "trigger-apache-airflow" {
  actions {
    actions {
      action_type = "FAAS"
      is_enabled  = true
      function_id = module.devops.functions["apache-airflow-trigger-fn"].id
    }
  }
  compartment_id = var.deployment_compartment_ocid
  condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\"],\"data\":{\"additionalDetails\":{\"bucketName\":[\"${oci_objectstorage_bucket.volumes_bucket.name}\"]}}}"
  display_name   = "trigger-apache-airflow"
  description    = "Rule to trigger apache airflow for conversion of disk file to OCI block volume."

  is_enabled = true

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}