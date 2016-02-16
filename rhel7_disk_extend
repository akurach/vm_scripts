#!/bin/bash
#Script for extending HHD. RHEL 7/vmware

parted /dev/sda unit s print free -s | grep -v "^$" | tail -n 1 | awk '{print $1}' | xargs -I start parted /dev/sda mkpart primary start 100% -s
parted /dev/sda unit s print free -s | grep -v "^$" | tail -n 1 | awk '{print $1}' | xargs -I num parted /dev/sda set num lvm on -s
ls -l /dev/sda* | tail -n 1 | awk '{print $NF}' | xargs pvcreate
ls -l /dev/sda* | tail -n 1 | awk '{print $NF}' | xargs vgextend rhel 
lvextend -l+100%FREE /dev/mapper/rhel-root
xfs_growfs /dev/mapper/rhel-root
