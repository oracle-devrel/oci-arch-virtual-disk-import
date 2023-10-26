## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "private_key_bastion" {
  sensitive = true
  value     = tls_private_key.bastion_key.private_key_openssh
}

output "apache_airflow_instance_hostname" {
  value       = oci_core_instance.apache_airflow.display_name
  description = <<-EOT
  The hostname of the instance running Apache Airflow application.
  EOT  
}

output "apache_airflow_instance_private_ip" {
  value       = oci_core_instance.apache_airflow.private_ip
  description = <<-EOT
  The private IP address of the instance running Apache Airflow application.
  EOT  
}

output "apache_airflow_instance_public_ip" {
  value       = var.assign_public_ip && var.create_network ? oci_core_instance.apache_airflow.public_ip : "n/a"
  description = <<-EOT
  The public IP address of the instance running Apache Airflow application.
  EOT  
}

output "ssh_to_airflow_host_over_bastion_session" {
  value       = oci_bastion_session.session.ssh_metadata["command"]
  description = <<-EOT
  The Bastion session terminates automatically in 3 hours after creation.
  For required private_key check private_key_bastion output or execute: `terraform output private_key_bastion`
  EOT
}