%masking land using gebco data
%subroutine :
% - mask2poly.m
% - contourcs.m
%02-08-2018 : first created by Hollanda

function [lon,lat]=maskgebco(darat)

glat=ncread('GEBCO_2014_2D_90.0_-20.0_150.0_20.0.nc','lat');
glon=ncread('GEBCO_2014_2D_90.0_-20.0_150.0_20.0.nc','lon');
glev=ncread('GEBCO_2014_2D_90.0_-20.0_150.0_20.0.nc','elevation');

%make land masking
id=find(glev<darat);
[id1]=find(glev>=darat);
land=glev;
land(id)=0;
land(id1)=1;
land=logical(land);
p=mask2poly(land');
bujur=[];
lintang=[];
%make land polygon using NaN
for n = 1:numel(p)
if p(n).IsFilled
    if p(n).Length>1
       bujur=[bujur; NaN; p(n).X'];
       lintang=[lintang; NaN; p(n).Y'];
    end
end 
end

lon=nan(length(bujur),1);
lat=lon;

for n=1:length(bujur)
    if ~isnan(bujur(n))
       lon(n)=glon(bujur(n));
       lat(n)=glat(lintang(n));
    end
    

end

    save(['landGebco' num2str(darat) 'meter.mat'],'lon','lat')
    
    
    