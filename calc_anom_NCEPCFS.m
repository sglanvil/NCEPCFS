% June 3, 2022

clear; clc; close all;

varName='tas_2m'; % 'T_850','tas_2m','pr_sfc'

% -------------- file1: NCEPCFSR --------------
file1=sprintf('%s_NCEPCFSR.dailyAvg.ALL_interp.nc',varName);
var1=ncread(file1,varName);
lon=ncread(file1,'lon');
lat=ncread(file1,'lat');
time1=datetime(1999,1,1,'format','yyyyMMdd'):datetime(2010,12,31,'format','yyyyMMdd');
% -------------- file2: NCEPCFSv2 --------------
file2=sprintf('%s_NCEPCFSv2.dailyAvg.ALL_interp.nc',varName);
var2=ncread(file2,varName);
time2=datetime(2011,4,2,'format','yyyyMMdd'):datetime(2021,12,31,'format','yyyyMMdd');
% -------------- combine datasets --------------
varNan=nan(360,181,91);
obs=cat(3,var1,varNan,var2);
timeObs=datetime(1999,1,1,'format','yyyyMMdd'):datetime(2021,12,31,'format','yyyyMMdd');
% -------------- remove leap days --------------
obs(:,:,month(timeObs)==2 & day(timeObs)==29)=[];
timeObs(month(timeObs)==2 & day(timeObs)==29)=[];
% -------------- calculate clim/smooth + anom --------------
clear var_clim
for itime=1:365
    climObs(:,:,itime)=nanmean(obs(:,:,itime:365:end),3);
end
climCyclicalObs=cat(3,climObs,climObs,climObs); % make a 3-year loop of clims
climSmoothObs0=movmean(movmean(climCyclicalObs,31,3,'omitnan'),31,3,'omitnan'); 
% 31 day window to copy Lantao, but maybe it should be 16
climSmoothObs=climSmoothObs0(:,:,366:366+364); % choose the middle year (smoothed)
clear var_anom
for iyear=1:length(timeObs)/365
    for iday=1:365
        anomObs(:,:,(iyear-1)*365+iday)=...
            obs(:,:,(iyear-1)*365+iday)-climObs(:,:,iday);
    end
end

% -------------- save as netcdf --------------
time=yyyymmdd(timeObs);
ncSave=sprintf('%s_anom_NCEPCFS_sg_s2s_data.nc',varName);
ncid=netcdf.create(ncSave,'NC_WRITE');
dimidlon=netcdf.defDim(ncid,'lon',length(lon));
dimidlat=netcdf.defDim(ncid,'lat',length(lat));
dimidtime=netcdf.defDim(ncid,'time',length(time));

lon_ID=netcdf.defVar(ncid,'lon','float',[dimidlon]);
lat_ID=netcdf.defVar(ncid,'lat','float',[dimidlat]);
time_ID=netcdf.defVar(ncid,'time','float',[dimidtime]);
var_ID=netcdf.defVar(ncid,'anom','float',[dimidlon dimidlat dimidtime]);

netcdf.endDef(ncid);
netcdf.putVar(ncid,lon_ID,lon);
netcdf.putVar(ncid,lat_ID,lat);
netcdf.putVar(ncid,time_ID,time);
netcdf.putVar(ncid,var_ID,anomObs);
netcdf.close(ncid)
