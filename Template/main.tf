data "ibm_resource_group" "group" {
  name = "${var.resource_group}"
}

resource "ibm_is_ssh_key" "sshkeyjenkins" {
  name       = "keysshforjenkins"
  public_key = "${var.ssh_public}"
}

resource "ibm_is_vpc" "vpcforjenkins" {
  name = "vpcdemoforjenkins"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_is_subnet" "subnetjenkins" {
  name            = "subnetforvpc"
  vpc             = "${ibm_is_vpc.vpcforjenkins.id}"
  zone            = "us-south-1"
  total_ipv4_address_count= "256"
}

resource "ibm_is_security_group" "securitygroupforjenkins" {
  name = "securitygroupforvpc"
  vpc  = "${ibm_is_vpc.vpcforjenkins.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}


resource "ibm_is_instance" "vsiforjenkins" {
  name    = "instanceforvpc"
  image   = "r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  profile = "bx2-2x8"
  resource_group = "${data.ibm_resource_group.group.id}"


  primary_network_interface {
    subnet = "${ibm_is_subnet.subnetjenkins.id}"
    security_groups = ["${ibm_is_security_group.securitygroupforjenkins.id}"]
  }

  vpc       = "${ibm_is_vpc.vpcforjenkins.id}"
  zone      = "us-south-1"
  keys = ["${ibm_is_ssh_key.sshkeyjenkins.id}"]
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_all" {
  group     = "${ibm_is_security_group.securitygroupforjenkins.id}"
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_tomcat" {
  group     = "${ibm_is_security_group.securitygroupforjenkins.id}"
  direction = "inbound"
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_icmp" {
  group     = "${ibm_is_security_group.securitygroupforjenkins.id}"
  direction = "inbound"
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_out" {
  group     = "${ibm_is_security_group.securitygroupforjenkins.id}"
  direction = "outbound"
}

resource "ibm_is_floating_ip" "ipf1" {
  name   = "ipforjenkins"
  target = "${ibm_is_instance.vsiforjenkins.primary_network_interface.0.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}

output sshcommand {
  value = "ssh -i <name_of_sshkey_priv> root@${ibm_is_floating_ip.ipf1.address}"
}
