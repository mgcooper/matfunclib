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

% don't use boolean flags to change the path a function takes - create a
% separate function (or at minimum, a local function)

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


% filenames
% 
% Placename_object_geomtype_proj_optionaldescription
% 
% vector example: kuparuk_basin_line_geo_simplified
% raster example:
% kuparuk_topo_100m_utm_filled. 
% 
% another way:
% 
% identifier_type_status_date.ext
% example:
% interface_baseflow_update_v1_19Jan2023.ppt
% interface_baseflow_update_FINAL_19Jan2023.ppt
% 
% but if docs are already ordered in a directory such as:
% projects/interface/baseflow
% then the example above may be redundant and can be shortened to:
% projects/interface/baseflow/updates/baseflow_FINAL_19Jan2023
% or shorten paths in preference to filenames:
% projects/interface/baseflow_update_FINAL_19Jan2023
% 
% https://finance.uw.edu/recmgt/resources/file-folder-naming-conventions

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% TENTATIVE DEFAULT PROJECT DIRECTORY STRUCTURE
% data
% demos
% scripts
% functions
% figures
% tests
% sandbox
% workflow

% TENTATIVE DEFAULT TOOLBOX DIRECTORY STRUCTURE
% images
% release
% sandbox
% tests
% toolbox
% toolbox/toolbox.toml
% toolbox/gettingStarted.mlx
% toolbox/functionSignatures.json
% toolbox/data
% toolbox/docs
% toolbox/demos
% toolbox/hooks
% toolbox/internal
% toolbox/+tbx
% toolbox/+tbx/+internal
% toolbox/+tbx/+tools
% toolbox/+tbx/private

% regarding testbed/ Maybe usr/ is better than testbed but it might conflict
% with git. Basically anything obvious is problematic for git
% dev, devel, working is misleading, testing too similar to tests, user too
% similar to Users/ , private conflicts with matlab, sandbox could work but it's
% somewhat misleading although maybe not because testbed should be in another
% branch so maybe sandbox is ideal because it represents stuff you want in every
% branch but not pushed to remote.    
% Maybe local/ is best since that's exactly what it is. But actually info
% exclude might mean it's totally outside version control whereas git ignore
% just doesn't push it so I might need to consider that for my own work. Maybe
% ignore/ and local/ are two different things    

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

%% colors

% 
% C 0
% M 160
% Y 227
% B 51 
% Alpha 255
% 
% R 203
% G 75
% B 22
% Alpha 255
% Code: CB4B16
% 
% matrix:
% orange keywords CB4B16
% bluish grey background: 002B36
% lighter but good purple text: 6C71C4
% brighter red text: DC322F
% nice blue text: 268BD2
% 
% monokai
% pinkish red keywords: F92672
% yellowish strings: E6DB74
% grey brownish background : 272822 (this is what iw ant to change)
% grey comments: 75715E
% white text: F8F8F0
% 
% My combo:
% matrix background: 002B36
% monokai keywords: F92672
% matrix comments: 268BD2 (increased brighter to 4DBEEE then again to 61C9FF
% 
% 
% monokai yellowish strings are good: E6DB74
% But I tried it with text paired with light purple matrix for strings and it's too much yellow
% 
% 
% this is a silvery grey white for text: F0F0F0
% this blue is similar but slightly brighter than matrix 'nice blue text' but : 4DBEEE
% this orange is similar but slightly brighter than monokai's orange D95319
% 
% Overall the ones abve are good:
% matrix background: 002B36 (switched to 404040 then to 3B3B3B, chatgpt background is 444654)
% monokai keywords: F92672
% silvery grey white for text: F0F0F0
% brighter blue comments: 4DBEEE
% brighter orange strings: D95319
% 
% 
% after using it a bit, I don't like the orange strings, so I switched keywords with strings
% switch orange keywords: D95319 with red strings: F92672
% 
% 
% alternatives to orange D95319 to make it brighter
% E96329: Increasing the red and green channels slightly.
% FF7329: Maxing out the red and increasing the green for a brighter appearance.
% FF8339: This further increases the green channel, which can add brightness and warmth.
% 
% alternatives to grey background:
% 002B36: matrix, slightly too dark and slight green tint
% 404040: neutral grey, but appears slight brown tint probably my monitor
% 404050: adds a touch of blue without significantly changing the darkness.
% 3B3B3B: slightly cooler shade of grey, a touch darker, still a very slight brown tint
% 343541: darker chatgpt background bands
% 444654: lighter chatgpt background bands
% 3A3A50: pronounced bluish tint, reduces the red and green channels a bit and increases the blue
% 
% overall: 
% 
% 404050 = slight blue tint
% 3A3A50 = pronounced blue tint
% 343541 = darker version of above (more grey, darker of the two chatgpt backgrounds)
% 
