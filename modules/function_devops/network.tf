## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "vcn" {
  count = var.fnsubnet_OCID == "" && length(local.applications) > 0 ? 1 : 0

  cidr_block     = var.vcn_CIDR
  dns_label      = "vcn"
  compartment_id = var.compartment_ocid
  display_name   = "vcn"

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_nat_gateway" "ngw" {
  count = var.fnsubnet_OCID == "" && length(local.applications) > 0 ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "ngw"
  vcn_id         = oci_core_virtual_network.vcn[0].id

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}


resource "oci_core_route_table" "rt_via_ngw" {
  count = var.fnsubnet_OCID == "" && length(local.applications) > 0 ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "rt_via_ngw"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.ngw[0].id
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_dhcp_options" "dhcp_options" {
  count = var.fnsubnet_OCID == "" && length(local.applications) > 0 ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "dhcp_options"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_subnet" "fnsubnet" {
  count = var.fnsubnet_OCID == "" && length(local.applications) > 0 ? 1 : 0

  cidr_block                 = var.fnsubnet_CIDR
  display_name               = "fnsubnet"
  dns_label                  = "fnsub"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn[0].id
  route_table_id             = oci_core_route_table.rt_via_ngw[0].id
  dhcp_options_id            = oci_core_dhcp_options.dhcp_options[0].id
  security_list_ids          = [oci_core_virtual_network.vcn[0].default_security_list_id]
  prohibit_public_ip_on_vnic = true
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

