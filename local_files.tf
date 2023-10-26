## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "local_file" "public_key" {
  content         = tls_private_key.bastion_key.public_key_openssh
  filename        = local.ssh_public_key_path
  file_permission = "0400"
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.bastion_key.private_key_openssh
  filename        = local.ssh_private_key_path
  file_permission = "0400"
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.root}/ansible_playbooks/inventory.ini"
}