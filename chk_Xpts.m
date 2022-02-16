function err=chk_Xpts(X,str,ifplt)
% origin: chk_ifuniq

err=[]; ierr=0; t0=tic;

% 0. chk if real
[err5,~]=find(imag(X)>0); err5=unique(err5);ne5=length(err5); err.e5=err5;
me5=min(ne5,3);s5=[];for i=1:me5; s5=[s5 '%6d'];end
if ne5>0;fprintf(['  err: chk_Xpts %6s: %4d pts imag, 1st: ' s5 '\n'],str,ne5,err5(1:me5));ierr=5;end


% 1. chk if uniq
err1=[]; tolc=1.e-8; 
[X_chk,~,iXtoUX]=uniquetol(X,tolc,'ByRows',true);% way faster

n1=size(X,1); n2=size(X_chk,1); 
if(n1~=n2);ierr=1; 
  fprintf('  err: chk_Xpts %6s: pts are not unique! #old=%d, #new=%d, #diff=%d\n',str,n1,n2,n1-n2);

  if(ifplt); nX=size(X,1); 
    id=setdiff((1:nX)',iXtoUX);
    id2=find(hist(iXtoUX,unique(iXtoUX))>1);
    for i=1:length(id2);
      id3=find(iXtoUX==id2(i));
      plot3(X(id3,1),X(id3,2),X(id3,3),'ro'); hold on; axis equal
      err1=[err1,id3'];
    end
    title([str ' #=' num2str(length(id))]); drawnow
  end;
  err1=unique(err1);
end; err.e1=err1;

% 2.3 check bad numbers as well
[err3,~]=find(isinf(X)); err3=unique(err3);ne3=length(err3); err.e3=err3;
[err4,~]=find(isnan(X)); err4=unique(err4);ne4=length(err4); err.e4=err4;

me3=min(ne3,3);s3=[];for i=1:me3; s3=[s3 '%6d'];end
me4=min(ne4,3);s4=[];for i=1:me4; s4=[s4 '%6d'];end
if ne3>0;fprintf(['  err: chk_Xpts %6s: %4d pts has Inf, 1st: ' s3 '\n'],str,ne3,err3(1:me3));ierr=3;end
if ne4>0;fprintf(['  err: chk_Xpts %6s: %4d pts has NaN, 1st: ' s4 '\n'],str,ne4,err4(1:me4));ierr=4;end

if (ierr==0); 
  fprintf('  PASSED chk_Xpts %s (imag, uniq, Inf, NaN) (%2.4e sec)\n',str,toc(t0))
else;
  fprintf('  ERROR chk_Xpts %s (imag, uniq, Inf, NaN) (%2.4e sec)\n',str,toc(t0)); dbg
end
