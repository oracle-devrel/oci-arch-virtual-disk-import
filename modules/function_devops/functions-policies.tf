## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Functions Policies

resource "oci_identity_policy" "faas_read_repos_tenancy_policy" {
  count = var.create_functions_policies ? 1 : 0

  provider = oci.home

  name           = "faas-read-repos-tenancy-policy"
  description    = "faas-read-repos-tenancy-policy"
  compartment_id = var.tenancy_ocid

  statements = ["Allow service FaaS to read repos in tenancy"]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_identity_policy" "faas_use_vcn_family_policy" {
  count = var.create_functions_policies ? 1 : 0

  provider = oci.home

  name           = "faas-use-vcn-family-policy"
  description    = "faas-use-vcn-family-policy"
  compartment_id = var.tenancy_ocid
  statements     = ["Allow service FaaS to use virtual-network-family in compartment id ${var.compartment_ocid}"]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

## Required if functions must authN as resource principals

resource "oci_identity_dynamic_group" "faas_dg" {
  count = var.create_functions_resource_principal_policies ? 1 : 0

  provider    = oci.home
  name        = "faas-dg"
  description = "faas-dg"

  compartment_id = var.tenancy_ocid
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "oci_identity_policy" "faas_dg_policy" {
  count = var.create_functions_resource_principal_policies ? 1 : 0

  provider = oci.home

  name           = "faas-dg-policy"
  description    = "faas-dg-policy"
  compartment_id = var.compartment_ocid
  statements     = ["allow dynamic-group ${oci_identity_dynamic_group.faas_dg[0].name} to read object-family in compartment id ${var.compartment_ocid}"]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}
