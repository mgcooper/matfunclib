function [fname] = fnamefromlist(filelist,varargin)
%FNAMEFROMLIST convert directory list returned by dir to full path filename list
% 
%  [fname] = fnamefromlist(filelist) returns a list of all files in list
% 
%  [fname] = fnamefromlist(filelist,fileindex) returns the full path filename
%  for the file in list at the index fileindex
% 
%  [fname] = fnamefromlist(___,'asstring') returns a list formatted as an array
%  of strings. default behavior is to return a cellstr array of chars.
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also: numfiles
% 
% Updates
% 23 Jan 2023 - removed filepath input, now uses filelist.folder, combined with
% list2path and deleted list2path function

% parse optional true/false flags
opts = optionParser('asstring',varargin(:));

% apply the fileindex if provided (fileindex = varargin{1})
if nargin > 1 && isnumericscalar(varargin{1})
   fname = fullfile(filelist(varargin{1}).folder,filelist(varargin{1}).name);
else
   fname = transpose(fullfile({filelist.folder},{filelist.name}));   
end

% convert to string array if requested
if opts.asstring == true
   fname = string(fname);
end

%% original behavior - simplest case

% function [fname] = fnamefromlist(filelist,fileindex)
% 
% % Example
% %  list = fnamefromlist(list);
% %  list = fnamefromlist(list,1);

% if nargin == 1
%    fname = transpose(fullfile({filelist.folder},{filelist.name}));
% else
%    fname = fullfile(filelist(fileindex).folder,filelist(fileindex).name);
% end


%% optionParser with required fileindex
% 
% function [fname] = fnamefromlist(filelist,fileindex,varargin)
% % 
% % Example
% %  list = fnamefromlist(list,[],'asstring');
% 
% % parse optional true/false flags
% opts = optionParser('asstring',varargin(:));
% 
% if isempty(fileindex)
%    fname = transpose(fullfile({filelist.folder},{filelist.name}));
% else
%    fname = fullfile(filelist(fileindex).folder,filelist(fileindex).name);
% end
% 
% if opts.asstring == true
%    fname = string(fname);
% end

%% optionParser with optional fileindex
% 
% function [fname] = fnamefromlist(filelist,varargin)
% % 
% % Example
% % 
% %  list = fnamefromlist(list)
% %  list = fnamefromlist(___,index)
% %  list = fnamefromlist(___,'asstring')
% 
% % parse optional true/false flags
% opts = optionParser('asstring',varargin(:));
% 
% if nargin > 1 && isnumericscalar(varargin{1}) % fileindex = varargin{1}
%    fname = fullfile(filelist(varargin{1}).folder,filelist(varargin{1}).name);
% else
%    fname = transpose(fullfile({filelist.folder},{filelist.name}));   
% end
% 
% if opts.asstring == true
%    fname = string(fname);
% end


%% magicParser
% function [fname] = fnamefromlist(filelist,varargin)
% 
% % Example 
% %  list = fnamefromlist(list,'asstring',true);
% 
% p = magicParser;
% p.FunctionName = mfilename;
% p.addRequired('filelist');
% p.addOptional('fileindex',NaN,@(x)isnumericscalar(x));
% p.addParameter('asstring',false,@(x)islogicalscalar(x));
% p.parseMagically('caller');
% 
% % if no opts are true and nargin == 2, then assume 
% if isnan(fileindex)
%    fname = transpose(fullfile({filelist.folder},{filelist.name}));
% else
%    fname = fullfile(filelist(fileindex).folder,filelist(fileindex).name);
% end
% 
% if asstring == true
%    fname = string(fname);
% end


%%



% validopts = @(x)any(validatestring(x,{'asstring'}));
% p.addOptional('postfunc','none',validopts);


% % 

% if nargin == 3
%    postfunc = varargin{1}; % post-get function 
% end
% 
% if postfunc == "asstring"
%    fname = string(fname);
% end


