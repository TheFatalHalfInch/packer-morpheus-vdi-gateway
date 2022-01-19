
# Welcome!

This is a packer template i've been working on for creating a minecraft server on a vSphere instance.  
This is for a vanilla Minecraft server with no modding applied.

## Requirements

- Packer (https://www.packer.io/downloads)
- A vSphere environment

## How to use this template

- Clone the repo
- Create a pkrvars.hcl file with your variables somewhere on your computer
    - example.pkrvars.hcl can be altered from this repo to your needs
- CD into the cloned directory  
```
packer build --var-file="c:\path\to\your\pkrvars.hcl" -var "vsphere_password=yoursupergoodamazingunhackablepassword" MinecraftServer-20.04.pkr.hcl
```

## Template actions

- Create a VM with your specs from the pkrvars.hcl file
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
- Copy the files from scripts directory in repo to ubuntu user home directory on VM
- Copy backup and minecraft service configuration files to appropriate locations
- Remove the scripts and directory they were copied to
- Run the configuration script which does the following
    - Install open-vm-tools
    - Disable cloud-init
    - apt-get update & upgrade
    - Install java
    - Create minecraft service account
    - Create minecraft server directories
        - /opt/minecraft/backups
        - /opt/minecraft/server
        - /opt/minecraft/tools
    - Download minecraft server.jar to /opt/minecraft/server
    - Start the minecraft server and let it stop
    - Change the following settings in the server files:
        - eula=true in eula.txt
        - enable-rcon=true in server.properties
        - rcon.password=........... in server.properties
    - Install mcrcon to /opt/minecraft/tools
    - Set minecraft server service to autostart when VM runs
    - Allow 25565:TCP through firewall
    - Make backup script executable
    - Change ownership of minecraft home directory to minecraft service account
- Convert the completed server build to a vSphere template for speedy deployments later on

## Server backup behavior

Backup will occur every day at the default time in which cron.daily runs.
Backups will be available in /opt/minecraft/backups and retained for a week  

Unless the backup server script is removed (/etc/cron.daily/minecraftserverbackup)...  

Then the backups that are currently in the backup folder will remain there indefinitely but the backup script will not run automatically...  

The minecraftserverbackup script currently does the following:
- Remove files from /opt/minecraft/backups that are older than 7 days
- Compress the contents of the world folder
- Save compressed file into /opt/minecraft/backups/DAY_world.tgz

## Increasing RAM allocation to server

### Default amount is 1 GB.

If you want to increase the amount of RAM allocated to the server:
- Deploy the VM
- Edit /etc/systemd/system/minecraft.service
- Change the following from:
```
ExecStart=java -Xms1G -Xmx1G -XX:........
```
- TO:
```
ExecStart=java -Xms5G -Xmx5G -XX:........
```  

The -Xms1G and -Xmx1G arguments specify the amount of RAM in GB (1G is 1 GB of RAM)  

You can specify MB by changing the G to an M (example: -Xms512M is 512 MB of RAM)

## Acknowledgements

https://bobcares.com/blog/install-minecraft-server-on-ubuntu/ (guide for configuring minecraft server)  
https://louwrentius.com/understanding-the-ubuntu-2004-lts-server-autoinstaller.html (subiquity installation help)  
https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/ (minecraft server optimizations)  
https://www.spigotmc.org/threads/guide-server-optimization%E2%9A%A1.283181/ (minecraft server optimizations)  
https://travislawrence.co/2016/06/09/creating-vms-with-packer-and-vagrant/  
https://github.com/boxcutter/ubuntu/blob/master/script/desktop.sh (used the ubuntu.json template to get the sudo script syntax)  
https://github.com/vmware/open-vm-tools/issues/421 (used for solving issue with NIC not being connected when deploying with terraform)  
https://kb.vmware.com/s/article/59687 (used for solving issue with NIC not being connected when deploying with terraform)  
https://askubuntu.com/questions/20414/find-and-replace-text-within-a-file-using-commands (sed commands)  
