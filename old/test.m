c=0;
for i =1:1:93
    for j = 1:1:51
        if y(i,j)==0
            break
        else
            c=c+1;
            a1(c)=y(i,j);
            b2(c)=z(i,j);
        end
    end
end