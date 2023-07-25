function testfuncpath = copyfunctemplate(newfuncpath, parser)
%COPYFUNCTEMPLATE copy function template file to newfuncpath
% 
% testfuncpath = copyfunctemplate(newfuncpath, parser) copies a function
% template to the file NEWFUNCPATH and the testscript_template to
% test_newfuncname.m or a temporary backup file if test_newfuncname.m exists,
% and returns the full path to the test script file.
% 
% See also: copyjsontemplate

% use arguments block by default
if nargin == 1
   parser = 'AP';
end

% get the path and function name
[funcparts{1:3}] = fileparts(newfuncpath);

% set the function template filename
switch parser
   case 'MP' % magicParser
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateMP.m');
   case 'IP' % inputParser
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateIP.m');
   case 'OP' % optionParser
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateOP.m');
   case 'NP' % no parser
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateNP.m');
   case 'AP' % arguments block
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateAP.m');
end

copyfile(src, newfuncpath);

% copy the testscript_template
src = fullfile(getenv('MATLABTEMPLATEPATH'),'testscript_template.m');
dst = fullfile(funcparts{1}, ['test_' funcparts{2} '.m']);

% make sure not to write over an existing test file
if isfile(dst)
   tmp = tempfile();
   dst = fullfile(funcparts{1}, ['test_' funcparts{2} '_' tmp(1:10) '.m']);
end
copyfile(src, dst);

testfuncpath = dst;

% note: unlike copyjsontemplate, this accepts the filename, which already
% has _tmp appended in the case of an existing function, so there isn't any
% need to have an option to 'appendfunc' or similar