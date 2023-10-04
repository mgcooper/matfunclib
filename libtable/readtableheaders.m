function headers = readtableheaders(filepath, ImportOpts, CustomOpts)
   %READTABLEHEADERS Read header line of spreadsheet files.
   %
   %  T = READTABLEHEADERS(FILEPATH, SHEETNAMES) reads headers from sheets
   %  matching SHEETNAMES in file located in spreadsheet file FILEPATH.
   %  T = READTABLEHEADERS(T,'flag1') description
   %  T = READTABLEHEADERS(T,'flag2') description
   %  T = READTABLEHEADERS(___,'options.name1',options.value1,'options.name2',options.value2) description
   %        The default flag is 'plot'.
   %
   % Example
   %
   %
   % Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
   %
   % See also:

   arguments
      filepath {mustBeFile}
      ImportOpts.?matlab.io.spreadsheet.SpreadsheetImportOptions
      CustomOpts.SheetNames string = string.empty()

      % These also work. If they are used, then I think I need to convert them
      % to name=value or name,value syntax and pass to detectImportOptions for
      % the case where
      % ImportOpts.?matlab.io.ImportOptions
      % ImportOpts.?matlab.io.VariableImportOptions
   end
   
   checkOpts = detectImportOptions(filepath);
   
   % Keep track of whether detectImportOptions thinks the file is a spreadsheet
   isspreadsheet = isa(checkOpts, ...
      'matlab.io.spreadsheet.SpreadsheetImportOptions');

   % % Convert checkOpts from an importOptions object to a struct, because
   % % the arguments block populates ImportOpts into a struct.
   % % NOTE: THis is not functional b/c it sends an empty struct to
   % % metaclassDefaults, so use the struct conversion instead.
   % switch class(checkOpts)
   %    case 'matlab.io.spreadsheet.SpreadsheetImportOptions'
   %       checkOpts = metaclassDefaults(struct(), ...
   %          ?matlab.io.spreadsheet.SpreadsheetImportOptions);
   %    case 'matlab.io.text.DelimitedTextImportOptions'
   %       checkOpts = metaclassDefaults(struct(), ...
   %          ?matlab.io.text.DelimitedTextImportOptions);
   % end
   
   job = withwarnoff('MATLAB:structOnObject');
   checkOpts = struct(checkOpts);
   
   % If no import options were provided, detect them and return the headers
   if isempty(fieldnames(ImportOpts))
      ImportOpts = checkOpts;
   else
      % Confirm the file is a spreadsheet. I commented this out b/c I am not
      % sure whether the different options are incompatible e.g., .csv files
      % might be spreadhseets or they might be DelimitedTextImportOptions.
      % checkOpts = detectImportOptions(filepath);

      % Check if the detected options match the default Spreadsheet options
      if isspreadsheet  
         % Should be good to go, populate ImportOpts with defaults
         ImportOpts = metaclassDefaults(ImportOpts, ...
            ?matlab.io.spreadsheet.SpreadsheetImportOptions);
      else
         % Not sure. For now, just try what was passed in and debug this later
         % Or, set to checkOpts.
         ImportOpts = checkOpts;
      end
   end

   % If Sheet was provided, pass it over to SheetNames so one syntax is used
   if isspreadsheet && ...
         ~isempty(ImportOpts.Sheet) && isempty(CustomOpts.SheetNames)

      CustomOpts.SheetNames = ImportOpts.Sheet;
      ImportOpts.Sheet = char.empty();
   end

   headers = string.empty();

   % If sheet(s) were not requested, return the variable names
   if isempty(CustomOpts.SheetNames)
      try
         headers = string(ImportOpts.VariableNames);
      catch e
         rethrow(e)
      end
   elseif isspreadsheet
      for sheet = CustomOpts.SheetNames(:)'
         try
            sheetOpts = detectImportOptions(filepath, 'Sheet', sheet);
            headers = unique(union(headers, string(sheetOpts.VariableNames)));
            
            % Changed to unique(union(...)) so on n==1, the union is the first
            % sheet variable names, with intersect it is string.empty
            % headers = intersect(headers, string(sheetOpts.VariableNames));

         catch e
            if strcmp(e.identifier, 'MATLAB:textio:detectImportOptions:ParamWrongFileType')
               % This might mean a .csv file was provided
               if endsWith(filepath, ".csv")
                  % Use checkOpts, since .csv cannot have multiple sheets
                  headers = string(checkOpts.VariableNames);
               end
            else
               rethrow(e)
            end
         end
      end
   else
      % not a spreadsheet, but if ImportOpts.Sheet was provided, and
      % CustomOpts.SheetNames was not, Sheet may have been trasnferred so try
      try
      catch
      end
   end


   % % This is the original behavior. I think this depends on using either
   % ImportOpts.?matlab.io.ImportOptions OR
   % ImportOpts.?matlab.io.VariableImportOptions in the argumnets block, then
   % getting them into name-value format to pass to detectImportOptions. That way
   % this function works for spreadsheets or textfiles.

   %    args = optionsToNamedArguments(ImportOpts)

   %    if isempty(ImportOpts.Sheet) && isempty(CustomOpts.SheetNames)
   %       %ImportOpts = detectImportOptions(filepath, args);
   %       ImportOpts = detectImportOptions(filepath);
   %       headers = string(ImportOpts.VariableNames);
   %    else
   %       for sheet = CustomOpts.SheetNames(:)'
   %          ImportOpts = detectImportOptions(filepath, 'Sheet', sheet);
   %          if n == 1
   %             headers = string(ImportOpts.VariableNames);
   %          else
   %             headers = intersect(headers, string(ImportOpts.VariableNames));
   %          end
   %       end
   %    end

end

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.