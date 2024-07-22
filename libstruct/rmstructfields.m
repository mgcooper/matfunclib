function S = rmstructfields(S, fields, option)
   %RMSTRUCTFIELDS remove or keep fields from scalar or non-scalar structure
   %
   %  S = rmstructfields(S, fields)
   %  S = rmstructfields(S, fields, 'drop')
   %  S = rmstructfields(S, fields, 'keep')
   %
   % Description
   %  S = rmstructfields(S, fields, option) removes or keeps fields from S, a
   %  scalar or non-scalar struct. FIELDS is a cellstr array of field names,
   %  char, or string. OPTION specifies whether to 'drop' or 'keep' the fields.
   %  The default OPTION is 'drop', which replicates standard rmfield behavior.
   %
   % % Example with scalar struct
   %  s.a = 1; s.b = 2; s.c = 3;
   %  s = rmstructfields(s, {'a', 'b'}, 'drop')
   %
   %  s.a = 1; s.b = 2; s.c = 3;
   %  s = rmstructfields(s, {'a', 'b'}, 'keep')
   %
   % % Example with nonscalar struct
   %  s = arrayfun(@(x) struct('a', x), 1:10);
   %  s = arrayfun(@(s, x) setfield(s, 'b', x), s, 2:11);
   %  s = arrayfun(@(s, x) setfield(s, 'c', x), s, 3:12);
   %  s = arrayfun(@(s) setfield(s, 'd', magic(3)), s); % non-scalar field
   %
   %  s = rmstructfields(s, {'a', 'b'}, 'drop')
   %
   % % Example of "keep" with nonscalar struct
   %  s = arrayfun(@(x) struct('a', x), 1:10);
   %  s = arrayfun(@(s, y) setfield(s, 'b', y), s, 2:11);
   %  s = arrayfun(@(s, y) setfield(s, 'c', y), s, 3:12);
   %
   %  s = rmstructfields(s, {'a', 'b'}, 'keep')
   %
   % See also: rmfield, commonfields, addstructfields, catstructfields

   % Check inputs
   if nargin < 3
      option = 'drop';
   end
   validateattributes(S, {'struct'}, {'nonempty'}, mfilename, 'S', 1)
   option = validatestring(option, {'drop', 'keep'}, mfilename, 'option', 3);

   if ischar(fields) || isstring(fields)
      fields = cellstr(fields);
   end

   % Determine fields to remove based on the option
   switch option
      case 'drop'
         fields = intersect(fieldnames(S), fields);
      case 'keep'
         fields = setdiff(fieldnames(S), fields);
   end

   if isempty(fields)
      return
   end

   % Note: rmfields should work for scalar and non-scalar. Not sure why the
   % try-catch and the nonscalar and scalar cases are needed.

   if isscalar(S)
      % Scalar structure case
      try
         S = rmfield(S, fields);
      catch e
         for n = 1:numel(fields)
            S.(fields{n}) = [];
         end
      end
   else
      % Note: struct2table sets AsArray=true by default for non-scalar structs,
      % but it is set here for clarity. Similarly, 'ToScalar' defaults to false.
      try
         T = struct2table(S, 'AsArray', true);
         T = removevars(T, fields);
         S = table2struct(T, 'ToScalar', false);
      catch e
         % placeholder. shouldn't fail.
      end
   end
end
