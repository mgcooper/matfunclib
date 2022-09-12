function varnames = makevalidvarnames(varnames)
   
   % these are my preferred settings
   for n = 1:numel(varnames)
      varnames{n} = strrep(varnames{n},' ','_');
      varnames{n} = matlab.lang.makeValidName(varnames{n},              ...
                     'ReplacementStyle','delete');
   end