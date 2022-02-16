function [JACM3,err]=chk_hex(X,Hexes,str)
t0=tic;

E=size(Hexes,1); err=[];ierr=0; ns=min(length(str),6);str=str(1:ns);
i0=[1,2,3,4,5,6,7,8,1,2,3,4];
i1=[2,3,4,1,6,7,8,5,5,6,7,8];

% chk1: zero length
t1=tic;
Xd=X(Hexes(:,i0),:)-X(Hexes(:,i1),:); w=sqrt(sum(Xd.^2,2)); h=min(w); err.short_edge=h;
err1=[];if(h==0);[id,icol]=find(reshape(w,E,12)==0);err1=unique(id);end
fprintf('    done chk1 (%2.4e sec)\n',toc(t1));

% chk2: right handness
t1=tic;
ii1=[2,4,1,3,6,8,5,7];ii2=[3,1,4,2,7,5,8,6];ii3=[5,6,7,8,1,2,3,4];ii4=[1,2,3,4,5,6,7,8];
V=chk_rhs(X,Hexes,ii1,ii2,ii3,ii4);
err2=[];if(min(V(:))<0);[id,icol]=find(V<0);err2=unique(id);end
fprintf('    done chk2 (%2.4e sec)\n',toc(t1));

% chk3: negative Jacobian
t1=tic;
for d=1:3; Xtmp=X(Hexes,d); Xl(:,:,d)=reshape(Xtmp,E,8); end % GtoL 
JACM3=comp_Jacobian_v3_2(Xl); JACM3=reshape(JACM3,8,E)';
err3=[];if(min(JACM3(:))<0);[id,col]=find(JACM3<0);err3=unique(id);end
fprintf('    done chk3 (%2.4e sec)\n',toc(t1));

% chk4: isnan
t1=tic;
err4=find(isnan(X));
fprintf('    done chk4 (%2.4e sec)\n',toc(t1));

% make error print and output
ne1=length(err1); err.e1=err1;
ne2=length(err2); err.e2=err2;
ne3=length(err3); err.e3=err3;
ne4=length(err4); err.e4=err4;

if ne1>0; ierr=1; me1=min(ne1,3);s1=[];for i=1:me1; s1=[s1 '%6d'];end
  fprintf(['  >>> CHK: chk_hex %6s: %4d elements have zero edge,       1st: ' s1 '\n'],str,ne1,err1(1:me1)); end
if ne2>0; ierr=2; me2=min(ne2,3);s2=[];for i=1:me2; s2=[s2 '%6d'];end
  fprintf(['  >>> CHK: chk_hex %6s: %4d elements fail right-handiness, 1st: ' s2 '\n'],str,ne2,err2(1:me2)); end
if ne3>0; ierr=3; me3=min(ne3,3);s3=[];for i=1:me3; s3=[s3 '%6d'];end
  fprintf(['  >>> CHK: chk_hex %6s: %4d elements have Neg-Jac,         1st: ' s3 '\n'],str,ne3,err3(1:me3)); end
if ne4>0; ierr=4; me4=min(ne4,3);s4=[];for i=1:me4; s4=[s4 '%6d'];end
  fprintf(['  >>> CHK: chk_hex %6s: %4d elements have NaN X,           1st: ' s4 '\n'],str,ne4,err4(1:me4)); end


if(ierr==0); 
  fprintf('  PASSED chk_hex %6s (0len, RHS, NegJac, NaN) (%2.4e sec)\n',str,toc(t0)); 
elseif(ierr==4); 
  fprintf('  ERROR chk_hex %6s (%2.4e sec)\n',str,toc(t0));dbg;% fetal error
else
  fprintf('  >>> CHK: chk_hex %6s (%2.4e sec)\n',str,toc(t0));
end


function  V=chk_rhs(X,Hexes,ii1,ii2,ii3,ii4)

VOLUM0=@(P1,P2,P3,P0) dot(cross(P1-P0,P2-P0,2),P3-P0,2);

ii0=[1 2 4 3 5 6 8 7];
ii1=ii0(ii1);ii2=ii0(ii2);ii3=ii0(ii3);ii4=ii0(ii4);

E=size(Hexes,1);% Hexes=Hexes(:,[1 2 4 3 5 6 8 7]);
P1=X(Hexes(:,ii1),:); P2=X(Hexes(:,ii2),:); P3=X(Hexes(:,ii3),:); P0=X(Hexes(:,ii4),:);
V=VOLUM0(P1,P2,P3,P0); V=reshape(V,E,8);V(:,5:8)=-V(:,5:8);

