%Remove empty data in the footprint
%- 21-Jul-2018   first created by Hollanda

%Remove NaN value in every footprint

% 21-Jul-2018: First created modified from rempass - Hollanda

function out=remfoot(file,opsi)

lenasc=length(file);
out=struct([]);
%idAsc=zeros(length(asc),1);

for i=1:lenasc
    %Define total footprint in current pass track
    [k,~]=size(file(i).con);
    n=0;
    for j = 1:k
        %check value char in var con
        if(ischar(file(i).con{j}))
            n=n+1;
            out(i).con(n,:)=file(i).con(j,:); % constituent name
            
            if(opsi==0)
                out(i).mss(n,1)=file(i).mss(j,1); % mean sea surface (m)
                out(i).pos(n,:)=file(i).pos(j,:);% Footprint Coordinate
                out(i).amp(n,:)=file(i).amp(j,:); % amplitude (m)
                out(i).pha(n,:)=file(i).pha(j,:); % phase (rad)
                out(i).std(n,1)=file(i).std(j,1);  % standard deviation prediction
                out(i).sdp(n,:)=file(i).sdp(j,:);  % standard deviation parameter (m^2)
                out(i).sshPred{n,1}=file(i).sshPred{j,1};  % ssh prediction
                out(i).sshObs{n,1}=file(i).sshObs{j,1}; % SSH observation
                out(i).timeObs{n,1}=file(i).timeObs{j,1}; % Time observation
                
            elseif (opsi==1)
                out(i).correlation{n,1}=file(i).correlation{j,1}; % Nilai tidal correlation
            end
        end
    end
end

clear lenasc i j k n file opsi
end


