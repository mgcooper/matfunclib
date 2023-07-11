function tbpath = gettbsourcepath(tbname)

if nargin == 0
   tbpath = getenv('MATLABSOURCEPATH');
elseif nargin == 1
   tbdirectory = readtbdirectory;
   tbpath = char(tbdirectory.source(findtbentry(tbdirectory,tbname)));
   
   % some older entries in the directory have the trailing slash, which could
   % mess with move operations
   tbpath = rmtrailingslash(tbpath);
end

function newpath = rmtrailingslash(oldpath)

if strcmp(oldpath(end),'/')
   newpath = oldpath(1:end-1);
else
   newpath = oldpath;
end

% old way that doesn't support sublibs
% if nargin == 0
%    tbpath = getenv('MATLABSOURCEPATH');
% else
%    tbpath = [getenv('MATLABSOURCEPATH') tbname '/'];
% end
%    