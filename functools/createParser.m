function parser = createParser(functionName, varargin)
   % CREATEPARSER create parser object
   %
   % function parser = createParser( ...
   %    functionName, ...
   %    RequiredArguments,RequiredValidations, ...
   %    OptionalArguments, OptionalDefaults, OptionalValidations, ...
   %    ParameterArguments, ParameterDefaults, ParameterValidations)
   %
   % Example
   %
   % p = createParser( ...
   %    mfilename, ...
   %    'OptionalArguments', {'Dc','sigDc','Dg'}, ...
   %    'OptionalDefaults', {nan(size(Db)), nan(size(Db)), nan(size(Db))}, ...
   %    'OptionalValidations', {@(x) isnumeric(x), @(x) isnumeric(x), @(x) isnumeric(x)}, ...
   %    'ParameterArguments', {'ax', 'method'}, ...
   %    'ParameterDefaults', {gca, 'ols'}, ...
   %    'ParameterValidations', {@(x) bfra.validation.isaxis(x), @(x) ischar(x)} ...
   %    );
   %
   % See also

   % for reference, another format I toyed with:
   % p = createParser(mfilename, 'Optional', { ...
   %    {'Dc', nan(size(Db)), @(x)isnumeric(x)}, ...
   %    {'Dg', nan(size(Db)), @(x)isnumeric(x)}, ...
   %    {'sigDc', nan(size(Db)), @(x)isnumeric(x)} }, 'Parameters',{ ...
   %    {'ax', gca, @(x) bfra.validation.isaxis(x)}, ...
   %    {'method', 'ols', @(x) ischar(x)} } );

   p = magicParser; %#ok<*USENS>
   p.addRequired('functionName',@(x)ischar(x)|isstring(x));
   p.addParameter('RequiredArguments',cell(0),@(x)iscell(x));
   p.addParameter('RequiredValidations',cell(0),@(x)iscell(x));
   p.addParameter('OptionalArguments',cell(0),@(x)iscell(x));
   p.addParameter('OptionalDefaults',cell(0),@(x)iscell(x));
   p.addParameter('OptionalValidations',cell(0),@(x)iscell(x));
   p.addParameter('ParameterArguments',cell(0),@(x)iscell(x));
   p.addParameter('ParameterDefaults',cell(0),@(x)iscell(x));
   p.addParameter('ParameterValidations',cell(0),@(x)iscell(x));
   p.parseMagically('caller');

   % see this, saved in mysource/matlab/manager, but i cannot tell what it does
   % that p.parse and then using p.Results doesn't already do ... actually looking
   % more carefully the varargin2opt function doesn't use inputParser but the _tiny
   % version does
   % https://github.com/MarcinKonowalczyk/varargin2opt.git

   parser = magicParser;
   % parser.FunctionName = functionName;
   parser.FunctionName = mfilename;

   % cycle over default parser options - KeepUnmatched etc.

   % for n = 1:numel(parseropts)
   % 	parser.parseropts{n}   = false;
   % end

   numrequired = numel(RequiredArguments);
   numoptional = numel(OptionalArguments);
   numparameters = numel(ParameterArguments);

   for n = 1:numrequired

      parser.addRequired( ...
         RequiredArguments{n}, ...
         RequiredValidations{n} ...
         );
   end

   for n = 1:numoptional

      parser.addOptional( ...
         OptionalArguments{n}, ...
         OptionalDefaults{n}, ...
         OptionalValidations{n} ...
         );
   end

   for n = 1:numparameters

      parser.addParameter( ...
         ParameterArguments{n}, ...
         ParameterDefaults{n}, ...
         ParameterValidations{n} ...
         );
   end

   % parser.parseMagically('caller');
   % target = 'caller';
   % names = fieldnames(parser.Results);
   % for nn = 1:numel(names)
   %    name = names{nn};
   %    value = parser.Results.(name);
   %    if ischar(target)
   %       assignin(target, name, value);
   %    elseif isstruct(target) || isprop(target, name)
   %       target.(name) = value;
   %    end
   % end
end
