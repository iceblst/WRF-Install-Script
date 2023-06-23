#!/bin/bash

wget -c https://github.com/iceblst/WRF-Install-Script/blob/version-yum/WRF4.5_Install-yumverse.sh
chmod 777 WRF4.5_Install-yumverse.sh
./WRF4.5_Install-yumverse.sh -chem >& ~/compile_install_chem.log