function copyjsontemplate(destpath,destname)
%COPYJSONTEMPLATE copy the json signature file template to destpath
%
%  copyjsontemplate() copies the template to pwd()
%
%  copyjsontemplate(destpath) copies the template to destpath
%
% See also: copyfunctemplate

% UPDATES
% 10 Feb 2023, added destname input to support appending function name in
% mkfunction, changed conflict filename from .bare to .tmp. NOTE: could also use
% an isfile vs isfolder check and if isfile true, assume a full filename has
% been passed in.

if nargin == 0
   destpath = pwd;
   destname = 'functionSignatures.json';
elseif nargin == 1
   destname = 'functionSignatures.json';
end

% copy the bare template
src = fullfile(getenv('MATLABTEMPLATEPATH'),'functionSignatures.json.bare');
dst = fullfile(destpath,destname);

if isfile(dst) % the file exists, append a 'tmp' version
   dst = fullfile(destpath,'functionSignatures.json.tmp');
   copyfile(src,dst);
else
   copyfile(src,dst);
end


% replace the default function name with the actual one
% need to get the folder name, can do later if wanted

% May 4: copy as _tmp so as not to overwrite existing function

% this is if the template is in the function directory
% pth = fileparts(which('copyjsontemplate.m'));
% src = [pth '/functionSignatures.json.template'];