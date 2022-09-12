function jspath = getprjjsonpath(workonoroff)
   
   if nargin>1
      error('one optional input allowed: ''workon'' or ''workoff'''); 
   end
   
   if strcmp(workonoroff,'workoff')
      jspath = getenv('PRJJSONWORKOFFPATH');
   else
      jspath = getenv('PRJJSONWORKONPATH');
   end