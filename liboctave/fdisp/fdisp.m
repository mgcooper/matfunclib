function fdisp(fid, x, varargin)
   %FDISP write disp-style formatted numbers and text to open fid
   %
   % fdisp(fileId, data);
   % fdisp(fileId, data, overrideSizeLimit);
   % fdisp(fileId, data, newSizeLimit);
   %
   % This function works similarly to fdisp in Octave. It writes numeric arrays,
   % logical arrays, strings/characters to a file. If the input is a cell array,
   % it writes each cell's contents on a new line. Mixed data types within a
   % cell array are not supported. By default, it sets a limit to the size of
   % arrays it will print. For example, if an array is larger than 1e6 elements,
   % which roughly equals 8 MB for double arrays, 4 MB for single arrays, and 1
   % MB for chars, the function will print a warning and not print the array in
   % full. You can override this by passing true as the third argument or
   % specify a different size limit by passing a numeric value as the third
   % argument.
   %
   %
   % INPUT:
   % fileId - File identifier returned by fopen.
   % data - The data to be printed. It could be numeric arrays, logical arrays,
   % strings/characters, or a cell array of these types.
   % overrideSizeLimit - Optional, logical. If true, ignores the size limit.
   % newSizeLimit - Optional, numeric. Specifies a different size limit.
   %
   % EXAMPLES:
   %
   %    Example 1
   %
   % fid = fopen('myfile.txt', 'w');  % Open file for writing
   % if fid ~= -1  % Check that file opened successfully
   %    fdisp(fid, [1 2 3]);  % Use fdisp to write numeric array
   %    fdisp(fid, 'Hello, World!');  % Use fdisp to write string
   %    % Use fdisp to write cell array of strings:
   %    fdisp(fid, {'Apple', 'Banana', 'Cherry'});  
   %    fclose(fid);  % Always close your files!
   % else
   %    error('Failed to open file');
   % end
   %
   % %    Example 2 - Use the sizelimit option
   %
   % fid = fopen('mybigfile.txt', 'w');  % open file for writing
   % if fid ~= -1  % check if the file was opened successfully
   %    % try to write a big numeric array. The default sie limit is 1e6
   %    fdisp(fid, rand(2e6,1));  
   %    fclose(fid);  % close the file
   % else
   %    error('Failed to open file');
   % end
   %
   % fid = fopen('mybigfile.txt', 'w');  % open file for writing
   % if fid ~= -1  % check if the file was opened successfully
   %    % write a big numeric array by overriding the size limit
   %    fdisp(fid, rand(2e6,1), true);
   %    fclose(fid);  % close the file
   % else
   %    error('Failed to open file');
   % end

   % Process the third argument for sizelimit and override_sizelimit
   if nargin == 3
      if isscalar(varargin{1})
         if isnumeric(varargin{1})
            sizelimit = varargin{1};
            ignore_sizelimit = false;
         elseif islogical(varargin{1})
            ignore_sizelimit = varargin{1};
            sizelimit = 1e6;  % Default value
         else
            error('fdisp:InvalidInput', ...
               'Third argument should be numeric or logical');
         end
      else
         error('fdisp:InvalidInput', 'Third argument should be scalar');
      end
   elseif nargin == 2
      sizelimit = 1e6;  % Default value
      ignore_sizelimit = false;
   else
      error('fdisp:InvalidInput', 'Invalid number of input arguments');
   end

   % Printing process
   if isnumeric(x) || islogical(x)
      if numel(x) <= sizelimit || ignore_sizelimit
         if size(x, 1) == 1
            fprintf(fid, '%g ', x);
            fprintf(fid, '\n');
         else
            % For each row, print each column value followed by a space,
            % and after each row, print a newline character
            for row = 1:size(x, 1)
               fprintf(fid, '%g ', x(row, :));
               fprintf(fid, '\n');
            end
         end
      else
         warning( ...
            ['Array size exceeds the limit and will not be printed in full.' ...
            ' Pass true as the third argument to override.']);
         fprintf(fid, '[%s %s]\n', mat2str(size(x)), class(x));
      end
   elseif ischar(x) || isstring(x)
      fprintf(fid, '%s\n', x);
   elseif iscell(x)
      if all(cellfun(@ischar, x) | cellfun(@isstring, x))
         fprintf(fid, '%s\n', x{:});
      elseif all(cellfun(@isnumeric, x) | cellfun(@islogical, x))
         for i = 1:numel(x)
            if numel(x{i}) <= sizelimit || ignore_sizelimit
               if isscalar(x{i})
                  fprintf(fid, '%g\n', x{i});
               else
                  for row = 1:size(x{i}, 1)
                     fprintf(fid, '%g ', x{i}(row, :));
                     fprintf(fid, '\n');
                  end
               end
            else
               warning( ...
                  ['Array size in cell element %d exceeds the limit and will ' ...
                  'not be printed in full. Pass true as the third argument ' ...
                  'to override.'], i);
               fprintf(fid, '[%s %s]\n', mat2str(size(x{i})), class(x{i}));
            end
         end
      else
         error('fdisp:InvalidInput', ...
            'Mixed data types within cell array not supported');
      end
   else
      error('fdisp:InvalidInput', 'Input type not supported');
   end
end
