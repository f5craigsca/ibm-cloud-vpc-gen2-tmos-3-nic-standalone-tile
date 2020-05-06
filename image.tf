
#locals {
#  image_url = "cos://${var.region}/${var.vnf_bucket_base_name}-${var.region}/${var.tmos_image_name}"
#}

# Generating random ID
#resource "random_uuid" "test" { }

#resource "ibm_is_image" "f5_custom_image" {
#  depends_on       = [random_uuid.test]
#  href             = "${local.image_url}"
#  name             = "${var.tmos_image_name}-${substr(random_uuid.test.result,0,8)}"
#  operating_system = "centos-7-amd64"
  # resource_group   = "${data.ibm_resource_group.rg.id}"

#  timeouts {
#    create = "30m"
#    delete = "10m"
#  }
#}

#data "ibm_is_image" "f5_custom_image" {
#  name       = "${var.tmos_image_name}-${substr(random_uuid.test.result,0,8)}"
#  depends_on = [ibm_is_image.f5_custom_image]
#}

# Delete custom image from the local user after VSI creation.
#data "external" "delete_custom_image" {
#  depends_on = [ibm_is_instance.f5_ve_instance]
#  program    = ["bash", "${path.module}/scripts/delete_custom_image.sh"]

#  query = {
#    custom_image_id   = "${data.ibm_is_image.f5_custom_image.id}"
#    region            = "${var.region}"
#  }
#}

#output "delete_custom_image" {
#  value = "${lookup(data.external.delete_custom_image.result, "custom_image_id")}"
#}

