%{
This function design to save data amplitude, phase, and standard deviation
every constituent in file ascending and descending into one file txt


%subroutine : rempass.m
%Output :
- amp.txt
- pha.txt
- amp_std.txt
- pha_std.txt

%19-Jul-2018 : first created by Muhammad Syahrullah F
%31-Jul-2018 : add mkdir option by Hollanda

%}

function savedata(flasc,fldsc,name,ncol,numbcons)

fout='../OutTxt/';
if (~exist(fout,'dir'))
    mkdir(fout);
end

[data3]=rempass(flasc);
[data4]=rempass(fldsc);

tidal=[data3 data4];

alldat_amp=[];
alldat_pha=[];

for i=1:length(tidal)
    %amplitude
    alldat_amp=cat(1,alldat_amp,[tidal(i).pos(:,2),tidal(i).pos(:,1)...
        tidal(i).amp(:,ncol) tidal(i).sdp(:,ncol)]);
    %phase
    alldat_pha=cat(1,alldat_pha,[tidal(i).pos(:,2),tidal(i).pos(:,1)...
        tidal(i).pha(:,ncol) tidal(i).sdp(:,ncol+numbcons)]);
end

idx=find(alldat_amp(:,1)~=0);
idx2=find(alldat_pha(:,1)~=0);
alldat_amp2=alldat_amp(idx,:);
alldat_pha2=alldat_pha(idx2,:);

clear idx idx2
idx=find(~isnan(alldat_amp2(:,1)));
idx2=find(~isnan(alldat_pha2(:,1)));

alldat_amp3=alldat_amp2(idx,:);
alldat_pha3=alldat_pha2(idx2,:);

clear idx idx2

formatspec='%12.6f %12.6f %12.6f\n';

fname1=sprintf('%s_amp.txt',name);
fname2=sprintf('%s_pha.txt',name);
fname3=sprintf('%s_amp_std.txt',name);
fname4=sprintf('%s_pha_std.txt',name);

fid1=fopen([fout fname1],'w');
fid2=fopen([fout fname2],'w');
fid3=fopen([fout fname3],'w');
fid4=fopen([fout fname4],'w');

%amplitude
fprintf(fid1,formatspec,[alldat_amp3(:,1),alldat_amp3(:,2),...
    alldat_amp3(:,3)]');
%phase
fprintf(fid2,formatspec,[alldat_pha3(:,1),alldat_pha3(:,2),...
    alldat_pha3(:,3)]');
%standard deviation amplitude
fprintf(fid3,formatspec,[alldat_amp3(:,1),alldat_amp3(:,2),...
    alldat_amp3(:,4)]');
%standard deviation phase
fprintf(fid4,formatspec,[alldat_pha3(:,1),alldat_pha3(:,2),...
    alldat_pha3(:,4)]');

fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);

end



