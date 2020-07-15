
resource "ibm_compute_ssh_key" "ssh_key_bin" {
  label      = "${var.ssh_label}"
  public_key = "${var.ssh_public_key}"
}

resource "ibm_compute_vm_instance" "terraform_p_sample" {
  hostname                   = "${var.hostname}"
  domain                     = "ibm.cloud-landingzone.com"
  os_reference_code          = "UBUNTU_18_64"
  datacenter                 = "dal10"
  network_speed              = "100"
  hourly_billing             = "true"
  private_network_only       = "false"
  cores                      = "1"
  memory                     = "1024"
  disks                      = [25]
  local_disk                 = false
  ssh_key_ids                = [ "${ibm_compute_ssh_key.ssh_key_bin.id}" ]

  connection {
    type = "ssh"
    user = "root"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update", 
      "yes|apt install openjdk-8-jdk",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "echo 'deb https://pkg.jenkins.io/debian-stable binary/' >> /etc/apt/sources.list",
      "apt update",
      "yes|apt install jenkins",
      "systemctl status jenkins",
      "timeout 10 ufw allow 8080",
      

    ]
  }
}

/*       "intial_password_jenkins=$(cat /var/lib/jenkins/secrets/initialAdminPassword)",
      "echo $intial_password_jenkins" */