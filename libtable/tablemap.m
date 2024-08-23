function tbls = tablemap(fn, tbls)
   %TABLEMAP Apply a function to each table in a collection of tables
   %
   %    TBLS = TABLEMAP(FN, TBLS) applies the function FN to each table in TBLS
   %    and returns the results. FN should be a function handle that takes a
   %    table as input and returns a table as output.
   %
   %   Inputs:
   %       FN   - Function handle to apply to each table. Should accept a table
   %              as input and return a table as output.
   %       TBLS - Can be one of the following:
   %              - A single table
   %              - A cell array of tables
   %              - A struct with table fields
   %
   %   Outputs:
   %       TBLS - Has the same structure as the input TBLS:
   %              - A single table if TBLS was a single table
   %              - A cell array of tables if TBLS was a cell array
   %              - A struct with table fields if TBLS was a struct
   %
   %   Example:
   %       % Define a function to apply to each table
   %       Fn_annualData = @(monthlyData) retime(monthlyData, 'yearly', @mean);
   %
   %       % Apply to a single table
   %       annualTable = tablemap(Fn_annualData, monthlyTable);
   %
   %       % Apply to a cell array of tables
   %       annualTables = tablemap(Fn_annualData, {table1, table2, table3});
   %
   %       % Apply to a struct of tables
   %       data.temp = tempTable;
   %       data.precip = precipTable;
   %       annualTables = tablemap(Fn_annualData, data);
   %
   % See also: CELLFUN, STRUCTFUN, RETIME

   % Prepare inputs.
   [tbls, wastabular, wasstruct, names] = parseinputs(tbls);

   % Process each table.
   tbls = cellmap(@(tbl) fn(tbl), tbls);

   % Prepare outputs.
   tbls = parseoutputs(tbls, wastabular, wasstruct, names);
end

%%
function [tbls, wastabular, wasstruct, names] = parseinputs(tbls)

   names = string.empty;
   wasstruct = isstruct(tbls);
   wastabular = istabular(tbls);

   if iscell(tbls)
      assert(all(cellfun(@istabular, tbls)))

   elseif wasstruct
      [tbls, names] = deal(struct2cell(tbls), string(fieldnames(tbls)));

   elseif wastabular
      tbls = {tbls};
   end
end

function tbls = parseoutputs(tbls, wastabular, wasstruct, names)

   if wasstruct
      tbls = cell2struct(tbls, names, 1);

   elseif wastabular
      tbls = tbls{1};
   end
end

% NOTE: Design functions to call this rather than borrow this construct from
% libtable_functemplate. See merra.waterBalanceTrends. Rather than embed
% parseinputs, cellmap, and parseoutputs in every function, simply write the
% "processOneTable" subfunction and pass it to this function, which performs
% the standard input and output parsing. Exceptions could be handled by
% function-specific input/output parsers, but this way any updates to the
% standard parseinputs/outputs will flow through to all other functions e.g.
% if arrays are supported. This will also encourage embedding as much
% flexibility as possible into the "processOneTable" subfunction, because the
% input parsing often involves assumptions that each element shares something
% in common like the "Time" dimension or variable names. Instead of parsing
% those out once, just do it on every iteration. This is not always the most
% efficient approach, but unless those steps are expensive, this will greatly
% simplify the way code is written.a
