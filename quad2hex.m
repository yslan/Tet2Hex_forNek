function [Xnew,Hexes]=extrude_Sphere_Q(X,QuadsAll,func_proj,Nlevel,par_in)
% lv=1: facet -> lv=Nlevel: sphere
% ordering: bottom=facet | 0<par(1)<par(2)<...<par(end)=1.0 | top=sph  % FIXME
%                        | par(1) | par(2)-par(1) | ...     | 
% Note for developing overlapped spheres:
%   project pts onto Sph(isph,Rs_bdry), if dist(pts,isph) > Rs_bdry
%   project pts onto Sph(isph,Rtarget), if dist(pts,isph) <=Rs_bdry
%     where Rtarget = 0.5*( dist(pts,isph) + Rs )

t0=tic; nX0=size(X,1); nQ0=size(QuadsAll,1);

% set par
if(isempty(par_in)==1); % uniform(default)
  Rpar=linspace(0,1,Nlevel+1);Rpar=Rpar(2:end);nRpar=length(Rpar);por=diff([0,Rpar]);
  fprintf('  extrude Q on S: uniform par: facet|');for i=1:nRpar;fprintf('%2d%%|',int32(100*por(i)));end;fprintf('sph\n');
else % custom
  Rpar=par_in;nRpar=length(Rpar);por=diff([0,Rpar]);
  fprintf('  extrude Q on S: custom par: facet|');for i=1:nRpar;fprintf('%2d%%|',int32(100*por(i)));end;fprintf('sph\n');
end
if(nRpar~=Nlevel);fprintf('ERROR: extrude_Sphere_Q, Rpar wrong size,%d\n',nRpar);dbg;end
if(sum(por<=0)>0);fprintf('ERROR extrude Q on S diff(par)<0\n');dbg;end
if(abs(sum(por)-1)>1e-6);fprintf('ERROR extrude Q on S sum(par)~=1\n');dbg;end

% Allocate static memory
Nhex=Nlevel*nQ0; Hexes=zeros(Nhex,8); 
nXnew=nX0*(2*Nlevel+1); Xnew=zeros(nXnew,3);

ih0=1;ih1=0; ih2=1;ih3=0; ix0=1;ix1=0;
%% Start Loop (legacy)
  % collect Quads, Ids
  iquad=QuadsAll;
  
  % Generate new points
  myXYZ=X; newXYZ=func_proj(X);
  Arr=newXYZ-myXYZ; 
  for lv=1:Nlevel; iX4(lv)=nX0+ix1;
  Xtmp=myXYZ + Arr * Rpar(lv); nx=size(Xtmp,1); ix1=ix1+nx;
  Xnew(ix0:ix1,:)=Xtmp; ix0=ix0+nx;
  end
  
  % Generate Hexes
  iHex_l=iquad; iHex_r=iHex_l; nHlv=size(iHex_l,1);
  for lv=1:Nlevel; ih1=ih1+nHlv; 
  Hexes(ih0:ih1,:)=[iHex_r+iX4(lv),iHex_l]; ih0=ih0+nHlv;
  iHex_l=iHex_r+iX4(lv); 
  end
  
  % Track connection,
  if Nlevel==1; lv=1; ih3=ih3+nHlv;
    ih2=ih2+nHlv;
  else
    lv=1; ih3=ih3+nHlv;
    ih2=ih2+nHlv;
    for lv=2:Nlevel-1; ih3=ih3+nHlv;
    ih2=ih2+nHlv;
    end
    lv=Nlevel; ih3=ih3+nHlv;
    ih2=ih2+nHlv;
  end

% Adjust var sizes
if( Nhex<ih1);fprintf('  WARN extrude_Sphere_Q, allocate more for Nhex, %d %d\n',ih1,Nhex);end; 
if(nXnew<ix1);fprintf('  WARN extrude_Sphere_Q, allocate more for nX, %d %d\n',ix1,nXnew);end; 
Nhex=ih1; Hexes=Hexes(1:Nhex,:);
nX=ix1;   Xnew=Xnew(1:nX,:);

fprintf('DONE extrude_Sphere_Q nhex= %d nX= %d (%2.4e sec)\n',Nhex,nX,toc(t0));
