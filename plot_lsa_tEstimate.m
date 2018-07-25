clc;
close all;

file='GFO-1_a_col_asc_Tid_Est';
corel='GFO-1_a_col_asc_Tid_Corel';
satelit='GFO-1';
tic;
a=toc/60;
%load variables
if(~exist('tidal','var'))
    load(['../Out/',file,'.mat']);
    load(['../Out/',corel,'.mat']);
    load coast
end
ntrx=length(tidal);

fprintf('Load variables------> %f min\n\n',toc/60-a)

disp('<--  PROGRAM TO SHOW SSH PLOT OBSERVATION AND PREDICTION, ALSO CORRELATION ANALYSIS  -->')

img=input('Want to show tidal analysis figure?(1=Yes;0=No)\n');
simpan=input('Want to save the figure?(1=Yes;0=No)\n');
%option to show figure
if (img==1)
    %Open All track
    gambar
    plot(long,lat,'k')
    axis ([90 155 -20 20])
    hold on
    for i=1:5:20%ntrx
        %posisi footprint hasil colinear analysis - data dari .pos
        lintang=tidal(i).pos(:,1);
        bujur=tidal(i).pos(:,2);
        id=find(bujur==0);
        lintang(id)=[];
        bujur(id)=[];
        
        lo=min(bujur);
        lo1=max(bujur);
        la=min(lintang);
        la1=max(lintang);
        plot(bujur,lintang,'o','markerfacecolor','r','MarkerSize',2,'MarkerEdgeColor','r')
        
        b=mod(i,2);
        if(b==1)
            if(i>9)
                text(lo1-0.5,la-1,num2str(i),'fontsize',14);
            else text(lo1-0.2,la-1,num2str(i),'fontsize',14);
            end
        elseif(b==0)
            text(lo-0.6,la1+1,num2str(i),'fontsize',14);
        end
        %clear lo lo1 la la1 b lintang bujur
    end
    grid on
    
    %pilih track number yang diinginkan
    dcm_obj = datacursormode(gcf);
    info_struct = getCursorInfo(dcm_obj);
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on')
    
    disp('Click point to display a data tip');
    disp('Press ALT key to add more point')
    disp('Right-click to finish or Press Return in Command window')
    % Wait while the user does this.
    pause;
    c_info = getCursorInfo(dcm_obj);
    clear dcm_obj
    
    %Get selected pass & footprint position
    lenPass=length(c_info);
    for i=1:lenPass
        lintang=c_info(i).Position(2);
        bujur=c_info(i).Position(1);
        idxl=[];
        idxb=[];
        latj=[];
        lonj=[];
        for j=1:ntrx
            idl=find(tidal(j).pos(:,1)==lintang);
            idb=find(tidal(j).pos(:,2)==bujur);
            if(~isempty(idl))
                latj=[latj;j];
                idxl=[idxl;idl];
            end
            if(~isempty(idb))
                lonj=j;
                idxb=[idxb;idb];
                Pass(i) = intersect(latj,lonj);
                id_fp = intersect(idxl,idxb);
                footprint(i)=id_fp;
                
                %extract time observation, ssh observation, and ssh
                %prediction
                sshObs(i)=tidal(Pass(i)).sshObs(id_fp,:);
                yp(i)=tidal(Pass(i)).sshPred(id_fp,:);
                tObs(i)=tidal(Pass(i)).timeObs(id_fp,:);
                waktu=cell2mat(tObs{1,i,1}); %error data hilang 1
                tobs{i}=(datenum(mjd2date(waktu)));
                yr{i}=datepart(tobs{i},'yr');
                co_real{i}=cortide(Pass(i)).correlation(id_fp,:);
                %find constituent amplitude ==0; remove from constituent
                
                clear waktu
            end
        end
        clear  idl idb
    end
    %clear unneeded variable
    clear ntrx
    
    %Plot data observasi, prediksi, dan errornya
    for i=1:lenPass
        gambar
        %plot coordinate
        subplot(2,2,3)
        plot(long,lat,'k');
        hold on
        scatter(c_info(i).Position(1),c_info(i).Position(2),25,'g','filled')
        s=['Pass ' num2str(Pass(i)) ' Footprint ' num2str(footprint(i))];
        text(c_info(i).Position(1)-5,c_info(i).Position(2)-1,s,'fontsize',8,'fontangle','italic','color',[0.2 0.2 0.6]);
        xlabel('Longitude (\circ)')
        ylabel('Latitude (\circ)')
        hold off
        axis equal
        axis ([90 150 -15 15])
        grid on
        
        %plot SSH observation and prediction with error
        subplot (2,2,1)
        x=yr{i};
        y1=cell2mat(sshObs{1,i,1});%observation
        y2=cell2mat(yp{1,i,1});%prediction
        y3=y1-y2;
        plot(x,y1,'-b');hold on
        plot(x,y2,'-+m');
        xlabel('Year')
        ylabel('SSH (m)')
        legend('Observation','Prediction')
        legend('location','best')
        
        subplot (2,2,2)
        plot(x,y3,'-r')
        xlabel('Year')
        ylabel('Difference (m)')
        clear x y1 y2 y3
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %TIDAL CORRELATION - korelasi antar konstanta pasut ,
        %Semakin tinggi nilai korelasi maka dapat diduga bahwa kedua konstanta
        %tersebut tidak bisa dipisahkan karena kurang dari rayleigh criterion
        amp=tidal(Pass(i)).amp(id_fp,:);
        zu=find(amp~=0);
        konstanta=tidal(Pass(i)).con(zu,1);
        subplot (2,2,4)
        %imagesc(R); %caxis([-1 1]);colorbar;colormap default;
        axis equal
        title('Tidal Correlation','fontweight','bold','fontsize',15)
        s=['Tidal analysis & correlation ' satelit];
        %Option to save figure
        if (simpan==1)
            %Make directory
            fg='../gambar/';
            mkdir(fg);
            F    = getframe(gcf);
            imwrite(F.cdata, [fdir s], 'tif')
            
        end
    end
    
end

