% Generat arbitrary Hex mesh via Delaunay and tet-to-hex

warning off;clear all; close all;format compact;profile off;diary off;restoredefaultpath;warning on; pause(.1);

cname='output'; % All new files will go this folder

ifplot = 0; % print initial points distribution, this is expansive for large #P 
ifdump = 1; % dump mesh into vtk file for further inspection

gen_logfile(cname,1); % auto gen logfile


%% Step 0: Input points
disp_step(0,'Load points');

% % Template 1: single tet
% P=[0,0,0;1,0,0;0,1,0;0,0,1];
% 
% % Template 2: uniform lattice
% L = 3; W = 2; H = 1; % length, width and height of box
% xx=linspace(0,L,11);
% yy=linspace(0,L,7);
% zz=linspace(0,L,3);
% [X,Y,Z] = meshgrid(xx,yy,zz);
% P=[X(:),Y(:),Z(:)];

% Template 3: random points in a 3D box
L = 3; W = 2; H = 1; % length, width and height of box
npts = 201;  % # pts

P = zeros(npts,3); rng(23); % for reproducible
P(:,1) = L*rand(1,npts); %x-coordinate of a point
P(:,2) = W*rand(1,npts); %y-coordinate of a point
P(:,3) = H*rand(1,npts); %z-coordinate of a point

% % Template 4: uniform points in a unit sphere, E1,335,096
% npts=50000;
% x=normrnd(0,1,npts,1);
% y=normrnd(0,1,npts,1);
% z=normrnd(0,1,npts,1);
% R=rand(npts,1).^(1/3);
% R = R./sqrt(x.^2+y.^2+z.^2);
% P=[x.*R,y.*R,z.*R];

if(ifplot);
   scatter3(P(:,1),P(:,2),P(:,3),'MarkerFaceColor','b','MarkerEdgeColor','b'); end
fprintf('DONE loading points, #points=%d\n',size(P,1));


%% Step 1: Denauley
disp_step(1,'Denauley'); t0=tic;

Tet = delaunay(P); 
fprintf('DONE BUILD Tet, Ntet=%d (%2.4e sec)\n',size(Tet,1),toc(t0));


%% Step 2: Tet-to-Hex
disp_step(2,'Tet-to-Hex');

[Hexes,X,Xnew,Prnt] = tet2hex(P,Tet); X=[X;Xnew];
[X,Hexes] = unique_vtx(X,Prnt,Hexes);

con_table=connect_hex(Hexes);
CBC=zeros(size(Hexes,1),6);
CBC(con_table==0)=1; % 1='W  ', 2='W01', 3='W03', ...

% Some checks, print metrics
sc = 'Hini';
Xerr=chk_Xpts(X,sc,0); chk_hex(X,Hexes,sc); hex_info=chk_hex_metric(X,Hexes,sc);

if(ifdump); draw_Hexes_vtk(X,Hexes,CBC,cname,sc,-4);end


%% Step 3: dump into Nek5000 mesh
disp_step(3,'Dump Nek files');
fout='mesh';fout=[cname '/' fout];

dump_nek_con(fout,Hexes,1);      % mesh.co2
dump_nek_re2(fout,X,Hexes,CBC);  % mesh.re2 % can be speed up further


%% Ending % TODO: add summary
fprintf(['Time: ' char(datetime('now','Format','HH:mm:ss MMM/dd/yyyy')) '\n']);
disp_step(100,'End');
fprintf('FINISH, reaching EOF\n');
diary off

