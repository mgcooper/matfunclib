function varargout = function_tricks(varargin)
%FUNCTION_TRICKS function tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

% 

% thought the comma separated lists trick might work with p.Results but 1) the
% default args are included in p.Results, and 2) the fields are sorted
% alphabetically, not in the order added to the parser, so dealing them out
% requires specifying the argument on the LHS alphabeticaly which is too error
% prone to use in practice
[out1, out2,...,] = P.Results(:)

%%

% might try to implement this. It is not needed for parsegraphics, but might be
% useful in general.

% ifany = any(cellfun(@(v) strcmp('any', v), varargin));

%% error handling

% For error (and i think assert), use num2ordinal, unlike validateattributes,
% where the integer is used. for example from checkxy.m:
error(sprintf('map:%s:inconsistentXY', function_name), ...
   'Function %s expected its %s and %s input arguments, %s and %s, to match in size or NaN locations.', ...
   upper(function_name), num2ordinal(x_pos), num2ordinal(y_pos), ...
   x_var_name, y_var_name)

% for cleaner try-catch, use this:
try
   something
catch e
   rethrow(e)
end

% in a subfunction (or private/internal function meant to always be called)
try
   something
catch e
   throwAsCaller(e)
end

%%
% below are snippets from zmat libary

% contents of miss_hit:
% project_root
% suppress_rule: "redundant_brackets"
% indent_function_file_body: false

% Could use this instead of my other default nargin == 0 open file command,
% and/or call the .help function
if (nargin == 0)
    fprintf(1, 'Usage:\n\t[output,info]=zmat(input,iscompress,method);\nPlease run "help zmat" for more details.\n');
    return
end

% zipmat is a mex file, the 
[varargout{1:max(1, nargout)}] = zipmat(input, iscompress, zipmethod);

%% ? syntax for arguments block

% to get the ? syntax, create the object, and call metaclass, e.g. if H is a
% boxcchart handle:
mc = metaclass(H);

% If the class is known, use it, as in the opts.? arguments block method:
mc = ?matlab.graphics.chart.primitive.BoxChart

% Equivalent to:
meta.class.fromName('matlab.graphics.chart.primitive.BoxChart')

% But since the class name is not normally known, the workflow is to create the
% object then query it using mc =metaclass(obj)

% Example:

% Generate some data
data = randn(100, 3);

% Create a boxchart
H = boxchart(data); hold on;

% Gett the metaclass
mc = metaclass(H);

% then use the 'Name' field, evaluate the next line to see what would go in the
% arguments block:
['opts.?' mc.Name]

% e.g.:
% arguments
%    opts.?matlab.graphics.chart.primitive.BoxChart
% end

%% ax input

% I tried to add an optional 'ax' first arg to mimic the way matlab pltoting
% fucntions work, but the trick is the function must only accept vararagin, so
% ax can be removed, and the remainig args parsed so this doesnt work b/c 'ax'
% is interpreted as 'time' if passed in, and cannot be removed, although i
% suppose i could do a complicated check if th efirst arg is an ax, then
% time=flow, and flow=prec, and prec = varargin{1}

% function h = hyetograph(time,flow,prec,varargin)
% p = magicParser; %#ok<*NODEF>
% p.FunctionName = mfilename;
% p.addOptional('ax',     gca,              @(x)isaxis(x)                    );
% p.addRequired('time',                     @(x)isnumeric(x)|isdatetime(x)   );
% p.addRequired('flow',                     @(x)isnumeric(x)                 );
% p.addRequired('prec',                     @(x)isnumeric(x)                 );
% p.addOptional('t1',     min(time),        @(x)isnumeric(x)|isdatetime(x)   );
% p.addOptional('t2',     max(time),        @(x)isnumeric(x)|isdatetime(x)   );
% p.addParameter('units', {'mm','cm d-1'},  @(x)ischarlike(x)                );
% p.parseMagically('caller');

%%

% various fex arg parsers
% https://www.mathworks.com/matlabcentral/fileexchange/42205-argutils?s_tid=answers_rc2-1_p4_Topic
% https://www.mathworks.com/matlabcentral/fileexchange/39772-easyparse?s_tid=answers_rc2-3_p6_Topic
% https://www.mathworks.com/matlabcentral/fileexchange/52173-parseparameters?s_tid=answers_rc2-2_p5_MLT

% to get help for local or nested functions use filemarker which returns >
help(['getFloodPeaks' filemarker 'peaksonref'])

% i think this would work for input parsing with multiple mutually
% exclusive inputs:
%    if ismember(p.UsingDefaults,{'library','project'})
%       functionpath = [getenv('MATLABFUNCTIONPATH') library '/' funcname '/'];
%    elseif ismember(p.UsingDefaults,'
%       functionpath = [getenv('MATLABPROJECTPATH') project '/func/' funcname '/'];
%    end

% some matlab built-ins have a folder for the functionSignature support
% functions e.g. my functiondirectorylist.m, see:
% /Applications/MATLAB_R2020b.app/toolbox/matlab/datatypes/tabular/+matlab/+internal/+tabular


% to use a function to generate choices, see mkfunction, the key was to not
% put {} around the function name 

% if i set structexpand false, then i know for certain it won't be expanded
% (and it leaves a clue to later know that i don't want opts to have
% matching namevalue)  

   
% WOW see bfra_mapbasins for option to autocomplete a variable "choice"
% based on input structure field names

% TLDR: only use 'flag' type arguments when there aren't any name-values,
% and otherwise use all name-values


% UPDATE TLDR: after testing, i think none of my prior concerns are valid.
% you can pass in a struct and the default behavior is to unpack it. if so,
% any name-value parameters will be overriden by the struct value. If the
% struct doens't have a name-value, the default set in the parser will be
% used

% UPDATE: on below, if I use validateattributes to create a valid input
% argument, I can get around the stuff below, see:
% https://stackoverflow.com/questions/39946990/can-we-use-addoptional-and-addparameter-together
% from bfra_refline I learned how to use an optional char prior to
% name-value. The key thing is that when calling the function, you have to
% pass a value to the optional char argument even when you don't want it.
% for example, with refline i want an optional argument to just pass in
% 'upperenvelope' but i also want the name-value 'refpoint',point option,
% if parser is in this order:

% addrequired
% ...
% addoptional('refline','userdefined',@(x)ischar(x));
% addparameter('refpoint',nan,@(x)isnumeric(x));

% then when calling it I must use:
% bfra_refline(x,y,b,'userdefined','refpoint',points)
% NOT
% bfra_refline(x,y,b,'refpoint',points)

% I also tried moving the argument 'refline' to the end and making it a
% flag and a positional argument in the input parser and json file but it
% doesn't work, the reason is explaiend in the stack overlflow below,
% because it's a char, and parser gets confued b/c name-values are also
% char

% this is discussed here
% https://stackoverflow.com/questions/45670058/function-with-varargin-giving-error-when-providing-name-value-pair-only-matla

% In the end i decided it's better tojust make them all name-value since i
% would have to remmenber that refline can be a flag and others cannot, and
% it must be set

%--------------------------------------------------------------------------
% struct inputs to parser
%--------------------------------------------------------------------------

% UPDATE on below: it seems I was confused. It is true that you don't
% addRequired or addOptional the struct array, but it appears you can have
% additional name-value pairs in the input parser that are not in the
% struct. For sure the addRequired thing was an initial confusion, but
% maybe there was a second problem like with the json file or something
% else that caused me to think they had to match exactly. I tested both 1)
% having fields in opts that do not have matching name-value. I think the
% confusion was becuase i did not hvae p.StructExpand = false; It could
% have also been related to keepUnmatched or partialMatching

% a key thing I didn't understand is that you DONT addRequired or
% addOptional the struct array, you addParameter all the name-value pairs
% within the struct array. 

% HOWEVER, this means you have to have the exact name-value pairs in the
% struct you pass in as you have addParameter statements, which can be
% annoying if you have a default opts strucutre and you want to pass it to
% subfunctions that only need some of the opts

% I thought MIP would solve this, but it doesn't seem to expand the name-


%--------------------------------------------------------------------------
% true false logical autocomplete function hint json
%--------------------------------------------------------------------------

{"name":"B",   "kind":"namevalue",  "type":["logical","scalar"],"purpose":"Option"}
%--------------------------------------------------------------------------
% optional input function hint
%--------------------------------------------------------------------------

% two ways I tried to pass an optional argument and still show the argument
% name in the function hint:

% 1. put an extra argument first and don't pass it to the parser
% 
%  function pauseSaveFig(obj,savekey,filename,varargin)
% 
%    % first check if first input is a graphics handle
% 
%     if not(isgraphics(obj)); obj = gcf; end
% 
%     % then do the parsing:
% 
%    p                 = inputParser;
%    p.FunctionName    = 'pauseSaveFig';
%    p.CaseSensitive   = true;
%    
%    addRequired(   p,'savekey',               @(x)ischar(x)     );
%    addRequired(   p,'filename',              @(x)ischar(x)     );
%    addOptional(   p,'obj',             gcf,  @(x)isgraphics(x) );
%    addParameter(  p,'Resolution',      300,  @(x)isnumeric(x)  );
%    
%    parse(p,savekey,filename,varargin{:});
% 
%    % I also tried parse with 'obj' as the first argument and no luck
%    
%    filename    = p.Results.filename;
%    savekey     = p.Results.savekey;
%    figres      = p.Results.Resolution;
% 
%  UPDATE: THIS OPTION WORKED, POSSIBLE I HAD ANOTHER MISTAKE AND ABOVE
%  WOULD WORK TOO
% 
% 2. put an optional argument last (but before varargin) and pass it to the parser
% 
% function pauseSaveFig(savekey,filename,obj,varargin)
% 
%    p                 = inputParser;
%    p.FunctionName    = 'pauseSaveFig';
%    p.CaseSensitive   = true;
% 
%    
%    addRequired(   p,'savekey',               @(x)ischar(x)     );
%    addRequired(   p,'filename',              @(x)ischar(x)     );
%    addOptional(   p,'obj',             gcf,  @(x)isgraphics(x) );
%    addParameter(  p,'Resolution',      300,  @(x)isnumeric(x)  );
%    
%    parse(p,savekey,filename,obj,varargin{:});
%    
%    filename    = p.Results.filename;
%    savekey     = p.Results.savekey;
%    figres      = p.Results.Resolution;
   
   
%--------------------------------------------------------------------------
% this way worked, i think because it's the only arugment
%--------------------------------------------------------------------------

% plotevents (or maybe pickevents) is where I used a function as the
% default value in inputparser, also in deactivate i think

% deactivate is where i retained an optional argument in the input syntax
% so it shows in the function hint

%--------------------------------------------------------------------------
% validate json notes:
%--------------------------------------------------------------------------

% new notes:
% For creating a function that converts inputParser to functionSignatures:
% required = required
% optional = ordered
% parameter = namevalue
% required followed by required that is followed by an optional = positional 
% positional is tricky, but is demonstrated in the help page for
% validateFunctionSignatures. they are technically optional, but "become
% required" to specify subsequent optional positional arguments. Bottom line,
% they are (? optional or required in the inputParser? or maybe they don't fit
% into an input parser neatly ...)
% flag on the other hand is a char switch at the end

% older notes:

% in json:
% 
% flag is something like 'omitnan'
% ordered
% 
% positional is not what i would intuitively expect - that's ordered or flag i.e. 'omitnan' or 
% positional is optional if it occurs at the end of the argument list, but becomes required to specify a subsequent positional argument, not sure if 
% positional must come before all name-value and flag arguments

%--------------------------------------------------------------------------
% detecting graphics with inputparser 
%--------------------------------------------------------------------------
% isobject(h)
% will return true for a line or patch or whatever handle and also an axis
% I wrote 'isaxis' which should work for axes but there are other types of
% axes that it won't detect, try help type to see many more
% other ones to know about:
% isgraphics
% isa
% e.g.: isa(suppliedline,'matlab.graphics.chart.primitive.Line')
doc is*

% for function signature fiels i got confused trying to require a structure
% as an input. a sturcture is an 'array' according to matlab, but array is
% not a valid type for the json file, below might help explain

% https://www.mathworks.com/help/mps/restfuljson/json-representation-of-matlab-data-types.html

% these two also have examples
% https://www.mathworks.com/help/matlab/matlab_prog/customize-code-suggestions-and-completions.html
% https://www.mathworks.com/help/mps/restfuljson/matlab-function-signatures-in-json.html

%--------------------------------------------------------------------------

% ARGUMENT PARSING IN SUBFUNCTION

% function h = plotrunoff(mar,merra,racmo,icemod,discharge,catchment,varargin)

%--------------------------------------------------------------------------

% set_opts is a subfunction that deals with the input arguments

% note that i should probably learn to use inputParser

    narginchk(6,9)

    numargin    = nargin;
    argsin      = varargin;
    opts        = set_opts(numargin,argsin);

    if opts.plot_surf == true
        icemod.runoff =   icemod.surf_runoff;
    elseif opts.plot_melt == true
        icemod.runoff =   icemod.depth_melt;
    end

%--------------------------------------------------------------------------

% from areaint.m:

% Ensure that lat and lon are column vectors
lat = lat(:);
lon = lon(:);

