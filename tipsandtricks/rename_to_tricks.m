% decided not to do this ... instead functions will be tabletricks,
% mappingtricks, etc, and will open these ... for now

clean

list = getlist(pwd,'.m');

for n = 1:numel(list)
   
   f = list(n).name;
   
   if strcmp(f(end-5:end),'_fun.m') == true
      
      fnew = [f(1:end-5) 'tricks.m'];
      
      movefile(f,fnew);
   end
end