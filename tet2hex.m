function [Hexes,X,Xnew,Prnt] = tet2hex(P,Tet)

t0=tic;
id_face = [1,2,3;1,2,4;2,3,4;3,1,4];
id_edge = [1,2;2,3;3,1;1,4;2,4;3,4];

X = P; nX = size(X,1); nTet = size(Tet,1); nXnew = (1+4+6)*nTet;

Xnew = zeros(nXnew,3); 
Prnt = zeros(nXnew,5); % [type, Xid, parent1, parent2, parent3]
Hexes = zeros(nTet*4,8);

iPt=nX;iXnew=0;iHnew=0;
for itet=1:nTet % TODO remove loop later
  % Generate points: Tet center
  iTpt = iPt + 1; XTpt = zeros(1,3);
  XTpt = (X(Tet(itet,1),:)+X(Tet(itet,2),:)+X(Tet(itet,3),:)+X(Tet(itet,4),:))/4;

  Prnt(iXnew+1,1) = 1; Prnt(iXnew+1,2) = iTpt;

  % Generate points: Face center
  iFpt = (iPt+2):(iPt+5); XFpt = zeros(4,3);
  XFpt(1,:) = sum(P(Tet(itet,id_face(1,:)),:),1)/3;
  XFpt(2,:) = sum(P(Tet(itet,id_face(2,:)),:),1)/3;
  XFpt(3,:) = sum(P(Tet(itet,id_face(3,:)),:),1)/3;
  XFpt(4,:) = sum(P(Tet(itet,id_face(4,:)),:),1)/3;
  
  tP = (iXnew+2):(iXnew+5); Prnt(tP,1) = 2; Prnt(tP,2) = iFpt';
  Prnt(iXnew+2,3:5) = Tet(itet,id_face(1,:));
  Prnt(iXnew+3,3:5) = Tet(itet,id_face(2,:));
  Prnt(iXnew+4,3:5) = Tet(itet,id_face(3,:));
  Prnt(iXnew+5,3:5) = Tet(itet,id_face(4,:));

  % Generate points: Edge center
  iEpt = (iPt+6):(iPt+11); XEpt = zeros(6,3);
  XEpt(1,:) = sum(P(Tet(itet,id_edge(1,:)),:),1)/2;
  XEpt(2,:) = sum(P(Tet(itet,id_edge(2,:)),:),1)/2;
  XEpt(3,:) = sum(P(Tet(itet,id_edge(3,:)),:),1)/2;
  XEpt(4,:) = sum(P(Tet(itet,id_edge(4,:)),:),1)/2;
  XEpt(5,:) = sum(P(Tet(itet,id_edge(5,:)),:),1)/2;
  XEpt(6,:) = sum(P(Tet(itet,id_edge(6,:)),:),1)/2;

  tP = (iXnew+6):(iXnew+11); Prnt(tP,1) = 3; Prnt(tP,2) = iEpt';
  Prnt(iXnew+6, 3:4) = Tet(itet,id_edge(1,:));
  Prnt(iXnew+7, 3:4) = Tet(itet,id_edge(2,:));
  Prnt(iXnew+8, 3:4) = Tet(itet,id_edge(3,:));
  Prnt(iXnew+9, 3:4) = Tet(itet,id_edge(4,:));
  Prnt(iXnew+10,3:4) = Tet(itet,id_edge(5,:));
  Prnt(iXnew+11,3:4) = Tet(itet,id_edge(6,:));

  Xnew((iXnew+1):(iXnew+11),:) = [XTpt; XFpt; XEpt];

  iPt = iPt + 1 + 4 + 6;
  iXnew = iXnew + 11;

  % Generate Hexes
  Hexes(iHnew+1,:)=[Tet(itet,1),iEpt(1),iFpt(1),iEpt(3), iEpt(4),iFpt(2),iTpt,iFpt(4)];
  Hexes(iHnew+2,:)=[Tet(itet,2),iEpt(2),iFpt(1),iEpt(1), iEpt(5),iFpt(3),iTpt,iFpt(2)];
  Hexes(iHnew+3,:)=[Tet(itet,3),iEpt(3),iFpt(1),iEpt(2), iEpt(6),iFpt(4),iTpt,iFpt(3)];
  Hexes(iHnew+4,:)=[Tet(itet,4),iEpt(5),iFpt(2),iEpt(4), iEpt(6),iFpt(3),iTpt,iFpt(4)];

  iHnew = iHnew + 4;

end

fprintf('DONE tet2hex, nhex= %d (%2.4e sec)\n',size(Hexes,1),toc(t0));
