#replace these variables with ones that work for your vsphere instance
vcenter_server = "vcenter.someplace.com"
vcenter_cluster = "Cluster"
vcenter_datastore = "Datastore"
vcenter_network = "VM Network"
vcenter_folder = "Packer"
vcenter_username = "user@vsphere.local"

#you can set your password here, however i would highly recommended you
#send your password through the packer build command instead
#example: packer build -var-file="path/to/example.pkrvars.hcl" -var "vcenter_password=yoursupersecretgoodpassword" MinecraftServer-20.04.pkr.hcl
vcenter_password = ""

#this is used if you still have a self-signed cert through vsphere
insecure_connection = true

#vm setup during provisioning process
cpus = 4
cpu_cores = 4
memory = 1024
disk_size = 10000
convert_template = true

#i have a relatively slow internet connection which caused long wait times for security updates
#this is set to 17m for me on a 50mbps connection and may take longer/shorter depending on your connection
ssh_wait = "17m"

http_directory = "./http"

#this is used if you are using an iso that is uploaded to your vsphere instance
#if iso url and checksum is used, then this can be commented out
iso_paths = ["[Datastore] path/to/ubuntu-20.04.2-live-server-amd64.iso"]