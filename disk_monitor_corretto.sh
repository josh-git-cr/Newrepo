#!/bin/bash

# Verifica se è stato passato un argomento
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nome_disco>"
    echo "Esempio: $0 sda"
    exit 1
fi

DISK=$1

# Controlla se il disco esiste
if ! lsblk | grep -q "$DISK"; then
    echo "Errore: Il disco $DISK non esiste."
    exit 1
fi

echo "Monitoraggio del disco: $DISK"
echo "Premi CTRL+C per interrompere."

# Variabili iniziali per il calcolo di MB letti e scritti
prev_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}')
prev_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}')
total_read_mb=0
total_write_mb=0

while true; do
    # Ottieni le statistiche attuali
    current_read=$(cat /proc/diskstats | grep "$DISK" | awk '{print $6}')
    current_write=$(cat /proc/diskstats | grep "$DISK" | awk '{print $10}')

    # Calcola il numero di settori letti e scritti
    read_sectors=$((current_read - prev_read))
    write_sectors=$((current_write - prev_write))

    # Calcola la quantità di dati letti e scritti in MB (512 byte per settore)
    read_mb=$((read_sectors * 512 / 1024 / 1024))
    write_mb=$((write_sectors * 512 / 1024 / 1024))

    # Aggiorna il totale di dati letti e scritti
    total_read_mb=$((total_read_mb + read_mb))
    total_write_mb=$((total_write_mb + write_mb))

    # Calcola la velocità di lettura e scrittura in MB/s
    read_speed=$((read_mb / 5))
    write_speed=$((write_mb / 5))

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

    # Attendi 5 secondi prima del prossimo aggiornamento
    sleep 1
done
