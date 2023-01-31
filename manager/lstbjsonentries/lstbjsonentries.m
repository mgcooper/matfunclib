function lstbjsonentries()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

displayjsonentries('activate');
displayjsonentries('deactivate');



function displayjsonentries(directory)

jspath      = gettbjsonpath(directory);
wholefile   = readtbjsonfile(jspath);

istart      = strfind(wholefile,'choices={');
istop       = strfind(wholefile,'}"]}');

fprintf('\n activate: \n %s \n',wholefile(istart:istop));