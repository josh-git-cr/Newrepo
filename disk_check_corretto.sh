#!/bin/bash

# Verifica se è stato passato un argomento
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nome_disco>"
    echo "Esempio: $0 sda"
    exit 1
fi

DISK=$1

# Controlla se il disco esiste
if ! lsblk | grep -w -q "$DISK"; then
    echo "Errore: Il disco $DISK non esiste."
    exit 1
fi

echo "Monitoraggio del disco: $DISK"
echo "Premi CTRL+C per interrompere."

# Lettura dei dati iniziali di lettura e scrittura
prev_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}' | head -n 1)
prev_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}' | head -n 1)
total_read_mb=0
total_write_mb=0

# Ottiene la dimensione del settore (in byte)
Sector=$(cat /sys/block/$DISK/queue/hw_sector_size)

# Controlla se Sector è impostato, altrimenti usa 512 byte come default
if [ -z "$Sector" ]; then
    Sector=512
fi

while true; do
    # Ottieni le statistiche attuali
    current_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}' | head -n 1)
    current_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}' | head -n 1)

    # Calcola il numero di settori letti e scritti
    read_sectors=$((current_read - prev_read))
    write_sectors=$((current_write - prev_write))

    # Calcola i dati letti e scritti in MB
    read_mb=$((read_sectors * Sector / 1024 / 1024))
    write_mb=$((write_sectors * Sector / 1024 / 1024))

    # Aggiorna il totale di dati letti e scritti
    total_read_mb=$((total_read_mb + read_mb))
    total_write_mb=$((total_write_mb + write_mb))

    # Calcola la velocità di lettura e scrittura in MB/s
    read_speed=$((read_mb / 1))
    write_speed=$((write_mb / 1))

    # Stampa il report
    echo "----------------------------------------"
    echo "Disco: $DISK"
    echo "Velocità di lettura: $read_speed MB/s"
    echo "Velocità di scrittura: $write_speed MB/s"
    echo "Totale MB letti: $total_read_mb MB"
    echo "Totale MB scritti: $total_write_mb MB"
    echo "----------------------------------------"

    # Aggiorna i valori precedenti
    prev_read=$current_read
    prev_write=$current_write

    # Attendi 1 secondo prima del prossimo aggiornamento
    sleep 1
done
