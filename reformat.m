% ------------------------------------------------------------------------
% Purpose : Create ITB stack-file and write it into a Matlab structure file
%
% Input   : RADS2ASC output file at Raw_0 directory
%            
% Output  : Stack-file (stf) file at Raw_1 directory  
%
% Routine : -
%
%
% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 01-May-2018: First created - DDW
% 13-Jul-2018: Edited by Muhammad Syahrullah Fathulhuda
%              - input SSH dari rads diatas limit yang diberikan di file xml
%19-Jul-2018 : adding mkdir to make sure folder output exist
% ------------------------------------------------------------------------
%% 
clear
clc
close all

fdir='../Raw_0/';
mkdir(fdir);
fdir1='../Raw_1/';
mkdir(fdir1);
fout=strrep(fdir,'Raw_0','Raw_1');
fl=dir([fdir,'*.*sc']);

fprintf('Creating Satelit stack-file\n');
for ii=1:length(fl)
    tic;
    fname=fl(ii).name;
    fprintf('%i. File: %s\n',ii,fname);
    fname=[fdir,fname]; 
    fid=fopen(fname,'r');
    np=0;
    while(~feof(fid))
        str = fgetl(fid);  
        if ~isempty(str) 
        if strfind(str(1),'#')
            nd=0;np=np+1;
            str = fgetl(fid); % Created\
            str = fgetl(fid);
            sat=str(15:end); tt(np).sat=sat;        % Satellite
            str = fgetl(fid);tt(np).phase=str(15);   % Phase
            phase=str(15);
            str = fgetl(fid);tt(np).cycle=str2num(str(15:end));   % Cycle
            str = fgetl(fid);tt(np).pass=str2num(str(15:end));   % Pass
            str = fgetl(fid);tt(np).equ_time=str2num(str(15:32));   % Equ_time
            str = fgetl(fid);tt(np).equ_lon=str2num(str(15:end));   % Equ_lon
            %fprintf('%i %i %i\n',[np tt(np).cycle tt(np).pass])
            for i=1:6;fgetl(fid);end
            str=[];
        end
        if length(str)>2
            nd=nd+1;
			try
            data(nd,:)=str2num(str);
            catch 
			disp('Nilai SSH diatas limit yang diberikan')
			idx=strfind(str,'*');
			data(nd,:)=[str2num(str(1:min(idx)-1)) NaN str2num(str(max(idx)+1:end))];
			end
			clear idx
        end
        else
            tt(np).data=data;
            clear data    
        end
    end
    fclose(fid);
    tt(np).data=data;
     stf=tt;
     clear tt
    clear data 
    
    save([fout,sat,'_',phase,'_',fname(end-2:end)],'stf');clear stf
    fprintf(' ---> time: %f min\n', toc/60);
    fprintf('\n');
end
