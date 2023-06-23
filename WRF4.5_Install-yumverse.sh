#!/bin/bash
#########################################################
#		WRF Install Script     			#
# 	This Script was written by Umur Dinç    	#
#  Modified by Hanif Ismail to use yum instead of apt   #
#   To execute this script "bash WRF4.5_Install.bash"   #
#########################################################
WRFversion="4.5"
type="ARW"
if [ -n "$1" ]; then
    if [ "$1" = "-chem" ]; then
        type="Chem"
    elif [ "$1" = "-arw" ]; then
        type="ARW"
    elif [ "$1" = "-hydro" ]; then
        type="Hydro"
    else
        echo "Unrecognized option, please run as"
        echo "For WRF-ARW \"bash WRF${WRFversion}_Install.bash -arw\""
        echo "For WRF-Chem \"bash WRF${WRFversion}_Install.bash -chem\""
	echo "For WRF-Hydro \"bash WRF${WRFversion}_Install.bash -hydro\""
        exit
    fi
fi
start_run=$(date +%s)
echo "Welcome! This Script will install the WRF${WRFversion}-${type}"
echo "Installation may take several hours and it takes 52 GB storage. Be sure that you have enough time and storage."
echo "The time right now is $(date)"
#########################################################
#	Controls					#
#########################################################
if [ "$EUID" -eq 0 ]
  then echo "Running this script as root or sudo, is not suggested"
  exit
fi
osbit=$(uname -m)
if [ "$osbit" = "x86_64" ]; then
        echo "64 bit operating system is used"
else
        echo "Sorry! This script was written for 64 bit operating systems."
exit
fi
########
packagemanagement=$(which yum)
if [ -n "$packagemanagement" ]; then
        echo "Operating system uses yum packagemanagement"
else
        echo "Sorry! This script is written for the operating systems which uses yum package management. Please try this script with the corresponding operating systems, such as,Fedora, Centos, RHEL etc."
#Tested on Ubuntu 20.04
exit
fi
local_language=$(locale | grep LANG | grep tr_TR)
if [ -n "$local_language" ]; then
 echo "Merhaba, WRF modelinin kodundaki hatadan dolayı, WRF kurulumu işletim sistemi dili Türkçe olduğunda, Türkçedeki i ve ı harflerinin farklı olması sebebiyle hata vermektedir. Lütfen işletim sisteminizin dilini başka bir dile çevirip yeniden çalıştırınız. Kurulum bittikten sonra işletim sistemi dilini tekrar Türkçe'ye çevirebilirsiniz."
 exit
fi
#########################################################
#   Installing neccesary packages                       #
#########################################################

if [ "$type" = "Chem" ]; then
 extra_packages="flex libfl-devel libfl-static bison byacc"
fi
echo "Please enter your sudo password, so necessary packages can be installed."
sudo yum update
export mpich_repoversion=$(yum --cacheonly list mpich | grep 64 | awk '{print $2}' | cut -c1 | grep -Eo '[0-9]{1,2}')
if [ "$mpich_repoversion" -ge 4 ]; then
mpirun_packages="openmpi-devel hdf5-openmpi-devel"
else
mpirun_packages="mpich hdf5-mpich-devel"
fi
sudo yum install -y $mpirun_packages
sudo yum install -y time dpkg gcc gcc-c++ make csh gfortran m4 curl perl libpng-devel netcdf netcdf-fortran-devel lbzip2
sudo yum install -y $extra_packages

# package4checks="gcc gcc-c++ make csh gfortran m4 curl perl ${mpirun_packages} png-devel netcdf netcdf-fortran-devel ${extra_packages}"
# for packagecheck in ${package4checks}; do
#  packagechecked=$(dpkg-query --show --showformat='${db:Status-Status}\n' $packagecheck | grep not-installed)
#  if [ "$packagechecked" = "not-installed" ]; then
#         echo $packagecheck "$packagechecked"
#      packagesnotinstalled=yes
#  fi
# done
# if [ "$packagesnotinstalled" = "yes" ]; then
#         echo "Some packages were not installed, please re-run the script and enter your root password, when it is requested."
# exit
# fi
#########################################
cd ~
homey=$(pwd)
mkdir Build_WRF
cd Build_WRF
mkdir LIBRARIES
cd LIBRARIES
echo "" >> ~/.bashrc
bashrc_exports=("#WRF Variables" "export DIR=$(pwd)" "export CC=gcc" "export CXX=g++" "export FC=gfortran" "export FCFLAGS=-m64" "export F77=gfortran" "export FFLAGS=-m64"
		"export NETCDF=/usr" "export HDF5=/usr/lib64" "export LDFLAGS="\""-L/usr/lib64 -L/usr/lib"\""" 
		"export CPPFLAGS="\""-I/usr/include/hdf5/serial/ -I/usr/include"\""" "export LD_LIBRARY_PATH=/usr/lib")
for bashrc_export in "${bashrc_exports[@]}" ; do
[[ -z $(grep "${bashrc_export}" ~/.bashrc) ]] && echo "${bashrc_export}" >> ~/.bashrc
done
DIR=$(pwd)
export CC=gcc
export CXX=g++
export FC=gfortran
export FCFLAGS=-m64
export F77=gfortran
export FFLAGS=-m64
export NETCDF=/usr
export NETCDF_classic=1
export HDF5=/usr
export LDFLAGS="-L/usr/lib64 -L/usr/lib"
export CPPFLAGS="-I/usr/include"
export LD_LIBRARY_PATH=/usr/lib64
export PATH=/usr/lib64/openmpi/bin:$PATH
export PATH=/usr:$PATH
export WRF_DIR="WRF-${WRFversion}-${type}"
export J="-j 6"
if [ "$type" = "Chem" ]; then
[[ -z $(grep "export FLEX_LIB_DIR=/usr/lib64" ~/.bashrc) ]] && echo "export FLEX_LIB_DIR=/usr/lib64" >> ~/.bashrc
[[ -z $(grep "export YACC='yacc -d'" ~/.bashrc) ]] && echo "export YACC='yacc -d'" >> ~/.bashrc
export FLEX_LIB_DIR=/usr/lib64
export YACC='yacc -d'
fi
##########################################
#	Jasper Installation		#
#########################################
[ -d "jasper-1.900.1" ] && mv jasper-1.900.1 jasper-1.900.1-old
[ -f "jasper-1.900.1.tar.gz" ] && mv jasper-1.900.1.tar.gz jasper-1.900.1.tar.gz-old
wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz -O jasper-1.900.1.tar.gz
tar -zxf jasper-1.900.1.tar.gz
cd jasper-1.900.1/
./configure --prefix=$DIR/grib2
make
make install
[[ -z $(grep "export JASPERLIB=$DIR/grib2/lib" ~/.bashrc) ]] && echo "export JASPERLIB=$DIR/grib2/lib" >> ~/.bashrc
[[ -z $(grep "export JASPERINC=$DIR/grib2/include" ~/.bashrc) ]] && echo "export JASPERINC=$DIR/grib2/include" >> ~/.bashrc
export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include
cd ..
#########################################
#	WRF Installation		#
#########################################
cd ..
[ -d "WRFV${WRFversion}" ] && mv WRFV${WRFversion} WRFV${WRFversion}-old
[ -f "WRFV${WRFversion}.tar.gz" ] && mv WRFV${WRFversion}.tar.gz WRFV${WRFversion}.tar.gz-old
wget -c https://github.com/wrf-model/WRF/releases/download/v${WRFversion}/v${WRFversion}.tar.gz -O WRFV${WRFversion}.tar.gz
tar -zxf WRFV${WRFversion}.tar.gz
if [ "$type" = "Hydro" ]; then
export WRF_HYDRO=1
[ -f "v5.2.0.tar.gz" ] && mv v5.2.0.tar.gz v5.2.0.tar.gz-old
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/archive/refs/tags/v5.2.0.tar.gz -O v5.2.0.tar.gz
tar -zxf v5.2.0.tar.gz
/bin/cp -rf wrf_hydro_nwm_public-5.2.0/trunk/NDHMS/* WRFV${WRFversion}/hydro/
rm v5.2.0.tar.gz
rm -r wrf_hydro_nwm_public-5.2.0
fi
cd WRFV${WRFversion}
if [ "$type" = "Chem" ]; then
export WRF_CHEM=1
export WRF_KPP=1
fi
sed -i 's#$NETCDF/lib#$NETCDF/lib64#g' configure
./clean -a
( echo 34 ; echo 1 ) | ./configure
sed -i 's#-L/usr/lib -lnetcdff -lnetcdf#-L/usr/lib64 -lnetcdff -lnetcdf#g' configure.wrf
sed -i 's#LIBS    = $(LIB_LOCAL) -L$(NETCDFPATH)/lib -lnetcdf#LIBS    = $(LIB_LOCAL) -L$(NETCDFPATH)/lib64 -lnetcdff -lnetcdf#g' ${homey}/Build_WRF/WRFV${WRFversion}/external/io_netcdf/makefile
gfortversion=$(gfortran -dumpversion | cut -c1)
if [ "$gfortversion" -lt 8 ] && [ "$gfortversion" -ge 6 ]; then
sed -i '/-DBUILD_RRTMG_FAST=1/d' configure.wrf
fi
logsave compile.log ./compile em_real
if [ -n "$(grep "Problems building executables, look for errors in the build log" compile.log)" ]; then
        echo "Sorry, There were some errors while installing WRF."
        echo "Please create new issue for the problem, https://github.com/bakamotokatas/WRF-Install-Script/issues"
        exit
fi
if [ "$type" = "Chem" ]; then
logsave convert_emi.log ./compile emi_conv
if [ -n "$(grep "Problems building executables, look for errors in the build log" convert_emi.log)" ]; then
        echo "Sorry, There were some errors while installing WRF."
        echo "Please create new issue for the problem, https://github.com/bakamotokatas/WRF-Install-Script/issues"
        exit
fi
fi
cd ..
[ -d "WRF-${WRFversion}-${type}" ] && rsync -a WRF-${WRFversion}-${type}/ WRF-${WRFversion}-${type}-old/ && rm -rf WRF-${WRFversion}-${type}
mv WRFV${WRFversion} WRF-${WRFversion}-${type}
#########################################
#	WPS Installation		#
#########################################
WPSversion="4.5"
[ -d "WPS-${WPSversion}" ] && rsync -a  WPS-${WPSversion}/ WPS-${WPSversion}-old/ && rm -rf WPS-${WPSversion}
[ -f "WPSV${WPSversion}.TAR.gz" ] && mv WPSV${WPSversion}.TAR.gz WPSV${WPSversion}.TAR.gz-old
wget -c https://github.com/wrf-model/WPS/archive/v${WPSversion}.tar.gz -O WPSV${WPSversion}.TAR.gz
tar -zxf WPSV${WPSversion}.TAR.gz
cd WPS-${WPSversion}
./clean
sed -i '163s/.*/    NETCDFF="-lnetcdff"/' configure
sed -i "195s/.*/standard_wrf_dirs=\"WRF-${WRFversion}-${type} WRF WRF-4.0.3 WRF-4.0.2 WRF-4.0.1 WRF-4.0 WRFV3\"/" configure
export FFLAGS="-m64 -I/usr/lib64/gfortran/modules"
echo 1 | ./configure
sed -i "72s#FFLAGS              = -ffree-form -O -fconvert=big-endian -frecord-marker=4#FFLAGS              = -ffree-form -O -fconvert=big-endian -frecord-marker=4 -I/usr/lib64/gfortran/modules#g" configure.wps
logsave compile.log ./compile
sed -i "s# geog_data_path.*# geog_data_path = '../WPS_GEOG/'#" namelist.wps
cd ..
#########################################
#	Opening Geog Data Files 	#
#########################################
if [ -d "WPS_GEOG" ]; then
  echo "WRF and WPS are installed successfully"
  echo "Directory WPS_GEOG is already exists."
  echo "Do you want WPS_GEOG files to be redownloaded and reexracted?"
  echo "please type yes or no"
  # read GEOG_validation
  export GEOG_validation="yes"
  if [ ${GEOG_validation} = "yes" ]; then
    wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz -O geog_high_res_mandatory.tar.gz
    tar -zxf geog_high_res_mandatory.tar.gz
    if [ "$type" = "Chem" ]; then
      cd WPS_GEOG
      Chem_Geog="modis_landuse_21class_30s soiltype_top_2m soiltype_bot_2m albedo_ncep maxsnowalb erod clayfrac_5m sandfrac_5m"
      for i in ${Chem_Geog}; do
        if [ ! -d $i ]; then
          echo $i
          wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/${i}.tar.bz2 -O ${i}.tar.bz2
          tar -xf ${i}.tar.bz2
          rm ${i}.tar.bz2
        fi
      done
  else
    echo "You can download it later from http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz and extract it"
   fi
else
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz -O geog_high_res_mandatory.tar.gz
tar -zxf geog_high_res_mandatory.tar.gz
fi
 cd ..
fi
#######################################
#       PREP_CHEM_SRC                 #
#######################################
if [ "$type" = "Chem" ]; then
 echo "Do you want the PREP-CHEM-SRC program to be installed? PREP-CHEM-SRC is a widely used emission preparation program for WRF-Chem."
 echo "please type yes or no"
 export prep_chem_validation="yes"
 #read prep_chem_validation
  if [ ${prep_chem_validation} = "yes" ]; then
  echo "firstly starting to compile convert_emiss.exe. convert_emiss.exe is needed for convert emissions which are created from PREP-CHEM-SRC." 
#moved convert_emiss compilation upward because of some unexpected error
  echo "Compilation of convert_emiss.exe is finished, now PREP-CHEM-SRC download and compilation has started."
  [ -d "PREP-CHEM-SRC-1.5" ] && rsync -a PREP-CHEM-SRC-1.5/ PREP-CHEM-SRC-1.5-old/ && rm -rf PREP-CHEM-SRC-1.5
  [ -f "prep_chem_sources_v1.5_24aug2015.tar.gz" ] && mv prep_chem_sources_v1.5_24aug2015.tar.gz prep_chem_sources_v1.5_24aug2015.tar.gz-old
  wget -c ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/prep_chem_sources_v1.5_24aug2015.tar.gz -O prep_chem_sources_v1.5_24aug2015.tar.gz
  tar -zxf prep_chem_sources_v1.5_24aug2015.tar.gz
  cd PREP-CHEM-SRC-1.5/bin/build
  sed -i "s#NETCDF=.*#NETCDF=/usr#" include.mk.gfortran.wrf
  sed -i 's#-L$(NETCDF)/lib#-L/usr/lib64#' include.mk.gfortran.wrf
  sed -i "s#HDF5=.*#HDF5=/usr/lib64#" include.mk.gfortran.wrf
  sed -i "s#HDF5_INC=.*#HDF5_INC=-I/usr/include#" include.mk.gfortran.wrf
  sed -i 's#-L$(HDF5)/lib#-L/usr/lib64#' include.mk.gfortran.wrf
  gfortversion=$(gfortran -dumpversion)
  if [ "$gfortversion" -ge 10 ]; then
  sed -i 's#F_OPTS=.*#F_OPTS=  -Xpreprocessor -D$(CHEM) -O2 -fconvert=big-endian -frecord-marker=4 -fallow-argument-mismatch#' include.mk.gfortran.wrf
  fi
  sed -i "s#-L/scratchin/grupos/catt-brams/shared/libs/gfortran/zlib-1.2.8/lib#-L/usr/lib#" include.mk.gfortran.wrf
  sed -i "842s#.*#    'ENERGY     ',\&#" ../../src/edgar_emissions.f90
  sed -i "843s#.*#    'INDUSTRY   ',\&#" ../../src/edgar_emissions.f90
  sed -i "845s#.*#    'TRANSPORT  '/)#" ../../src/edgar_emissions.f90
  make OPT=gfortran.wrf CHEM=RADM_WRF_FIM
  cd ..
  mkdir datain
  cd datain
  wget -c ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/global_emissions_v3_24aug2015.tar.gz -O global_emissions_v3_24aug2015.tar.gz
  tar -zxf global_emissions_v3_24aug2015.tar.gz
  mv Global_emissions_v3/* .
  rm -r Global_emissions_v3
  mv Emission_data/ EMISSION_DATA
  mv surface_data/ SURFACE_DATA
  cd ../../..
  echo "PREP-CHEM-SRC compilation has finished."
  fi
fi
##########################################################
#	End						#
##########################################################
finish_run=$(date +%s)
totaltime_run=$((finish_run-start_run))
echo "Installation has completed, and it took $(date -d@{totaltime_run} -u +%H:%M:%S) from start to finish"
