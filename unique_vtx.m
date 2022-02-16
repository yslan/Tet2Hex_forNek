function [X,Hexes] = unique_vtx(X,Prnt,Hexes)

% Prnt [type, Xid, parent1, parent2, parent3]
% Prnt(:,1): type
%  1:     Tet center
%  2:     Face center
%  3:     Edge center

t0=tic;
nX=size(X,1); nP=size(Prnt,1); if nP>nX; error('ERROR: more parents then points!'); end

% sort index to compare without orientation
for i=1:nP; 
  tp=Prnt(i,1); % grep type
  if tp==2;      % face center
    Prnt(i,3:5)=sort(Prnt(i,3:5));
  elseif tp==3;  % edge center
    Prnt(i,3:4)=sort(Prnt(i,3:4));
  end
end

% sort to do unique
[Prnt,isort]=sortrows(Prnt,[1,3,4,5]); jsort(isort)=1:nP;

% find router pointer and remove pointer
id_rm=logical(zeros(nX,1)); iXtoUX=(1:nX)';
if nP>0
Xlast=Prnt(1,2);
Plast=Prnt(1,:);
for i=2:nP
  Xid=Prnt(i,2);
  if Prnt(i,1)==1
      Plast=Prnt(i,:); Xlast=Xid;
  else
    if sum(abs(Prnt(i,[1,3:end])-Plast([1,3:end])))~=0
      Plast=Prnt(i,:); Xlast=Xid;
    else
      id_rm(Xid)=1;      % this is duplicate, remove it
      iXtoUX(Xid)=Xlast; % redirect pointer
    end
  end
end
end 

% put them together
id=1:nX; id(logical(id_rm))=[]; id2(id)=1:length(id); % This kills my brain, hope don't have to go through again...
iXtoUX=id2(iXtoUX);

n1=nX; n2=sum(~id_rm);
fprintf('DONE CLEAN points by parents, #old=%d #new=%d, #purged=%d (%2.4e sec)\n',...
         n1,n2,n1-n2,toc(t0))


% clean up vertices to work array
X(id_rm,:)=[];
Hexes=iXtoUX(Hexes);
