function Info = renamefiles(FileList,varargin)
%RENAMEFILES rename files using a common pattern, prefix, or suffix
%
% Syntax
%
%  Info = RENAMEFILES(FileList,'NewFileNames',newnames) renames all files in
%  FileList by moving each file to a new file using the names (and order) in
%  NewFileNames, and returns status messages in Info.
%
%  Info = RENAMEFILES(FileList,'Prefix',prefix) prepends prefix to all filenames
%  in FileList.
%
%  Info = RENAMEFILES(FileList,'Prefix',prefix) appends suffix to all filenames
%  in FileList.
%
% Example
%
%
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
%
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'renamefiles';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

% validstrings      = {''}; % or [""]
% validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'FileList',                   @(x)islist(x)        );
p.addParameter(   'NewFileNames',   '',         @(x)islist(x)        );
p.addParameter(   'Prefix',         '',         @(x)ischar(x)        );
p.addParameter(   'Suffix',         '',         @(x)ischar(x)        );
p.addParameter(   'StrFind',        '',         @(x)ischar(x)        );
p.addParameter(   'StrRepl',        '',         @(x)ischar(x)        );
p.addParameter(   'dryrun',         false,      @(x)islogical(x)     );
p.addParameter(   'useGitMove',     false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

% check if .git exists in the base folder to avoid losing git history
BasePath = FileList(1).folder;
if isfolder([BasePath filesep '.git']) && useGitMove == false
   msg = ['.git folder detected but useGitMove is false. press ' ...
      '''y'' to continue or any other key to cancel.'];
   disp(msg);
   ch = getkey();
   if ch==121
      return
   end
end

% get the requested renaming option
options = {'NewFileNames','Prefix','Suffix','StrFind','StrRepl'};
renameOption = struct();
for n = 1:numel(options)
   renameOption.(options{n}) = ~isempty(p.Results.(options{n}));
end

% determine if NewFileNames, Prefix, or Suffix should be used
if renameOption.NewFileNames && renameOption.Suffix
   warning('appending suffix to new filenames');
elseif renameOption.NewFileNames && renameOption.Prefix
   warning('prepending prefix to new filenames');
elseif renameOption.Suffix && renameOption.Prefix
   warning('appending prefix and suffix to existing filenames');
end

% FindReplace is mutually exclusive with the other options
if renameOption.StrFind + renameOption.StrRepl == 1
   error('Parameters StrFind and StrRepl must be provided together');
elseif renameOption.StrFind + renameOption.StrRepl == 2
   if any([renameOption.NewFileNames renameOption.Prefix renameOption.Suffix])
      error('FindReplace cannot be used with any other option');
   end
end

% convert NewFileNames and Prefix/Suffix to string/arrays
NewFileNames = cellstr(NewFileNames);
Prefix = char(Prefix);
Suffix = char(Suffix);
StrFind = char(StrFind);
StrRepl = char(StrRepl);

Info = struct();

% FIND REPLACE NEEDS TO BE ADDED

for n = 1:numel(FileList)
   
   Path    = FileList(n).folder;
   Name    = FileList(n).name;
   File    = fullfile(Path, Name);
   
   if useNewFileNames
      newName = NewFileNames{n};
   else
      newName = Name;
   end
   if usePrefix
      newName = [Prefix newName];
   end
   if useSuffix
      newName = [newName Suffix];
   end
   
   newFile = fullfile(Path, newName);
   
   if dryrun == true
      disp(['moving ' Name ' to ' newName]);
      continue
   else
   
      if useGitMove
         [status,msg] = system(['git mv ' File ' ' newFile]);
      else
         [status,msg] = movefile(File, newFile);
      end
      if status ~= 1
         error(msg);
      end
      Info.msg{n} = msg;
   end
end












