getmatrix;
[d,e]=size(w);
e=e-1;
count=0;
for i=1:1:d
    for j=1:1:e
        count=count+1;
        j2=j+1;
        if  w(i,j)~=0 & w(i,j2)~=0
            C(count,1)=w(i,j);
            C(count,2)=w(i,j2);
        else
            count=count-1;
            break
        end
    end
end

[x1,y1]=size(C);
NodeIdConnect = zeros(size(C));
Longitude = zeros(size(C));
Latitude = zeros(size(C));
for i=1:1:x1
    idx1 = find(NodeInfo(:,4)==C(i,1));
    idx2 = find(NodeInfo(:,4)==C(i,2));
    NodeIdConnect(i,1)=NodeInfo(idx1,1);
    NodeIdConnect(i,2)=NodeInfo(idx2,1);
    Longitude(i,1)=NodeInfo(idx1,2);
    Longitude(i,2)=NodeInfo(idx2,2);
    Latitude(i,1)=NodeInfo(idx1,3);
    Latitude(i,2)=NodeInfo(idx2,3);
end
Longitude = Longitude*pi/180;%Longitude in radians
Latitude = Latitude*pi/180;%Latitude in radians
DelLat=Latitude(:,2)-Latitude(:,1);
DelLong=Longitude(:,2)-Longitude(:,1);
aterm=(sin(DelLat./2)).^2+cos(Latitude(:,1)).*cos(Latitude(:,2)).*(sin(DelLong./2)).^2;
cterm=2*atan2(a.^(0.5),(1-a).^0.5)
RadiusEarth=6371e3; %mean radius of Earth in km
Distance = cterm**0.000621371;%Distance between nodes in miles
G=accumarray(NodeIdConnect,1);