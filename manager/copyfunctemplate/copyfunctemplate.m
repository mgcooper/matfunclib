function copyfunctemplate(newfuncpath,parser)

% use magic parser by default
if nargin == 1
   parser = 'MP';
end

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

copyfile(src,newfuncpath);
   
% note: unlike copyjsontemplate, this accepts the filename, which already
% has _tmp appended in the case of an existing function, so there isn't any
% need to have an option to 'appendfunc' or similar