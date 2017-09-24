#!/bin/bash
set -e

################
##   CONFIG   ##
################
CWD="$(pwd)" # current working directory
flash_arduino="u2" # u2 or ftdi
arduino_device="ttyACM0" # ls /dev/tty* and find your arduino
mega=2560 #2560 or 1280

script_version="1.0.0"
rdate="23/09/2017"

################
##  SOFTWARE  ##
################

clear
echo ""
echo -n -e "\e[97m\u2554"
for i in {1..34}; do echo -e -n "\u2550"; done
echo -e "\u2557\e[0m"
echo -e "\e[97m\u2551     SPI Bios Flashrom \e[93m"V$script_version"\e[0m\e[97m     \u2551\e[0m"
echo -e "\e[97m\u2551      Release date: \e[93m"$rdate"\e[0m\e[97m    \u2551\e[0m"
echo -n -e "\e[97m\u255A"
for j in {1..34}; do echo -e -n "\u2550";done
echo -e -n "\u255D\e[0m"
echo


function arduino_ {
echo -e ""
echo -e "\e[92m\e[4mBuild Arduino SPIFlash tools:\e[0m\e[24m"

echo -e "\n\e[93mPerforming Update :\e[0m"
sudo apt-get install flashrom gcc-avr binutils-avr gdb-avr avr-libc avrdude libpci-dev git -y

if [ ! -d frser-duino ]
then
echo -e "\n\e[93mDownload frser-duino :\e[0m"
git clone --recursive git://github.com/urjaman/frser-duino frser-duino
else
cd frser-duino
git reset --hard
git pull
cd ..
fi

cd frser-duino
sed -i -e "s/dev\/ttyUSB0/dev\/$arduino_device/g" Makefile
echo -e "\n\e[93mBuild frser-arduino :\e[0m"
make $flash_arduino
echo -e "\n\e[93mFlash Arduino :\e[0m"
make flash-$flash_arduino
}

function mega_ {
echo -e ""
echo -e "\e[92m\e[4mBuild ATMEGA$mega SPIFlash tools:\e[0m\e[24m"

echo -e "\n\e[93mPerforming Update :\e[0m"
sudo apt-get install flashrom gcc-avr binutils-avr gdb-avr avr-libc avrdude libpci-dev git -y

if [ ! -d frser-duino ]
then
echo -e "\n\e[93mDownload frser-mega :\e[0m"
git clone --recursive git://github.com/urjaman/frser-duino frser-duino
else
cd frser-duino
git reset --hard
git pull
cd ..
fi

cd frser-duino
sed -i -e "s/dev\/ttyUSB0/dev\/$arduino_device/g" Makefile
echo -e "\n\e[93mBuild frser-duino :\e[0m"
make mega$mega
echo -e "\n\e[93mFlash ATMega$mega :\e[0m"
make flash-mega$mega

}

function raspberry_ {
echo -e ""
echo -e "\e[92m\e[4mBuild Raspberry SPIFlash tools:\e[0m\e[24m"
echo -e "\n\e[93mPerforming Update :\e[0m"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install build-essential pciutils usbutils libpci-dev libusb-dev libusb-1.0-0 libusb-1.0-0-dev libftdi1 libftdi-dev zlib1g-dev subversion git ghex -y
sudo modprobe spi_bcm2708
sudo modprobe spidev
sudo sed -i -e "s/\#dtparam=spi=on/dtparam=spi=on/g" /boot/config.txt
}

function flashrom_ {
cd $CWD

if [ ! -d flashrom ]
then
echo -e "\n\e[93mDownload flashrom :\e[0m"
git clone git://github.com/flashrom/flashrom.git
fi

cd flashrom
sed -i -e "s/WARNERROR ?= yes/WARNERROR ?= no/g" Makefile
echo -e "\n\e[93mBuild and install flashrom:\e[0m"
make
sudo make install
}

function clean_ {
echo -e ""
echo -e "\e[93m\e[4mCleaning:\e[0m\e[24m"
if [ -d flashrom ]; then rm -r -f flashrom; fi
if [ -d frser-duino ]; then rm -r -f frser-duino; fi
echo -e "\n\e[95mCleaning...Done !\e[0m"
echo""
}

function flashrom_raspberry_check_ {
echo -e "\n\e[93mCheck flashrom :\e[0m"
flashrom -p linux_spi:dev=/dev/spidev0.0 || :
}

function flashrom_arduino_check_ {
echo -e "\n\e[93mCheck flashrom :\e[0m"
sleep 1
flashrom -p serprog:dev=/dev/$arduino_device:115200 || :
}

function flashrom_mega_check_ {
echo -e "\n\e[93mCheck flashrom :\e[0m"
flashrom -p serprog:dev=/dev/$arduino_device:115200 || :
}

function footer_ {
echo ""
echo -e "\e[92m\e[21mMemo Command line: \e[0m"
echo -e ""
echo -e "\e[93m\e[21mArduino/Mega2560/Mega1280: \e[0m"
echo -e "flashrom -p serprog:dev=/dev/$arduino_device:115200"
echo -e ""
echo -e "\e[93m\e[21mRaspberryPI/beagleBone: \e[0m"
echo -e "flashrom -p linux_spi:dev=/dev/spidev0.0"
echo -e ""
if  ! [ -x "$(command -v flashrom)" ]
then
echo 'Error: flashrom is not yet installed.' >&2
echo 'Build and come back to help section....' >&2
else
echo -e "\e[93m\e[21mFlashrom version: \e[0m"
flashrom -R
fi
echo ""
}

function show_help {
echo "\
Usage: $0 [--arduino] [--mega] [--raspberry] [--clean] [--help]

     --help             Display extended help message
     --arduino          Build Serial SPI flashrom tools for arduino328
     --mega             Build Serial SPI flashrom tools for arduinoMega
     --raspberry        Build Serial SPI flashrom tools for raspberryPI
     --clean       	Clean all build files

Install script Written by: wareck <wareck@gmail.com>
"
}

if [ "$#" == "0" ]; then
    $0 *
    exit 0
fi

for i in "$@"
do
    case $i in
        --help)
            show_help && footer_
            exit
            ;;
        --arduino)
            arduino_ && flashrom_ && flashrom_arduino_check_ && footer_
            ;;
        --mega)
           mega_ && flashrom_ && flashrom_mega_check_ && footer_
           ;;
        --raspberry)
            raspberry_ && flashrom_ && flashrom_raspberry_check_ && footer_
            ;;
        --clean)
            clean_
            ;;
        *)
            show_help
            exit
            ;;
    esac
done
