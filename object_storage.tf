## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_objectstorage_bucket" "volumes_bucket" {

  compartment_id = var.deployment_compartment_ocid
  name           = var.bucket_name
  namespace      = lookup(data.oci_objectstorage_namespace.os_namespace, "namespace")

  access_type           = "NoPublicAccess"
  auto_tiering          = "Disabled"
  defined_tags          = local.defined_tags
  freeform_tags         = local.freeform_tags
  object_events_enabled = true
  storage_tier          = "Standard"

  dynamic "retention_rules" {
    for_each = var.enable_bucket_cleanup ? [0] : []
    content {
      display_name = "cleanup-in-7-days"
      duration {
        #Required
        time_amount = 7
        time_unit   = "DAYS"
      }
      time_rule_locked = false
    }
  }
  versioning = "Disabled"

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}