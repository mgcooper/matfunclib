function cdfunctions(funcname)
   
   if nargin==1
      funcpath = strrep(which([funcname '.m']),[funcname '.m'],'');
   else
      funcpath = getenv('MATLABFUNCTIONPATH');
   end
   
   cd(funcpath)
    
    