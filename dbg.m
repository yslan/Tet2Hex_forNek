IO

ifdbg_for_dbg_only=0; IO;

if((exist('IFDBG'))&& (~isempty(IFDBG)))
  if(IFDBG>0); ifdbg_for_dbg_only=1; end
else
  ifdbg_for_dbg_only=1;
end

if(ifdbg_for_dbg_only>0)
disp('dbg    (press any key to continue)...');pause
end
