#!/bin/sh

#Create snapshotshots of root and home
btrfs subvolume snapshot -r / /root-snapshot.$(date +%d-%m-%Y)
sync

# Delete snapshotshots older than 7 days
find /* -maxdepth 0 -mtime +7 -name "root-snapshot.*" | xargs btrfs subvolume delete 

# Update systemd-boot snapshots
systemctl restart update-systemd-boot-snapshots.service

