close all
clear
clc

fdir='../GMT_nc/';
fout='../gambar/';
fileNC='GFO-1_a_col_K2_amp.nc';
judul='GFO-1 a Contituent K2 Amplitude';
satuan='meter';

%extract data from nc file
lon=ncread([fdir,fileNC],'lon');
lat=ncread([fdir,fileNC],'lat');
z=ncread([fdir,fileNC],'z');

%plot
gambar
imagesc(lon',lat',z')
set(gca,'YDir','normal')
hold on
geoshow('landareas.shp','FaceColor','White')
axis equal
axis([95 150 -15 15])
title(upper(judul),'fontsize',24,'fontweight','bold')
xlabel('Longitude (\circ)','fontsize',18,'fontweight','bold')
ylabel('Latitude (\circ)','fontsize',18,'fontweight','bold')
colormap jet
c=colorbar;
c.Label.String=satuan;
c.Label.FontSize=18;
set(gca,'fontsize',14)

%save image
set(gcf,'PaperPositionMode','auto')
print([fout judul ' GMT.tiff'],'-dpng','-r300')
