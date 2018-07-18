%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fdir='../Out/';
flasc=dir('*asc');
fldsc=dir('*dsc');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(flasc)
data1=importdata([fdir flasc(i).name]);
data2=importdata([fdir fldsc(i).name]);
[data3,data4]=rempass(data1,data2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(data3)
data3(j).tipe='asc';
end
for j=1:length(data4)
data4(j).tipe='dsc';
end
tidal=[data3 data4];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idxn=strfind(flasc(i).name,'_as');
save(sprintf('%s_allpass.mat'flasc(i).name(1:idxn-1)),'tidal');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data1 data2 data3 data4 tidal idxn
end