% June 7, 2022

clear; clc; close all;

% ---------------------------------------------------------- user specifies
varName='tas_2m';
simName='cesm2cam6climoATMv2';
season='DJF';
timeAvg='daily';

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
