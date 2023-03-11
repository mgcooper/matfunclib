function lstbjsonentries()
%LSTBJSONENTRIES list toolbox json entries
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

displayjsonentries('activate');
displayjsonentries('deactivate');



function displayjsonentries(directory)

jspath      = gettbjsonpath(directory);
wholefile   = readtbjsonfile(jspath);

istart      = strfind(wholefile,'choices={');
istop       = strfind(wholefile,'}"]}');

fprintf('\n %s: \n %s \n',directory,wholefile(istart:istop));