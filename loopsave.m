%{
Export data to text file

subroutine :
- findcons.m
- savedata.m
- rempass.m

output : text file inside folder OutTxt
%}
%19-Jul-2018 : first created by Muhammad Syahrullah F
%31-Jul-2018 : change folder directory for flasc and fldsc - Hollanda


close all
clear
clc

fdir='../OutF/';
flasc=dir('../OutF/*asc_Tid_Est.mat');
fldsc=dir('../OutF/*dsc_Tid_Est.mat');

for j=1:length(flasc)
    idxn=strfind(flasc(j).name,'_as');
    name1=flasc(j).name(1:idxn-1);
    tic;
    fprintf('saving matfile to txt ---> %s \n',flasc(j).name(1:idxn-1));
    
    %import data
    data1=importdata([fdir flasc(j).name]);
    data2=importdata([fdir fldsc(j).name]);
    
    con=data1(1).con(1,:);
    disp('Tidal constituent from ascending and descending=');
    fprintf('[');
    
    disp('Tidal Constituent that want to be validated :')
    cons=(input('example : ''k1,o1,M1'' or ''all''\n'));
    cons=upper(cons);
    
    if(strcmp(cons,'ALL'))
        cons=con;
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
    
    lenCon=length(cons);
    
    for i=1:length(cons)
        fprintf('%s ',cons{i});
    end
    fprintf(']\n\n');
    
    
    for i=1:lenCon
        %find constituent
        [consID,TotalCons]=findcons(data1,cons{i});
        
        name2=sprintf('%s_%s',name1,cons{i});
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

