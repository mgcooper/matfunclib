clean

% Description of this file

%%
% save_figs       =   0;

%%
homepath        =   pwd;

if strcmp(homepath(2:6),'Users')
    pathbase    =   '/Users/MattCooper/Dropbox/CODE/MATLAB/';
    pathdata    =   [pathbase ''];
    pathsave    =   [pathbase ''];
elseif strcmp(homepath(10:16),'mcooper')    
    pathbase    =   'C:\Users\mcooper\Dropbox\CODE\MATLAB\';
    pathdata    =   [pathbase ''];
    pathsave    =   [pathbase ''];
end

%%
set(groot                                                   , ...
    'defaultAxesFontName'       ,   'times'                 , ...
    'defaultTextFontName'       ,   'times'                 , ...
    'defaultAxesFontSize'       ,   16                      , ...
    'defaultTextFontSize'       ,   16                      );
%%
