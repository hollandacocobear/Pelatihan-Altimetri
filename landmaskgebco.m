%delete altimetry data inside land using GEBCO data

%02-08-2018 : first created by Hollanda

close all
clear
clc
pause(1)


%uncomment on of these option
%Estimate='*_Tid_Est.mat';
xOver='*_xover_*.mat';

%choose z buffer
darat=0; %in meter

fdir='../Out/';
fout='../OutF/';

if(~exist('Estimate','var'))
    tipe='xOver';
else tipe='Estimate';
end

%option to display figure
tampil=1;

s=sprintf('file=dir([fdir %s]);',tipe);
eval(s);
lenF=length(file);

%produce land mask using gebco data
if(~exist(['landGebco' num2str(darat) 'meter.mat'],'file'))
[lon,lat]=maskgebco(darat);
else load (['landGebco' num2str(darat) 'meter.mat']);
end

%looping process
for z=1:lenF
    clear nama data data1 in on i j k
    nama=file(z).name;
    fprintf('--> Process %s\n',nama);
    data=importdata([fdir nama]);
    
    %in polygon    
    if (~exist('Estimate','var')) %for xOver
        data1=struct('xcoord_ref',[],'xcoord_tgt',[],'xamp',[],'xpha',[]);
        for i=1:numel(data)
            n=0;
            [in,on]=inpolygon(data(i).xcoord_ref(:,2),data(i).xcoord_ref(:,1),lon,lat);
            for j=1:length(in)
                if(in(j)==0&&on(j)==0)
                    n=n+1;
                    data1(i).xcoord_ref(n,:)=data(i).xcoord_ref(j,:);
                    data1(i).xcoord_tgt(n,:)=data(i).xcoord_ref(j,:);
                    data1(i).xamp(n,:)=data(i).xcoord_ref(j,:);
                    data1(i).xpha(n,:)=data(i).xcoord_ref(j,:);
                end
            end
        end
        
    else %for tidal estimate
        data1=struct('con',{},'mss',[],'pos',[],'amp',[],'pha',[],...
                'std',[],'sdp',[],'sshPred',{},'sshObs',{},'timeObs',{});
        for i=1:numel(data)
            n=0;
            [in,on]=inpolygon(data(i).pos(:,2),data(i).pos(:,1),lon,lat);
            for j=1:length(in)
                if(in(j)==0&&on(j)==0)
                    n=n+1;
                    data1(i).con(n,:)=data(i).con(j,:);
                    data1(i).mss(n,1)=data(i).mss(j,1);
                    data1(i).pos(n,:)=data(i).pos(j,:);
                    data1(i).amp(n,:)=data(i).amp(j,:);
                    data1(i).pha(n,:)=data(i).pha(j,:);
                    data1(i).std(n,:)=data(i).std(j,:);
                    data1(i).sdp(n,:)=data(i).sdp(j,:);
                    data1(i).sshPred(n,:)=data(i).sshPred(j,:);
                    data1(i).sshObs(n,:)=data(i).sshObs(j,:);
                    data1(i).timeObs(n,:)=data(i).timeObs(j,:);
                end
            end
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%

    %save filtered data
    if(~exist(fout,'dir'))
        mkdir(fout)
    end
    save([fout,nama],'data1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    %Concatenate array
    alldat=[];
    alldat1=[];
    
    for k=1:numel(data)
        if (~exist('Estimate','var')) %for xOver
            alldat=cat(1,alldat,data(k).xcoord_ref(:,1:2));
            if(~isempty(data1(k).xcoord_ref))
                alldat1=cat(1,alldat1,data1(k).xcoord_ref(:,1:2));
            end
        else
            alldat=cat(1,alldat,data(k).pos(:,1:2));
            if(~isempty(data1(k).pos))
                alldat1=cat(1,alldat1,data1(k).pos(:,1:2));
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %display figure
    if(tampil==1)
        gambar
        hold on
        plot(alldat(:,2),alldat(:,1),'r*')
        plot(alldat1(:,2),alldat1(:,1),'b*')
        plot(lon,lat,'k')
        hold off
        axis equal
        xlabel('Longitude (Degrees)');ylabel('Latitude (Degrees)');
        legend('Raw','Filtered','Coast Line')
    end
    
    %dont display figure for other xOver contituent
    if(strcmp(tipe,'xOver'))
        tampil=0;
    end
    
    fprintf('--> %s finish!\n',nama);
end


