function gen_logfile(cname,ilog,varargin)
if(ilog==0);disp('(no logfile)');return;end

%fdr=['./cases/' cname]; 
fdr=[cname]; 
flog='logfile';if(length(varargin)==1);flog=varargin{1};end
flog=[fdr '/' flog];flog2=[flog '.1'];
if exist( flog,'file')==2
  str=['!mv ' flog ' ' flog2]; eval(str)
end 

diary off; eval(['diary ' flog]); 
fprintf(['Time: ' char(datetime('now','Format','HH:mm:ss MMM/dd/yyyy')) '\n']);
fprintf(['Write to ' flog '\n']);








