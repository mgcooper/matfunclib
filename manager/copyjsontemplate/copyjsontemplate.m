function copyjsontemplate(destpath)
%COPYJSONTEMPLATE copy the json signature file template to destpath
% 
%  copyjsontemplate() copies the template to pwd()
% 
%  copyjsontemplate(destpath) copies the template to destpath
% 
% See also

if nargin == 0
   destpath = pwd;
end

% copy the bare template
src = fullfile(getenv('MATLABTEMPLATEPATH'),'functionSignatures.json.bare');
dst = fullfile(destpath,'functionSignatures.json');
if ~isfile(dst)
   copyfile(src,dst);
else % the file exists already
   dst = fullfile(destpath,'functionSignatures.json.bare');
   copyfile(src,dst);
end
   
% % nov 29, 2022 commented this out, use openjsontemplate.m if needed
%    % copy the detailed one
%    src = [getenv('MATLABTEMPLATEPATH') 'functionSignatures.json.template'];
%    dst = [destpath '/functionSignatures_reference.json'];
%    copyfile(src,dst);
   

% replace the default function name with the actual one
% need to get the folder name, can do later if wanted

% May 4: copy as _tmp so as not to overwrite existing function

% this is if the template is in the function directory
% pth = fileparts(which('copyjsontemplate.m'));
% src = [pth '/functionSignatures.json.template'];