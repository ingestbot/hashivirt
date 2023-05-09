
# Hashivirt

The items in this repository demonstrate how to create libvirt based virtual machines using Hashicorp's [Packer](https://developer.hashicorp.com/packer) and [Vagrant](https://developer.hashicorp.com/vagrant). The 
definitions included here were developed for Ubuntu 20.04.2 VMs allowing for specifications with autoinstall, cpu, memory, disk size, and storage footprint.

While [pre-built boxes](https://app.vagrantup.com/boxes/search?provider=libvirt) are available and offer a speedier means of creating VMs, they don't offer a customization
path without the complexities of reverse engineering.

## Requirements
* A functional KVM/libvirt/qemu environment
* [Hashicorp Packer](https://developer.hashicorp.com/packer/downloads) (latest version recommended)
* [Hashicorp Vagrant](https://developer.hashicorp.com/vagrant/downloads) (latest version recommended)
* [Libvirt provider for Vagrant (plugin)](https://github.com/vagrant-libvirt/vagrant-libvirt)

## Quick Start

```
cd /usr/local
git clone https://github.com/ingestbot/hashivirt.git
cd hashivirt/packer
vi packer.json (define `iso_checksum` with `md5sum` and location of Ubuntu ISO)

      "iso_checksum": "33993f79ba694f1dba9fcf89f11257ea",
      "iso_url": "/root/ubuntu-22.04.2-live-server-amd64.iso",

packer build packer.json
vagrant box add output/package.box --name ubuntu_22.04
cd ..
cp Vagrant.yaml.example Vagrant.yaml
vi Vagrant.yaml (define NIC, hostname(s), and Vagrant box name)
vagrant up <hostname>
```

## Username/Password

The username and password for the completed VM is `vagrant/vagrant`

## Packer

* To see a console of the build process, change `headless: true`, run [XQuartz](https://www.xquartz.org/) (or similar), `export DISPLAY=<hostname>:0.0`
* For detailed output of the build, `PACKER_LOG=info packer build packer.json`
* Once a build has completed succesfully, `vagrant box add output/packer.box --name ubuntu_22.04`

## Vagrant

* These environment variables may be desired:

```
VAGRANT_DOTFILE_PATH=/usr/local/hashivirt/vagrant.d   
VAGRANT_HOME=/usr/local/hashivirt/vagrant.d
```

* Add one or more hostnames to Vagrant.yaml. The names must resolve for provision/netplan.yaml.eth.sh to create a functional definition.
* For detailed output of the process: `VAGRANT_LOG=info vagrant up`

## Autoinstall

* BOTH `packer/http/user-data` and `packer/http/meta-data` must be present for autoinstall to properly function. The `packer/http/meta-data` file can be blank.

## Issues

- One (or both) of these options must be chosen to get more than one box working through packer -> vagrant. Issues with dhcp address allocation and/or sshd not 
starting will persist if neither of these options are present.

 - Removal of ssh hostkeys in `packer/packer.json` `post-processors`: `virt-sysprep --operations defaults,-ssh-hostkeys...`
 - Use of `dhcp-identifier: mac` in `packer/http/user-data` 


## Make Tiny

Using the definitions provided here, the finished VM will have a 1.5G OS storage footprint.

### Ubuntu minimal

The OS storage footprint is decreased by parsing `/cdrom/casper/install-sources.yaml`. This is done with autoinstall's (`http/user-data`) `early-commands`:

```  
  early-commands:
       - cat /cdrom/casper/install-sources.yaml | awk 'NR>1 && /^-/{exit};1' > /run/my-sources.yaml
       - mount -o ro,bind /run/my-sources.yaml /cdrom/casper/install-sources.yaml
```

### Disk Size Definition

When modifying `machine_virtual_size` in Vagrant be aware that sizes smaller than the size specified by the box metadata (defined in Packer `disk_size`) will be ignored.

- When defining a 25G `disk_size` in Packer and a 10G `machine_virtual_size` in Vagrant the end result will be a 25G disk.
- When defining a 25G `disk_size` in Packer and a 30G `machine_virtual_size` in Vagrant the end result will be a 25G disk with 5G extendable.

This means `disk_size` must be => `machine_virtual_size`. If `disk_size` < `machine_virtual_size`, the latter definition will provide the result.

See `machine_virtual_size` in https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html


### To Resize a Partition

```
# (echo d; echo ""; echo n; echo ""; echo ""; echo ""; echo "N"; echo w) | fdisk /dev/vda
# resize2fs /dev/vda2
```

- [https://askubuntu.com/questions/115310/how-to-resize-enlarge-grow-a-non-lvm-ext4-partition]()
- [http://positon.org/resize-an-ext3-ext4-partition]()
- [https://unix.stackexchange.com/questions/480369/automatize-partition-creation-with-fdisk]()


## Resources

* [https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html]()
* [https://github.com/vagrant-libvirt/vagrant-libvirt]()
* [https://ubuntu.com/server/docs/install/autoinstall]()
* [https://developer.hashicorp.com/packer/docs/configure]()
* [https://developer.hashicorp.com/packer/plugins/builders/qemu]()
* [https://ubuntu.com/server/docs/install/autoinstall]()
* [https://netplan.readthedocs.io/en/stable/netplan-yaml/]()
* [https://libguestfs.org/virt-sysprep.1.html]()
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/index]()
* [https://github.com/lavabit/robox]()
* [https://github.com/alvistack/vagrant-ubuntu/]()

