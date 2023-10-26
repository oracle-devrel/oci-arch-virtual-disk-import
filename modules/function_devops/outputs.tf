## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


output "devops_project" {
  value = oci_devops_project.devops_project.id
}

output "functions" {
  value = {
    for k, v in oci_functions_function.function :
    v.display_name => {
      id              = v.id,
      invoke_endpoint = v.invoke_endpoint
    }
  }
}