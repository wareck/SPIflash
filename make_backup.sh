#!/bin/bash
device=raspberry #arduino or raspberry
port=ttyACM0
baud=115200

if [ $device = "arduino" ]
then
flashrom -p serprog:dev=/dev/$port:$baud -r backup.hex
fi
if [ $device = "raspberry" ]
then
modprobe spi_bcm2835
modprobe spidev
flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=1000 -r backup.hex
fi

echo "n'oubliez pas de renomer le fichier !!!!"
