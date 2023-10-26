## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 1.2"
  required_providers {
    oci = {
      source                = "hashicorp/oci"
      configuration_aliases = [oci.home]
    }
  }
}

provider "oci" {
  alias  = "home"
  region = lookup(data.oci_identity_regions.home_region.regions[0], "name")

  tenancy_ocid = var.tenancy_ocid
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}

provider "oci" {
  region = var.region

  tenancy_ocid = var.tenancy_ocid
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}
