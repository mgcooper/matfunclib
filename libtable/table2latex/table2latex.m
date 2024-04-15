function table2latex(T, filename, precision, headers, alignment, caption)
   %TABLE2LATEX Export a MATLAB table to a LaTeX formatted table
   %
   %   TABLE2LATEX(T, filename, precision) writes table T to a LaTeX file
   %   with the given filename and specified decimal precision.
   %
   %   INPUTS:
   %   T          -  MATLAB table to be written to LaTeX. Should only contain
   %                 numeric, boolean, char, or string data types. Avoid
   %                 including structs or cells.
   %   filename   -  Optional. Name of the LaTeX output file (with or without
   %                 '.tex'). Default is ./table.tex.
   %   precision  -  Optional. Scalar or array that specifies the number of
   %                 decimal places for each column. If scalar, applies to all
   %                 numeric columns.
   %   headers    -  Optional. Cell array of column labels.
   %   alignment  -  Optional. Char: 'l', 'c', or 'r' for column alignment. Can
   %                 be a char array with one char per column e.g.: 'lccc'.
   %   caption    -  Optional. Char caption text.
   %
   %   EXAMPLE 1:
   %   T = table([1.111; 2.222], {'apple'; 'banana'}, 'VariableNames', {'Number', 'Fruit'});
   %   table2latex(T, 'table2latex_example1', [2 0])
   %
   %   EXAMPLE 2:
   %   LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
   %   Age = [38;43;38;40;49];
   %   Smoker = logical([1;0;1;0;1]);
   %   Height = [71.2;69;64;67;64];
   %   Weight = [176;163;131;133;119];
   %   T = table(Age,Smoker,Height,Weight);
   %   T.Properties.RowNames = LastName;
   %   table2latex(T, 'table2latex_example2', 2)
   %
   %  NOTES:
   %   - The function assumes that the table does not contain struct data types.
   %   - Special LaTeX characters are not escaped.
   %   - In case of infinite values, they are replaced with $\infty$ or $-\infty$.
   %
   %   Based on table2latex by Victor Martinez Cagigal.
   %
   %   Rewritten by Matt Cooper.
   %
   % See also:
   
   % Check arguments and set defaults
   [T, filename, precision, headers, alignment, rownames, units, caption] = ...
      parseinputs(T, filename, precision, headers, alignment, caption);

   % Open file and write LaTeX table header
   fileID = createLatexTable(filename, alignment, headers, units, caption);

   % Write the data
   [nrows, ncols] = size(T);
   try
      for row = 1:nrows
         rowData = strings(1, ncols); % cell(1, ncol);
         for col = 1:ncols
            rowData(1, col) = processOneElement(T{row, col}, precision(col));
         end
         if ~isempty(rownames)
            rowData = [rownames{row}, rowData];
         end
         fprintf(fileID, '%s \\\\ \n', strjoin(rowData, ' & '));
      end
   catch ME
      fclose(fileID);
      rethrow(ME)
   end
   % Close the LaTeX table
   closeLatexTable(fileID, caption)
end

%% Create the latex file
function fileID = createLatexTable(filename, colspec, colnames, units, caption)
   fileID = fopen(filename, 'w');
   fprintf(fileID, '\\begin{table}[ht]\n');
   fprintf(fileID, '\\centering\n');
   
   % % This one requires begin tabular here, followed by hline
   % fprintf(fileID, '\\begin{tabular}{%s}\n', colspec);
   %  if ~isempty(caption)
   %      fprintf(fileID, '\\multicolumn{%d}{l}{%s} \\\\ \n', ...
   %         numel(colspec)-count(colspec,'|'), caption);
   %  end
   %  fprintf(fileID, '\\hline \n');
    
   if ~isempty(caption)
      printCaption(fileID, caption, numel(colspec));
   end
   fprintf(fileID, '\\begin{tabular}{%s}\n', colspec);
   
   fprintf(fileID, '%s \\\\ \n', colnames);
   fprintf(fileID, '%s \\\\ \n', units);
   fprintf(fileID, '\\hline \n');
end

function printCaption(fileID, caption, numcol)
   
   % This doesn't seem to work
   % fprintf(fileID, '\\multicolumn{%d}{l}{\\caption{%s}} \n', numcol, caption);
   
   % This will not be left justified
   % fprintf(fileID, '\\caption{%s}\n', caption);
   
   % This requires adding \usepackage{caption} to front matter
   fprintf(fileID, '\\captionsetup{justification=raggedright,singlelinecheck=false}\n');
   fprintf(fileID, '\\caption{%s}\n', caption);
end

%% Prepare one table element
function value = processOneElement(value, precision)
   if isstruct(value)
      error('Table must not contain structs.');
   end
   while iscell(value)
      value = value{1, 1};
   end
   if iscategorical(value)
      if isordinal(value)
         value = try_(@() cat2double(value));
      else
         value = try_(@() char(value));
      end
   end
   if isstring(value)
      value = char(value);
   end
   if isinf(value)
      if sign(value) == 1
         value = '$\infty$';
      else
         value = '$-\infty$';
      end
   end
   if isnumeric(value) && ~isnan(precision)
      value = num2str(value, sprintf('%%.%df', precision));
   else
      value = num2str(value);
   end
end
%% Close the file
function closeLatexTable(fileID, caption)
   fprintf(fileID, '\\hline \n');
   fprintf(fileID, '\\end{tabular}\n');
%    if ~isempty(caption)
%       fprintf(fileID, '\\caption{%s} \n', caption);
%    end
   fprintf(fileID, '\\end{table}\n');
   fclose(fileID);
end

%% Parse inputs
function [T, filename, precision, columnlabels, columnspecs, rowlabels, ...
      units, caption] = parseinputs(T, filename, precision, columnlabels, ...
      columnspecs, caption)
   
   if ~istable(T)
      error('Input must be a table.');
   end
   [~, ncols] = size(T);

   % Parse the filename
   if nargin < 2 || isempty(filename)
      filename = 'table.tex';
      fprintf('Output path is not defined. Writing table to: %s.\n', filename);
   else
      filename = convertStringsToChars(filename);
      if ~ischar(filename)
         error('The output file name must be a char or string.');
      elseif ~strcmp(filename(end-3:end), '.tex')
         filename = [filename '.tex'];
      end
   end

   % Parse the precision
   if nargin < 3 || isempty(precision)
      precision = nan(1, ncols);
   else
      % If a scalar decimal places was provided, convert to an array
      if isscalar(precision)
         precision = repmat(precision, 1, ncols);
      elseif length(precision) ~= ncols
         % Check if precision matches the number of numeric columns
         if length(precision) == numel(T{1, vartype("numeric")})
            % Pad to ncols. Note that precision only applies to numeric columns
            tmp = zeros(1, ncols);
            tmp(tablevartypeindices(T, "numeric")) = precision; %#ok<FNDSB>
            precision = tmp;
         else
            error('PRECISION must be scalar or contain one value per table column.');
         end
      end
   end

   % Parse the headers
   if nargin < 4 || isempty(columnlabels)
      columnlabels = T.Properties.VariableNames;
   end
   if length(columnlabels) ~= width(T)
      error('The number of custom headers must match the number of table columns.');
   end
   columnlabels = cellfun(@(x) strrep(x, '&', '\&'), columnlabels, 'Uniform', false);

   % Set the column specs (alignment)
   if nargin < 5 || isempty(columnspecs)
      columnspecs = repmat('l', 1, ncols);
   else
      % If a scalar column spec was provided, convert to an array
      if isscalar(columnspecs)
         columnspecs = repmat(columnspecs, 1, ncols);
      elseif length(columnspecs) ~= ncols
         error('COLSPEC must be a scalar char or row char with one value per table column.');
      end
   end
   
   if nargin < 6 || isempty(caption)
      caption = [];
   end
   
   % Prepare column and row specs
   columnlabels = strjoin(columnlabels, ' & ');
   rowlabels = T.Properties.RowNames;
   units = strjoin(T.Properties.VariableUnits, ' & ');

   % Update specs if row names are present
   if ~isempty(rowlabels)
      columnspecs = ['l' columnspecs]; % assume row names should be left justified
      columnlabels = ['& ' columnlabels];
      units = ['& ' units];
   end
end
