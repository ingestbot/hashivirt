

# packer

Trouble. Trouble. Trouble.

---
packer 1.10+ does not include plugins, either figure out how to get it working with external plugins or use 1.9.
    - apt-get install packer=1.9.5-1

---
Must include proxy settings in http/user-data

---
virt-sysprep is needed. Install with 'apt install libguestfs-tools' or 'apt install guestfs-tools' 

---
After building, see:
 # du -sh /var/tmp/.guestfs-0
 724M	/var/tmp/.guestfs-0

https://libguestfs.org/guestfs-faq.1.html
 - Libguestfs uses too much disk space!
