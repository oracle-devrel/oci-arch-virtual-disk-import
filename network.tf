## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "vcn" {
  count = var.create_network == true ? 1 : 0

  cidr_block     = var.vcn_CIDR
  dns_label      = "vcn"
  compartment_id = var.deployment_compartment_ocid
  display_name   = var.vcn_display_name

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_nat_gateway" "ngw" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  display_name   = "${var.vcn_display_name}-ngw"
  vcn_id         = oci_core_virtual_network.vcn[0].id

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}


resource "oci_core_service_gateway" "sgw" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  display_name   = "${var.vcn_display_name}-sgw"
  vcn_id         = oci_core_virtual_network.vcn[0].id

  services {
    service_id = data.oci_core_services.all_region_services.services[0].id
  }

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_internet_gateway" "igw" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  display_name   = "${var.vcn_display_name}-igw"
  vcn_id         = oci_core_virtual_network.vcn[0].id

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_route_table" "private_subnet_RT" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "private_subnet_RT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.ngw[0].id
  }

  route_rules {
    destination       = data.oci_core_services.all_region_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw[0].id
  }

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}


resource "oci_core_route_table" "public_subnet_RT" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "private_subnet_RT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[0].id
  }

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_dhcp_options" "dhcp_options" {
  count = var.create_network == true ? 1 : 0

  compartment_id = var.deployment_compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn[0].id
  display_name   = "dhcp_options"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_subnet" "public_subnet" {
  count = var.create_network == true ? 1 : 0

  cidr_block                 = var.public_subnet_CIDR
  display_name               = "${var.vcn_display_name}-public-subnet"
  dns_label                  = "public"
  compartment_id             = var.deployment_compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn[0].id
  route_table_id             = oci_core_route_table.public_subnet_RT[0].id
  dhcp_options_id            = oci_core_dhcp_options.dhcp_options[0].id
  security_list_ids          = [oci_core_virtual_network.vcn[0].default_security_list_id]
  prohibit_public_ip_on_vnic = false
  defined_tags               = local.defined_tags
  freeform_tags              = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_subnet" "private_subnet" {
  count = var.create_network == true ? 1 : 0

  cidr_block                 = var.private_subnet_CIDR
  display_name               = "${var.vcn_display_name}-private-subnet"
  dns_label                  = "private"
  compartment_id             = var.deployment_compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn[0].id
  route_table_id             = oci_core_route_table.private_subnet_RT[0].id
  dhcp_options_id            = oci_core_dhcp_options.dhcp_options[0].id
  security_list_ids          = [oci_core_virtual_network.vcn[0].default_security_list_id]
  prohibit_public_ip_on_vnic = true
  defined_tags               = local.defined_tags
  freeform_tags              = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_network_security_group" "network_security_group" {

  compartment_id = var.deployment_compartment_ocid
  vcn_id         = var.create_network ? oci_core_virtual_network.vcn[0].id : var.deployment_vcn

  display_name = "${var.vcn_display_name}-nsg"

  defined_tags  = local.defined_tags
  freeform_tags = local.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_ingress" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "all"

  description = "allow ingress from VCN CIDR"
  source      = var.create_network ? var.vcn_CIDR : data.oci_core_vcn.deployment_vcn[0].cidr_blocks[0]
  source_type = "CIDR_BLOCK"
  stateless   = false
}

resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_ingress_public_ip" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "6"

  description = "allow ingress to 8080"
  source      = var.allowed_source_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      max = 8080
      min = 8080
    }
  }
}

resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_egress" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "EGRESS"
  protocol                  = "all"

  description      = "allow ingress from VCN CIDR"
  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false
}