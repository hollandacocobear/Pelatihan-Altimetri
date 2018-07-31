%subroutine : findcons.m

%19-Jul-2018 : first created by Muhammad Syahrullah F
%31-Jul-2018 : change folder directory for flasc and fldsc

close all
%clear
clc

fdir='../Out/';
flasc=dir('../Out/*asc_Tid_Est.mat');
fldsc=dir('../Out/*dsc_Tid_Est.mat');
% Konstanta yang ingin di ekspor ke txt
con={'K1','O1','M2','S2','K2'};
con=upper(con);
lenCon=length(con);


for j=1:length(flasc)
	idxn=strfind(flasc(j).name,'_as');
	name1=flasc(j).name(1:idxn-1);
	tic;
	fprintf('saving matfile to txt ---> %s \n',flasc(j).name(1:idxn-1));
    
    %import data
    %data1=importdata([fdir flasc(j).name]);
    %data2=importdata([fdir fldsc(j).name]);

for i=1:lenCon
    %find constituent
	[consID,TotalCons]=findcons(data1,con{i});
    
	name2=sprintf('%s_%s',name1,con{i});
    %save data in this constituent
	savedata(data1,data2,name2,i,TotalCons);
	fprintf('--->%s\n',name2)
	clear name2 consID TotalCons name2
end
	fprintf('saved to txt for file ---> %s \n',flasc(j).name(1:idxn-1))
	fprintf('Elapsed time ---> %f min\n',toc/60)
	fprintf('\n')
clear name1 idxn
end

