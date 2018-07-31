%{
This plot used to see amplitude and phase residu value every cross over
point


Input :
- con : constituents used in plotting

Output :
- figure every constituent
- save image automatically

History
26-Jul-2018 : first created by Hollanda

%}
clear
close all
clc

%konstituen
con={'SA','SSA','MSF', ...
    'K1','O1','Q1', ...
    'M2','S2','N2','K2','2N2', ...
    'M4','MS4'};

%satellite name
satelit='GFO-1';

%filename-> change satelit name in 'file' according to your filename in
%folder 'Out'
file='GFO-1_a_xover_';

lencon=length(con);

for a=1:lencon
    %load file
    nama=[file con{a} '.mat'];
    
    fdir='../Out/';
    if(exist([fdir nama],'file'))
    data=importdata([fdir nama]);
    
    
    Rpha=[];
    Ramp=[];
    
    %get error value from amplitude and phase
    for i=1:length(data)
        Rpha=cat(1,Rpha,data(i).xpha(:,4));
        Ramp=cat(1,Ramp,data(i).xamp(:,3));
    end
    
    %error distribution
    gambar
    subplot(2,2,2)
    h=histfit(Ramp,50);
    title(upper(['Cross Point Amplitude Error Distribution']),'fontsize',16)
    set(gca,'FontSize',12);
    legend(h(2),'Gaussian Distribution')
    maxr=max(Ramp);
    minr=min(Ramp);
    xlim([round(minr)-1 round(maxr)+1])
    
    subplot (2,2,4)
    h=histfit(Rpha,50,'inversegaussian');
    maxr=max(Rpha);
    xlim([0 round(maxr)+1])
    title(upper(['Cross Point Phase Error Distribution constituent ']),'fontsize',16)
    set(gca,'FontSize',12);
    legend(h(2),'Inverse Gaussian Distribution')
    %save image

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %sebaran error amplitude
    subplot(2,2,[1,3])
    Samp=[];
    for j=1:i
        Samp=[Samp;data(j).xcoord_ref(:,1) data(j).xcoord_ref(:,2) data(j).xamp(:,3)];
        scatter(data(j).xcoord_ref(:,2),data(j).xcoord_ref(:,1),25,data(j).xamp(:,3),'filled')
        hold on
    end
    geoshow('landareas.shp', 'FaceColor', 'black');
    axis equal
    axis([93 152 -15 15])
    colormap jet
    c=colorbar;
    c.Label.String='Error (m)';
    %caxis([miner maxer])
    s=['Spatial Distribution Amplitude Error ' con{a} ' ' satelit];
    title(upper(s),'fontsize',16,'fontweight','bold')
    set(gca,'FontSize',12);
    xlabel('Longitude (\circ)','fontweight','bold')
    ylabel('Latitude (\circ)','fontweight','bold')
    
    s=['Cross Point Hist Amp & Phase Error constituent ' con{a} ' ' satelit];
    fg='../gambar/';
    if(exist(fg,'dir')==0)
        mkdir(fg);
    end
    F    = getframe(gcf);
    imwrite(F.cdata, [fg s '.tif'], 'tif')
    
    %display error spatial distribution from min & max value
%     gambar
%     [xc,yc]=find(Samp(:,3)>miner & Samp(:,3)<maxer);
%     scatter(Samp(xc,2),Samp(xc,1),50,Samp(xc,3),'filled')
%     hold on
%     geoshow('landareas.shp', 'FaceColor', 'black');
%     axis equal
%     axis([93 152 -15 15])
%     colormap jet
%     c=colorbar;
%     c.Label.String='Error (m)';
%     caxis([miner maxer])
%     title(upper('error spatial distribution from min & max value'),'fontweight','bold')
%     set(gca,'FontSize',16);
%     xlabel('Longitude (\circ)','fontweight','bold')
%     ylabel('Latitude (\circ)','fontweight','bold')
    end 
end