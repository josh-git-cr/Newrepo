#!/bin/bash

#echo "inserisci il nome del disco da monitorare tra quelli elencati:" 
#lsblk
#read -p 1

if [ $# -ne 1 ]; then
    echo "Uso: $0 <nome_disco>"
    echo "Esempio: $0 sda"
    exit 1
fi

#if [ -z "$1" ]; then 
#    echo "inserisci un valore" 
#    exit 1
#fi

DISK=$1

if ! lsblk | grep -q "$DISK" ; then
    echo "Il disco $DISK non esiste."
    exit 1
fi

#Lettura dei dati del 6 lettura 10 scrittura in /proc/diskstats

#dati iniziali 
prev_read=$(cat /proc/diskstats |grep "$DISK" | awk '{print $6}' | head -n 1)
prev_write=$(cat /proc/diskstats |grep "$DISK" | awk '{print $10}' | head -n 1)
total_read_mb=0
total_write_mb=0
Sector= blkid /dev/$DISK | grep -o 'BLOCK_SIZE="[0-9]*"' | cut -d'"' -f2  
echo "$Sector"
echo "$prev_read"
echo "$prev_write"

while true; do 
current_read=$(cat /proc/diskstats |grep "$DISK" | awk '{print $6}')
current_write=$(cat /proc/diskstats |grep "$DISK" | awk '{print $10}')

New_read_sectors=$((current_read - prev_read))
New_write_sectors=$((current_write - prev_write))


Read_mb=$((New_read_sectors * Sector / 1024 / 1024))
Write_mb=$((New_write_sectors * Sector / 1024 / 1024))

total_read_mb=$((Read_mb + total_read_mb))
total_write_mb=&((Write_mb + total_write_mb))

read_speed=$((Read_mb / 5))
write_speed=$((Write_mb / 5))

    echo "----------------------------------------"
    echo "Disco: $DISK"
    echo "Velocità di lettura: $read_speed MB/s"
    echo "Velocità di scrittura: $write_speed MB/s"
    echo "Totale MB letti: $total_read_mb MB"
    echo "Totale MB scritti: $total_write_mb MB"
    echo "----------------------------------------"

prev_read=$current_read
prev_write=$current_write

sleep 1
done