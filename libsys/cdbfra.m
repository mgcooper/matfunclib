function cdbfra(dest)
    
   if nargin < 1
      dest = 'main';
   end
   
   switch dest
      case 'main'
         cd('/Users/coop558/MATLAB/INTERFACE/BFRA/main')
      case 'test'
         cd('/Users/coop558/myprojects/matlab/bfra_test')
      case 'git'
         cd('/Users/coop558/myprojects/matlab/bfra')         
         
   end