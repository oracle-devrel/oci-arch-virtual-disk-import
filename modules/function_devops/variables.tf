## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


## Provider variables

variable "tenancy_ocid" {}
# variable "user_ocid" {}
# variable "fingerprint" {}
# variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}


## ORM Schema visual control variables
variable "show_advanced" {
  default = false
}

## Tagging

variable "defined_tags" {
  default     = null
  type        = map(string)
  description = "Map of string with defined tags to attach to all the resources."
}

variable "freeform_tags" {
  default = {
    created_via = "terraform"
  }
  type        = map(string)
  description = "Map of string with the freeform tags to attach to all the resources."
}


## DevOps project

variable "devops_project_name" {
  default     = "devops-project"
  description = "Name of the devops project."
}

variable "devops_external_connections" {
  type = map(object({
    access_token = string
    display_name = string
  }))
  default = {}
}

variable "applications" {
  type = map(any)
}

variable "functions" {
  type = map(any)
  default = {}
}

## Networking

variable "fnsubnet_OCID" {
  default     = ""
  description = "existing subnet OCID. If empty, a new VCN will be created."
}

variable "vcn_CIDR" {
  default = "10.0.0.0/16"
}

variable "vcn_display_name" {
  default = ""
}
variable "fnsubnet_CIDR" {
  default = "10.0.1.0/24"
}

variable "project_logging_config_retention_period_in_days" {
  default = 30
}

# Create Dynamic Group and Policies
variable "create_devops_policies" {
  default = false
}

variable "create_functions_policies" {
  default = false
}

variable "create_functions_resource_principal_policies" {
  default = false
}

variable "oci_user_name" {
  default = ""
}

variable "oci_user_authtoken" {
  default = ""
}