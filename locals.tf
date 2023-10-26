## Copyright (c) 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  ssh_proxy_cmd_groups = regexall("\"(.+?)\"", oci_bastion_session.session.ssh_metadata["command"])
  ssh_proxy_command = (length(local.ssh_proxy_cmd_groups) == 1 ?
    local.ssh_proxy_cmd_groups[0][0] :
    ""
  )
  ssh_private_key_path = "${abspath(path.root)}/ssh_private_key"
  ssh_public_key_path  = "${abspath(path.root)}/ssh_public_key"

  defined_tags = merge(
    var.default_defined_tags,
    {
      "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release,
    }
  )
  freeform_tags = merge(var.default_freeform_tags, {})
}