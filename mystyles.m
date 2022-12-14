% Style Guide notes:
% - use i for iterator, like I normally do e.g. for iFile
% - use n for number of, like I normally do e.g. for nFiles
% 
% use Camel Case (aka Upper Camel Case) for classes: VelocityResponseWriter
% use Lower Case for packages: com.company.project.ui
% use Mixed Case (aka Lower Camel Case) for variables: studentName
% use Upper Case for constants : MAX_PARAMETER_COUNT = 100
% use Camel Case for enum class names and Upper Case for enum values.
% don't use '_' anywhere except constants and enum values (which are constants).


% function signatures
% required args followed by one optional argument (if string/char, must use
% validatestring so parser can distinguish from optional parameters), followed
% by optional name-value parameters, followed by one string/char flag argument.
% standard practice would use 'plotfit' or 'dispfit' for the flag. 

% NOTE: until function hints are supported for the editor and/or commandwindow,
% I am using 'Required' for stuff I would prefer to use 'Optional' becuase
% with Optional, the argument is buried in 'varargin' and doesn't show up in
% the function hint. Use Live Scripts to see the difference, change a required
% argument to optional, remove it from the function definition line, and in a
% live script it will show it but otherwise you get
% myfunc(required1,required2,...) where the optional arg is buried in ...
% but somehow matlab supports these function hints for their own functions even
% ones like prctile that don't appear to be in the functionSignatures.json file
% in that folder

% Line widths:
% fortran 77 is 72
% python (PEP-8) says 79 for code, and 72 for " flowing long blocks of text
% with fewer structural restrictions (docstrings or comments)".

% PEP-8:
% https://peps.python.org/pep-0008/#maximum-line-length

% Objects are capitalized. This includes structures, tables, and cell
% arrays. Datetime objects too. Standard variable names include:

% Data (could be a structure, table, or timetable of data)
% Time (a calendar represented as a Datetime object)
% Path (a structure of paths set by setpath)

% counters:
% outer: n
% inner: m
%  inner inner: nn
%     inner inner inner: mm

% camel case:
% used only for variable names
% when a variable name is three or more words, e.g.:
% pathUserData not pathuserdata
% pathdata not pathData
% function variable inputs can be more than two words, above rules apply
% function paramter or optional inputs are never more than two words so
% camel case is never used 

% structs:
% variables are never accessed from structures within scripts or functions
% this means the data must be assigned out of the structure to a workspace
% variable at the top of the script or function, in its own dedicated block
% this greatly simplifies code change due to structure variable name change


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


% scripts
% data
% func
% docs
% notes
% private
% test

% usr
% dat
% src
% man
% doc

% or:

% usr
% dat
% src
% man

% plus:

% usr/scripts
% usr/docs
% usr/notes

% and keep usr private



