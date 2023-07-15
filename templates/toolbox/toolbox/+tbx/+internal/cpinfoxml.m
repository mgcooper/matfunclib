function cpinfoxml(dstpath)
%CPINFOXML copy info.xml and helptoc.xml templates to dstpath without overriding
%  
% 
% When publishing a toolbox, the info.xml file is required. It describes the
% custom documentation. See help Display Custom Documentation for more info.
% 
% See also


if nargin == 0
   dstpath = pwd();
end

% full path to destination file
dstname = fullfile(dstpath,'info_template.xml');

if isfile(dstname)
   warning('info_template.xml exists in dstpath, copying with unique filename ID')
   tmpname = tempfile();
   dstname = fullfile(dstpath,['info_template_' tmpname '.xml']);
end

% full path to source file
srcname = fullfile(matlabroot,'help','techdoc','matlab_env',...
   'examples','templates','info_template.xml');

% copy the file, make it writeable, and open it
copyfile(srcname,dstname)
fileattrib(dstname,'+w')
edit(dstname)

%% repeat with the helptoc.xml file

% full path to destination file
dstname = fullfile(dstpath,'helptoc_template.xml');

if isfile(dstname)
   warning('helptoc_template.xml exists in dstpath, copying with unique filename ID')
   tmpname = tempfile();
   dstname = fullfile(dstpath,['helptoc_template_' tmpname '.xml']);
end

% full path to source file
srcname = fullfile(matlabroot,'help','techdoc','matlab_env',...
'examples','templates','helptoc_template.xml');

% copy the file, make it writeable, and open it
copyfile(srcname,dstname)
fileattrib(dstname,'+w')
edit(dstname)
