# The "all years" files are too big, so chunk them down, then interpolate with matlab

module load nco

for iyear in {2011..2021}; do
        echo $iyear 
        ncecat -O -u time pr_sfc_NCEPCFSv2.${iyear}*.dailyAvg.nc pr_sfc_NCEPCFSv2.dailyAvg.${iyear}.nc
        ncecat -O -u time tas_2m_NCEPCFSv2.${iyear}*.dailyAvg.nc tas_2m_NCEPCFSv2.dailyAvg.${iyear}.nc
        ncecat -O -u time -d lv_ISBL0,84000.,86000. T_NCEPCFSv2.${iyear}*.dailyAvg.nc T_850_NCEPCFSv2.dailyAvg.${iyear}.nc
done
