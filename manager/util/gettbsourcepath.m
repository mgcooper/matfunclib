function tbpath = gettbsourcepath(tbname)

if nargin == 0
   tbpath = getenv('MATLABSOURCEPATH');
elseif nargin == 1
   tbdirectory = readtbdirectory;
   tbpath = char(tbdirectory.source(findtbentry(tbdirectory,tbname)));
end

% old way that doesn't support sublibs
% if nargin == 0
%    tbpath = getenv('MATLABSOURCEPATH');
% else
%    tbpath = [getenv('MATLABSOURCEPATH') tbname '/'];
% end
%    