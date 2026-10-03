packer {
  required_version = ">= 1.14.0"

  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.1"
    }

    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1.1"
    }
  }
}

source "qemu" "ubuntu" {
  accelerator = "kvm"

  boot_command = [
    "<wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall net.ifnames=0 ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>",
  ]

  boot_wait = "1s"

  cpus             = 2
  memory           = 4096
  disk_size        = 10240
  disk_cache       = "writeback"
  disk_compression = true
  disk_image       = false
  disk_interface   = "virtio"

  format = "qcow2"

  headless = true

  http_directory = "http"

  iso_url      = "/ISO/ubuntu-26.04.1-live-server-amd64.iso"
  iso_checksum = "cb81232e7fb50cf009234df515306dfe"

  net_device = "virtio-net"

  qemu_binary = "kvm"

  qemuargs = [
    ["-cpu", "host"],
  ]

  output_directory = "output"

  shutdown_command = "sudo shutdown -h now"

  ssh_username           = "vagrant"
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_read_write_timeout = "600s"
  ssh_timeout            = "30m"

  vnc_bind_address = "0.0.0.0"
  vnc_port_min     = 5900
  vnc_port_max     = 6000
}

build {
  sources = [
    "source.qemu.ubuntu",
  ]

  post-processor "shell-local" {
    inline = [
      "set -eu",
      "export _IMAGE=\"output/packer-qemu\"",
      "sudo qemu-img convert -f qcow2 -O qcow2 \"$_IMAGE\" \"$_IMAGE.convert\"",
      "sudo rm -rf \"$_IMAGE\"",
      "sudo chmod a+r /boot/vmlinuz*",
      "sudo virt-sysprep --operations defaults,-ssh-hostkeys,-ssh-userdir,-customize -a \"$_IMAGE.convert\"",
      "sudo virt-sparsify --in-place \"$_IMAGE.convert\"",
      "sudo qemu-img convert -f qcow2 -O qcow2 -c \"$_IMAGE.convert\" \"$_IMAGE\"",
      "sudo rm -rf \"$_IMAGE.convert\"",
    ]
  }

  post-processor "vagrant" {
    compression_level   = 9
    keep_input_artifact = true
    output              = "output/package.box"
    provider_override   = "libvirt"
  }
}

