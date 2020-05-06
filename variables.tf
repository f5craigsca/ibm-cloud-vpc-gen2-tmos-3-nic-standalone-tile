variable "instance_name" {
  default = "f5-ve-01"
  description = ""
}

variable "tmos_image_name" {
  default = "BIGIP-13.1.3-0.0.6.ALL_1SLOT.qcow2"
  description = "The image to be used when provisioning the F5 BIG-IP instance. To list available images, run `ibmcloud is images`."
}
variable "vnf_cos_image_name" {
  default=""
  description = "The name of the qcow2 Image name"
}
variable "vnf_bucket_base_name" {
  default = "bigip-13.1.3-0.0.6.all-1slot"
  description ="The base name of the bucket which holds the qcow2 Image, For Ex. If bucket name is bigip-13.1.3-0.0.6.all-1slot-eu-de bigip-13.1.3-0.0.6.all-1slot should be the input here, hyphen(-) and region name will be added by the script before copy"
}

variable "instance_profile" {
  default = "cx2-2x4"
  description = "The profile of compute CPU and memory resources to be used when provisioning F5 BIG-IP instance. To list available profiles, run `ibmcloud is profiles`."
}

variable "ssh_key_name" {
    default = ""
    description = "The name of the public SSH key (VPC Gen 2 SSH Key) to be used when provisioning the F5 BIG-IP instance.  To list available keys, run `ibmcloud is keys`."
}

variable "tmos_license_basekey" {
    default = ""
    description = "Base registration key for the F5 BIG-IP instance."
}

variable "tmos_admin_password" {
    default = ""
    description = "'admin' account password for the F5 BIG-IP instance."
}

variable "management_subnet_id" {
  default = ""
  description = "VPC Gen2 subnet ID for the TMOS management network.  To list available subnets, run `ibmcloud is subnets`."
}

#variable "internal_subnet_id" {
#  default = ""
#  description = "VPC Gen2 subnet ID for the TMOS internal network.  To list available subnets, run `ibmcloud is subnets`."
#}

#variable "external_subnet_id" {
#  default = ""
#  description = "VPC Gen2 subnet ID for the TMOS external (VIP) network.  To list available subnets, run `ibmcloud is subnets`."
#}



