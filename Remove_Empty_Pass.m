%Remove NaN and [] from Pass & footprint
close all
clear
clc

%folder & filename
fout='../Out/';
%file='GFO-1_a_col_asc_Tid_Est';

fl=dir([fout,'*.mat']);

for i=1:length(fl)
    file=fl(i).name;
    if(strfind(file,'Est'))
        opsi=0; %1 if removing tid_correl
    else opsi =1;
    end
    
    %processing
    tic
    fprintf('Load %s\n',file)
    %load ([fout file '.mat']);
    load ([fout file]);
    if (opsi==0)
        b='tidal';
    else b='cortide';
    end
    fprintf('Total Time------> %f min\n',toc/60)
    
    %Remove NaN pass
    tic
    fprintf('Remove NaN & [] Pass ---> %s\n',file)
    s=sprintf('pasc=rempass(%s);',b);
    eval(s);
    fprintf('Total Time------> %f min\n',toc/60)
    
    %Remove NaN footprint
    tic
    fprintf('Remove NaN & [] Footprint ---> %s\n',file)
    out=remfoot(pasc,opsi);
    s=sprintf('%s=%s;',b,'out');
    eval(s);
    s1=sprintf('save([fout file],''%s'');',b);
    eval(s1);
    fprintf('Total Time------> %f min\n\n',toc/60)
    
end

