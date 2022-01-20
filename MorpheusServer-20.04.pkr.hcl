//vsphere vars
variable "vcenter_username" {
  type    = string
  default = ""
}
variable "vcenter_password" {
  type    = string
  default = ""
}
variable "vcenter_server" {
  type    = string
  default = ""
}
variable "vcenter_cluster" {
  type    = string
  default = ""
}
variable "vcenter_datastore" {
  type    = string
  default = ""
}
variable "vcenter_folder" {
  type    = string
  default = ""
}
variable "vcenter_network" {
  type    = string
  default = "VM Network"
}
variable "convert_template" {
  type    = bool
  default = false
}
variable "insecure_connection" {
  type    = bool
  default = false
}

//iso vars
variable "iso_checksum" {
  type    = string
  default = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
}
variable "iso_url" {
  type    = string
  default = "http://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso"
}
variable "iso_paths" {
  type    = list(string)
  default = [""]
}

//vm specs
variable "name" {
  type    = string
  default = "MorpheusServer-20.04"
}
variable "cpus" {
  type    = number
  default = 1
}
variable "cpu_cores" {
  type = number
  default = 4
}
variable "memory" {
  type    = number
  default = 8192
}
variable "disk_size" {
  type    = number
  default = 210000
}

//other vars
variable "http_directory" {
  type = string
  default = "./http"
}
variable "ssh_password" {
  type = string
  default = "ubuntu"
}
variable "ssh_wait" {
  type = string
  default = "20m"
}

source "vsphere-iso" "autogenerated_1" {
  //vcenter configuration
  username       = "${var.vcenter_username}"
  password         = "${var.vcenter_password}"
  vcenter_server = "${var.vcenter_server}"
  cluster             = "${var.vcenter_cluster}"
  convert_to_template = "${var.convert_template}"
  datastore           = "${var.vcenter_datastore}"
  folder              = "${var.vcenter_folder}"
  guest_os_type       = "ubuntu64Guest"
  notes = "${formatdate("MMM DD YYYY hh:mm ZZZ","${timestamp()}")}"
  insecure_connection = "${var.insecure_connection}"

  //vm configuration
  vm_name        = "${var.name}"
  CPUs                = "${var.cpus}"
  cpu_cores = "${var.cpu_cores}"
  RAM              = "${var.memory}"
  cdrom_type = "sata"
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "vmxnet3"
  }
  disk_controller_type = ["lsilogic-sas"]
  storage {
    disk_size = "${var.disk_size}"
    disk_thin_provisioned = true
  }

  //ssh configuration
  #ssh password is set in the user-data yaml file which is used for the OS install
  #a different password can be generated and replaced in the yaml file, however
  #it will be easier to just change the password for the ubuntu user once the VM
  #is officially provisioned
  ssh_password     = "${var.ssh_password}"
  ssh_timeout      = "30m"
  ssh_username     = "ubuntu"

  http_directory      = "${var.http_directory}"

  //iso configuration
  #to prevent the need to download the iso all the time, i placed the iso
  #in my datastore in my vsphere environment and used it for the template build.
  #if you want to download and attach the iso independent of vsphere,
  #ensure that you comment or remove the iso_paths line and uncomment
  #the iso_url and iso_checksum lines
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"
  #iso_paths = "${var.iso_paths}"

  //boot configuration
  boot_command        = [
    "<esc><enter><f6><esc>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>",

    #the ssh_wait var was added to account for an issue i ran into where
    #ssh would be available during the OS installation and packer would
    #spam the connection and fail due to authentication issues
    #there weren't any other places i could add a wait time before
    #establishing the ssh connection so i placed it
    #into the boot commands for now :/
    "<wait${var.ssh_wait}>"
  ]
  boot_wait           = "5s"
}

build {
  sources = ["source.vsphere-iso.autogenerated_1"]

  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    script = "${path.root}/scripts/config.sh"
  }
}