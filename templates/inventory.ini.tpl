[airflow]
${instance_hostname} ansible_host=127.0.0.1 #${instance_private_ip}

[airflow:vars]
apache_airflow_admin_user="${apache_airflow_admin_user}"
apache_airflow_admin_pass="${apache_airflow_admin_pass}"
compartment_id="${compartment_id}"
subnet_id="${subnet_id}"
instance_shape="${instance_shape}"
instance_ocpus="${instance_ocpus}"
instance_memory_in_gbs="${instance_memory_in_gbs}"
instance_image_id="${instance_image_id}"
backup_policy_id="${backup_policy_id}"
ssh_pub_key="${ssh_pub_key}"
ssh_priv_key="${ssh_priv_key}"
cloud_init="${cloud_init}"
defined_tag_key="${defined_tag_key}"
defined_tag_value="${defined_tag_value}"

[all:vars]
ansible_connection=${ansible_connection}
ansible_ssh_private_key_file="${ssh_private_key_path}"
ansible_user="${ansible_user}"
ansible_port=22
ansible_python_interpreter="/usr/bin/python3"

# Below can be commented out if no bastion host is used.
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="${ssh_proxy_command}"'