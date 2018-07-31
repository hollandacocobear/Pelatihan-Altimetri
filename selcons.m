%select constituent index from spesific track
%created by Muhammad Syahrullah F
function [numc]=selcons(fl,cm,k)
 
lc=fl(k).con;

n=0;
for j=1:size(lc,1)
    if ~isempty(lc{j})
        if ~isnan(lc{j})
            n=n+1;
            m(j)=n;
        else
            m(j)=0;
        end
        
        else
            m(j)=0;
    end
    
end

idxcon1=find(m~=0);

for i=1:size(lc,2)    
    tf(i)=strcmp(lc{idxcon1(1),i},cm);      
end
numc=find(tf==1);

end