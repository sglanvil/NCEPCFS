#!/bin/bash
# run this script after interp_NCEPCFS.m

module load nco

for ifile in *interp.nc; do
        echo $ifile
        ncks --mk_rec_dmn time -O $ifile $ifile
done
