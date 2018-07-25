close all;clear;clc;
%filename
file='GFO-1_a_col_dsc';

%Tidal Constituent
%con={'M2'};
 con={'SA','SSA','MSF', ...
     'K1','O1','Q1', ...
     'M2','S2','N2','K2','2N2', ...
     'M4','MS4'};

%Nama Satelit * TP, Jason, ERS, ENVISAT, GFO, GEOSAT, SARAL, SENTINEL, CRYOSAT
satelit='GFO-1';

%directory
fdir='../Raw_2/';
fout='../Out/';
fl=dir([fdir,[file '.mat']]);

tic;
a=toc/60;
if(isempty(fl))
    fprintf('File Input Name doesn''t exist in folder %s\n',fdir);
    return;
end

tidal_estimate(fl.name,satelit,con)
fprintf('Export data to txt ---> %s\n',fl.name)
fprintf('Total Time------> %f min\n',toc/60-a)
fprintf('\n')

