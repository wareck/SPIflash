#!/bin/bash
## dumy maker
## la fichier dummy correspond à la taille maximale de votre puce - le firmware
## par exemple pour une puce de 16M la taille de la puce est de 16777216 bytes
## si mon firmware fait 65536 bytes
## 16777216-65536 = 16711680 byte
## le fichier dummy fera donc 16711680
## ensuite il faudra coller le fichier dummy à la fin du firmware
## copy firmware.bin tampon.bin
## cat dummy.bin >> tampon.bin
## mv tampon.bin firmware_full.bin

#dd if=/dev/zero of=dummy4.bin bs=4128768 count=1
dd if=/dev/zero of=dummy128.bin bs=16651264 count=1
#dd if=/dev/zero of=dummy128_f.bin bs=12582912 count=1
