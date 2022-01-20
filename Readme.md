
# Welcome!

This is a Packer template which can be used to deploy a vSphere template for a Ubuntu 20.04 based instance of Morpheus Community Edition.  

## Requirements

- Packer (https://www.packer.io/downloads)
- A vSphere environment
- A Morpheus Hub account (https://morpheushub.com/login/auth)

## NOTES

Default Username: ubuntu
Default Password: ubuntu  

Running the template will sit for a long time (default is 20 minutes) at "Typing boot command...", this is by Design!
SSH is available during the installation phase of the OS, and Packer will spam the connection until it maxes out the SSH retries which will in turn cause the template to fail.
This will occur everytime unless a wait time is set to allow the OS to finish installing and reboot.
(The variable ssh_wait can be altered if your OS finishes installing well under 20 minutes)

## How to use this template

- Clone the repo
- Create a pkrvars.hcl file with your variables somewhere on your computer
    - example.pkrvars.hcl can be altered from this repo to your needs
- CD into the cloned directory  
```
packer build --var-file="c:\path\to\your\pkrvars.hcl" -var "vsphere_password=yoursupergoodamazingunhackablepassword" MorpheusServer-20.04.pkr.hcl
```

## AFTER DEPLOYMENT

You will need to do the following after deploying the VM from the template to ensure Morpheus will work properly:  
- Configure a static ip address
- Configure a DNS entry either in your local computer or router (if it supports DNS entries)
- Run the MorpheusConfig.sh script as sudo
```
sudo /home/ubuntu/MorpheusConfig.sh
```

## Template actions

- Create a VM using vars from the pkrvars.hcl file
- Create a temporary http share from the http directory in the repo
- ISO mount
    - If iso_url and iso_checksum are used and iso_paths is commented out or removed:
        - Packer will download the ubuntu iso and mount it from your computer to the VM
    - If iso_url and iso_checksum are commented or removed and iso_paths is used:
        - Packer will mount the iso(s) from the vsphere datastore and path provided to the VM
- Boot the computer from the ISO
- Type the boot commands
- Initiate an automated installation using the user-data file in http directory
- Reboot the VM
- Establish SSH
- Copy the MorpheusConfig.sh file from the scripts directory and place it into the ubuntu user's home directory
- Run the configuration script which does the following
    - Create a temp directory
    - Install open-vm-tools
    - Disable cloud-init (prevents issues with subsequent VMs created from this template)
    - apt-get update & upgrade
    - Download Morpheus Community Edition to the temp directory
    - Run the Morpheus installation
    - Run the Morpheus reconfiguration after installation
    - Get the status of Morpheus
    - Remove the temp directory that the installer was placed in
- Shutdown the VM used for creating the template
- Convert the completed server build to a vSphere template for speedy deployments later on (Manual or Terraform)

## Acknowledgements

Used to help get the ip address - https://www.geeksforgeeks.org/bash-scripting-split-string/  
Reference for Morpheus installation - https://morpheusdata.com/cloud-blog/installing-morpheus-on-your-laptop-or-pc/  