function projattr = getactiveproject(projlist,property)
%GETACTIVEPROJECT get active project in project directory
% 
%  projattr = getactiveproject(projname) gets the projectlist.activeproject
%  attribute for for the project specified by `projname`. attributes are
%  'name','folder','activefiles'

if nargin == 0
   property = 'name';
   projlist = readprjdirectory;
elseif nargin == 1
   property = projlist; 
   projlist = readprjdirectory;
end

projattr = projlist.(property)(projlist.activeproject == true);
projattr = projattr{:};

% switch property
%    case 'name'
%       projattr = projlist.name(projlist.activeproject == true);
%       projattr = projattr{:};
%    case 'folder'
%       projattr = projlist.name(projlist.activeproject == true);
%       projattr = projattr{:};



% % if i go this route:
% projname = getenv('MATLABACTIVEPROJECT');

