function opts = optionParser(validopts,calleropts,varargin)
   %OPTIONPARSER Parse optional inputs to logical name-value struct
   %
   %  opts = optionParser(validopts,calleropts) finds elements of calleropts
   %  that are members of validopts and sets them to true in structure opts
   %
   %  opts = optionParser(validopts,calleropts,opts) adds elements of calleropts
   %  that are members of validopts to provided structure opts and sets them to
   %  true
   %
   % optionParser is based on this method:
   %
   % optargs = varargin(cellfun(@ischar, convertStringsToChars(varargin)));
   % opts = cell2struct(num2cell(false(size(validopts))), validopts, 2);
   % for arg = validopts(:).'
   %    opts.(arg{:}) = ismember(arg, optargs);
   % end
   %
   % Inputs
   %  VALIDOPTS are the options available within a function.
   %  CALLEROPTS is the varargin cell array of optional inputs.
   %  OPTS is an optional opts structure that the parsed options are added to.
   %
   %  Example 1
   % -----------
   %
   %  opts = optionParser({'option1','option2','option3'},{'option1'})
   %
   % opts =
   %
   %   struct with fields:
   %
   %     option1: 1
   %     option2: 0
   %     option3: 0
   %
   %  Example 2
   % -----------
   %
   % %  set some opts in the calling script
   %  opts.makeplots = true;
   %  opts.saveplots = false
   %
   % %  pass that opts struct to another function and set some new opts relevant
   % to the new function
   %
   %  myfunc(1,2,opts,'add')
   %
   %  function c = myfunc(a,b,opts,varargin)
   %  % make up a fake varargin for demonstration
   %  varargin={'add'}
   %  validopts = {'add','multiply'};
   %  opts = optionParser(validopts,varargin(:),opts);
   % % returns:
   % % opts =
   % %   struct with fields:
   % %
   % %     makeplots: 1
   % %     saveplots: 0
   % %           add: 1
   % %      multiply: 0
   %
   %  if opts.add == true && opts.multiply == true
   %     error('only one options, add or multiply, can be true');
   %  end
   %
   %  if opts.add == true
   %     c = a+b;
   %  elseif opts.multiply == true
   %     c = a*b;
   %  end
   %
   %
   % % test the simpler version - this shows how optionParser could be simplified
   %  opts.makeplots = true;
   %  opts.saveplots = false
   %  validopts = {'add','multiply'};
   % % pretend we also have valid opts in the calling function
   %  newopts = fieldnames(opts);
   %  validopts = {'add','multiply', newopts{:}};
   % % build the calleropts
   %  calleropts = {'add', newopts{struct2array(opts)}}
   % % add some non-compatible values
   % calleropts = [calleropts, 2, string.empty]
   %  test_optionparser(validopts, calleropts{:})
   %
   % See also:

   narginchk(2,3);
   if nargin == 3
      opts = varargin{1};
   end

   % convert to cell array if passed in as a char
   if ischar(validopts)
      validopts = cellstr(validopts);
   end

   % I think i broke something with the last update ... if i preset opts to
   % contain the default opts they get overriden as false UPDATE 7 feb, this
   % should fix it - replace any non-comparable calleropts with an empty char
   for n = 1:numel(calleropts)
      try
         ismember(calleropts{n},validopts);
      catch ME
         if strcmp(ME.identifier,'MATLAB:ISMEMBER:InputClass')
            calleropts{n} = '';
         end
      end
   end

   % set opts true if passed in via varargopts
   for n = 1:numel(validopts)

      try
         if isfield(opts,validopts{n}) % keep default value that was passed in
            continue
         end
      catch
         opts.(validopts{n}) = false; % set default false
      end

      try
         opts.(validopts{n}) = ismember(validopts{n},calleropts);

      catch ME
         % catch cases where varargin from the calling function is not a char.
         % Note, this may be too lenient, but it means this function works if
         % the calling funtion has non-char optional inputs that are processed
         % within the calling function. if name-value pairs are used it will get
         % confused but as long as the callign function knows the valid optional
         % args it should be ok
         if strcmp(ME.identifier,'MATLAB:ISMEMBER:InputClass')
            % let it go
         end
      end
   end
end
