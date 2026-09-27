function c=tuongtuchum(w,xi);
gtmax=[];
for i=1:size(w,1)
gtmax=[gtmax; max(w(i,:))];
end
chieu=size(w);
k=chieu(1,2);
for i=1:chieu(1,2)-1
for j=i+1:chieu(1,2)
    if norm(w(:,i)-w(:,j))==0
        k=k-1;

    end
end
end
if k==1 
c=1;
else
c=(1-(sum(gtmax)/length(xi)*(max(xi)-min(xi)))/k)*k/(k-1);    
end

