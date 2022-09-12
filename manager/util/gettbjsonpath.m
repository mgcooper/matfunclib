function jspath = gettbjsonpath(activateordeactivate)
   
   if nargin>1
      error('one optional input allowed: ''activate'' or ''deactivate'''); 
   end
   
   if strcmp(activateordeactivate,'deactivate')
      jspath = getenv('TBJSONDEACTIVATEPATH');
   else
      jspath = getenv('TBJSONACTIVATEPATH');
   end