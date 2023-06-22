# WRF-Install-Script


WRF Install scripts will install the WRF and WPS with the needed libraries(netcdf4 hdf5, mpich, zlib, libpng, jasper). Currently only support installation for WRF 4.5. These scripts are written for Linux OS that have yum as package manager, such as Fedora, CentOS, or RHEL.

Since WRF-Install-Script uses operating system libraries, it installs much faster than manually installing the libraries and then installing the WRF model.

You can download the Debian version from the [releases](https://github.com/bakamotokatas/WRF-Install-Script/releases).

Tested successfully to run in Fedora 38.

To run the scripts, you should run the commands below.

For WRF4.5 with ARW option(default)

```
bash WRF4.5_Install-yumverse.bash
```
or
```
bash WRF4.5_Install-yumverse.bash -arw
```

For WRF4.5 with Chem option (WRF-Chem)
```
bash WRF4.5_Install-yumverse.bash -chem
```

For WRF4.5 with Hydro option (WRF-Hydro)
```
bash WRF4.5_Install-yumverse.bash -hydro
```
