%{
This function design to save data residual amplitude and phase,
and diff tidal constituent resultant every constituent
in file xOver into file txt


%subroutine :
%Output :
- amp_std.txt
- pha_std.txt

%19-Jul-2018 : first created by Muhammad Syahrullah F
%31-Jul-2018 : add mkdir option by Hollanda



%}

close all
clear
clc

fdir='../Out/';
fout='../Out1/';
if (~exist(fout,'dir'))
    mkdir(fout);
end

fname='*xover*';
fx=dir([fdir fname]);

formatspec='%12.6f%12.6f%12.6f\n';

for i=1:length(fx)
    xoverap=importdata([fdir fx(i).name]);
    idxn=strfind(fx(i).name,'.mat');
    name=sprintf('%s',fx(i).name(1:idxn-1));
    fprintf('--> Get data from %s.txt\n',name);
    %get residu amplitude, residu phase, and diff resultan vektor
    ampli=[];
    phase=[];
    resultan=[];
    
    for j=1:length(xoverap)
        ampli=cat(1,ampli,[xoverap(j).xcoord_ref(:,2),...
            xoverap(j).xcoord_ref(:,1),xoverap(j).xamp(:,3)]);
        phase=cat(1,phase,[xoverap(j).xcoord_ref(:,2),...
            xoverap(j).xcoord_ref(:,1),xoverap(j).xpha(:,3)]);
        resultan=cat(1,resultan,[xoverap(j).xcoord_ref(:,2),...
            xoverap(j).xcoord_ref(:,1),xoverap(j).xpha(:,4)]);
    end
    
    
    %save all data in different text file
    fname1=sprintf('%s_amp_residu.txt',name);
    fname2=sprintf('%s_pha_residu.txt',name);
    fname3=sprintf('%s_diff_Resultan.txt',name);
    
    %Open file to write
    fid1=fopen([fout fname1],'w');
    fid2=fopen([fout fname2],'w');
    fid3=fopen([fout fname3],'w');
    
    %write data to file txt
    fprintf(fid1,formatspec,[ampli(:,1),ampli(:,2),ampli(:,3)]');
    fprintf(fid2,formatspec,[phase(:,1),phase(:,2),phase(:,3)]');
    fprintf(fid3,formatspec,[resultan(:,1),resultan(:,2),resultan(:,3)]');
    
    fclose(fid1);
    fclose(fid2);
    fclose(fid3);
    fprintf('--> Data from %s export successfully \n',name);
    clear xoverap idxn name alldatx
end