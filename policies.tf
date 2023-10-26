## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "apache-airflow-dg" {
  count = var.create_required_policies ? 1 : 0

  provider = oci.home

  name           = "apache-airflow-dg-${random_id.tag.hex}"
  description    = "Dynamic group for virtual disk import instances."
  compartment_id = var.tenancy_ocid
  matching_rule  = "All {instance.compartment.id = '${var.deployment_compartment_ocid}', tag.${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterRole.name}.value='worker'}"

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

resource "oci_identity_policy" "apache-airflow-policies" {
  count = var.create_required_policies ? 1 : 0

  provider       = oci.home
  name           = "apache-airflow-policies-${random_id.tag.hex}"
  description    = "Policies to allow virtual disk import instances to interact with OCI API."
  compartment_id = var.deployment_compartment_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.apache-airflow-dg[0].name} to manage instance-family in compartment id ${var.deployment_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.apache-airflow-dg[0].name} to manage volume-family in compartment id ${var.deployment_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.apache-airflow-dg[0].name} to use virtual-network-family in compartment id ${var.deployment_compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.apache-airflow-dg[0].name} to read object-family in compartment id ${var.deployment_compartment_ocid}"
  ]

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}