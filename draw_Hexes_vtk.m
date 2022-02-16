function draw_Hexes_vtk(X,Hexes,CBC,cname,str,imode)


% imode:
%   =0 default (ascii)
%    1 (ascii) plot bdry faces only (slow)
%    2 (ascii) plot all faces 
%    3 (ascii) plot hex (tp12)
%   -1 (binary) plot bdry faces only (slow)
%   -2 (binary) plot all faces 
%   -3 (binary) plot hex (tp12)
%   -4 (binary) plot hex (tp12) + cell id
t0=tic; iftoiv=[1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;1 2 3 4;5 6 7 8]; 

fname = 'Hexes.vtk'; if(~isempty(str));fname=['Hexes_' str '.vtk'];end; 
fname=[cname '/' fname];
%fname=['cases/' cname '/' fname];
format='ascii'; if(imode<0);format='binary';end

if(isinf(X(end,1))==1); X=X(1:end-1,:);end
nX=size(X,1); nH=size(Hexes,1); 

if (abs(imode)==1 || imode==0);
  [ide,idf]=find(CBC~=0);
elseif (abs(imode)==2)
  ide=(1:nH)'; ide=[ide;ide;ide;ide;ide;ide];
  idf=[ones(nH,1);2*ones(nH,1);3*ones(nH,1);4*ones(nH,1);5*ones(nH,1);6*ones(nH,1)];
elseif (abs(imode)==3)
  ide=(1:nH)'; 
elseif (abs(imode)==4)
  ide=(1:nH)'; 
else
  error('un-support imode in draw_Ufacets_vtk');
end
nF=length(ide);

data_type=1; if (abs(imode)==3) data_type=2; end % 1=face, 2=hex
if (abs(imode)==4) data_type=3; end

vtk_title='Hexes'; vtk_title = vtk_title(1:min(length(vtk_title),256));

switch format
  case 'ascii'
    fid=fopen(fname,'wt');
    fprintf(fid,'# vtk DataFile Version 2.0\n');
    fprintf(fid,[vtk_title '\n']);
    fprintf(fid,'ASCII\n');
    fprintf(fid,'DATASET UNSTRUCTURED_GRID\n');
    fprintf(fid,'\n');

    fprintf(fid,'POINTS %d float\n',nX);
    s='%f %f %f \n'; fprintf(fid,s,X');fprintf(fid,'\n');

    if (data_type==1)
      fprintf(fid,'CELLS %d %d\n',nF,nF*5);

      iend=length(ide); nblock=ceil(length(ide)/1000); % void memory allocation
      i0=1;i1=min(1000,iend);
      for i=1:length(ide);ie=ide(i);iF=idf(i);
        dat=[4,Hexes(ie,iftoiv(iF,:))-1];
        fprintf(fid,'%d %d %d %d %d\n',dat');
      end
      fprintf(fid,'\n');

      fprintf(fid,'CELL_TYPES %d\n',nF);
      fprintf(fid,'%d\n',7*ones(nF,1));
      fprintf(fid,'\n');

      fprintf(fid,'CELL_DATA %d\n',nF);
      fprintf(fid,'SCALARS cell_id int 1\n');
      fprintf(fid,'LOOKUP_TABLE default\n');
      in1=sub2ind(size(CBC),ide,idf);
      fprintf(fid,'%d\n',CBC(in1));
      fprintf(fid,'\n');
    elseif (data_type==2)
      fprintf(fid,'CELLS %d %d\n',nH,nH*9);
      dat=[8*ones(nH,1),Hexes-1];
      fprintf(fid,'%d %d %d %d %d %d %d %d %d\n',dat');
      fprintf(fid,'\n');

      fprintf(fid,'CELL_TYPES %d\n',nH);
      fprintf(fid,'%d\n',12*ones(nH,1));
      fprintf(fid,'\n');
    else
       error('Wrong data_type when dumping vtk for Hexes')
    end

  case 'binary'
    write_a = @(fid,str) [fprintf(fid,str); fprintf(fid,'\n');];
    write_b = @(fid,dat,prec) [fwrite(fid,dat,prec); fprintf(fid,'\n');];
    write_b2= @(fid,dat,prec) [fwrite(fid,dat,prec)];

    fid=fopen(fname,'wb','ieee-be');

    write_a(fid,'# vtk DataFile Version 2.0');

    write_a(fid,vtk_title);
    write_a(fid,'BINARY\n');
    write_a(fid,'DATASET UNSTRUCTURED_GRID');

    write_a(fid,['POINTS ' num2str(nX) ' float']);
    write_b(fid,X','float32');
    write_a(fid,'');
         
    if (data_type==1)
      write_a(fid,['CELLS ' num2str(nF) ' ' num2str(5*nF)]);
      for i=1:nF;ie=ide(i);iF=idf(i); 
        dat=uint32([4,Hexes(ie,iftoiv(iF,:))-1]);
        write_b2(fid,dat,'uint32'); % no break line
      end;
      write_a(fid,''); write_a(fid,'');

      write_a(fid,['CELL_TYPES ' num2str(nF)]);
      write_b(fid,uint32(7*ones(1,nF)),'uint32');
      write_a(fid,'');

      write_a(fid,['CELL_DATA ' num2str(nF)]);
      write_a(fid,'SCALARS cell_id int 1');
      write_a(fid,'LOOKUP_TABLE default');
      in1=sub2ind(size(CBC),ide,idf);
      write_b(fid,uint32(CBC(in1)),'uint32');
      write_a(fid,'');

    elseif (data_type==2)
      write_a(fid,['CELLS ' num2str(nH) ' ' num2str(9*nH)]);
      dat=uint32([8*ones(nH,1),Hexes-1]);
      write_b2(fid,dat','uint32');
      write_a(fid,''); write_a(fid,'');

      write_a(fid,['CELL_TYPES ' num2str(nH)]);
      write_b(fid,uint32(12*ones(1,nH)),'uint32');
      write_a(fid,'');
    elseif (data_type==3)
      write_a(fid,['CELLS ' num2str(nH) ' ' num2str(9*nH)]);
      dat=uint32([8*ones(nH,1),Hexes-1]);
      write_b2(fid,dat','uint32');
      write_a(fid,''); write_a(fid,'');

      write_a(fid,['CELL_TYPES ' num2str(nH)]);
      write_b(fid,uint32(12*ones(1,nH)),'uint32');
      write_a(fid,'');

      write_a(fid,['CELL_DATA ' num2str(nH)]);
      write_a(fid,'SCALARS cell_id int 1');
      write_a(fid,'LOOKUP_TABLE default');
      write_b(fid,uint32(1:nH),'uint32');
      write_a(fid,'');
    else
       error('Wrong data_type when dumping vtk for Hexes')
    end
 
  otherwise
    error('wrong input dummy :P');
end


fclose(fid);

[osize,otype]=comp_fsize(fname);
fprintf(['DONE dump %d Hexes into ' fname ' (%3.1f %s, %2.4e sec)\n'],nH,osize,otype,toc(t0))
