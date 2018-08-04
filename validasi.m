%{
validate satellite data ascending and descending with FES MODEL 2014

Input:
- fasc : file ascending
- fdsc : file descending
- cons : constituent name

subroutine :
- selcons.m
- rempass.m

output:
- datainn :
- data_fes2014 :
- tideres :
- figure
%}
%19-Jul-2018 : first created by Muhammad Syahrullah F
%01-Aug-2018 : using each constituent file in folder fes2014_mat

function [datainn, data_fes2014, tideres]=validasi(fasc,fdsc,flasc,fldsc,cons,satelit,fid)

datafes='../fes2014_mat/';
fes='fes2014_';

confes={'2N2','K1','K2','M2','M4','Mf','MS4','N2','O1','Q1','S2','SA','SSA'};
id=strncmpi(cons,confes,4);
id=find(id==1);
if(isempty(id))
    datainn=[];
    data_fes2014=[];
    tideres=[];
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%import fes amplitude and phase data
fes2014a=dlmread([datafes fes 'A_' cons]);
fes2014p=dlmread([datafes fes 'P_' cons]);
fes2014_data=[fes2014a fes2014p(:,3)];
clear feas2014a fes2014p confes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%combining data ascending and descending
[data3]=rempass(flasc);
[data4]=rempass(fldsc);
tidal=[data3 data4];
[numc]=selcons(tidal,cons,1);
clear data3 data4

%all pass data
allpass=[];
for i=1:length(tidal)
    allpass=cat(1,allpass,[tidal(i).pos(:,1:2),...
        tidal(i).amp(:,numc),tidal(i).pha(:,numc)]);
end

%Data Input
idx=find(allpass(:,1)~=0);
allpass2=allpass(idx,:);
clear idx numc
idx=find(~isnan(allpass2(:,1)));
allpass3=allpass2(idx,:);
datainn=allpass3;
clear allpass allpass2 allpass3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create fes2014 model
%Amplitude
fes_grid_amp=scatteredInterpolant(fes2014_data(:,1),...
    fes2014_data(:,2),fes2014_data(:,3));
%Phase
fes_grid_phase=scatteredInterpolant(fes2014_data(:,1),...
    fes2014_data(:,2),fes2014_data(:,4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create data input model
%Amplitude
in_grid_amp=scatteredInterpolant(datainn(:,2),...
    datainn(:,1),datainn(:,3));
%Phase
in_grid_phase=scatteredInterpolant(datainn(:,2),...
    datainn(:,1),datainn(:,4));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fes2014 data in footprint
%Amplitude
fes_amp=fes_grid_amp(datainn(:,2),datainn(:,1));
%Phase
fes_pha=fes_grid_phase(datainn(:,2),datainn(:,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_fes2014=[fes_amp fes_pha];

%Calculate Residual and RMS
tideres_amp=datainn(:,3)-data_fes2014(:,1);
tideres_pha=datainn(:,4)-data_fes2014(:,2);
tiderms_amp=rms(datainn(:,3)-data_fes2014(:,1),'omitnan');
tiderms_pha=rms(datainn(:,4)-data_fes2014(:,2),'omitnan');

tideres=[tideres_amp tideres_pha];

%Find max residual amplitude and phase
%idxmax_amp=find(abs(tideres(:,1))==max(abs(tideres(:,1))));
%idxmax_pha=find(abs(tideres(:,2))==max(abs(tideres(:,2))));

%create residual model
%Amplitude
res_grid_amp=scatteredInterpolant(datainn(:,2),...
    datainn(:,1),tideres(:,1));
%Phase
res_grid_phase=scatteredInterpolant(datainn(:,2),...
    datainn(:,1),tideres(:,2));

% Calculate average spatial density
%smax=km2deg((vdist(max(datainn(:,1)),max(datainn(:,2)),...
%		min(datainn(:,1)),min(datainn(:,2))))/1000);
%ds=sqrt((2*pi*(smax/2)^2)/(length(datainn(:,2))));
ds=1/16;
%gridding for plotting (data)
xi=min(datainn(:,2)):ds:max(datainn(:,2));
yi=min(datainn(:,1)):ds:max(datainn(:,1));
[X,Y]=ndgrid(xi',yi');

%gridding for plotting (fes2014)
dx=1/16; % Spatial Resolution FES2014 model
xii=min(fes2014_data(:,1)):dx:max(fes2014_data(:,1));
yii=min(fes2014_data(:,2)):dx:max(fes2014_data(:,2));
[X1,Y1]=ndgrid(xii',yii');

%gridding amplitude and phase (FES2014)
Z_amp_fes=fes_grid_amp(X1,Y1);
Z_pha_fes=fes_grid_phase(X1,Y1);
%gridding amplitude and phase (Data)
Z_amp_data=in_grid_amp(X,Y);
Z_pha_data=in_grid_phase(X,Y);
%gridding residual amplitude and phase (Data)
Z_ramp_data=res_grid_amp(X,Y);
Z_rpha_data=res_grid_phase(X,Y);

%Plotting

%FES2014
figure('units','normalized','outerposition',[0 0 1 1])
subplot 323
imagesc(xii',yii',Z_amp_fes') %Amplitude
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',10);
title(upper(sprintf('FES2014 tidal constituent (Amplitude) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Amplitude (Meter)';
c.FontSize=10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure('units','normalized','outerposition',[0 0 1 1])
subplot 324
imagesc(xii',yii',Z_pha_fes') %Phase
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',10);
title(upper(sprintf('FES2014 tidal constituent (Phase) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Phase (radian)';
c.FontSize=12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data Input Indonesia
subplot 321
imagesc(xi',yi',Z_amp_data') %Amplitude
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',10);
title(upper(sprintf('tidal constituent (Amplitude) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Amplitude (Meter)';
c.FontSize=12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure('units','normalized','outerposition',[0 0 1 1])
subplot 322
imagesc(xii',yii',Z_pha_data') %Phase
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',10);
title(upper(sprintf('TIDAL CONSTITUENT (Phase) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Phase (radian)';
c.FontSize=12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data Input Indonesia (residual)
subplot 325
imagesc(xi',yi',Z_ramp_data') %Residual Amplitude
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',10);
title(upper(sprintf('tidal constituent Residual (Amplitude) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Amplitude (Meter)';
c.FontSize=12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot 326
imagesc(xii',yii',Z_rpha_data') %Residual Phase
hold on
geoshow('landareas.shp', 'FaceColor', 'white');
ylabel('Latitude (Degrees)','fontsize',10);
xlabel('Longitude (Degrees)','fontsize',9);
title(upper(sprintf('tidal constituent Residual (Phase) %s',cons)),'fontsize',12,'fontweight','bold');
set(gca,'YDir','normal')
axis equal
axis([95 150 -15 15])
c = colorbar;
c.Label.String = 'Phase (radian)';
c.FontSize=12;

%save figure
s=['Validasi FES2014 & Asc Dsc ' cons ' ' satelit];
fg='../gambar/';
if(exist(fg,'dir')==0)
    mkdir(fg);
end
set(gcf,'PaperPositionMode','auto')
print([fg s '.tif'],'-dpng','-r300')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'Total Track in file(%s and %s) = %s\n',fasc,fdsc,...
    num2str(length(tidal)));
fprintf(fid,'Total Footprint in file(%s and %s) = %s\n',fasc,fdsc,...
    num2str(length(datainn(:,2))));
fprintf(fid,'Amplitude RMS = %f Meter\n',tiderms_amp);
fprintf(fid,'Phase RMS = %f Radian\n',tiderms_pha);
fprintf(fid,'Highest Residual Amplitudo = %f Meter\n',max(abs(tideres(:,1))));
fprintf(fid,'Highest Residual Phase = %f Radian\n',max(abs(tideres(:,2))));
fprintf(fid,'-----------------------------');
fprintf(fid,'\n');
end