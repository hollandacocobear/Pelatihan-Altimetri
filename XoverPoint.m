%Auto-Crossover Points Altimetry
%{
Input    :
- con    : constituents name used in cross over point

Routine  :
- selcons.m
- InterX.m

Output   :
- mat file named satellite_xover_constituent.mat
- figure (optional)
- save image automatically (optional)
%}

%History
%18-Jul-2018 : First created by Muhammad Syahrullah Fathulhuda
%25-Jul-2018 : Add plot cross over point & save image automatically - Hollanda
%26-Jul-2018 : Add option to skip cross over when constituent have zero
%              value in amplitude
%

clc;
close all;

%load variables
if(exist('flasc','var')==0)
    clear
    fdir='../Out/';
    flasc=dir([fdir,'*asc_Tid_Est.mat']);
    fldsc=dir([fdir,'*dsc_Tid_Est.mat']);
end

%constituents used in this analysis
con={'SA','SSA','MSF', ...
    'K1','O1','Q1', ...
    'M2','S2','N2','K2','2N2', ...
    'M4','MS4'};
%con={'ms4'};
con=upper(con);

lencon=length(con);

for i=1:length(flasc)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(exist('preff','var')==0)
        %Load Data Ascending and Descending
        preff=importdata(sprintf('%s%s',fdir,flasc(i).name));
        ptgtt=importdata(sprintf('%s%s',fdir,fldsc(i).name));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Satellite name
    idxn=strfind(flasc(i).name,'_col_asc_Tid_Est.mat');
    satelit=flasc(i).name(1:(idxn-1));
    fprintf('Kode satelit --> %s\n',satelit)
    fprintf('\n')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Start Calculate Crossover Points
    pr=length(preff);
    pt=length(ptgtt);
    data=cat(1,preff.amp);
    
    for q=1:lencon
        %check if all amplitude and phase value in this constituent zero
        value=isempty(find(data(:,q)));
        if (value==1)
            fprintf('Constituent %s have no amplitude value\n',con{q});
            value=0;
        else
            
            for j=1:length(preff)
                %if isempty(preff(j).pos); return ; else ; break ; end
                [numc1]=selcons(preff,con{q},j);
                xdataf_amp = [];
                xdataf_pha = [];
                for k=1:length(ptgtt)
                    %if isempty(ptgtt(k).pos); return ; else ; break ; end
                    [numc2]=selcons(ptgtt,con{q},k);
                    amp_ref_data=sortrows([preff(j).pos  preff(j).amp(:,numc1)],2);
                    pha_ref_data=sortrows([preff(j).pos  preff(j).pha(:,numc1)],2);
                    amp_tgt_data=sortrows([ptgtt(k).pos  ptgtt(k).amp(:,numc2)],2);
                    pha_tgt_data=sortrows([ptgtt(k).pos  ptgtt(k).pha(:,numc2)],2);
                    
                    if length(amp_ref_data(:,1)) > 1 && length(amp_tgt_data(:,1)) > 1
                        fprintf('Cari crossver point ---> Track %s/%s ascending vs Track %s/%s descending\t|\t%s\n',...
                            num2str(j),num2str(length(preff)),num2str(k),num2str(length(ptgtt)),con{q})
                        
                        cp1=InterX([amp_ref_data(:,2)';amp_ref_data(:,1)'],...
                            [amp_tgt_data(:,2)';amp_tgt_data(:,1)']);
                        
                        %Removing posible bug
                        cpid=find(cp1~=0);
                        cp=cp1(cpid);
                        if ~isempty(cp)
                            
                            %Removing NaN
                            indx=find(~isnan(amp_ref_data(:,1)));
                            indx2=find(~isnan(amp_tgt_data(:,1)));
                            
                            ref_data_amp2=amp_ref_data(indx,:);
                            ref_data_pha2=pha_ref_data(indx,:);
                            tgt_data_amp2=amp_tgt_data(indx2,:);
                            tgt_data_pha2=pha_tgt_data(indx2,:);
                            
                            
                            %Removing Zero Values
                            indx3=find(ref_data_amp2(:,1)~=0);
                            indx4=find(tgt_data_amp2(:,1)~=0);
                            
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
                            
                            idx_xref=dsearchn([ref_data_amp(:,2),ref_data_amp(:,1)],...
                                [cp(1,:),cp(2,:)]);
                            idx_xtgt=dsearchn([tgt_data_amp(:,2),tgt_data_amp(:,1)],...
                                [cp(1,:),cp(2,:)]);
                            
                            %Calculate Nearest Distance
                            dist_xref=vdist(cp(2,:),cp(1,:),ref_data_amp(idx_xref(1),1),ref_data_amp(idx_xref(1),2))/1000;
                            dist_xtgt=vdist(cp(2,:),cp(1,:),tgt_data_amp(idx_xtgt(1),1),tgt_data_amp(idx_xtgt(1),2))/1000;
                            
                            %Collecting output
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
                xoverap(j).xcoord_ref=xdata_amp(nidx,1:5);
                xoverap(j).xcoord_tgt=xdata_amp_tgt(nidx2,1:5);
                xoverap(j).xamp=xdata_amp(nidx,6:end);
                xoverap(j).xpha=xdata_pha(nidx,6:end);
                clear nidx nidx2 xdata_amp xdata_amp_tgt xdata_amp xdata_pha
            end
            
            %check empty field
            m=length(xoverap);
            n=0;
            for un=1:m
                xc=isempty(xoverap(un).xcoord_ref);
                if (xc==0)
                    n=n+1;
                    xover1(n).xcoord_ref=xoverap(un).xcoord_ref;
                    xover1(n).xcoord_tgt=xoverap(un).xcoord_tgt;
                    xover1(n).xamp=xoverap(un).xamp;
                    xover1(n).xpha=xoverap(un).xpha;
                end
            end
            
            clear xoverap xdata_pha_tgt xdataf_amp xdataf_pha xc un pha_ref_data
            clear pha_ref_datax pha_tgt_data pha_tgt_datax numc1 numc2 indx4 indx3
            clear idxn idx_cp2 idx_cp1 dist_xtgt dist_xref cpid cp1 cp
            clear amp_tgt_datax amp_ref_data amp_ref_datax amp_tgt_data
            
            xoverap=xover1;
            save(sprintf('%s%s_xover_%s.mat',fdir,satelit,con{q}),'xoverap');
            fprintf('%s%s_xover_%s.mat saved\n',fdir,satelit,con{q});
            pause(2)
        end
    end
end

clear i j k q data m n
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
    xlabel('Longitude (\circ)','fontsize',16,'fontweight','bold')
    ylabel('Latitude (\circ)')
    axis equal
    axis ([93 152 -17 17])
    s=['Cross Point ' satelit];
    h = [p0;p1;p2;p3];
    set(gca,'fontsize',14)
    legend(h,'Coast','Ascending line','Descending line','Cross Point','location','bestoutside')
    title(upper(s),'interpreter','none','fontsize',24,'fontweight','bold')
    
    clear h p0 p1 p2 p3
end

if(simpan==1)
    
    fg='../gambar/';
    if(exist(fg,'dir')==0)
        mkdir(fg);
    end
    F    = getframe(gcf);
    imwrite(F.cdata, [fg s '.tif'], 'tif')
end