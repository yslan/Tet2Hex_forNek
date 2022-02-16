function dump_nek_re2(fname,X,Hexes,CBC)
t0=tic;

ifheat=1;   nfld=1;if(ifheat);nfld=2;end % passive scaler is not supported for now
ifdouble=1; wdsize=4;if(ifdouble);wdsize=8;end

fprintf('    dump_nek_re2: IFHEAT=%d, nfld=%d, ifdouble=%d\n',ifheat,nfld,ifdouble);

ndim=3; nH=size(Hexes,1); lgeom=length(unique(abs(CBC(:)))); fname=[fname '.re2'];
if(nH>=1e6);disp('WARN dump_nek_re2 has not tested for E > 1,000,000');end

cbc_dmy{1}='W  ';
for ig=2:lgeom
  cbc_dmy{ig}=['W' sprintf('%02d',ig-1)];
end

dtype4='float32'; dtype8='float64';
itype4='int32';   itype8='float64';
dtype=dtype4;itype=itype4; if(wdsize==8);dtype=dtype8;itype=itype8;end

etag=654321; etag=etag*1e-5; emode = 'le';
[fid,message] = fopen(fname,'w',['ieee-' emode]);
if(fid==-1); disp(message); status=-1; return; end

%% Header
%{
        call blank(hdr,80)
        if(wdsize.ne.8) then       !8byte decision!!
          write(hdr,111) nel,ndim,nel
        else
          write(hdr,112) nel,ndim,nel
        endif
  111   format('#v001',i9,i3,i9,' hdr')
  112   format('#v002',i9,i3,i9,' hdr')
        call byte_write(hdr,20)   ! assumes byte_open() already issued
        call byte_write(test,1)   ! write the endian discriminator
%}

version='#v001'; if(wdsize==8);version='#v002';end
header=sprintf([version '%9d%3d%9d hdr'],nH,ndim,nH);header(end+1:80)=' '; fwrite(fid,header,'char');
fwrite(fid,etag,dtype4); % endian test

%% mesh
%{
elseif(wdsize.eq.4) then
  igroup = 0
  call byte_write(igroup, 1)
  buf(1-24)  = x1-x8 y1-y8 z1-z8
  call byte_write(buf,24)
else
  rgroup = 0.0
  call byte_write(rgroup, 2)
  buf2(1-24)  = x1-x8 y1-y8 z1-z8
  call byte_write(buf,48)
%}

fprintf('    dump_nek_re2 dump mesh...');
if(wdsize==4)
  % works for both types, but slower
  for e=1:nH
    igroup=0; fwrite(fid,igroup,itype);
    dat=[X(Hexes(e,1:8),1)',X(Hexes(e,1:8),2)',X(Hexes(e,1:8),3)']; fwrite(fid,dat,dtype);
  end
else
  % faster, but only works for double
  dat=[zeros(nH,1),reshape(X(Hexes(:,1:8),1),nH,8),reshape(X(Hexes(:,1:8),2),nH,8),reshape(X(Hexes(:,1:8),3),nH,8)]; 
  fwrite(fid,dat',dtype);
end
fprintf('    done !\n');


%% curve
%{
      elseif(wdsize.eq.4) then
         call byte_write(ncurv,1)
         do ie=1,nel
            do iedge = 2,maxedge,2
               if (curve(iedge,ie).ne.0) then
                  call icopy(buf(1),ie,1)
                  call icopy(buf(2),iedge,1)
                  buf(3) = curve(iedge,ie)
                  buf(4) = zero
                  buf(5) = zero
                  buf(6) = zero
                  buf(7) = zero
                  call chcopy(buf(8),'C',1)
                  call byte_write(buf,8)
               endif
            enddo
         enddo
      else
         rcurv=ncurv
         call byte_write(rcurv,2)
         do ie=1,nel
            do iedge = 2,maxedge,2
               if (curve(iedge,ie).ne.0) then
                  buf2(1) = ie
                  buf2(2) = iedge
                  buf2(3) = curve(iedge,ie)
                  buf2(4) = zero
                  buf2(5) = zero
                  buf2(6) = zero
                  buf2(7) = zero
                  call chcopy(buf2(8),'C',1)
                  call byte_write(buf,16)
               endif
            enddo
         enddo
      endif
%}

% TODO add sphere curves
ncurv=0; fwrite(fid,ncurv,itype);


%% bdry
%{
      icount = 0
      do ifld=1,nfld
         nbc = 0
         if (if3d) then
           do ipass=1,2 % 1= count bc, 2=print

             ie = 0
             e0 = 0

             if (ipass.eq.2 .and. .not. iffo) then
                if(wdsize.eq.4) then
                   call byte_write(nbc,1)
                else
                   rbc=nbc
                   call byte_write(rbc,2)
                endif
             endif

                 if(ipass.eq.2) then
                   do ii = 1,6
                     ibc(ii) = rbc8(ii)
                   enddo
                   call blank(buf(1),30*4)

                   if(wdsize.eq.4) then
                     call icopy(buf(1),ie,1) %% loop rbc3 2 4 1 5 6
                     if(cbc3.ne.'E  ') then
                       call icopy(buf(2),eface(3),1)
                       call copy48(buf(3),rbc3,5)
                       call chcopy(buf(8),cbc3,3)
                       if(nel.ge.1000000) call icopy(buf(3),ibc(3),1) % FIXME: not implemented
                       call byte_write(buf,8)
                       icount = icount+1
                     endif
                     if(cbc2.ne.'E  ') then
                       call icopy(buf(2),eface(2),1)
                       call copy48(buf(3),rbc2,5)
                       call chcopy(buf(8),cbc2,3)
                       if(nel.ge.1000000) call icopy(buf(3),ibc(2),1)
                       call byte_write(buf,8)
                       icount = icount+1
                     endif
                   else
                     buf2(1)=ie
                     if(cbc3.ne.'E  ') then
                       buf2(2)=eface(3)
                       call copy(buf2(3),rbc3,5)
                       call chcopy(buf2(8),cbc3,3)
                       if(nel.ge.1000000) buf2(3)=ibc(3)
                       call byte_write(buf,16)
                       icount = icount+1
                     endif
                     if(cbc2.ne.'E  ') then
                        buf2(2)=eface(2)
                        call copy  (buf2(3),rbc2,5)
                        call chcopy(buf2(8),cbc2,3)
                        if(nel.ge.1000000) buf(3)=ibc(2)
                        call byte_write(buf,16)
                        icount = icount+1
                     endif
%}

fprintf('    dump_nek_re2 dump bc...\n');

nbc=sum(sum(CBC>0)); 
sp_cbc=' '; if(wdsize==8); sp_cbc='     '; end

for ifld=1:nfld
  nbcs=zeros(1,lgeom);nbc0=0;nbce=0;
  fwrite(fid,nbc,itype);

  % ie eface rbc rbc rbc rbc rbc cbc*3
  for e=1:nH; 

    o=0.0; o1=0.0; o2=0.0; o3=0.0; o4=0.0; o5=0.0;

    for f=1:6; cbc=CBC(e,f); igeom=max(cbc,0);    

      if igeom==0
        bcf='E  '; nbc0=nbc0+1;
      else
        if (igeom>0 && igeom<=lgeom)
          bcf=cbc_dmy{igeom}; nbcs(igeom)=nbcs(igeom)+1;
        else
          bcf='v  '; nbce=nbce+1; warning('bc id missing, put inflow %d %d',e,f); igeom=0;
        end
        dat=[e,f]; fwrite(fid,dat,itype);
        dat=[o1,o2,o3,o4,o5]; fwrite(fid,dat,dtype); 
        fwrite(fid,[bcf sp_cbc],'char*1'); 
      end

    end % f

  end % e

  fprintf('    dump_nek_re2 ifld=%d, #E=%d  #Curves=%d  #BCs',ifld,nH,0);
  fprintf(' %d',[nbc0,nbcs,nbce]);fprintf('\n');
end % fld
fprintf('    done !\n');

fclose(fid);

[osize,otype]=comp_fsize(fname);
fprintf(['DONE dump re2 file ' fname ' (%3.1f %s %2.4e sec)\n'],osize,otype,toc(t0));

