function proplist = completions(funcname)
%COMPLETIONS function completions
switch lower(funcname)
   
   case 'completions'
      tmp = dir( ...
         fullfile(tbx.internal.projectpath, 'toolbox', '+tbx', '*.m'));
      proplist = strrep({tmp.name}, '.m', '');
      
   % fill out remaining functions 
   % case 'functionname'
end
