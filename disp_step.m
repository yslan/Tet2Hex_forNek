function disp_step(istep,str)
% Print a nice separation block into logfile for major steps + timer

TIMER; max_len=80; imode=0; % imode: 0=elapsed time, 1=clock

if(imode==1||isempty(t_start)); imode=1;
  str3=sprintf(['Time: ' char(datetime('now','Format','HH:mm:ss MMM/dd/yyyy'))]); 
else
  t_now = toc(t_start); str3=sprintf('eTime: %2.4e sec',t_now);
  if(istep>0 && istep<=20 && istep==int32(istep)); t_steps(istep) = t_now; end; % record
end; nt=length(str3);


%% Print
for i=1:max_len;fprintf('-');end;fprintf('\n'); % sep line

% gen Step name
str2=sprintf(['Step %2d: ' str],istep);
n=length(str2); n=min(n,max_len); str2=str2(1:n); str2(n+1:max_len)=' ';

% combine and print
str2(end-nt+1:end)=str3; fprintf(str2); fprintf('\n'); 

for i=1:max_len;fprintf('-');end;fprintf('\n'); % sep line
