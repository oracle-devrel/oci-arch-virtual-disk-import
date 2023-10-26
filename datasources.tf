## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_tenancy" "tenant_details" {

  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "home_region" {

  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}

data "oci_identity_regions" "current_region" {

  filter {
    name   = "name"
    values = [var.region]
  }
}

data "oci_core_services" "all_region_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_core_vcn" "deployment_vcn" {
  count = var.create_network ? 0 : 1

  vcn_id = var.deployment_vcn
}


data "oci_objectstorage_namespace" "os_namespace" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ansible_inventory" {
  template = file("${path.root}/templates/inventory.ini.tpl")
  vars = {
    instance_hostname         = "${oci_core_instance.apache_airflow.display_name}"
    instance_private_ip       = "${oci_core_instance.apache_airflow.private_ip}"
    ssh_private_key_path      = local.ssh_private_key_path
    ssh_proxy_command         = replace(local.ssh_proxy_command, "<privateKey>", local.ssh_private_key_path)
    apache_airflow_admin_user = var.apache_airflow_admin_user
    apache_airflow_admin_pass = var.apache_airflow_admin_pass
    compartment_id            = var.deployment_compartment_ocid
    subnet_id                 = var.create_network ? one(oci_core_subnet.private_subnet[*].id) : var.deployment_subnet
    instance_shape            = var.instance_shape
    instance_ocpus            = 1
    instance_memory_in_gbs    = 8
    instance_image_id         = var.instance_image
    backup_policy_id          = var.block_vol_backup_policy_id
    ssh_pub_key               = base64encode(tls_private_key.bastion_key.public_key_openssh)
    ssh_priv_key              = base64encode(tls_private_key.bastion_key.private_key_openssh)
    cloud_init                = base64encode(file("${path.root}/utils/cloud-init_ol.sh"))
    ansible_user              = "opc"
    ansible_connection        = "local"
    defined_tag_key           = "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterRole.name}"
    defined_tag_value         = "worker"
  }
}
