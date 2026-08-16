function data = readtoml(filename)
   %READTOML Parse a TOML file into a nested struct.
   %
   %  data = readtoml(filename)
   %
   % Parses the TOML subset the mproject.toml manifest uses:
   %
   %   - full-line and trailing # comments
   %   - [section] and [dotted.section] tables
   %   - key = "string" (double-quoted; no escape processing)
   %   - key = true | false
   %   - key = <number>
   %   - key = ["a", "b"] single-line arrays of strings (returned cellstr)
   %
   % Anything outside the subset raises an identified error rather than
   % mis-parsing it. Section and key names become struct field names, so
   % they must be valid MATLAB identifiers.
   %
   % Written in Octave-compatible style (no arguments block, cellstr
   % internals): the manifest layer must parse under Octave per the
   % redesign DesignSpec, settled decision 3.
   %
   % See also: readmanifest

   narginchk(1, 1)
   filename = char(filename);
   if exist(filename, 'file') ~= 2
      error('matfunclib:readtoml:fileNotFound', ...
         'TOML file not found: %s', filename);
   end

   % Read all lines (fileread + strsplit keeps Octave compatibility).
   text = fileread(filename);
   lines = strsplit(text, {'\r\n', '\n', '\r'}, 'CollapseDelimiters', false);

   data = struct();
   section = {};   % current table path as a cellstr of field names

   for n = 1:numel(lines)
      line = stripcomment(lines{n});
      if isempty(line)
         continue
      end

      if line(1) == '['
         % Table header: [name] or [dotted.name]
         if line(end) ~= ']'
            error('matfunclib:readtoml:badSection', ...
               'Malformed section header on line %d: %s', n, lines{n});
         end
         section = strsplit(line(2:end-1), '.');
         section = validatenames(section, n, lines{n});
         data = ensuresection(data, section);
         continue
      end

      eq = find(line == '=', 1);
      if isempty(eq)
         error('matfunclib:readtoml:badLine', ...
            'Expected key = value on line %d: %s', n, lines{n});
      end

      key = validatenames({strtrim(line(1:eq-1))}, n, lines{n});
      value = parsevalue(strtrim(line(eq+1:end)), n, lines{n});
      data = setfieldpath(data, [section, key], value);
   end
end

%% Local functions
function line = stripcomment(line)
   % Remove a # comment (quote-aware: # inside a double-quoted string is
   % literal) and surrounding whitespace.
   inquote = false;
   for k = 1:numel(line)
      if line(k) == '"'
         inquote = ~inquote;
      elseif line(k) == '#' && ~inquote
         line = line(1:k-1);
         break
      end
   end
   line = strtrim(line);
end

function names = validatenames(names, lineno, rawline)
   for k = 1:numel(names)
      names{k} = strtrim(names{k});
      if ~isvarname(names{k})
         error('matfunclib:readtoml:badName', ...
            ['Section or key name "%s" on line %d is not a valid field ' ...
            'name: %s'], names{k}, lineno, rawline);
      end
   end
end

function data = ensuresection(data, section)
   % Create nested empty structs down the section path. The broadcast
   % struct() call builds the whole subscript-reference array at once.
   ref = struct('type', '.', 'subs', section);
   try
      existing = subsref(data, ref);
      % A section reopening a scalar key is a collision, not a table.
      if ~isstruct(existing)
         error('matfunclib:readtoml:nameCollision', ...
            'Section [%s] collides with an existing key.', ...
            strjoin(section, '.'));
      end
   catch sectionErr
      if strcmp(sectionErr.identifier, 'matfunclib:readtoml:nameCollision')
         rethrow(sectionErr)
      end
      data = subsasgn(data, ref, struct());
   end
end

function data = setfieldpath(data, path, value)
   ref = struct('type', '.', 'subs', path);
   % A key overwriting an existing table would drop the table without a
   % message; fail fast instead.
   try
      existing = subsref(data, ref);
      collides = isstruct(existing);
   catch
      collides = false;
   end
   if collides
      error('matfunclib:readtoml:nameCollision', ...
         'Key %s collides with an existing section.', strjoin(path, '.'));
   end
   data = subsasgn(data, ref, value);
end

function value = parsevalue(raw, lineno, rawline)
   if isempty(raw)
      error('matfunclib:readtoml:badValue', ...
         'Empty value on line %d: %s', lineno, rawline);
   end

   if raw(1) == '"'
      % Double-quoted string.
      if numel(raw) < 2 || raw(end) ~= '"'
         error('matfunclib:readtoml:badValue', ...
            'Unterminated string on line %d: %s', lineno, rawline);
      end
      value = raw(2:end-1);
      % The subset does no escape processing, so an embedded quote means
      % an out-of-subset construct (triple-quoted or concatenated
      % strings); fail fast instead of returning a corrupted value.
      if any(value == '"')
         error('matfunclib:readtoml:badValue', ...
            'Embedded quotes are outside the supported subset (line %d): %s', ...
            lineno, rawline);
      end

   elseif raw(1) == '['
      % Single-line array of strings.
      if raw(end) ~= ']'
         error('matfunclib:readtoml:badValue', ...
            'Arrays must open and close on one line (line %d): %s', ...
            lineno, rawline);
      end
      inner = strtrim(raw(2:end-1));
      if isempty(inner)
         value = {};
         return
      end
      parts = strsplit(inner, ',');
      value = cell(1, numel(parts));
      for k = 1:numel(parts)
         part = strtrim(parts{k});
         if numel(part) < 2 || part(1) ~= '"' || part(end) ~= '"'
            error('matfunclib:readtoml:badValue', ...
               ['Array elements must be double-quoted strings ' ...
               '(line %d): %s'], lineno, rawline);
         end
         value{k} = part(2:end-1);
      end

   elseif strcmp(raw, 'true')
      value = true;
   elseif strcmp(raw, 'false')
      value = false;
   else
      value = str2double(raw);
      if isnan(value)
         error('matfunclib:readtoml:badValue', ...
            ['Unsupported value syntax on line %d (the manifest subset ' ...
            'allows strings, booleans, numbers, and string arrays): %s'], ...
            lineno, rawline);
      end
   end
end
