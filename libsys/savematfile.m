function msg = savematfile(filename,variables,varargin)
%SAVEMATFILE general description of function
% 
%  msg = SAVEMATFILE(filename,variables) is identical to built-in save function
% 
%  msg = SAVEMATFILE(filename,variables,savefile) is identical to built-in save
%  function if savefile is TRUE. If savefile is FALSE, nothing is done. This
%  option removes the need to include if-else statements in code.
% 
%  msg = SAVEMATFILE(_,version) saves to the MAT-file version specified by
%  VERSION. 
% 
% Example
%  
% 
% Matt Cooper, 14-Mar-2023, https://github.com/mgcooper
% 
% See also

% TODO add dbstack

% parse inputs
validversion = @(x)~isempty(validatestring(x,{'-v7','-v73','-v6','-v4'}));

parser = inputParser;
parser.FunctionName = mfilename;
parser.addRequired('filename', @ischarlike);
parser.addRequired('variables', @ischarlike);
parser.addOptional('saveflag', false, @islogical);
parser.addParameter('version', '-v7', validversion);
parser.parse(filename,variables,varargin{:});

% use this to figure out if this function is being called from some other
% function more than one workspace away, in case that affects the ability to run
% the evalin command
[~,I] = dbstack;

if parser.Results.saveflag == false
   return
else
   
   % not sure exactly how to use this yet
   if I>1
      % error('savematfile must be called from ')
   end
   
   % get the version and ensure the inputs are chars
   version = convertStringsToChars(parser.Results.version);
   filename = convertStringsToChars(filename);
   variables = convertStringsToChars(variables);

   % this should not be needed with convertStringsToChars
   % if isstring(variables); 
   %    error('string arrays of variable names not supported'); 
   % end
   
   % append .mat to the filename if necessary
   [filepath, filebase, fileext] = fileparts(filename);
   if isempty(fileext)
      fileext = '.mat';
   end
   
   % validate the filepath
   if isempty(filepath)
      filepath = pwd();
      warning('using pwd for filepath')
   elseif ~isfolder(filepath)
      error('path to filename does not exist')
   end
   
   % rebuild the filename
   filename = fullfile(filepath, [filebase fileext]);
   
   % if the filename exists, back it up before saving the new one
   if isfile(filename)
      filename = backupfile(filename);
      warning('file exists, backing it up to %s', filename);
   end
   
   % validate that variables is the name of variales in the calling workspace
   % not sure how to do this, instead use a try on the final evalin command
   % try
   %    
   % catch ME
   %    
   % end
   
   % build the save command
   savecmd = ['save(''' filename ''',''' variables ''',''' version ''');'];
   
   % save the data - I think we want 'caller' not 'base'
   try
      evalin('caller',savecmd)
   catch ME
      if strcmp(ME.identifier,'MATLAB:string:MustBeStringScalarOrCharacterVector')
         try
            evalin('caller',strjoin(savecmd,''));
         catch
         end
      else
         try
            evalin('base',savecmd)
         catch
            warning('file not saved, see try-catch block in savematfile')
         end
      end
   end
end



% % assign in the variable data
% variables = evalin('caller', variables);
% 
% % save the data
% if p.Results.saveflag
%    save(filename,variables,p.Results.version);
% end













