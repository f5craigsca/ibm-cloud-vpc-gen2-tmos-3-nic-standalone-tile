#data "ibm_is_image" "tmos_image" {
#    name = var.tmos_image_name
#}

locals {
  image_url = "cos://${var.region}/${var.vnf_bucket_base_name}-${var.region}/${var.tmos_image_name}"
}

# Generating random ID
resource "random_uuid" "test" { }

resource "ibm_is_image" "f5_custom_image" {
  depends_on       = [random_uuid.test]
  href             = local.image_url
  #name             = "${var.tmos_image_name}-${substr(random_uuid.test.result,0,4)}"
  name             = lower(replace(replace("${var.tmos_image_name}-${substr(random_uuid.test.result,0,4)}",".","-"),"_","-"))
  operating_system = "centos-7-amd64"
  # resource_group   = "${data.ibm_resource_group.rg.id}"

  timeouts {
    create = "30m"
    delete = "10m"
  }
}

data "ibm_is_image" "f5_custom_image" {
  #name       = "${var.tmos_image_name}-${substr(random_uuid.test.result,0,4)}"
  name = lower(replace(replace("${var.tmos_image_name}-${substr(random_uuid.test.result,0,4)}",".","-"),"_","-"))
  depends_on = [ibm_is_image.f5_custom_image]
}

# Delete custom image from the local user after VSI creation.
data "external" "delete_custom_image" {
  depends_on = [ibm_is_instance.f5_ve_instance]
  program    = ["bash", "${path.module}/scripts/delete_custom_image.sh"]

  query = {
    custom_image_id   = "${data.ibm_is_image.f5_custom_image.id}"
    region            = "${var.region}"
  }
}
data "ibm_is_subnet" "f5_management" {
  identifier = var.management_subnet_id
}

#data "ibm_is_subnet" "f5_internal" {
#  identifier = var.internal_subnet_id
#}

#data "ibm_is_subnet" "f5_external" {
#  identifier = var.external_subnet_id
#}

data "ibm_is_ssh_key" "f5_ssh_pub_key" {
  name = var.ssh_key_name
}

data "ibm_is_instance_profile" "instance_profile" {
  name = var.instance_profile
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.yaml")}"
  vars = {
    tmos_admin_password = var.tmos_admin_password
    tmos_license_basekey = var.tmos_license_basekey
  }
}

# create F5 control plane firewalling
# https://support.f5.com/csp/article/K46122561
resource "ibm_is_security_group" "f5_management_sg" {
  name = "f5-management-sg"
  vpc  = data.ibm_is_subnet.f5_management.vpc
}

resource "ibm_is_security_group_rule" "f5_management_in_icmp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "f5_management_in_ssh" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}
resource "ibm_is_security_group_rule" "f5_management_in_https" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  tcp {
    port_min = 443
    port_max = 443
  }
}
resource "ibm_is_security_group_rule" "f5_management_in_snmp_tcp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  tcp {
    port_min = 161
    port_max = 161
  }
}
resource "ibm_is_security_group_rule" "f5_management_in_snmp_udp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  udp {
    port_min = 161
    port_max = 161
  }
}
resource "ibm_is_security_group_rule" "f5_management_in_ha" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  udp {
    port_min = 1026
    port_max = 1026
  }
}

resource "ibm_is_security_group_rule" "f5_management_in_iquery" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  tcp {
    port_min = 4353
    port_max = 4353
  }
}

resource "ibm_is_security_group_rule" "f5_management_in_8443" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "inbound"
  tcp {
    port_min = 8443
    port_max = 8443
  }
}

// allow all outbound on control plane
// all TCP
resource "ibm_is_security_group_rule" "f5_management_out_tcp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "outbound"
  tcp {
    port_min = 1
    port_max = 65535
  }
}

// all outbound UDP
resource "ibm_is_security_group_rule" "f5_management_out_udp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "outbound"
  udp {
    port_min = 1
    port_max = 65535
  }
}

// all ICMP
resource "ibm_is_security_group_rule" "f5_management_out_icmp" {
  group     = ibm_is_security_group.f5_management_sg.id
  direction = "outbound"
  icmp {
    type = 0
  }
}

// allow all traffic to data plane interfaces
// TMM is the firewall
#resource "ibm_is_security_group" "f5_tmm_sg" {
#  name = "f5-tmm-sg"
#  vpc  = data.ibm_is_subnet.f5_management.vpc
#}

// all TCP
#resource "ibm_is_security_group_rule" "f5_tmm_in_tcp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "inbound"
#  tcp {
#    port_min = 1
#    port_max = 65535
#  }
#}

#resource "ibm_is_security_group_rule" "f5_tmm_out_tcp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "outbound"
#  tcp {
#    port_min = 1
#    port_max = 65535
#  }
#}

// all UDP
#resource "ibm_is_security_group_rule" "f5_tmm_in_udp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "inbound"
#  udp {
#    port_min = 1
#    port_max = 65535
#  }
#}

#resource "ibm_is_security_group_rule" "f5_tmm_out_udp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "outbound"
#  udp {
#    port_min = 1
#    port_max = 65535
#  }
#}

// all ICMP
#resource "ibm_is_security_group_rule" "f5_tmm_in_icmp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "inbound"
#  icmp {
#    type = 8
#  }
#}

#resource "ibm_is_security_group_rule" "f5_tmm_out_icmp" {
#  group     = ibm_is_security_group.f5_tmm_sg.id
#  direction = "outbound"
#  icmp {
#    type = 0
#  }
#}

resource "ibm_is_instance" "f5_ve_instance" {
  name    = var.instance_name
  #image   = data.ibm_is_image.tmos_image.id
  image   = ibm_is_image.f5_custom_image.id
  profile = data.ibm_is_instance_profile.instance_profile.id
  primary_network_interface {
    name            = "management"
    subnet          = data.ibm_is_subnet.f5_management.id
    security_groups = [ibm_is_security_group.f5_management_sg.id]
  }
  #network_interfaces {
  #  name            = "tmm-1-1-internal"
  #  subnet          = data.ibm_is_subnet.f5_internal.id
  #  security_groups = [ibm_is_security_group.f5_tmm_sg.id]
  #}
  #network_interfaces {
  #  name            = "tmm-1-2-external"
  #  subnet          = data.ibm_is_subnet.f5_external.id
  #  security_groups = [ibm_is_security_group.f5_tmm_sg.id]
  #}
  vpc  = data.ibm_is_subnet.f5_management.vpc
  zone = data.ibm_is_subnet.f5_management.zone
  keys = [data.ibm_is_ssh_key.f5_ssh_pub_key.id]
  user_data = data.template_file.user_data.rendered
}

# create floating IPs
resource "ibm_is_floating_ip" "f5_management_floating_ip" {
  name   = "management-floating-ip"
  target = ibm_is_instance.f5_ve_instance.primary_network_interface.0.id
}

#resource "ibm_is_floating_ip" "f5_external_floating_ip" {
#  name   = "external-floating-ip"
#  target = ibm_is_instance.f5_ve_instance.network_interfaces.1.id
#  depends_on = [ibm_is_instance.f5_ve_instance, ibm_is_floating_ip.f5_management_floating_ip]
#}
