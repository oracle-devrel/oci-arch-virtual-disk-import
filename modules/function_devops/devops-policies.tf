# ## Copyright (c) 2023, Oracle and/or its affiliates.
# ## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "devopsdynamicgroup" {
  count = var.create_devops_policies ? 1 : 0

  provider       = oci.home
  compartment_id = var.tenancy_ocid
  name           = "${var.devops_project_name}-devops-dg"
  description    = "${var.devops_project_name} DevOps Dynamic Group"
  matching_rule  = "ALL {Any {resource.type = 'devopsdeploypipeline', resource.type = 'devopsrepository', resource.type = 'devopsbuildpipeline', resource.type = 'devopsconnection'}, resource.compartment.id = '${var.compartment_ocid}'}"

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "oci_identity_policy" "devops_policies" {
  count = var.create_devops_policies ? 1 : 0

  provider       = oci.home
  name           = "${var.devops_project_name}-devops-policies"
  description    = "${var.devops_project_name} DevOps Policies"
  compartment_id = var.compartment_ocid

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to manage fn-function in compartment ${data.oci_identity_compartment.work_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to read fn-app in compartment ${data.oci_identity_compartment.work_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to use repos in compartment ${data.oci_identity_compartment.work_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to use ons-topics in compartment ${data.oci_identity_compartment.work_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to read secret-family in compartment ${data.oci_identity_compartment.work_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.devopsdynamicgroup[0].name} to manage devops-family in compartment ${data.oci_identity_compartment.work_compartment.name}"
  ]
  provisioner "local-exec" {
    command = "sleep 5"
  }
}