%create gmt batch file automatically looping
%31-Jul-2018 : first created by Hollanda

close all
clear
clc

%choose one (comment using %. Delete % to uncomment variable
%fname='*col*';
fname='*xover*';

fdir='../OutTxt/';
fgraph='../GMT_Graphic/';
fnc='../GMT_nc/';
if (~exist(fgraph,'dir'))
    mkdir(fgraph);
end
if (~exist(fnc,'dir'))
    mkdir(fnc);
end


fx=dir([fdir fname]);
nfx=length(fx);

%find constituent name
p=1;
st1=cell(nfx,1);
fprintf('Constituent :\t');
for i=1:nfx
    s=strfind(fx(i).name,'_');
    s=fx(i).name(s(3)+1:s(4)-1);
    st1{i}=s;
    
    if (i==1)
        str{1}=s;
    else
        if (~strcmp(st1{i},st1{i-1}))
            p=p+1;
            str{p}=s;
            fprintf('%s\t',s)
        end
    end
end
    fprintf('\n ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i=1:nfx
    clear data mindata maxdata range IDs s nama jenis
    data=dlmread([fdir fx(i).name]);
    mindata=floor(min(data(:,3)));
    maxdata=round(max(data(:,3)));
    range=maxdata-mindata;
    IDs=strfind(fx(i).name,'_');
    s=fx(i).name(IDs(3)+1:IDs(4)-1);
    nama=fx(i).name(1:end-4);
    jenis=fx(i).name(IDs(4)+1:end-4);
    
    if(strcmp(jenis,'amp'))
        judul='AMPLITUDE';
        satuan='meter';
    elseif(strcmp(jenis,'amp_std'))
        judul='STANDARD DEVIATION AMPLITUDE';
        satuan='meter';
    elseif(strcmp(jenis,'pha'))
        judul='PHASE';
        satuan='radian';
    elseif(strcmp(jenis,'pha_std'))
        judul='STANDARD DEVIATION PHASE';
        satuan='radian';
    elseif(strcmp(jenis,'amp_residu'))
        judul='AMPLITUDE RESIDU';
        satuan='meter';
    elseif(strcmp(jenis,'pha_residu'))
        judul='PHASE RESIDU';
        satuan='radian';
    elseif(strcmp(jenis,'diff_Resultan'))
        judul='DIFFERENCE RESULTAN VEKTOR';
        satuan='meter';
    end
    
    fprintf('%s %s --->%d - %d\n',judul,s,i,nfx);
    %{
    if(range<=3)
        interval=0.5;
    elseif(range>3&&range<=10)
        interval=1;
    elseif(range>10&&range<=100)
        interval=20;
    elseif(range>100&&range<=1000)
        interval=200;
    elseif(range>1000&&range<=3000)
        interval=500;
        elseif(range>3000&&range<=20000)
        interval=1000;
        elseif(range>20000&&range<=100000)
        interval=10000;
    else interval=50000;
    end
    %}
    %generate GMT batch file
    fname='gmt.bat';
    fid=fopen(fname,'w');
    
    fprintf(fid,'cls\r\n'); %ECHO on\r\n'); % clear screen
    %setting map
    fprintf(fid,'gmtset FONT_TITLE 24p,5\r\n');
    fprintf(fid,'gmtset FONT_LABEL 24p,5\r\n');
    fprintf(fid,'gmtset FONT_ANNOT 16p,4\r\n');
    
    %setting file
    p=pwd;
    cd ..
    cd (fdir(2:end));
    pdir=pwd;
    cd ..
    cd (fnc(2:end));
    pnc=pwd;
    cd ..
    cd(fgraph(2:end));
    pgraph=pwd;
    cd (p)
    
    fprintf(fid,'set file1="%s.txt"\r\n',[pdir '\' nama]);
    fprintf(fid,'set file2="%s.nc"\r\n',[pnc '\' nama]);
    %fprintf(fid,'set file3="%s.grd"\r\n',[pnc '\' nama]);
    fprintf(fid,'set R="%s.ps"\r\n',[pgraph '\' nama]);
    fprintf(fid,'set gambar="%s.jpg"\r\n',[pgraph '\' nama]);
    
    fprintf(fid,'surface %%file1%% -R95/150/-15/15 -G%%file2%% -I2m -T0.25 -C0.1 \r\n');
    %%file1% - input file
    %-G output file *.nc
    %-R Region xmin/xmax/ymin/ymax
    %-I increment grid spacing. xinc[unit]/yinc[unit]. unit: m>arc minute, s>arc second, e>meter, f>foot, k>km, M>mile, n>nautical mile, u> US Survey foot
    %-T Tension factor - between 0 and 1. Experience suggests T ~ 0.25 usually looks good for potential field data
    %-C Convergence limit (%).
    %-G%file2% - output file with nc extension
    
    %=membuat colormap plot=%
    fprintf(fid,'makecpt -Cjet -T%d/%d -Z > Colorpalet.cpt\r\n',mindata,maxdata);
    %-T Defines the range of the new CPT by giving the lowest and highest z-value and interval(optional)
    %-Z Creates a continuous CPT
    
    %Project grids or images and plot them on maps - Produce images from 2-D gridded data sets
    fprintf(fid,'grdimage %%file2%% -JM20c -R95/150/-15/15 -CColorpalet.cpt -Xc -Yc -B10 -K >%%R%% \r\n'); % -X3 -Y3
    %%file3% - input file in grd
    %-JM > J - Select map projection; M - Mercator; 13c > 13 cm map width
    %-R > Region xmin/xmax/ymin/ymax
    %-C > Name of the CPT
    %-B > Set map boundary frame and axes attributes. tick interval every 10 degree
    %-X > Shift plot origin relative to the current origin by (x-shift)
    %-Y > Shift plot origin relative to the current origin by (y-shift)
    %-K > Do not finalize the PostScript plot
    %-P > Select “Portrait” plot orientation.
    % > use to export to R
    
    %Plot continents, shorelines, rivers, and borders on maps
    fprintf(fid,'pscoast -JM -R -Bx10 -B+t"%s" -By5 -Df+ -Ggrey -O -K -V -N1 -W0.2 >> %%R%%\r\n',...
        [judul ' ' s]);
    %-R > region
    %-JM > Map projection Mercator
    %-Df > Selects the resolution of the data set to use. ((f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude)
    %-B > Set map boundary frame and axes attributes.
    %-G > Select filling or clipping of “dry” areas. example : -Ggrey or -G120
    %-W > Draw shorelines with 0.2 linewidth
    %-N > border .
    %1 = National boundaries;
    %2 = State boundaries within the Americas
    %3 = Marine boundaries
    %a = All boundaries (1-3)
    %>> save to %R% file
    
    %Plot a gray or color scale-bar on maps
    fprintf(fid,'gmtset FONT_LABEL 16p,4\r\n');
    fprintf(fid,'gmtset MAP_LABEL_OFFSET -2c\r\n');
    fprintf(fid,'psscale -Dx9/-1.5c/20c/0.50h -CColorpalet.cpt  -By+l%s -R -J -O  >>%%R%%\r\n',satuan);
    %-C > color palette to be used
    %-D > Defines the reference point on the map for the color scale using one of four coordinate systems
    %-B > Set annotation, tick, and gridline interval for the colorbar.
    %>> save to %R% file
    
    %Convert [E]PS file(s) to other formats using GhostScript
    fprintf(fid,'psconvert %%R%% -Tj -F%%gambar%%\r\n');
    % %R% - ps file
    % -Tj - Sets the output format, where b means BMP, e means EPS,
    % E means EPS with PageSize command, f means PDF, F means multi-page PDF,
    %j means JPEG, g means PNG, G means transparent PNG, m means PPM,
    % s means SVG, and t means TIFF [default is JPEG].
    
    fclose(fid);
    
    
    fprintf('running dos\n');
    [status,cmdout]=dos('gmt.bat'); %,'-echo'
    fprintf('done\n\n');
end