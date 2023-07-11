function cpinfoxml(dstpath)
%CPINFOXML copies template info.xml file to dstpath without overriding
%  When publishing a toolbox, the info.xml file is required. It describes the
%  custom documentation. See help Display Custom Documentation for more info.


if nargin == 0
   dest = pwd();
end

% full path to source file
srcname = fullfile(matlabroot,'help','techdoc','matlab_env',...
'examples','templates','helptoc_template.xml');

% copy the file, make it writeable, and open it
copyfile(srcname,dstname)
fileattrib(dstname,'+w')
edit(dstname)
