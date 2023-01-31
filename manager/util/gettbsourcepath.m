function tbpath = gettbsourcepath(tbname)
tbdirectory = readtbdirectory;
tbpath = char(tbdirectory.source(findtbentry(tbdirectory,tbname)));

% old way that doesn't support sublibs
% if nargin == 0
%    tbpath = getenv('MATLABSOURCEPATH');
% else
%    tbpath = [getenv('MATLABSOURCEPATH') tbname '/'];
% end
%    