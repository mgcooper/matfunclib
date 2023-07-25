function opentbdirectory()
%OPENTBDIRECTORY
% 
% 
% See also

try
   system(sprintf('open %s', ...
      fullfile(getenv('TBDIRECTORYPATH'),'toolboxdirectory.csv')));
catch
end