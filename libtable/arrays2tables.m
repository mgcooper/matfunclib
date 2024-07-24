function C = arrays2tables(C, kwargs)
   %ARRAYS2TABLES Convert arrays or tables in a struct or cell into timetables.
   %
   %    tbls = arrays2tables(arrays)
   %    tbls = arrays2tables(arrays, ArrayNames=ArrayNames)
   %    tbls = arrays2tables(arrays, ColumnNames=ColumnNames)
   %    tbls = arrays2tables(arrays, astimetables=true, time=time)
   %    tbls = arrays2tables(arrays, bycolumn=true)
   %
   % Description
   %
   %    This function converts numeric matrices, tables, or timetables stored in
   %    a struct or a cell array into timetables. The output timetables are
   %    constructed either directly from the input arrays, or by concatenating
   %    columns taken individually from each input array to create new arrays.
   %    Specify the optional argument BYCOLUMN=TRUE to create one timetable for
   %    each respective column of regularly sized input arrays.
   %
   % Inputs (Required)
   %
   %    C - Container of input arrays. Can be a cell array containing one array
   %    per element, a struct containing one array per field, or a 3d numeric
   %    array where each page along the 3rd dimension is taken as one array.
   %    Each individual array is either a numeric matrix, table, or a timetable.
   %
   % Inputs (Optional name-value pairs)
   %
   %    ArrayNames - Names for each input array. If C is a struct, ArrayNames
   %    can be obtained from the fieldnames of C.
   %
   %    COLUMNNAMES - Names for the variables (columns) of input arrays. If the
   %    arrays are tables or timetables, COLUMNNAMES can be obtained from their
   %    VariableNames property. Specify COLUMNNAMES to override this.
   %
   %    ASSTRUCT - Logical flag to return the output container C as a struct
   %    (default: false). By default, C is returned as a cell array if the input
   %    type was 'cell' or a 3d numeric matrix, or a struct if the input type
   %    was 'struct'. Set ASSTRUCT=TRUE to return tables packaged into a struct
   %    regardless of the input type of C. In this case, the ArrayNames and
   %    COLUMNNAMES arguments become required.
   %
   %    ASTIMETABLES - Logical flag indicating if output tables should be
   %    returned as timetables (default: false). If ASTIMETABLES=TRUE, either
   %    the input arrays must be timetables so the RowTimes property can be
   %    obtained from them, or the ROWTIMES argument is required.
   %
   %    ROWTIMES - Datetime array to construct the output timetables. The length
   %    of ROWTIMES must match the first dimension of each input array. If the
   %    input arrays are timetables, ROWTIMES can be obtained directly from
   %    them. Specify ROWTIMES to override this.
   %
   %    BYCOLUMN - Logical flag to control how input arrays map to output arrays
   %    (default: false). If BYCOLUMN=TRUE, output arrays are constructed by
   %    concatenating respective columns of input arrays, such that output array
   %    1 is comprised of column 1 from each input array concatenated along the
   %    second dimension, and so on. In this case, ArrayNames and COLUMNAMES are
   %    swapped: ArrayNames become the VariableNames of returned tables, and
   %    COLUMNAMES become the fieldnames of C if C is returned as a struct,
   %    otherwise C is returned as a cell array and the input COLUMNAMES (which
   %    have become ArrayNames) have no meaning in this context.
   %
   % See also

   arguments(Input)
      C
      kwargs.ArrayNames (1, :) string = string.empty(1, 0)
      kwargs.ColumnNames (1, :) string = string.empty(1, 0)
      kwargs.bycolumn (1, 1) logical = false
      kwargs.asstruct (1, 1) logical = false
      kwargs.astimetables (1, 1) logical = false
      kwargs.RowTimes (:, 1) datetime = datetime.empty()
      % props.?matlab.tabular.TimetableProperties
   end

   [ArrayNames, ColumnNames, bycolumn, asstruct, astimetables, RowTimes] ...
      = dealout(kwargs);

   wasstruct = isstruct(C);

   if isnumericmatrix(C)
      C = squeeze(num2cell(C, [1 2]));
   end

   if iscell(C)

      maybewarn(asstruct, bycolumn, ColumnNames, ArrayNames, mfilename)

   else
      validateattributes(C, ...
         {'struct'}, {'scalar', 'nonempty'}, mfilename, 'V', 1)

      if isempty(ArrayNames)
         ArrayNames = string(fieldnames(C));
      end

      C = struct2cell(C);
   end

   onearray = C{1};

   if astimetables

      if isempty(RowTimes)
         assert(all(cellfun(@istimetable, C)))

         RowTimes = onearray.(C.Properties.DimensionNames{1});
      else
         assert(all(cellfun(@(a) height(a) == height(RowTimes), C)))
      end
   end

   if isempty(ColumnNames) && istabular(onearray)
      ColumnNames = onearray.Properties.VariableNames;
   end

   if bycolumn
      [ArrayNames, ColumnNames] = deal(ColumnNames, ArrayNames);
   end

   if bycolumn

      C = arrayfun(@(ia) ...
         createOneTable(ia, C, ColumnNames, astimetables, RowTimes), ...
         1:size(onearray, 2), 'UniformOutput', false);

   else % byarray - create one table from each array in V

      if astimetables
         C = cellfun(@(a) ...
            array2timetable(a, 'VariableNames', ColumnNames, ...
            'RowTimes', RowTimes), C, 'UniformOutput', false);
      else
         C = cellfun(@(a) ...
            array2table(a, 'VariableNames', ColumnNames), ...
            C, 'UniformOutput', false);
      end
   end

   % Note: currently there is no option to return input struct as cell.
   if wasstruct || asstruct
      if ~isempty(ArrayNames)
         C = cell2struct(C, ArrayNames, 2);
      end
   end
end

function tbl = createOneTable(ia, C, names, astimetable, time)

   % Create one table per column in input arrays (or tables) in V, by
   % rearranging the arrays such that each output array is comprised of
   % respective columns of the input arrays. For instance, if input array
   % dimensions are [time x group], with one array per variable, the output
   % arrays will have dimensions [time x variables], with one array per group.

   array = nan(numel(time), numel(names)); % time x vars
   for m = 1:numel(names)

      obj = C{m}(:, ia);

      if istabular(obj)
         array(:, m) = obj.Variables;

      elseif isnumericmatrix(obj)
         array(:, m) = obj;
      end
   end

   if astimetable
      tbl = array2timetable(array, "VariableNames", names, "RowTimes", time);
   else
      tbl = array2table(array, "VariableNames", names);
   end
end


function maybewarn(asstruct, bycolumn, ColumnNames, ArrayNames, mfilename)

   % Logic for cell array input:
   % If asstruct=true, require ArrayNames, but if bycolumn=true, require
   % ColumnNames b/c they become ArrayNames. In both cases, require
   % ColumnNames to construct the timetable varnames, but if bycolumn=true,
   % require ArrayNames because they become ColumnNames.
   if asstruct
      if bycolumn
         eid = ['custom:' mfilename ':ColumnNamesRequired'];
         msg = 'ColumnNames must be provided if V is a cell or numeric array.';
         assert(~isempty(ColumnNames), eid, msg);
      else
         eid = ['custom:' mfilename ':ArrayNamesRequired'];
         msg = 'ArrayNames must be provided if V is a cell or numeric array.';
         assert(~isempty(ArrayNames), eid, msg);
      end
   else
      if bycolumn
         eid = ['custom:' mfilename ':ArrayNamesRequired'];
         msg = 'ArrayNames must be provided if V is a cell or numeric array.';
         assert(~isempty(ArrayNames), eid, msg);
      else
         eid = ['custom:' mfilename ':ColumnNamesRequired'];
         msg = 'ColumnNames must be provided if V is a cell or numeric array.';
         assert(~isempty(ColumnNames), eid, msg);
      end
   end
end

% Note on property inheritence:

% % Valid name-value pairs for array2timetable:
% VariableNames
% DimensionNames
% RowTimes
% SampleRate
% TimeStep
% StartTime
%
% % If inheriting props, would need to ignore:
% CustomProperties
% Description
% UserData
% VariableContinuity
% VariableUnits


% eid = ['custom:' mfilename ':arrayNamesRequired'];
% msg = 'Array names must be provided when V is a cell array.';
% assert(~isempty(ArrayNames), eid, msg);

% eid = ['custom:' mfilename ':timeArgumentRequired'];
% msg = 'The ArrayNames must correspond to fieldnames in V if time is not provided';
% assert(isfield(V, ArrayNames(1)), eid, msg);
%
% eid = ['custom:' mfilename ':timeArgumentRequired'];
% assert(istimetable(V.(ArrayNames(1))), 'The first field of V must be a timetable when astimetables is true');
% time = V.(ArrayNames(1)).Time;
