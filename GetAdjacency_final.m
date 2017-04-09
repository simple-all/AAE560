clear all
close all
clc
usage_example;
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
cterm=2*atan2(aterm.^(0.5),(1-aterm).^0.5);
Radmajor=6378137;%Earth's major axis radius in meters
Radminor=6356752.3142;%Earth's minor axis radius in meters
f=1-Radminor/Radmajor;
esquared=2*f-f^2;
Denom=1-esquared*(sin(Latitude)).^2;
N=Radmajor./Denom.^0.5;
Avg=mean(N);
Navg=(Avg(1,1)+Avg(1,2))/2;%in meters instead of meters
Radmean=6371000; %mean radius of Earth in m
DistanceGeodetic = cterm*Radmean*0.000621371;%Distance between nodes in miles
xy=[NodeInfo(:,2),NodeInfo(:,3)];
xyzcartECEF=zeros(length(xy),3);
temp = xy*pi/180;
xyzcartECEF(:,1)=Navg.*(cos(temp(:,2)).*cos(temp(:,1)));%X,Y in cartesian coord in meters
xyzcartECEF(:,2)=Navg.*(cos(temp(:,2)).*sin(temp(:,1)));%X,Y in cartesian coord in meters
xyzcartECEF(:,3)=Navg.*(sin(temp(:,2)));%X,Y in cartesian coord in meters
xycartECEF=[xyzcartECEF(:,1),xyzcartECEF(:,2)];
Xr=xyzcartECEF(1,1);
Yr=xyzcartECEF(1,2);
Zr=xyzcartECEF(1,3);
Phir=xy(1,2)*pi/180;Lambdar=xy(1,1)*pi/180;
xyzcartENU=xyzcartECEF;
xycartENU=xycartECEF;
TransformMat=[-sin(Lambdar),cos(Lambdar),0;-sin(Phir)*cos(Lambdar),-sin(Phir)*sin(Lambdar),cos(Phir);cos(Phir)*cos(Lambdar),cos(Phir)*sin(Lambdar),sin(Phir)];
for i=1:1:length(xyzcartECEF)
    xyzcartENU(i,:)=xyzcartENU(i,:)-[Xr,Yr,Zr];
    temp2=TransformMat*transpose(xyzcartENU(i,:));
    xyzcartENU(i,:)=transpose(temp2);
    xycartENU(i,:)=[xyzcartENU(i,1),xyzcartENU(i,2)];
end
xycartECEF=xycartECEF*0.000621371;%ECEF coordinates in miles
xyzcartECEF=xyzcartECEF*0.000621371;%ECEF coordinates in miles
xycartENU=xycartENU*0.000621371;%ENU coordinates in miles
xyzcartENU=xyzcartENU*0.000621371;%ENU coordinates in miles
Adjacency=accumarray(NodeIdConnect,1);
for i=1:1:length(Adjacency)
Indegree(i) = sum(Adjacency(:,i));
Outdegree(i)=sum(Adjacency(i,:));
Totaldegree(i)=Indegree(i)+Outdegree(i);
end

count=0;
Subindx=zeros(length(Adjacency),1);
NIdCon=zeros(size(NodeIdConnect));
for i = 1:1:length(Adjacency)
    if Totaldegree(i)>0
        count=count+1;
        Subindx(i)=count;
        XYENU(count,1)=xycartENU(i,1);
        XYENU(count,2)=xycartENU(i,2);
    end
end

for i=1:1:length(Adjacency)
    for j=1:1:length(NodeIdConnect)
        if Totaldegree(i) > 0
            if NodeIdConnect(j,1) == i
                NIdCon(j,1)=Subindx(i);
            end
            if NodeIdConnect(j,2) == i
                NIdCon(j,2)=Subindx(i);
            end
        end
    end
end
AdjScrubed=accumarray(NIdCon,1);
%clear temp temp2 w x X x1 y z j j2 k i idx1 idx2 g y1 Y d Avg C count;