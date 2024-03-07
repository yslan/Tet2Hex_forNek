% Generat arbitrary Hex mesh via Delaunay and tet-to-hex

warning off;clear all; close all;format compact;profile off;diary off;restoredefaultpath;warning on; pause(.1);

cname='output'; % All new files will go this folder

ifplot = 1; % print initial points distribution, this is expensive for large #P 
ifdump = 1; % dump mesh into vtk file for further inspection

gen_logfile(cname,1); % auto gen logfile


%% Step 0: Input points (#pts,3) 
disp_step(0,'Load points');

% Template 6: uniform points in a unit sphere surface
npts=100; rng(23);
x=normrnd(0,1,npts,1);
y=normrnd(0,1,npts,1);
z=normrnd(0,1,npts,1);
R = 2.0;
Rinner=1.0;

R = R./sqrt(x.^2+y.^2+z.^2);
P=[x.*R,y.*R,z.*R];

func_rad = @(X) Rinner./sqrt(X(:,1).^2+X(:,2).^2+X(:,3).^2);
func_proj = @(X) [X(:,1).*func_rad(X), X(:,2).*func_rad(X), X(:,3).*func_rad(X)]; % 3x cost but ok :)

% Template 7: Gauss points on sphere
Router = 1.0;
Rinner = 0.5;
Nlevel = 2;

nphi=5;
ntheta=5;
u=linspace(0,pi,ntheta+1); u=u(2:end); % avoid duplicate pts
v=linspace(1/nphi,1-1/nphi,nphi)*pi; v=[v,v+pi]; % avoid poles
[phi,theta] = meshgrid(u,v);

x=sin(theta(:)).*cos(phi(:));
y=sin(theta(:)).*sin(phi(:));
z=cos(theta(:));

R = Router./sqrt(x.^2+y.^2+z.^2);
P=[x.*R,y.*R,z.*R];
P=[P;0,0,Router;0,0,-Router]; % add poles

func_rad = @(X) Rinner./sqrt(X(:,1).^2+X(:,2).^2+X(:,3).^2);
func_proj = @(X) [X(:,1).*func_rad(X), X(:,2).*func_rad(X), X(:,3).*func_rad(X)]; % 3x cost but ok :)


if(ifplot);
   scatter3(P(:,1),P(:,2),P(:,3),'MarkerFaceColor','b','MarkerEdgeColor','b'); end
fprintf('DONE loading points, #points=%d\n',size(P,1));


%% Step 1: Denauley
disp_step(1,'Denauley'); t0=tic;
Perr=chk_Xpts(P,'usr',0); 
Tri = convhulln(P);

fprintf('DONE BUILD Tri, Ntri=%d (%2.4e sec)\n',size(Tri,1),toc(t0));


%% Step 2: Tri-to-Quad
disp_step(2,'Tri-to-Quad');

[Quads,X,Xnew,Prnt] = tri2quad3d(P,Tri); X=[X;Xnew];
[X,Quads] = unique_vtx(X,Prnt,Quads);


%% Step 3: Extrude Quad to Hex
disp_step(3,'Quad-to-hex');
[Xnew,Hexes]=quad2hex(X,Quads,func_proj,Nlevel,[]); X=[X;Xnew];

con_table=connect_hex(Hexes);
CBC=zeros(size(Hexes,1),6);
CBC(con_table==0)=1; % 1='W  ', 2='W01', 3='W03', ...

% Some checks, print metrics
sc = 'Hini';
Xerr=chk_Xpts(X,sc,0); [~,Herr]=chk_hex(X,Hexes,sc); hex_info=chk_hex_metric(X,Hexes,sc);

if numel(Herr.e2)>0 % fix rhs
  Hexes = Hexes(:,[5,6,7,8,1,2,3,4]);
  [~,Herr]=chk_hex(X,Hexes,sc); 
end

if(ifdump); draw_Hexes_vtk(X,Hexes,CBC,cname,sc,-4);end


%% Step 4: dump into Nek5000 mesh
disp_step(3,'Dump Nek files');
fout='mesh2';fout=[cname '/' fout];

dump_nek_con(fout,Hexes,1);      % mesh.co2
dump_nek_re2(fout,X,Hexes,CBC);  % mesh.re2 % can be speed up further


%% Ending % TODO: add summary
fprintf(['Time: ' char(datetime('now','Format','HH:mm:ss MMM/dd/yyyy')) '\n']);
disp_step(100,'End');
fprintf('FINISH, reaching EOF\n');
diary off

