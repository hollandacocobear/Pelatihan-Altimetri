% ------------------------------------------------------------------------
% Purpose : Tidal analysis & prediction every footprint at collinear track
%
%{
 Input   : - Collinear data at Raw_2 directory
           - Nama satelit
             * TP, Jason
             * ERS, ENVISAT
             * GFO,GEOSAT
             * SARAL, SENTINEL
             * CRYOSAT
           - con : constituent pasut yang akan dicari nilai amplitude dan
           phase
%}
%{
 Output  : - mat file in out folder contain amplitude, phase, dan standar deviasniya all
             constituents
%}
%{
 Routine : - find_outliers_Thompson.m by Michele Rienzner(2010)
           - lsa_tide.m by Dudy D. Wijaya (2018)
           - t_constituents.mat from t_tide
           - GetFreq
%}

% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 12-Jul-2018: First created - DDW
%20-Jul-2018 :  - Adding option satelit and constituents - HAK
%               - Calculate satelit sampling period from variable satelit
%               -
% ------------------------------------------------------------------------
%%
function tidal_estimate(fname,satelit,con)

% CHECK VARIABLE CONSTITUENT EXIST OR NOT.
% If not exist, 13 variable used in tidal estimate
if (exist('con','var')==1)
    fprintf('\n%d Constituent ',length(con));
    if(length(con)>1)
        fprintf('s ');
    end
    fprintf('used\n\n');
else
    con={'SA','SSA','MSF', ...
        'K1','O1','Q1', ...
        'M2','S2','N2','K2','2N2', ...
        'M4','MS4'};
    fprintf('%d ',length(con));
    disp('Constituents ');
    j=0;
    for i=1:length(con)
        j=j+1;
        fprintf('%s\t',char(con{i}));
        if(j>5)
            fprintf('\n');
            j=0;
        end
    end
    fprintf('\n');
    disp('will used in tidal analysis');
    fprintf('\n\n');
end
lenCon=length(con);

%CHOOSE SAMPLING PERIOD (day) FROM SATELIT
satelit=lower(satelit);
%Choose TS
if(strncmpi(satelit,'tp',5)||strncmpi(satelit,'topex',5)||...
        strncmpi(satelit,'jason',5))
    Ts=9.91567;                         % Sampling period (day) T/P Jason
elseif (strncmpi(satelit,'ers',3)||strncmpi(satelit,'envisat',7))
    Ts=17.05;                           % Sampling period (day) ERS ENVISAT
elseif (strncmpi(satelit,'saral',5)||strncmpi(satelit,'sentinel',8))
    Ts=27;                             % Sampling period (day) SARAL SENTINEL
elseif (strncmpi(satelit,'geosat',6)||strncmpi(satelit,'gfo',3))
    Ts=35;                             % Sampling period (day) GEOSAT
elseif (strncmpi(satelit,'cryosat',5))
    Ts=369;                            % Sampling period (day) CRYOSAT2
else
    disp('Nama satelit tidak dikenal. Silahkan diulangi lagi')
    return
end
fprintf('Satelit ''%s'' have sampling periods %3.2f days\n\n',upper(satelit),Ts)


% START ANALYSIS
% --------------
fdir='../Raw_2/';
load([fdir,fname]);

to=[1985 01 01];
ntrx=length(coa);   % Number of collineared track
%create struct file
tidal=struct('con',[],'mss',[],'pos',[],'amp',[],'pha',[],'std',[],...
    'sdp',[],'sshPred',{},'sshObs',{},'timeObs',{}); %%
cortide=struct('con',[],'correlation',{}); %%

for i=1:ntrx %Track Number
    tic
    fprintf('---> Track %s dari %s\n',num2str(i),num2str(length(coa)))
    y=coa(i).ssh;   % SSH
    t=coa(i).tep;   % time
    pos=coa(i).pos; % pos
    
    [nfp,nobs]= size(y); % nfp=number of footprint, nobs=number of obs
    
    if nfp ~= 0 && nobs ~=0
        %running every footprint
        for j=1:nfp
            id=ones(nobs,1);
            t1=(date2mjd([to(1)*id to(2)*id to(3)*id 0*id 0*id t(j,:)']));
            yt=sortrows([t1 y(j,:)'],1); %sort observation from oldest to newest observation
            
            % check ISNAN
            yt(isnan(yt(:,1)),:)=[];
            if ~isempty(yt)
                %remove outlier thompson
                id=size(yt);
                if id(1) > 3
                    idx=find_outliers_Thompson(yt(:,2));
                    idx2=find(~ismember(yt(:,2),yt(idx,2))==1);
                else
                    idx2=':';
                end
                clear id
                %------------------------------------
                
                %Syarat Nyquist Frequency - jumlah data lebih panjang dari 2
                %kali jumlah konstituen pasut yang diinginkan
                if length(yt(idx2,2))>2*length(con)+1
                    
                    %TIDAL ANALYSIS EVERY FOOTPRINT
                    [mss,amp,pha,sd,err,yp,correl]= ...
                        lsa_tide(con,yt(idx2,2),yt(idx2,1),Ts,pos(j,1));
                    
                    %simpan hasil tidal analysis ke dalam variabel tidal
                    tidal(i).con(j,:)=con'; % constituent name
                    tidal(i).mss(j,1)=mss'; % mean sea surface (m)
                    tidal(i).pos(j,:)=pos(j,:);% Footprint Coordinate
                    tidal(i).amp(j,:)=amp'; % amplitude (m)
                    tidal(i).pha(j,:)=pha'; % phase (rad)
                    tidal(i).std(j,1)=err';  % standard deviation hasil prediction
                    tidal(i).sdp(j,:)=sd;  % standard deviation amplitude dan phase
                    %% add additional information from tidal estimate
                    tidal(i).sshPred{j,1}=num2cell(yp);  % ssh prediction
                    tidal(i).sshObs{j,1}=num2cell(yt(idx2,2)); % SSH observation
                    tidal(i).timeObs{j,1}=num2cell(yt(idx2,1)); % Time observation
                    
                    cortide(i).con(j,:)=con'; % constituent name
                    cortide(i).correlation{j,1}=num2cell(correl); % Nilai tidal correlation
                else
                    %Add NaN value
                    tidal(i).con(j,:)=num2cell(NaN([1 lenCon])); % constituent name
                    tidal(i).mss(j,1)=NaN; % mean sea surface (m)
                    tidal(i).pos(j,:)=NaN([1 2]);% Footprint Coordinate
                    tidal(i).amp(j,:)=NaN([1 lenCon]); % amplitude (m)
                    tidal(i).pha(j,:)=NaN([1 lenCon]); % phase (rad)
                    tidal(i).std(j,1)=NaN;  % std a posteriori (-)
                    tidal(i).sdp(j,:)=NaN([1 2*lenCon+1]);  % std parameter (m^2)
                    
                    tidal(i).sshPred{j,1}=NaN;  % ssh prediction
                    tidal(i).sshObs{j,1}=NaN; % mean sea surface (m)
                    tidal(i).timeObs{j,1}=NaN; % mean sea surface (m)
                    
                    cortide(i).con(j,:)=num2cell(NaN([1 lenCon])); % constituent name
                    cortide(i).correlation{j,1}=NaN; % Nilai tidal correlation
                end
            end
            clear idx idx2
        end
        
        
        
    else
        continue
    end
    clear  mss amp pha sd err pos1
    toc
end
%simpan variable tidal dengan nama fname di folder fout di dalam
%mat file
fout='../Out/';
if ~exist(fout,'dir');mkdir(fout);end
save([fout,[fname(1:end-4) '_Tid_Est']],'tidal');
save([fout,[fname(1:end-4) '_Tid_Corel']],'cortide');

%}

