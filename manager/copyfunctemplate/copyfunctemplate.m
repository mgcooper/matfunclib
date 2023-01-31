function copyfunctemplate(newfuncpath,parser)

% use magic input parser or built in input parser (default: MIP)
if nargin == 1
   parser = 'MIP';
end

% set the function template filename
switch parser
   case 'MIP'
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateMIP.m');
   case 'IP'
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateIP.m');
   case 'ArgList'
      src = fullfile(getenv('MATLABTEMPLATEPATH'),'functemplateArgList.m');
end

copyfile(src,newfuncpath);
   
% note: unlike copyjsontemplate, this accepts the filename, which already
% has _tmp appended in the case of an existing function, so there isn't any
% need to have an option to 'appendfunc' or similar