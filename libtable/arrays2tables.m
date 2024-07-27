function C = arrays2tables(C, kwargs)
   %ARRAYS2TABLES Convert array of 2d arrays into array of tables or timetables.
   %
   %    tbls = arrays2tables(arrays)
   %    tbls = arrays2tables(arrays, ArrayNames=ArrayNames)
   %    tbls = arrays2tables(arrays, ColumnNames=ColumnNames)
   %    tbls = arrays2tables(arrays, asstruct=true)
   %    tbls = arrays2tables(arrays, astimetables=true, RowTimes=time)
   %    tbls = arrays2tables(arrays, bycolumn=true)
   %
   % Description
   %
   %    This function converts numeric 2d matrices ("arrays") stored in a struct
   %    array, cell array, or 3d matrix into tables or timetables. Output tables
   %    are constructed either directly from input arrays, or by concatenating
   %    columns taken individually from each input array to create new arrays.
   %    Specify the optional argument BYCOLUMN=TRUE to create one table for each
   %    respective column of regularly sized input arrays. The input arrays can
   %    themselves be tables or timetables; use arrays2tables to convert between
   %    them or construct new tables using columnwise concatenation.
   %
   % Inputs (Required)
   %
   %    C - Container of input arrays. Can be a cell array containing one array
   %    per element, a struct containing one array per field, or a 3d numeric
   %    array where each page along the 3rd dimension is taken as one 2d array.
   %    Each array is either a 2d numeric matrix, table, or a timetable. Each
   %    input array is converted to either a table or a timetable and returned
   %    as elements or fields of output C.
   %
   % Inputs (Optional name-value pairs)
   %
   %    ARRAYNAMES - Names for each input array. If C is a struct, default
   %    ARRAYNAMES are obtained from the fieldnames of C. Specify ARRAYNAMES to
   %    override this. If C is not a struct but is returned as one by specifying
   %    ASSTRUCT=TRUE, the ARRAYNAMES argument becomes required to construct the
   %    fieldnames of output C.
   %
   %    COLUMNNAMES - Names for the variables (columns) of input arrays. If the
   %    arrays are tables or timetables, default COLUMNNAMES are obtained from
   %    their VariableNames property. Specify COLUMNNAMES to override this. If
   %    the input arrays are numeric matrices, COLUMNNAMES becomes required to
   %    set the VariableNames property of output tables. See the documentation
   %    for BYCOLUMN to understand the behavior of COLUMNNAMES and ARRAYNAMES
   %    when BYCOLUMN=TRUE.
   %
   %    ASSTRUCT - Logical flag to return C as a struct. The default value
   %    depends on its input type; C is returned as a cell array if its input
   %    type was either 'cell' or a 3d numeric matrix, or as a struct if its
   %    input type was 'struct'. Set ASSTRUCT=TRUE to return C as a struct
   %    regardless of its input type. If ASSTRUCT=TRUE, the ARRAYNAMES argument
   %    becomes required if C was not input as a struct.
   %
   %    ASTIMETABLES - Logical flag to return output arrays as timetables (TRUE)
   %    or as tables (FALSE). The default value is FALSE. If ASTIMETABLES=TRUE,
   %    the input arrays must either be timetables, from which default values
   %    for ROWTIMES can be obtained from their RowTimes property, or the
   %    ROWTIMES argument is required.
   %
   %    ROWTIMES - Datetime array to construct output timetables. The length of
   %    ROWTIMES must match the first dimension of each input array. If the
   %    input arrays are timetables, ROWTIMES can be obtained directly from
   %    them. Specify ROWTIMES to override this.
   %
   %    BYCOLUMN - Logical flag to control how input arrays map to output
   %    arrays. Note that "output arrays" are tables (or timetables) stored as
   %    individual elements of C. If BYCOLUMN=TRUE, output arrays are
   %    constructed by concatenating respective columns of input arrays, such
   %    that output array 1 is comprised of column 1 from each input array
   %    concatenated along the second dimension. This procedure is repeated to
   %    produce N output arrays, each with M columns, from M input arrays, each
   %    with N columns.
   %
   %    If BYCOLUMN=TRUE, ARRAYNAMES and COLUMNAMES are swapped: ARRAYNAMES
   %    become the VariableNames of returned tables, and COLUMNAMES become the
   %    fieldnames of C if C is returned as a struct, otherwise C is returned as
   %    a cell array and the input COLUMNAMES (which have become ARRAYNAMES)
   %    have no meaning in this context.
   %
   % See also: array2table

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

   [ArrayNames, ColNames, bycolumn, asstruct, astimetables, Time] ...
      = dealout(kwargs);

   wasstruct = isstruct(C);

   if isnumericmatrix(C)
      C = squeeze(num2cell(C, [1 2]));
   end

   if iscell(C)

      maybewarn(asstruct, bycolumn, ColNames, ArrayNames, mfilename)

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

      if isempty(Time)
         assert(all(cellfun(@istimetable, C)))

         Time = onearray.(C.Properties.DimensionNames{1});
      else
         assert(all(cellfun(@(a) height(a) == height(Time), C)))
      end
   end

   if isempty(ColNames) && istabular(onearray)
      ColNames = onearray.Properties.VariableNames;
   end

   if bycolumn
      [ArrayNames, ColNames] = deal(ColNames, ArrayNames);
   end

   if bycolumn

      C = arrayfun(@(ia) ...
         createOneTable(ia, C, ColNames, astimetables, Time), ...
         1:size(onearray, 2), 'UniformOutput', false);

   else % byarray - create one table from each array in V

      if astimetables
         C = cellfun(@(a) ...
            array2timetable(a, 'VariableNames', ColNames, 'RowTimes', Time), ...
            C, 'UniformOutput', false);
      else
         C = cellfun(@(a) ...
            array2table(a, 'VariableNames', ColNames), ...
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
