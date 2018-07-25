%Auto-Crossover Points Altimetry


%18-Jul-2018 : First created by Muhammad Syahrullah Fathulhuda
%25-Jul-2018 : Add plot cross over point & save image automatically - Hollanda

clc;
close all;

if(exist('flasc','var')==0)
    clear
    fdir='../Out/';
    flasc=dir([fdir,'*asc_Tid_Est.mat']);
    fldsc=dir([fdir,'*dsc_Tid_Est.mat']);
    cm='k2';
end
% con={'SA','SSA','MSF', ...
%     'K1','O1','Q1', ...
%     'M2','S2','N2','K2','2N2', ...
%     'M4','MS4'};
cm=upper(cm);

for i=1:length(flasc)
    
    %Load Data
    preff=importdata(sprintf('%s%s',fdir,flasc(i).name));
    ptgtt=importdata(sprintf('%s%s',fdir,fldsc(i).name));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    idxn=strfind(flasc(i).name,'_col_asc_Tid_Est.mat');
    satelit=flasc(i).name(1:(idxn-1));
    fprintf('Kode satelit --> %s\n',satelit)
    fprintf('\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Start Calculate Crossover Points
    pr=length(preff);
    pt=length(ptgtt);
    for j=1:pr
        %if isempty(preff(j).pos); return ; else ; break ; end
        [numc1]=selcons(preff,cm,j); %select constituent
        xdataf_amp = [];
        xdataf_pha = [];
        
        for k=1:pt
            %if isempty(ptgtt(k).pos); return ; else ; break ; end
            [numc2]=selcons(ptgtt,cm,k);
            
            %sort descending coordinates, amplitude, and phase based on
            %longitude
            amp_ref_data=sortrows([preff(j).pos  preff(j).amp(:,numc1)],2);
            pha_ref_data=sortrows([preff(j).pos  preff(j).pha(:,numc1)],2);
            amp_tgt_data=sortrows([ptgtt(k).pos  ptgtt(k).amp(:,numc2)],2);
            pha_tgt_data=sortrows([ptgtt(k).pos  ptgtt(k).pha(:,numc2)],2);
            
            if length(amp_ref_data(:,1)) > 1 && length(amp_tgt_data(:,1)) > 1
                fprintf('Cari crossver point ---> Track %s/%s ascending vs Track %s/%s descending\n',...
                    num2str(j),num2str(length(preff)),num2str(k),num2str(length(ptgtt)))
                
                %Cross Over Point
                idx_cp1=find(amp_ref_data(:,1)~=0);
                idx_cp2=find(amp_tgt_data(:,2)~=0);
                
                cp1=InterX([amp_ref_data(idx_cp1,2)';amp_ref_data(idx_cp1,1)'],...
                    [amp_tgt_data(idx_cp2,2)';amp_tgt_data(idx_cp2,1)']);
                
                clear idw_cp1 idx_cp2
                
                %Removing posible bug
                cpid=find(cp1~=0);
                cp=cp1(cpid);
                if ~isempty(cp)
                    
                    %Removing NaN
                    indx=find(~isnan(amp_ref_data(:,1)));
                    indx2=find(~isnan(amp_tgt_data(:,1)));
                    
                    %data amplitude and phase reference and target
                    ref_data_amp2=amp_ref_data(indx,:);
                    ref_data_pha2=pha_ref_data(indx,:);
                    tgt_data_amp2=amp_tgt_data(indx2,:);
                    tgt_data_pha2=pha_tgt_data(indx2,:);
                    
                    %Removing Zero Values
                    indx3=find(ref_data_amp2(:,1)~=0);
                    indx4=find(tgt_data_amp2(:,1)~=0);
                    
                    %data filtered from zero value
                    ref_data_amp=ref_data_amp2(indx3,:);
                    ref_data_pha=ref_data_pha2(indx3,:);
                    tgt_data_amp=tgt_data_amp2(indx4,:);
                    tgt_data_pha=tgt_data_pha2(indx4,:);
                    
                    clear ref_data_amp2 ref_data_pha2 tgt_data_amp2 tgt_data_pha2
                    
                    %Find Nearest Points at Crossover Points
                    %[idx_xref,dist_xref]=dsearchn([ref_data_amp(:,2),ref_data_amp(:,1)],...
                    %   [cp(1,:),cp(2,:)]);
                    %[idx_xtgt,dist_xtgt]=dsearchn([tgt_data_amp(:,2),tgt_data_amp(:,1)],...
                    %   [cp(1,:),cp(2,:)]);
                    
                    %N-D nearest point search
                    idx_xref=dsearchn([ref_data_amp(:,2),ref_data_amp(:,1)],...
                        [cp(1,:),cp(2,:)]);
                    idx_xtgt=dsearchn([tgt_data_amp(:,2),tgt_data_amp(:,1)],...
                        [cp(1,:),cp(2,:)]);
                    
                    %Calculate Nearest Distance
                    dist_xref=vdist(cp(2,:),cp(1,:),ref_data_amp(idx_xref(1),1),ref_data_amp(idx_xref(1),2))/1000;
                    dist_xtgt=vdist(cp(2,:),cp(1,:),tgt_data_amp(idx_xtgt(1),1),tgt_data_amp(idx_xtgt(1),2))/1000;
                    
                    %Collecting output
                    %cross point (id+1) | cross point (id) | amplitude | distance
                    amp_ref_datax=[cp(2,:)' cp(1,:)' ref_data_amp(idx_xref(1),:) dist_xref(1)];
                    pha_ref_datax=[cp(2,:)' cp(1,:)' ref_data_pha(idx_xref(1),:) dist_xref(1)];
                    amp_tgt_datax=[cp(2,:)' cp(1,:)' tgt_data_amp(idx_xtgt(1),:) dist_xtgt(1)];
                    pha_tgt_datax=[cp(2,:)' cp(1,:)' tgt_data_pha(idx_xtgt(1),:) dist_xtgt(1)];
                    
                    %return
                    clear idx_xref idx_xtgt indx indx2 cp ref_data_amp ref_data_pha tgt_data_amp tgt_data_pha
                    
                    %Calculate residual amplitude and phase at
                    %crossover points
                    xres_amp=abs(amp_ref_datax(5))-abs(amp_tgt_datax(5));
                    xres_pha=abs(pha_ref_datax(5))-abs(pha_tgt_datax(5));
                    
                    
                    %Calculate diff tidal constituent resultant at crossover
                    %points
                    xrst=sqrt((amp_ref_datax(5)^2)-...
                        ((amp_ref_datax(5)*amp_tgt_datax(5)*cosd(xres_pha))*2)+...
                        (amp_tgt_datax(5)^2));
                    
                    %cp (id+1)|cp(id)|dist|amplitude|resultan amplitude
                    xdata_amp(k,:)=[amp_ref_datax(1:4)...
                        amp_ref_datax(6) amp_ref_datax(5) amp_tgt_datax(5) xres_amp];
                    xdata_amp_tgt(k,:)=[amp_tgt_datax(1:4)...
                        amp_tgt_datax(6) amp_tgt_datax(5) amp_tgt_datax(5) xres_amp];
                    xdata_pha(k,:)=[pha_ref_datax(1:4)...
                        pha_ref_datax(6) pha_ref_datax(5) pha_tgt_datax(5) xres_pha xrst];
                    xdata_pha_tgt(k,:)=[pha_tgt_datax(1:4)...
                        pha_tgt_datax(6) pha_ref_datax(5) pha_tgt_datax(5) xres_pha xrst];
                    
                    clear xres_amp xres_pha xrst
                else
                    xdata_amp(k,:)=NaN([1 8]);
                    xdata_pha(k,:)=NaN([1 9]);
                    xdata_amp_tgt(k,:)=NaN([1 8]);
                    xdata_pha_tgt(k,:)=NaN([1 9]);
                end
            else
                continue
            end
            
        end
        
        nidx=find(~isnan(xdata_amp(:,1)));
        nidx2=find(~isnan(xdata_amp_tgt(:,1)));
        %prepare output
        xoverap(j).xcoord_ref=xdata_amp(nidx,1:5); %
        xoverap(j).xcoord_tgt=xdata_amp_tgt(nidx2,1:5);
        xoverap(j).xamp=xdata_amp(nidx,6:end);
        xoverap(j).xpha=xdata_pha(nidx,6:end);
        clear nidx nidx2
    end
    save(sprintf('%s%s_xover_%s.mat',fdir,flasc(i).name(1:(idxn-1)),cm),'xoverap');
end

%option to display figure
img=input('Want to display the figure?(1=Yes;0=No)\n');
if(img==1)
    simpan=input('Want to save the figure?(1=Yes;0=No)\n');
end

%plot crossover point
load coast
if (img==1)
    gambar
    p0=plot(long,lat,'-k');
    hold on
    m=length(xoverap);
    
    %plot ascending line
    for i=1:pr
        p1=plot(preff(i).pos(:,2),preff(i).pos(:,1),'b');
    end
    
    %plot descending line
    for i=1:pt
        p2=plot(ptgtt(i).pos(:,2),ptgtt(i).pos(:,1),'c');
    end
    
    for i=1:m
        p3=scatter(xoverap(i).xcoord_ref(:,2),xoverap(i).xcoord_ref(:,1),35,'or','filled'); %cross over point
        %p4=scatter(xoverap(i).xcoord_ref(:,4),xoverap(i).xcoord_ref(:,3),25,'ob','filled'); %titik terdekat dari footprint
        %p5=scatter(xoverap(i).xcoord_tgt(:,4),xoverap(i).xcoord_tgt(:,3),15,'og','filled');%titik terdekat target
    end
    xlabel('Longitude (\circ)')
    ylabel('Latitude (\circ)')
    axis equal
    axis ([95 150 -15 15])
    s=['Cross Point ' satelit];
    h = [p0;p1;p2;p3];
    
    legend(h,'Coast','asc line','dsc line','Cross Point','location','bestoutside')
    title(upper(s),'interpreter','none','fontsize',16,'fontweight','bold')
end

if(simpan==1)
    
    fg='../gambar/';
    if(exist(fg,'dir')==0)
        mkdir(fg);
    end
    F    = getframe(gcf);
    imwrite(F.cdata, [fg s '.tif'], 'tif')
end