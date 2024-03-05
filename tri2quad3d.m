function [Quads,X,Xnew,Prnt] = tet2hex(P,Tri)

t0=tic;
id_edge = [1,2;2,3;3,1];

X = P; nX = size(X,1); nTri = size(Tri,1); nXnew = (1+3)*nTri;

Xnew = zeros(nXnew,3); 
Prnt = zeros(nXnew,5); % [type, Xid, parent1, parent2, parent3]
Quads = zeros(nTri*3,4);

iPt=nX;iXnew=0;iHnew=0;
for itet=1:nTri % TODO remove loop later
  % Generate points: Tri center
  iTpt = iPt + 1; XTpt = zeros(1,3);
  XTpt = (X(Tri(itet,1),:)+X(Tri(itet,2),:)+X(Tri(itet,3),:))/3;
  Prnt(iXnew+1,1) = 1; Prnt(iXnew+1,2) = iTpt;

  % Generate points: Edge center
  iEpt = (iPt+2):(iPt+4); XEpt = zeros(3,3);
  XEpt(1,:) = sum(P(Tri(itet,id_edge(1,:)),:),1)/2;
  XEpt(2,:) = sum(P(Tri(itet,id_edge(2,:)),:),1)/2;
  XEpt(3,:) = sum(P(Tri(itet,id_edge(3,:)),:),1)/2;

  tP = (iXnew+2):(iXnew+4); Prnt(tP,1) = 3; Prnt(tP,2) = iEpt';
  Prnt(iXnew+2, 3:4) = Tri(itet,id_edge(1,:));
  Prnt(iXnew+3, 3:4) = Tri(itet,id_edge(2,:));
  Prnt(iXnew+4, 3:4) = Tri(itet,id_edge(3,:));

  Xnew((iXnew+1):(iXnew+4),:) = [XTpt; XEpt];

  iPt = iPt + 1 + 3;
  iXnew = iXnew + 4;

  % Generate Quad
  Quads(iHnew+1,:)=[Tri(itet,1),iEpt(1),iTpt(1),iEpt(3)];
  Quads(iHnew+2,:)=[Tri(itet,2),iEpt(2),iTpt(1),iEpt(1)];
  Quads(iHnew+3,:)=[Tri(itet,3),iEpt(3),iTpt(1),iEpt(2)];

  iHnew = iHnew + 3;

end
fprintf('DONE tri2quad, nQuad= %d (%2.4e sec)\n',size(Quads,1),toc(t0));
