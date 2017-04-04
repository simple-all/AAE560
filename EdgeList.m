[x1,y1]=size(connectivity_matrix);
count=0;
for i=1:1:x1
    for j=1:1:y1
        if connectivity_matrix(i,j)~=0
            count=count+1;
            Edges(count,1)=i;
            Edges(count,2)=j;
        end
    end
end