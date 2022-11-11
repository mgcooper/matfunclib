function cpinfoxml(dest)
% CPINFOXML copies template info.xml file to dest
%  When publishing a toolbox, the info.xml file is required. It describes the
%  custom documentation. See help Display Custom Documentation for more info.


if nargin == 0
   dest = pwd();
end

copyfile(fullfile(matlabroot,'help','techdoc','matlab_env',...
   'examples','templates','info_template.xml'),dest)
fileattrib('info_template.xml','+w')
edit('info_template.xml')


% copy the helptoc.xml file
copyfile(fullfile(matlabroot,'help','techdoc','matlab_env',...
'examples','templates','helptoc_template.xml'),pwd)
fileattrib('helptoc_template.xml','+w')
edit('helptoc_template.xml')