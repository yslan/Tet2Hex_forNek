function dump_nek_con(fname,Hexes,ifco2)
% Tested by test_con.m
t0=tic;

if(ifco2); ext='.co2'; fname=[fname ext]; write_co2(fname,Hexes); 
else;      ext='.con'; fname=[fname ext]; write_con(fname,Hexes); end

[osize,otype]=comp_fsize(fname);
fprintf(['DONE dump ' ext ' file ' fname ' (%3.1f %s %2.4e sec)\n'],osize,otype,toc(t0));


function write_con(fname,Hexes)
  [nH,nv]=size(Hexes); fmt='';for i=1:nv+1;fmt=[fmt '%12d'];end;fmt=[fmt '\n'];
  map=[(1:nH)',Hexes]; map=map(:,[1,2,3,5,4,6,7,9,8]);

  fid=fopen(fname,'w');
  fprintf(fid,'#v001%12d%12d%12d\n',nH,nH,nv);
  fprintf(fid,fmt,map');
  fclose(fid);

function write_co2(fname,Hexes)
  [nH,nv]=size(Hexes); map=[(1:nH)',Hexes]; map=map(:,[1,2,3,5,4,6,7,9,8]);
  etag=654321; etag=etag*1e-5; emode = 'le';
  [fid,message] = fopen(fname,'w',['ieee-' emode]);
  if fid == -1, disp(message), status = -1; return, end

  header=sprintf('#v001%12d%12d%12d',nH,nH,nv);header(end+1:132) = ' ';
  fwrite(fid,header,'char');
  fwrite(fid,etag,'float32');
  fwrite(fid,map','int32');
  fclose(fid);


