## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.deployment_compartment_ocid
  target_subnet_id             = var.create_network ? one(oci_core_subnet.public_subnet[*].id) : var.deployment_subnet
  name                         = "virtual-disk-import-bastion"
  client_cidr_block_allow_list = ["0.0.0.0/0"]

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

resource "null_resource" "wait_for_bastion_plugin" {
  depends_on = [oci_bastion_bastion.bastion]

  provisioner "local-exec" {
    command     = <<EOT
      timeout 20m bash -c -- 'while true; do [ ! $(oci instance-agent plugin get --instanceagent-id $INSTANCE_ID --compartment-id $COMPARTMENT_ID --plugin-name Bastion --query "data.status || 'NO_RESPONSE'" 2>/dev/null) == "RUNNING" ] && exit 0 ; echo "Waiting for bastion plugin to become active on the instance...";sleep 20; done;'
EOT
    interpreter = ["/bin/bash", "-c"]

    environment = {
      INSTANCE_ID    = oci_core_instance.apache_airflow.id
      COMPARTMENT_ID = var.deployment_compartment_ocid
    }
  }
}

resource "oci_bastion_session" "session" {
  depends_on = [null_resource.wait_for_bastion_plugin]

  bastion_id = oci_bastion_bastion.bastion.id
  key_type   = "PUB"
  key_details {
    public_key_content = tls_private_key.bastion_key.public_key_openssh
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.apache_airflow.id
    target_resource_operating_system_user_name = "opc"
  }

  display_name           = "virtual-disk-import-session"
  session_ttl_in_seconds = 10800

  lifecycle {
    ignore_changes = [target_resource_details]
  }
}