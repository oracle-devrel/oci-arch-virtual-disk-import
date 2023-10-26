module "devops" {
  source                                       = "./modules/function_devops"
  providers                                    = { oci.home = oci.home }
  region                                       = var.region
  compartment_ocid                             = var.deployment_compartment_ocid
  tenancy_ocid                                 = var.tenancy_ocid
  defined_tags                                 = local.defined_tags
  freeform_tags                                = local.freeform_tags
  devops_project_name                          = var.devops_project_name
  oci_user_name                                = var.oci_user_name
  oci_user_authtoken                           = var.oci_user_authtoken
  create_devops_policies                       = var.create_required_policies
  create_functions_policies                    = var.create_required_policies
  create_functions_resource_principal_policies = var.create_required_policies
  applications = {
    apache-airflow-trigger-app = {
      application_name = "apache-airflow-trigger-app"
      nsg_ids          = [oci_core_network_security_group.network_security_group.id]
      subnet_ocids     = [var.create_network == true ? one(oci_core_subnet.private_subnet[*].id) : var.deployment_subnet]
    }
  }

  functions = {
    "apache-airflow-trigger-fn" = {
      function_name     = "apache-airflow-trigger-fn"
      application_name  = "apache-airflow-trigger-app"
      default_branch    = "main"
      repository_type   = "HOSTED"
      function_code_zip = "fn-apache-airflow-trigger.zip"
      env_variables = {
        "AIRFLOW_PASSWORD"     = var.apache_airflow_admin_pass
        "AIRFLOW_USERNAME"     = var.apache_airflow_admin_user
        "AIRFLOW_API_ENDPOINT" = "http://${oci_core_instance.apache_airflow.private_ip}:8080/api/v1"
        "AIRFLOW_DAG_ID"       = "1_virtual_disk_to_oci_block_volume"
      }
    }
  }
}