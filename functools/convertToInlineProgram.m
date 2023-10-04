function newFunctionLines = convertToInlineProgram(folderPath, mainFileName, ...
      copyToClipboard, acceptRisk)
   %CONVERTTOINLINEPROGRAM Convert function calls in file to inline code.
   %
   %
   %
   % See also

   if nargin < 4 || acceptRisk == false
      warning(['CONVERTTOINLINEPROGRAM is experimental, ' ...
         'set input argument 4 true to proceed'])
      return
   end

   if nargin < 3
      copyToClipboard = false;
   end

   % Read the main function file
   mainFilePath = fullfile(folderPath, mainFileName);
   mainFile = fopen(mainFilePath, 'r');
   mainFileLines = string(fread(mainFile, '*char')');
   fclose(mainFile);

   % Find all .m files in the folder and its subfolders
   mFiles = dir(fullfile(folderPath, '**/*.m'));

   % Replace function calls with their code
   newFunctionLines = mainFileLines;
   for i = 1:numel(mFiles)
      if strcmp(mFiles(i).name, mainFileName)
         continue;
      end

      % Read the function file
      functionFilePath = fullfile(mFiles(i).folder, mFiles(i).name);
      functionFile = fopen(functionFilePath, 'r');
      functionFileLines = string(fread(functionFile, '*char')');
      fclose(functionFile);

      % Extract function name and parameters
      functionSignature = extractBetween(functionFileLines, 'function', '(');
      functionName = strtrim(extractAfter(functionSignature, '= '));

      % Replace the function call with the function code
      functionCallPattern = strcat(functionName, '\s*\(');
      [startIndex, endIndex] = regexp(newFunctionLines, functionCallPattern);
      for j = 1:numel(startIndex)
         newFunctionLines = [newFunctionLines(1:startIndex(j)-1), ...
            functionFileLines, newFunctionLines(endIndex(j)+1:end)];
      end
   end

   % Save the new inline function
   inlineFileName = strrep(mainFileName, '.m', '_inline.m');
   inlineFilePath = fullfile(folderPath, inlineFileName);
   inlineFile = fopen(inlineFilePath, 'w');
   fwrite(inlineFile, newFunctionLines);
   fclose(inlineFile);

   % Copy the new function to the clipboard if desired
   if copyToClipboard
      clipboard('copy', newFunctionLines);
   end
end
