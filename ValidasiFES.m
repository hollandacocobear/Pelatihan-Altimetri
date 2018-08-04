%{
Validate satellite constituents amplitude and phase from ascending and
descending file with FES Model2014

Input:
fasc : file ascending mode
fdsc : file descending mode
cons : tidal constituent used for validation

subroutine:
-validasi.m

output:
- Figure
- mat file contain raw data, data FES2014, residu

01-08-2018 : first created by Hollanda Arief Kusuma
03-08-2018 : adding option to obtain constituent interactive - Hollanda
%}
%%
close all
clear
clc
%%
fdir='../OutF/';
fasc='GFO-1_a_col_asc_Tid_Est.mat';
fdsc='GFO-1_a_col_dsc_Tid_Est.mat';
satelit='GFO-1_a';
data1=importdata([fdir fasc]);
data2=importdata([fdir fdsc]);

%%
%choosing constituent
con=data1(1).con(1,:);
disp('Tidal constituent from ascending and descending=');
fprintf('[');
for i=1:length(con)
    fprintf('%s ',con{i});
end
fprintf(']\n\n');

disp('Tidal Constituent that want to be validated :')
cons=(input('example : ''k1,o1,M1'' or ''all''\n'));
%cons={'K1'};
cons=upper(cons);
if(strcmp(cons,'ALL'))
    cons=con;
    clear con
else
    id=strfind(cons,',');
    idx=1;
    con1=cell(length(id),1);
    for i=1:length(id)
        con1{i}=cons(idx:id(i)-1);
        idx=id(i)+1;
    end
    con1{i+1}=cons(idx:end);
    cons=con1;
    clear i id idx con1
end


%%

fid=fopen([fdir satelit ' Validation Report.txt'],'w');
fprintf(fid,upper(['---   Validation Report Data ' satelit ' with FES2014   ---']));
fprintf(fid,'\n');
fprintf(fid,'\n');

for i=1:length(cons)
    fprintf(fid,'%d. TIDAL CONSTITUENT %s\n',i,cons{i});
    
    [Rawdata, data_fes2014, Residu]=validasi(fasc,fdsc,data1,data2,cons{i},satelit,fid);
    
    fdir='../OutValidation/';
    if(~exist(fdir,'dir'))
        mkdir(fdir)
    end
    
    if(~isempty(Rawdata))
        save([fdir satelit '_' cons{i} '_valid.mat'],'Rawdata', 'data_fes2014', 'Residu');
    end
    
    
    clear Rawdata data_fes2014 Residu
    
end
fclose(fid);

