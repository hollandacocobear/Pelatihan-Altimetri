% ------------------------------------------------------------------------
% Purpose : Perform collinear analysis for single/multi-mission 
%
% Input   : Matlab stucture file at Raw_1 directory
%            
% Output  : Collinear data at Raw_2 directory  
%
% Routine : -
%
%
% Dudy D. Wijaya
% Geodesy Research Group
% Institut Teknologi Bandung - Indonesia
% e-mail: wijaya.dudy@gmail.com
%
% 12-Jul-2018: Started by slightly modifying 'collinear.m' - DDW
% 19-Jul-2018: adding mkdir to output folder - HAK
% ------------------------------------------------------------------------
%% 
function collinearf(flist,fout)
tic

fdir='../Raw_1/';


% Read stack-files to be combined (if any)
% ----------------------------------------

nl=length(flist);
fprintf(' --> Read & combine stack-files : ')
if nl==1
    fname=[fdir,char(flist(nl))];
    fprintf(' %s, ',char(flist(nl)))
    load(fname);

else
    n=0;
    for x=1:nl
        fname=[fdir,char(flist(x))];
        fprintf(' %s, ',char(flist(x)))
        load(fname); 
        for y=1:length(stf)
            n=n+1;
            %stfc(n).sat=stf(y).sat;
            stfc(n).phase=stf(y).phase;
            stfc(n).cycle=stf(y).cycle;
            stfc(n).pass=stf(y).pass;
            stfc(n).equ_time=stf(y).equ_time;
            stfc(n).equ_lon=stf(y).equ_lon;
            stfc(n).data=stf(y).data;
        end
    end
    stf=stfc;clear stfc
    
end
fprintf('\n');



% Cek jumlah pass
% --------------
np=length(stf); 

% Urutkan equ-lon setiap pas dari barat ke timur
% -----------------------------------------------
eql=zeros(np,3);
for j=1:np
    eql(j,:)=[j stf(j).equ_time stf(j).equ_lon];
end
eql=sortrows(eql,3);


% Cek jumlah group untuk pass yang identik
% ----------------------------------------
k=1;gid=[];
for j=2:np
    d=vdist(0,eql(k,3),0.00001,eql(j,3))/1e3;
    dt=eql(j,2)-eql(j-1,2);
    %fprintf('Jarak: %4i  %f %f %f\n',j,d,eql(j,3),dt/(3600*24))
    if d>5
        %fprintf('---> %4i %f %f %f\n',j,d,eql(j,3),dt/(3600*24))
         gid=[gid j ];
         k=j;
    end
end
 
npg=length(gid); 
fprintf('     ... Number of pass %i ... Number of  group %i \n',np,npg)

% Collinear Analysis
% ------------------
clear coa

 
ts=1;
ng=0;
for j=1:npg
    if j==1
        id=j:gid(j)-1;
        pa=eql(id,1);
        ng=1;
    elseif j==npg
        id=gid(j):np;
        pa=eql(id,1);
        ng=ng+1;
    else
        id=gid(j-1):gid(j)-1;
        pa=eql(id,1);
        ng=ng+1;
    end
    %fprintf('Group %i/%i\n',ng,npg)
    n=length(id); 
    if n>1  % ERM data
        m=[];i=[];
        for s=1:n
            x=stf(pa(s)).data;
            t=stf(pa(s)).equ_time; 
            dto=((x(:,1)-t));
            m=[m;min(dto)];
            i=[i;max(dto)];
        end
      
        ep=round(min(m)):ts:ceil(max(i)); 
        nep=length(ep);
        
        y=NaN(nep-1,n);
        lat=y;lon=y;tv=y;
        
        for s=1:n 
            x=stf(pa(s)).data;
            t=stf(pa(s)).equ_time;
            dt=((x(:,1)-t)) ;
            for m=1:nep-1
                k=find(dt>=ep(m) & dt<ep(m+1));
                if ~isempty(k)
                    %[j ep(m) dt(k)' ep(m+1) x(k,4)']
                    tv(m,s)=mean(x(k,1));
                    y(m,s)=mean(x(k,4));
                    lat(m,s)=mean(x(k,2));
                    lon(m,s)=mean(x(k,3));
                end
            end
        end
        
        
        mssh=[nanmean(y')' nanstd(y')'];
        mpos=[nanmean(lat')' nanmean(lon')'];
        %coa(ng).sat=sat;
        coa(ng).ssh=y;
        coa(ng).tep=tv;
        coa(ng).bin=ep;
        coa(ng).lat=lat;
        coa(ng).lon=lon;
        coa(ng).mss=mssh;
        coa(ng).pos=mpos;
        coa(ng).grp=j;
        coa(ng).nfp=length(mpos);%n; %nfp tertukar dengan cycle
        
%     else %GM data
%         x=stf(pa).data;
%         t=stf(pa).equ_time;
%         dt=((x(:,1)-t));
%         stf(ng).sat=sat;
%         stf(ng).data=x(:,4);
%         stf(ng).lat=x(:,2);
%         stf(ng).lon=x(:,3);
%         stf(ng).ep=dt';
%         stf(ng).mssh=[(x(:,4)) sd*ones(length(dt),1) ];
%         stf(ng).mpos=[(x(:,2)) (x(:,3))];
%         stf(ng).group=j;
%         stf(ng).np=n;
    end
    
end
fdir=strrep(fdir,'Raw_1','Raw_2');
%make dir if folder Raw_2 not exist
mkdir(fdir)
save([fdir,fout],'coa');
fprintf('               ~~ elapsed time: %f min ~~ \n', toc/60);fprintf('\n');
end

