% ------------------------------------------------------------------------
% Purpose : Least square estimation of amplitudes and phases
%           of selected tidal constituents
%
%{
Input   : Collinear data at Raw_2 directory
          con       : constituent name
          y         : ssh              (nx1)
          t         : time observation (nx1)
          Ts        : Sampling period (day)
          lat       : latitude point observation
          img       : Option to show figure
          simpan    : Option to save figure to tiff file
%}
%{
 Output  : - Zo   : Mean Sea Surface
           - amp  : Amplitude All Constituents
           - pha  : Phase All Constituents
           - sd   : standard deviation a posteriori (-)
           - err  : standard deviation parameter (m^2)
           - yp   : tidal height prediction
           - R    : Tidal correlation between constituents
           - Figure (optional)
           - Save image (optional)
%}
%{
Routine : - t_constituents.mat from t_tide
          - GetFreq.m
%}
%
% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 12-Jul-2018: First created - DDW
% ------------------------------------------------------------------------
%%
function [Zo,amp,pha,sd,err,yp, R]=lsa_tide(con,y,t,Ts,lat)
% Check length of obs. (in MJD-day)
% ------------------------------
tobs=t(end)-t(1);

% Check type of nodal correction 
% If observation time more than 18.5 year use t_18constituents.mat. 
% if observation time less than 18.5 year use t_constituents.mat
% ------------------------------
ltype='nodal';
if tobs>18.5*365.25
    ltype='full';
    load('t_18constituents.mat')
else load('t_constituents.mat')
end

% Check reliability of tidal constituents
% ---------------------------------------
nc=length(con);fr=zeros(nc,1);ju=fr;
amp=zeros(nc,1);pha=amp;sd=zeros(2*nc+1,1);
for i=1:nc
    ju(i)=strmatch(char(con(i)),const.name) ;
    [fr(i),~]=GetFreq(Ts,const.freq(ju(i))*24); %check original or aliasing frequency
end

k=find(fr==0);  % Nyquist rule
if ~isempty(k)
    ju(k)=[];
    %con(k)=[];
    fr(k)=[];
    nc=length(ju);
end

k=find(1./fr>tobs);  % Rayleigh criteria
if ~isempty(k)
    ju(k)=[];
    %con(k)=[];
    fr(k)=[];
    nc=length(ju);
end

% Accumulate matrices AtY & AtA every epoch
% ------------------------------------------
tob=datenum(mjd2date(t));
tm=date2mjd([1985 1 1 0 0 0]);
rad=pi/180;maxpar=2*nc+1;
ATY=zeros(maxpar,1);
A=ATY; %%
ATA=zeros(maxpar,maxpar);
f=ones(nc,1);u=f*0;v=u;

for i=1:size(y,1)
    dt=(t(i)-tm);
    if i==1
        [v,u,f]=t_vuf(ltype,mean(tob),ju,lat) ; % nodal is corrected every epoch
        v=v*360*rad;u=u*360*rad; %vu=(v+u)*360; % total phase correction (degrees) from t_tide		
    end
    
    for j=1:nc					% CONSTRUCT EPOCH-WISE ROW MATRIX A
        arg=2*pi*fr(j)*dt+v(j)+u(j);
        A(j)=f(j)*cos(arg);
        A(j+nc)=f(j)*sin(arg);
    end
    A(maxpar)=1;
    
    for j=1:maxpar
        ATY(j)=ATY(j)+A(j)*y(i)	;	% ACCUMULATE ATY EVERY EPOCH
        for k=1:maxpar
            ATA(j,k)=ATA(j,k)+A(j)*A(k)	;% ACCUMULATE ATA EVERY EPOCH
        end
    end
    clear A
end

% LEAST SQUARE ESTIMATION
% -----------------------
Qx=pinv(ATA); %if error change to pinv
X=Qx*ATY; %X=ATA\ATY;
Zo=X(end);

% DETERMINE AMPLITUDE AND PHASE
% -----------------------------
for i=1:nc
    amp(i)=sqrt(X(i)^2+X(i+nc)^2);	% AMPLITUDE
    pha(i)=atan2(X(i+nc),X(i));		% PHASE
end

yp=zeros(size(y,1),1)+Zo;

%TIDAL ANALYSIS
for I=1:size(y,1)
    dt=(t(I)-tm);
    %[VN,PF,PU]=nodal(t(I));		% CALCULATE NODAL CORRECTIONS
    %VN=zeros(MAXCON,1);PU=zeros(MAXCON,1);PF=ones(MAXCON,1);
    for J=1:nc					% CONSTRUCT EPOCH-WISE ROW MATRIX A
        Ck=f(J)*amp(J)*cos(pha(J));
        Sk=f(J)*amp(J)*sin(pha(J));
        ARG=2*pi*fr(J)*dt+v(J)+u(J);
        yp(I)=yp(I)+Ck*cos(ARG)+Sk*sin(ARG);
        %ARG=WA(J)*dt(I)-pha(J)+VN(J)+PU(J);
        %yp(I)=yp(I)+PF(J)*amp(J)*cos(ARG);
    end
end


err=(y-yp);
err=sqrt(sum(err'*err)/(length(err)-maxpar));

%TIDAL CORRELATION
%- untuk melihat inference tiap konstituen yang dimasukkan
R=zeros(length(Qx),length(Qx)); %%
for i=1:length(Qx)
    for j=1:length(Qx)
        R(i,j)=Qx(i,j)/(sqrt(Qx(i,i))*sqrt(Qx(j,j)));
    end
end

%CALCULATE STANDARD DEVIATION
Qx=err^2*Qx;
for i=1:nc
    sd(i)=sqrt(Qx(i,i)); % Standard Deviation Amplitude
    sd(i+nc)=sqrt(Qx(i+nc,i+nc)); % Standard Deviation Phase
    %fprintf('%2i %s \t %8.2f %8.2f %8.2f\n',i,char(con(i)),1/fr(i),amp(i)*100,pha(i)/rad)
end

%Standard Deviation for Z0
sd(2*nc+1)=sqrt(Qx(2*nc+1,2*nc+1));

