clean

% Reads in Ice Sat HD5 data and plays around with it

%%
% save_data       =   0;

%%
homepath        =   pwd;

if strcmp(homepath(2:6),'Users')
    delim       =   '/';
    path.base   =   '/Users/MattCooper/Dropbox/CODE/MATLAB/';
    path.data   =   [path.base 'GREENLAND/IceSat/data/'];
    path.save   =   [path.base 'GREENLAND/IceSat/data/'];
elseif strcmp(homepath(10:16),'mcooper')    
    delim       =   '\';
    path.base   =   'C:\Users\mcooper\Dropbox\CODE\MATLAB\';
    path.data   =   [path.base ''];
    path.save   =   [path.base ''];
end

