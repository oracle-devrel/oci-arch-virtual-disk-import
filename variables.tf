## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "region" {}

variable "tenancy_ocid" {}
# variable "compartment_ocid" {default=""}
# variable "user_ocid" {}
# variable "fingerprint" {}
# variable "private_key_path" {}

variable "release" {
  default = "v1.0"
}

variable "default_freeform_tags" {
  type        = map(string)
  default     = {}
  description = "Default map(string) with freeform tags to add to all the resources."
}
variable "default_defined_tags" {
  type        = map(string)
  default     = {}
  description = "Default map(string) with defined tags to add to all the resources. Ensure that the referenced tag namespace is created."
}

variable "deployment_compartment_ocid" {
  description = "Compartment OCID where all the resources will be created."
}

# Apache Airflow instance variables
variable "instance_ad" {
  description = "Availability Domain where to deploy the server."
}
variable "instance_shape" {
  description = "Compute shape for the Apache Airflow server."
}
variable "instance_image" {
  description = "OS image to use for the Apache Airflow server. It's strongly recommended to go with Oracle Linux 8.x."
}
variable "instance_bootv_size_gbs" {
  description = "Apache Airflow server boot volume size in GBs."
  type        = number
  default     = 50
}
variable "instance_ocpus" {
  description = "Number of OCPUs for the Apache Airflow server."
  type        = number
  default     = 1
}
variable "instance_memory_gbs" {
  description = "Amount of RAM in GBs for the Apache Airflow server."
  type        = number
  default     = 8
}
variable "instance_hostname" {
  description = "Hostname for the Apache Airflow server."
  default     = "apache-airflow-1"
}
variable "assign_public_ip" {
  description = "Either to assign public IP or not to the Apache Airflow server."
  default     = false
  type        = bool
}
variable "deployment_vcn" {
  description = "OCID of the VCN to use for the deployment."
  default     = ""
}
variable "deployment_subnet" {
  description = "OCID of the subnet to use for the deployment."
  default     = ""
}
variable "ssh_public_key" {
  description = "SSH Public key for the Apache Airflow server."
}
variable "block_vol_backup_policy_id" {
  description = "OCID of the backup policy to configure on new created block volumes."
  default     = ""
}

variable "bucket_name" {
  default     = "block-volume-import-bucket"
  description = "Name of the bucket where the virtual image disk files will be uploaded."
}
variable "enable_bucket_cleanup" {
  default     = false
  description = "Automatically delete files uploaded to the bucket after 7 days."
}

variable "create_required_policies" {
  default = true
}

variable "apache_airflow_admin_user" {
  type        = string
  description = "Apache Airflow administrative user."
  default     = "admin"
}

variable "apache_airflow_admin_pass" {
  type        = string
  description = "Apache Airflow administrative password."
  default     = ""

  validation {
    condition     = length(var.apache_airflow_admin_pass) >= 8
    error_message = "Password lenght must be at least 8 characters."
  }
}

variable "create_network" {
  type        = bool
  description = "Create new VCN for this deployment?"
  default     = false
}

variable "vcn_display_name" {
  type        = string
  description = "The display name of the new VCN."
  default     = "apache-airflow-vcn"
}

variable "vcn_CIDR" {
  type        = string
  description = "The CIDR block of the new VCN."
  default     = "10.0.0.0/16"
}

variable "public_subnet_CIDR" {
  type        = string
  description = "CIDR block of the new public subnet."
  default     = "10.0.0.0/24"
}

variable "private_subnet_CIDR" {
  type        = string
  description = "CIDR block of the new private subnet."
  default     = "10.0.1.0/24"
}

variable "devops_project_name" {
  default     = "virtual-disk-import-devops-project"
  description = "Name of the DevOps project"
}
variable "oci_user_name" {
  default     = ""
  description = "Username for OCI DevOps HTTPS authentication: https://docs.oracle.com/en-us/iaas/Content/devops/using/https_auth.htm"

  validation {
    condition     = length(var.oci_user_name) > 0
    error_message = "OCI User name is required to push function code to OCI DevOps code repo."
  }
}

variable "oci_user_authtoken" {
  default     = ""
  description = "Authentication token for the username: https://docs.oracle.com/en-us/iaas/Content/devops/using/getting_started.htm#authtoken"

  validation {
    condition     = length(var.oci_user_authtoken) > 0
    error_message = "OCI Auth Token is required to push function code to OCI DevOps code repo."
  }
}

variable "allowed_source_cidr" {
  default     = "0.0.0.0/0"
  description = "CIDR block allowed to connect to the Apache Airflow administrative console."
}