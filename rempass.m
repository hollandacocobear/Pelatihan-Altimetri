%%
%   Remove pass track contains NaN
%   Input  > asc : struct file
%   Output > pasc : struct file removed NaN
%
% 19-Jul-2018 : first created by M Syahrullah F
%%
function [pasc]=rempass(asc)

%Removing empty data for mat file
n=0;
idAsc=zeros(length(asc),1);

for i=1:length(asc)
    if ~isempty(asc(i).con)
        n=n+1;
        idAsc(i)=n;
    else
        idAsc(i)=0;
    end
end

%Selecting Non-Empty Data
idxasc=find(idAsc~=0);
pasc=asc(idxasc);


%Checking Output
if (n==0)
    disp('No Data')
    return
end
clear asc idxasc idAsc n
end