## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_instance" "apache_airflow" {

  availability_domain = var.instance_ad
  compartment_id      = var.deployment_compartment_ocid
  shape               = var.instance_shape

  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
  }

  create_vnic_details {
    assign_public_ip = (  var.create_network ? 
                            var.assign_public_ip : 
                            false
    )
    freeform_tags    = local.freeform_tags
    defined_tags     = local.defined_tags
    hostname_label   = var.instance_hostname
    subnet_id        = (  var.create_network ? 
                            ( var.assign_public_ip ?
                              one(oci_core_subnet.public_subnet[*].id) : 
                              one(oci_core_subnet.private_subnet[*].id)
                            ) :
                            var.deployment_subnet 
    )
    nsg_ids          = [oci_core_network_security_group.network_security_group.id]
  }

  display_name = var.instance_hostname

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  shape_config {
    memory_in_gbs = var.instance_memory_gbs
    ocpus         = var.instance_ocpus
  }

  source_details {
    source_id   = var.instance_image
    source_type = "image"
  }

  preserve_boot_volume = false

  freeform_tags = local.freeform_tags
  defined_tags  = merge(local.defined_tags, {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterRole.name}" = "worker"})

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"],
      create_vnic_details[0].defined_tags["Oracle-Tags.CreatedBy"], create_vnic_details[0].defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

resource "null_resource" "archive_ansible_playbooks" {

  depends_on = [oci_bastion_session.session, local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "rm -rf ansible_playbooks.zip"
  }

  provisioner "local-exec" {
    command = "zip -r ansible_playbooks.zip \"${path.module}\"/ansible_playbooks"
  }
}

resource "null_resource" "copy_ansible_playbooks" {

  depends_on = [null_resource.archive_ansible_playbooks]
  connection {
    type                = "ssh"
    user                = regex("(\\S+)@(\\S+\\.oraclecloud\\.com).+?(\\S+)@([\\d.]+)", oci_bastion_session.session.ssh_metadata["command"])[2]
    host                = regex("(\\S+)@(\\S+\\.oraclecloud\\.com).+?(\\S+)@([\\d.]+)", oci_bastion_session.session.ssh_metadata["command"])[3]
    private_key         = tls_private_key.bastion_key.private_key_openssh
    bastion_user        = regex("(\\S+)@(\\S+\\.oraclecloud\\.com).+?(\\S+)@([\\d.]+)", oci_bastion_session.session.ssh_metadata["command"])[0]
    bastion_host        = regex("(\\S+)@(\\S+\\.oraclecloud\\.com).+?(\\S+)@([\\d.]+)", oci_bastion_session.session.ssh_metadata["command"])[1]
    bastion_private_key = tls_private_key.bastion_key.private_key_openssh
  }

  provisioner "file" {
    source      = "ansible_playbooks.zip"
    destination = "/home/opc/ansible_playbooks.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python39-pip python39",
      "sudo update-alternatives  --set python3 /usr/bin/python3.9",
      "sudo update-alternatives  --set python /usr/bin/python3.9",
      "sudo pip3 install ansible docker docker-compose",
      "unzip -o ansible_playbooks.zip",
      "cd ansible_playbooks && ansible-playbook -i inventory.ini aa_play.yml"
    ]
  }
}