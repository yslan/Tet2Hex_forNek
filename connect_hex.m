function con_table=connect_hex(Hexes)

iftoiv=[1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;1 2 3 4;5 6 7 8];
Nhex = size(Hexes,1); Face_hex=zeros(Nhex*6,4); k=0;

% old
%for i=1:Nhex
%  Face_hex(k+1,:)=Hexes(i,iftoiv(1,:));
%  Face_hex(k+2,:)=Hexes(i,iftoiv(2,:));
%  Face_hex(k+3,:)=Hexes(i,iftoiv(3,:));
%  Face_hex(k+4,:)=Hexes(i,iftoiv(4,:));
%  Face_hex(k+5,:)=Hexes(i,iftoiv(5,:));
%  Face_hex(k+6,:)=Hexes(i,iftoiv(6,:));
%  k=k+6;
%end
%Face_hex=sort(Face_hex,2); % sort for uniquess up to permutation
%
%[~,iUFtoF2,iFtoUF2]=unique(Face_hex,'rows'); % interger can be unique
%
%nUF=size(iUFtoF2,1); Face_pair=zeros(nUF,4); k=0;
%for i=1:Nhex; for j=1:6
%  if Face_pair(iFtoUF2(k+j),1) ==0
%    Face_pair(iFtoUF2(k+j),1)=i;
%    Face_pair(iFtoUF2(k+j),3)=j;
%  else
%    Face_pair(iFtoUF2(k+j),2)=i;
%    Face_pair(iFtoUF2(k+j),4)=j;
%  end
%end; k=k+6; end
%
%con_table=zeros(Nhex,6);
%for i=1:nUF; if Face_pair(i,2)~=0
%  con_table(Face_pair(i,1),Face_pair(i,3))=Face_pair(i,2);
%  con_table(Face_pair(i,2),Face_pair(i,4))=Face_pair(i,1);
%end;end 


% new
Nhex = size(Hexes,1); Face_hex=zeros(Nhex*6,4); k=0;
i0=1;i1=0;
for iface=1:6;
  i1=i1+Nhex;Face_hex(i0:i1,:)=Hexes(:,iftoiv(iface,:));i0=i0+Nhex;
end
Face_hex=sort(Face_hex,2); % sort for uniquess up to permutation

[~,iUFtoF2,iFtoUF2]=unique(Face_hex,'rows'); % interger can be unique

nUF=size(iUFtoF2,1); Face_pair=zeros(nUF,4); k=0;
for iface=1:6; for ie=1:Nhex;
  if Face_pair(iFtoUF2(k+ie),1) ==0
    Face_pair(iFtoUF2(k+ie),1)=ie;
    Face_pair(iFtoUF2(k+ie),3)=iface;
  else
    Face_pair(iFtoUF2(k+ie),2)=ie;
    Face_pair(iFtoUF2(k+ie),4)=iface;
  end
end; k=k+Nhex; end

con_table=zeros(Nhex,6);
for i=1:nUF; if Face_pair(i,2)~=0
  con_table(Face_pair(i,1),Face_pair(i,3))=Face_pair(i,2);
  con_table(Face_pair(i,2),Face_pair(i,4))=Face_pair(i,1);
end;end
% new2 (not faster?) DD1
%idF=(Face_pair(:,2)~=0);
%id1=sub2ind([Nhex,6],Face_pair(idF,1),Face_pair(idF,3)); con_table(id1)=Face_pair(idF,2);
%id2=sub2ind([Nhex,6],Face_pair(idF,2),Face_pair(idF,4)); con_table(id2)=Face_pair(idF,1);

