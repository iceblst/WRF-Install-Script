#!/bin/bash

[ -f "WRF4.5_Install-yumverse.sh" ] && rm WRF4.5_Install-yumverse.sh
wget -nv https://raw.githubusercontent.com/iceblst/WRF-Install-Script/version-yum/WRF4.5_Install-yumverse.sh
chmod 777 WRF4.5_Install-yumverse.sh
echo "Please enter your sudo password, so necessary packages can be installed."
sudo yum update
echo "Starting installation of WRF Chem V4.5"
./WRF4.5_Install-yumverse.sh -chem >& ~/compile_install_chem.log
cd 
WRF_DIR="Build_WRF/${WRF_DIR}"
wrf_executables="${WRF_DIR}/main/real.exe ${WRF_DIR}/main/ndown.exe ${WRF_DIR}/main/wrf.exe ${WRF_DIR}/main/tc.exe ${WRF_DIR}/chem/convert_emiss.exe \
                 ${homey}/Build_WRF/WPS-4.5/ungrib.exe ${homey}/Build_WRF/WPS-4.5/geogrid.exe ${homey}/Build_WRF/WPS-4.5/metgrid.exe\
                 ${homey}/Build_WRF/PREP-CHEM-SRC-1.5/bin/prep_chem_sources_RADM_WRF_FIM_.exe"
for i in ${wrf_executables}; do
if [ -f $i ]; then
echo "Successfully compiled ${i}"
else
echo "Failed to compile ${i}, need to reconfigure the installer"
echo "Please create new issue for the problem, https://github.com/bakamotokatas/WRF-Install-Script/issues"
fi
done
echo "Finished installing WRF Chem V4.5"