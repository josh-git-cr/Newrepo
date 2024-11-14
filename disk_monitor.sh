#!/bin/bash

#echo "Inserisci il nome del disco da monitoraretra quelli elencati: "
#lsblk
#read -p "Inserisci il nome del disco da monitorare: " 1


if [ $# -ne 1 ]; then
    echo "Inserisci il nome del disco da monitoraretra quelli elencati: "
    lsblk
    exit 1
fi

DISK=$1

if ! lsblk | grep -q "$DISK"; then
    echo "Errore: Il disco $DISK non esiste"
    exit 1
fi

prev_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}')
prev_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}')

total_read_mb=0
total_write_mb=0

Sector= blkid $DISK | grep -o 'BLOCK_SIZE="[0-9]*"' | cut -d '"' -f2
echo $Sector

while true; do
    current_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}')
    current_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}')

    new_read_sectors=$((current_read-prev_read))
    new_write_sectors=$((current_write-prev_write))

    read_mb=$((new_read_sectors * Sector / 1024 / 1024))
    write_mb=$((new_write_sectors * Sector / 1024 / 1024))

    total_read_mb=$((total_read_mb + read_mb))
    total_write_mb=$((total_write_mb + write_mb))



done