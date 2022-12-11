function copyjsontemplate(destpath)

if nargin == 0
   destpath = pwd;
end

% copy the bare template
src = [getenv('MATLABTEMPLATEPATH') 'functionSignatures.json.bare'];
dst = [destpath '/functionSignatures.json'];
if ~exist(dst,'file')
   copyfile(src,dst);
else
   dst = [destpath '/functionSignatures.json.bare'];
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