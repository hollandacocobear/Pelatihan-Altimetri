%19-Jul-2018 : first created by Muhammad Syahrullah F

function [consID,lenCon]=findcons(flasc,consname)
lc=flasc(1).con(1,:);
lenCon=length(lc);
%find constituent column number based on flasc
consID=find(strncmpi(consname,lc,4)==1);
end


