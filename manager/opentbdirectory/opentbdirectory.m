function opentbdirectory()
%OPENTBDIRECTORY
% 
% 
% See also

% parse inputs
p = inputParser;
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.KeepUnmatched = true;

dbpath = fullfile(getenv('TBDIRECTORYPATH'),'toolboxdirectory.csv');

system(sprintf('open %s',dbpath));