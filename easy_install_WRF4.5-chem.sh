#!/bin/bash

wget -cnv https://github.com/iceblst/WRF-Install-Script/blob/version-yum/WRF4.5_Install-yumverse.sh
chmod 777 WRF4.5_Install-yumverse.sh
echo "Please enter your sudo password, so necessary packages can be installed."
sudo yum update
echo "Starting installation of WRF Chem V4.5"
./WRF4.5_Install-yumverse.sh -chem >& ~/compile_install_chem.log