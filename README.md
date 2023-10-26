# oci-arch-virtual-disk-import

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_oci-arch-virtual-disk-import)](https://sonarcloud.io/dashboard?id=oracle-devrel_oci-arch-virtual-disk-import)

## Introduction

As organizations continue to migrate to the cloud, they often find themselves facing the challenge of seamlessly transferring and managing their existing block volumes. Whether it's for migrating on-premises workloads, implementing disaster recovery strategies, or simply optimizing their cloud infrastructure, the ability to import virtual disks with ease becomes a critical need.

This is where the synergy of Apache Airflow, [qemu-img](https://qemu-project.gitlab.io/qemu/tools/qemu-img.html), OCI functions, OCI object storage, and event-driven architectures comes into play.

This terraform stack will deploy and configure the following resources:
- Compute Instance - running Apache Airflow.
- Object Storage Bucket - to host the virtual disk image files.
- OCI Function - to invoke execution of Apache Airflow DAG with the virtual disk image file metadata.
- OCI DevOps project - to automate the build and deployment of functions.
- OCI Events - to trigger function execution when new virtual disk images are uploaded to the bucket.
- Required IAM dynamic-groups and policies to ensure solution functionality.

The typical workflow would be as follows:
1. The user will upload a new virtual disk to the Object Storage bucket. It is possible to customize the availability domain where the Block Volume will be created using the object `ad_number` [metadata](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm#HeadersAndMetadata).
2. When the virtual disk image file upload is finalized, the event will trigger the execution of an OCI Function.
3. The function will fetch the virtual disk object metadata and call the Apache Airflow API to start DAG (Directed Acyclic Graph) execution.
4. The Apache Airflow DAG will handle the import of the virtual disk image into OCI Block Volume in 14 steps. (some optional). 

  Some of the most important steps are:
  - Create a new worker compute instance that will handle the virtual disk import.
  - Set up required tools on the new instance: `qemu-img`, `oci-cli`.
  - Download the virtual disk image from the bucket to the worker instance.
  - Determine the virtual disk image's real size using `qemu-img` and provision a new OCI Block Volume (named as the virtual disk image).
  - Attach the OCI Block Volume to the worker compute instance.
  - Write the virtual disk image content to the OCI Block Volume.
  - Run `fsck` on the OCI Block Volume.
  - Detach the OCI Block Volume.
  - Terminate the worker instance.
5. Users can monitor the DAG execution by connecting to the Apache Airflow.
 
## Prerequisite

Ensure that the user who is deploying the stack has administrative priviledges.

## Deploy

### Automated deployment

Click below button, fill-in required values and `Apply`.

[![Deploy to OCI](https://docs.oracle.com/en-us/iaas/Content/Resources/Images/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-devrel/oci-arch-virtual-disk-import/archive/refs/tags/v1.0.zip)


### Manual deployment

 **Prerequisites:** `bash`, `zip`, `unzip`, `oci` - already configured

1. Create a file named `terraform.auto.tfvars` in the root directory using below list of variables and update associated values based on your use-case:

    ```
    tenancy_ocid              = "ocid1.tenancy.oc1...7dq"
    user_ocid                 = "ocid1.user.oc1...7wa"
    private_key_path          = "/path/to/..../oci_api_key.pem"
    private_key_password      = ""
    fingerprint               = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
    region                    = "eu-frankfurt-1"

    compartment_ocid          = "ocid1.compartment.oc1...iqq"
    instance_ad               = "GqIF:EU-FRANKFURT-1-AD-1"
    instance_shape            = "VM.Standard.E4.Flex"
    instance_image            = "ocid1.image.oc1...eha"
    instance_ocpus            = 1
    instance_memory_gbs       = 16
    instance_hostname         = "apache-airflow-1"
    create_network            = true

    ssh_public_key            = "<ssh_public_key_for_apache_airflow_host>"
    assign_public_ip          = true

    apache_airflow_admin_user = "admin"
    apache_airflow_admin_pass = "" #
    oci_user_name             = "" #
    oci_user_authtoken        = "" #
    ```

2. Execute `terraform init`
3. Execute `terraform plan`
4. Execute `terraform apply`

## Notes/Issues
* In case of errors, the DAG execution will not be retried automatically (users can check the logs and issue manual retries from Apache Airflow console).
* Only virtual disk images supported by `qemu-img` can be imported using this solution.
* Object Storage Bucket can't be destroyed if it's not empty. Before executing `terraform destroy` ensure that the bucket has no file.

## URLs
* [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/index.html)
* [qemu-img](https://qemu-project.gitlab.io/qemu/tools/qemu-img.html)
* [OCI Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)
* [OCI Block Storage](https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/overview.htm)


## Contributing
This project is open source. Please submit your contributions by forking this repository and submitting a pull request! Oracle appreciates any contributions that are made by the open-source community.

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 
