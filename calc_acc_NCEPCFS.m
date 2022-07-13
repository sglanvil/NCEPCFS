% June 7, 2022

clear; clc; close all;

% ---------------------------------------------------------- user specifies
varName='tas_2m';
simName='cesm2cam6climoATMv2';
season='DJF';
timeAvg='daily'; % --- note: currently only setup for "daily"

% --------------------------------------------------------------- load data
file=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_anom_%s_s2s_data.nc',varName,simName);
fileOBS=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_anom_NCEPCFS_sg_s2s_data.nc',varName);
anom=ncread(file,'anom');
lon=ncread(file,'lon');
lat=ncread(file,'lat');
date=datetime(ncread(file,'date'),'ConvertFrom','yyyyMMdd');
anomOBSorig=ncread(fileOBS,'anom'); % --- note: issue with this file's date
lonOBS=ncread(fileOBS,'lon');
latOBS=ncread(fileOBS,'lat');
dateOBS=datetime(1999,1,1,'format','yyyyMMdd'):datetime(2021,12,31,'format','yyyyMMdd');
dateOBS(month(dateOBS)==2 & day(dateOBS)==29)=[];

% ------------------- setup the anomOBS array to be the same format as anom
clear anomOBS
for itime=1:size(anom,4)
    [itime size(anom,4)]
    inxOBS=find(dateOBS==date(itime));
    anomOBS(:,:,:,itime)=squeeze(anomOBSorig(:,:,inxOBS:inxOBS+45));
end

%%

% ------------------ find where initializations match user-specified season
if strcmp(season,'DJF')==1
    amonth=1; bmonth=2; cmonth=12;
elseif strcmp(season,'MAM')==1
    amonth=3; bmonth=4; cmonth=5;
elseif strcmp(season,'JJA')==1
    amonth=6; bmonth=7; cmonth=8;
elseif strcmp(season,'SON')==1
    amonth=9; bmonth=10; cmonth=11;
end
if strcmp(season,'ALL')~=1 % ------- otherwise anom and anomOBS remain full
    anom=anom(:,:,:,month(date)==amonth | month(date)==bmonth | month(date)==cmonth);
    anomOBS=anomOBS(:,:,:,month(date)==amonth | month(date)==bmonth | month(date)==cmonth);
end

% ----------------------------------------------------------- calculate ACC
clear ACC
for ilead=1:size(anom,3) 
    anomFF=squeeze(anom(:,:,ilead,:));
    anomAA=squeeze(anomOBS(:,:,ilead,:));
    a=(anomFF.*anomAA);
    b=(anomFF).^2;
    c=(anomAA).^2;
    aTM=squeeze(nanmean(a,3)); % ---------------- calculate time means (TM)
    bTM=squeeze(nanmean(b,3));
    cTM=squeeze(nanmean(c,3));
    ACC(:,:,ilead)=aTM./sqrt(bTM.*cTM);
end
lead=1:size(ACC,3);

% ---------------------------------------------------------- save at netcdf
ncSave=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_%sseason_%s_%s_NCEPCFS_sg_s2s_data.nc',...
    varName,season,timeAvg,simName);
ncid=netcdf.create(ncSave,'NC_WRITE');
%Define the dimensions
dimidlon = netcdf.defDim(ncid,'lon',length(lon));
dimidlat = netcdf.defDim(ncid,'lat',length(lat));
dimidlead = netcdf.defDim(ncid,'lead',length(lead));
%Define IDs for the dimension variables (pressure,time,varsitude,...)
lon_ID=netcdf.defVar(ncid,'lon','double',[dimidlon]);
lat_ID=netcdf.defVar(ncid,'lat','double',[dimidlat]);
lead_ID=netcdf.defVar(ncid,'lead','double',[dimidlead]);
ACC_ID = netcdf.defVar(ncid,'ACC','double',[dimidlon dimidlat dimidlead]);
%We are done defining the NetCdf
netcdf.endDef(ncid);
%Then store the dimension variables in
netcdf.putVar(ncid,lon_ID,lon);
netcdf.putVar(ncid,lat_ID,lat);
netcdf.putVar(ncid,lead_ID,lead);
netcdf.putVar(ncid,ACC_ID,ACC);
%We're done, close the netcdf
netcdf.close(ncid)

             
