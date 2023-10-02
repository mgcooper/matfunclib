function namedargs = parser2varargin(p, requiredargs, option)
   %PARSER2VARARGIN convert parser object structs to varargin.
   %
   %  namedargs = parser2varargin(p, requiredargs, 'usingdefaults') converts
   %  values in p.Results struct for which p.UsingDefaults is true to a cell in
   %  varargin format. 
   %
   %  namedargs = parser2varargin(p, requiredargs, 'notusingdefaults') converts
   %  values in p.Results struct for which p.UsingDefaults is false to a cell in
   %  varargin format
   %
   %
   % See also

   % Note: update aug 2023, for this to work I think parser.keepunmatched might
   % need to be true and have values, and then it will parse out those ones
   % which are arguments not added to the parser but valid args to the wrapper
   % function

   % so far, this seems to work, but i am not certain the order of namedargs
   % will always be correct, for example with optional args, or multiple
   % required args, but espectially optional and/or flags. THIS SHOULD BE
   % REPLACED by an additioanl method in magicParser that adds the required args
   % to the parser object, then i could just use p.UsingDefaults and the known
   % required args to dtermine which inputs are NOT using defaults and pass
   % those to shaperead or whatever built-in I am wrapping around.

   % this was very confusing, but basically, this should be renamed something
   % like: defaults2varargin, unless there really are additional use cases that
   % justify a general function parser2varargin. the problem this solves is the
   % following: I want to write a function that wraps around a matlab built in
   % function and i want to be able to pass the default syntax for that built-in
   % function into my wrapper function. But I want to pass the built-in syntax
   % as varargin{:} because the built-in function doesn't use inputParser and/or
   % it has inputs that don't have default values, so i cannot mirror those
   % default values in my input parser and I don't know which default values
   % would work, in general. If I did know, then I could just use a full call to
   % the built-in. For example, this came up in shaperead. If I knew good
   % default values, my loadgis function could just call shaperead like:
   % 
   % S = shaperead(fname,'BoundingBox',defaultbbox,'Attributes',defaultatts, ...)
   % 
   % and so on. But without good default values, i cannot do this, and instead,
   % I need to have a switch block or a bunch of if/else statements that
   % determine which values were passed into my function and then execute each
   % calling syntax of shaperead. To avoid that, i want to use input parser to
   % determine which parameters were passed into my function, bundle them as a
   % cell array, and then send that to shaperead. This function does that.

   % requiredargs = varargin{1};
   % option = varargin{2};

   % first find which values of p.Results are optional
   allargs = fieldnames(p.Results);
   optionalargs = allargs(~ismember(allargs,requiredargs));


   % note: instead of fieldnames(p.Results), could use p.Parameters. It may turn
   % out that one or the other is needed in general to satisfy all cases.

   % we cannot just use p.Parameters(ismember(p.Parameters,p.UsingDefaults))
   % because we will get the required args too.

   % NOTE: this isn't going to work when an optional parameter IS used. in short,
   % there isn't a built in method to determine which args are rquired
   % requiredargs = allargs(~ismember(allargs,p.UsingDefaults));

   switch option

      % NOTE: i think this is nonsensical b/c I can just use p.UsingDefaults
      case 'usingdefaults'
         ok = find(ismember(optionalargs,p.UsingDefaults));

         % I think this is the only case that matters
      case 'notusingdefaults'
         ok = find(~ismember(optionalargs,p.UsingDefaults));

         % here I was gonna move unmatched2varargin here, in case theres an edge
         % case that isn't satisfied by namedargs2cell, so I have all the
         % various functionality in one place.
      case 'unmatched'


   end

   ok = sort([2.*ok-1;2.*ok]);
   namedargs = namedargs2cell(p.Results);
   namedargs = namedargs(ok);

   % N = numel(fieldnames(p.Results))
end
