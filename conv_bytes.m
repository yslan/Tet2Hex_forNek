function [onum,otype]=conv_bytes(inum,itype);

ilv=type2lv(itype); olv=ilv; onum=inum;
if (onum>1024); olv=olv+1; onum=onum/1024; end
if (onum>1024); olv=olv+1; onum=onum/1024; end
if (onum>1024); olv=olv+1; onum=onum/1024; end
otype=lv2type(olv); 


function lv=type2lv(str)
lv=999;
if (strcmp(str,'bytes')); lv=0; return; end
if (strcmp(str,'kb') || strcmp(str,'kB') || strcmp(str,'KB')); lv=1; return; end
if (strcmp(str,'mb') || strcmp(str,'mB') || strcmp(str,'MB')); lv=2; return; end
if (strcmp(str,'kb') || strcmp(str,'gB') || strcmp(str,'GB')); lv=3; return; end
if (strcmp(str,'tb') || strcmp(str,'tB') || strcmp(str,'TB')); lv=4; return; end


function str=lv2type(lv)
switch lv
  case 0; str='bytes';
  case 1; str='KB';
  case 2; str='MB';
  case 3; str='GB';
  case 4; str='TB';
  otherwise
    str='??';
end

