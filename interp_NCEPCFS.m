% interpolate NCEP data onto 1x1deg grid

clear; clc; close all;

lon=0:359; % 360
lat=-90:90; % 181
[xNew,yNew]=meshgrid(lon,lat);

datasetName='NCEPCFSR';
dirName=sprintf('/glade/scratch/sglanvil/%s/',datasetName);
year1=1999;
year2=2010;
varName='tas_2m';
ncepName='TMP_P0_L103_GLL0';

cd(dirName)

for iyear=year1:year2
    file=sprintf('%s_%s.dailyAvg.%.4d.nc',varName,datasetName,iyear);   
    ncSave=sprintf('%s_%s.dailyAvg.%.4d_interp.nc',varName,datasetName,iyear);   
    disp(file)
    var=squeeze(ncread(file,ncepName));
    lon=ncread(file,'lon_0');
    lat=ncread(file,'lat_0');
    [x,y]=meshgrid(lon,lat);
    clear varNew
    for itime=1:size(var,3)
        varNew(:,:,itime)=interp2(x,y,squeeze(var(:,:,itime))',...
            xNew,yNew,'linear',NaN);
    end
    time=yyyymmdd(datetime(iyear,1,1,'format','yyyyMMdd'):datetime(iyear,12,31,'format','yyyyMMdd'));
    size(time)
    size(varNew)
    
    % ------------------------ save at netcdf ------------------------
    lon=0:359; % 360
    lat=-90:90; % 181
    ncid=netcdf.create(ncSave,'NC_WRITE');
    dimidlon=netcdf.defDim(ncid,'lon',length(lon));
    dimidlat=netcdf.defDim(ncid,'lat',length(lat));
    dimidtime=netcdf.defDim(ncid,'time',length(time));

    lon_ID=netcdf.defVar(ncid,'lon','float',[dimidlon]);
    lat_ID=netcdf.defVar(ncid,'lat','float',[dimidlat]);
    time_ID=netcdf.defVar(ncid,'time','float',[dimidtime]);
    var_ID=netcdf.defVar(ncid,varName,'float',[dimidlon dimidlat dimidtime]);
    
    netcdf.endDef(ncid);
    netcdf.putVar(ncid,lon_ID,lon);
    netcdf.putVar(ncid,lat_ID,lat);
    netcdf.putVar(ncid,time_ID,time);
    netcdf.putVar(ncid,var_ID,double(varNew));
    netcdf.close(ncid)
end

