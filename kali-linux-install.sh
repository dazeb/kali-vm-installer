#!/bin/bash

# Variables
IMAGE_URL=$(whiptail --inputbox 'Enter the URL for the Kali Linux image (default: https://cdimage.kali.org/kali-2022.4/kali-linux-2022.4-qemu-amd64.7z):' 8 78 'https://cdimage.kali.org/kali-2022.4/kali-linux-2022.4-qemu-amd64.7z' --title 'Kali Linux Install' 3>&1 1>&2 2>&3)
RAM=$(whiptail --inputbox 'Enter the amount of RAM (in MB) for the new virtual machine (default: 2048):' 8 78 2048 --title 'Kali Linux Install' 3>&1 1>&2 2>&3)
CORES=$(whiptail --inputbox 'Enter the number of cores for the new virtual machine (default: 2):' 8 78 2 --title 'Kali Linux Install' 3>&1 1>&2 2>&3)

# Get the next available VMID
ID=$(pvesh get /cluster/nextid)

touch "/etc/pve/qemu-server/$ID.conf"

# Get the storage name from the user
STORAGE=$(whiptail --inputbox 'Enter the storage name where the image should be imported:' 8 78 --title 'Kali Linux Install' 3>&1 1>&2 2>&3)

# Download DietPi image
wget "$IMAGE_URL"

# Extract the image
IMAGE_NAME=${IMAGE_URL##*/}
IMAGE_NAME=${IMAGE_NAME%.7z}
7zr e kali-linux-2022.4-qemu-amd64.7z
sleep 3

# import the qcow2 file to the default virtual machine storage
qm importdisk "$ID" kali-linux-2022.4-qemu-amd64.qcow2 "$STORAGE"

# Set vm settings
qm set "$ID" --cores "$CORES"
qm set "$ID" --memory "$RAM"
qm set "$ID" --net0 'virtio,bridge=vmbr0'
qm set "$ID" --scsi0 "$STORAGE:vm-$ID-disk-0"
qm set "$ID" --boot order='scsi0'
qm set "$ID" --scsihw virtio-scsi-pci

# Tell user the virtual machine is created
echo "VM $ID Created."

# Start the virtual machine
qm start "$ID"