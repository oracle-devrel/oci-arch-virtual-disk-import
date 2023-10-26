## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_devops_connection" "external_connection" {
  for_each = var.devops_external_connections

  project_id = oci_devops_project.devops_project.id

  connection_type = "GITHUB_ACCESS_TOKEN"
  access_token    = each.value.access_token

  display_name = each.value.display_name

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_devops_repository" "repo" {
  for_each = local.functions

  name            = each.value.function_name
  project_id      = oci_devops_project.devops_project.id
  repository_type = each.value.repository_type

  #Optional
  default_branch = each.value.default_branch
  description    = "${each.value.function_name} function code repository"

  dynamic "mirror_repository_config" {
    for_each = each.value.repository_type == "MIRRORED" ? [0] : []
    content {
      connector_id   = oci_devops_connection.external_connection[each.value.external_connection].id
      repository_url = each.value.repository_url
      trigger_schedule {
        schedule_type   = each.value.trigger_schedule_type
        custom_schedule = each.value.trigger_schedule_type == "CUSTOM" ? each.value.trigger_custom_schedule : null
      }
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"], default_branch]
  }

  provisioner "local-exec" {
    # wait for the mirror to finalize
    command = each.value.repository_type == "MIRRORED" ? "sleep 120" : "echo HOSTED repo"
  }
}

resource "null_resource" "push_code" {
  for_each = { for k, v in local.functions : k => v if alltrue([v.function_code_zip != "", v.repository_type == "HOSTED"]) }

  provisioner "local-exec" {
    command = <<-EOT
      echo "remove existing repo";
      rm -rf '${abspath(path.root)}/function_code/${each.value.function_name}';
      mkdir -p '${abspath(path.root)}/function_code/${each.value.function_name}';
      echo '(3) Starting git clone command... '; echo 'Username: Before' ${var.oci_user_name}; echo 'Username: After' ${local.encode_user}; echo 'auth_token' ${local.auth_token}; git clone https://${local.encode_user}:${local.auth_token}@devops.scmservice.${var.region}.oci.oraclecloud.com/namespaces/${local.ocir_namespace}/projects/${oci_devops_project.devops_project.name}/repositories/${oci_devops_repository.repo[each.key].name} '${abspath(path.root)}/function_code/${each.value.function_name}';
      unzip -o '${abspath(path.root)}/${each.value.function_code_zip}' -d '${abspath(path.root)}/function_code/${each.value.function_name}';
      cd '${abspath(path.root)}/function_code/${each.value.function_name}/'; git config --global user.email 'test@example.com'; git config --global user.name '${var.oci_user_name}';git add .; git commit -m 'added latest files'; git push origin '${each.value.default_branch}'
EOT
  }
}

locals {
  encode_user = urlencode(var.oci_user_name)
  auth_token  = urlencode(var.oci_user_authtoken)
}