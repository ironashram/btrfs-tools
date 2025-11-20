#!/bin/sh

# Create snapshots of root and home
if ! [[ -d /.snapshots/root-snapshot.$(date +%d-%m-%Y) ]]
then
    btrfs subvolume snapshot -r / /.snapshots/root-snapshot.$(date +%d-%m-%Y)
    sync
fi
if ! [[ -d /home/.snapshots/home-snapshot.$(date +%d-%m-%Y) ]]
then
    btrfs subvolume snapshot -r /home /home/.snapshots/home-snapshot.$(date +%d-%m-%Y)
    sync
fi

# Delete snapshots older than 7 days
mountpoints="/.snapshots /home/.snapshots"
threshold=$(date --date="7 days ago" -Iseconds)
for mount in $mountpoints
do
    snapshots=$(ls $mount)
    for snapshot in $snapshots
    do
        created=$(btrfs subvolume show $mount/$snapshot | grep -oP 'Creation time:\s*\K\d.*$')
        if [[ "$created" < "$threshold" ]]
        then
            btrfs subvolume delete $mount/$snapshot
        fi
    done
done

# Update systemd-boot snapshots
systemctl restart update-systemd-boot-snapshots.service
