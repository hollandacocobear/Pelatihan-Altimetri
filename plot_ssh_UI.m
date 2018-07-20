% ------------------------------------------------------------------------
% Purpose : Plot time series of sea surface height (SSH) at selected
%           footprints.
%
% Input   : Collinear data at Raw_2 directory
%
% Output  : Figure
%
% Routine : -
%
%
% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 12-Jul-2018: First created - DDW
% 20-jUL-2018: adding option to see all track - HAK
% 20-Jul-2018: Add save image option
% ------------------------------------------------------------------------
%%
clear;clc;close all

to=[1985 01 01];

fdir='../Raw_2/';
load([fdir,'GFO-1_a_asc']);
load coast;
ntrx=length(coa);   % Number of collineared track
%tampilkan semua track satelit
a=2;
while(a>1)
    a=input('Ingin menampilkan semua track?(1=Yes;0=No)\n');
    if(a==1)
        figure('unit','normalized','outerposition',[0 0 1 1]); %,'visible','off'
        plot(long,lat,'k')
        axis ([90 155 -20 20])
        hold on
        for i=1:ntrx
            %posisi footprint hasil colinear analysis - data dari .pos
            lintang=coa(i).pos(:,1);
            bujur=coa(i).pos(:,2);
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
            else text(lo-0.6,la1+1,num2str(i),'fontsize',14);
            end
            
            clear lo lo1 la la1 b lintang bujur
        end
        %axis equal
        %
        grid on
        %set(gcf,'visible','on')
        
    elseif(a==0)
        fprintf('Jumlah collinear track ada %d\n',ntrx);
        disp('Tentukan jumlah track yang ingin dilihat.')
        disp('Pilih no track dengan [1 2 3]');
        disp('Jika semua langsung tekan enter');
        ntrx1=input('=');
        if isempty(ntrx1);ntrx1=ntrx;
        else
            ltrx=length(ntrx1);
        end
        
    else disp('Pilihan anda salah.')
    end
    
end

%pilih footprint berdasarkan klik pada point
if(a==1)
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
    
    %extract position and check into pass/track
    lenPass=length(c_info);
    for i=1:lenPass
        lintang=c_info(i).Position(2);
        bujur=c_info(i).Position(1);
        idxl=[];
        idxb=[];
        latj=[];
        lonj=[];
        for j=1:ntrx
            idl=find(coa(j).pos(:,1)==lintang);
            idb=find(coa(j).pos(:,2)==bujur);
            if(~isempty(idl))
                latj=[latj;j];
                idxl=[idxl;idl];
            end
            if(~isempty(idb))
                lonj=j;
                idxb=[idxb;idb];
                Pass(i) = intersect(latj,lonj);
                id_fp = intersect(idxl,idxb);
               %[row col] = ind2sub(size(latj), id_fp);
               footprint(i)=id_fp;
            end
        end
        clear  idl idb
    end
   clear c_info lintang bujur idxl idxb lonj latj
end

%Jika pemilihan manual berdasarkan no track
if (a==0)
    %cari jumlah footprint dari track yang dipilih
    clear ntrx;
    lenPass=length(ntrx1);
    Pass=[];
    footprint=[];
    for i=1:lenPass %Pass
        foot=length(coa(ntrx1(i)).pos);
        fprintf('Pada track %d ada %d footprint\n',ntrx1(i), foot);
        disp('Pilih footprint yang diinginkan ([1 2 3 n])')
        %s=['id' num2str(i) '=input(''='');'];
        %eval(s);
        fp=input('=');
        footprint=[footprint fp];
        Pass=[Pass repmat(ntrx1,length(footprint))];
    end
    lenPass=length(Pass);
end

a=input('Ingin disimpan?[1.Yes 2.No]\n');

gambar
subplot 212
plot(long,lat,'-k');
x=0;
if(a==1)
    for i=1:lenPass
        y=coa(Pass(i)).ssh(footprint(i),:);
        t=coa(Pass(i)).tep(footprint(i),:);
        
        pos=[coa(Pass(i)).pos(footprint(i),1) coa(Pass(i)).pos(footprint(i),2)]; %lat lon
        nobs=length(y);
        id=ones(nobs,1);
        t1=mjd2date(date2mjd([to(1)*id to(2)*id to(3)*id 0*id 0*id t']));
        yr=datepart(datenum(t1),'yr');
        yt=sortrows([yr y'],1);
        
        %plot SSH
        subplot 211
        h=plot(yt(:,1),yt(:,2),'-');
        hold on
        x=x+1;
        legendInfo{x} = ['Pass ' num2str(Pass(i)) ' FP ' num2str(footprint(i))];
        
        %plot point di peta
        subplot 212
        hold on
        scatter(pos(2),pos(1),25,h.Color,'filled')
    end
    
elseif(a==0)
    
end

%figure properties
subplot 211
xlabel('Year');ylabel('SSH (m)');
legend(legendInfo,'location','bestoutside')

subplot 212
grid on
axis equal
axis([90 150 -17 17]);
xlabel('Lon');ylabel('Lat');
legendInfo1=['Coast' cellstr(legendInfo)];
legend(legendInfo1,'location','best')

%save imge
if(a==1)
    s=[];
   for i=1:lenPass
    s= [s ' P' num2str(Pass(i)) ' Fp' num2str(footprint(i))];
   end
s=['Plot SSH' s '.tif'];
fdir='../gambar/';
mkdir(fdir);
F    = getframe(gcf);
imwrite(F.cdata, [fdir s], 'tif')
end
%clear h i a j m n lenC id info_struct

%%finish
%}