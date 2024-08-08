function appendToStartup(kwargs)

   arguments
      kwargs.templateFile = []
      kwargs.dryrun (1, 1) logical = true
   end
   dryrun = kwargs.dryrun;
   templateFile = kwargs.templateFile;

   % Default formatted string if no template file is provided
   defaultString = [
      newline ...
      '% >>>> BEGIN CONTENT MANAGED BY MATLAB TOOLBOX MANAGER' newline ...
      '% Add your addpath or other initialization commands here' newline ...
      '% addpath(genpath(''path/to/your/toolbox''));' newline ...
      '% >>>> END CONTENT MANAGED BY MATLAB TOOLBOX MANAGER' newline
      ];

   % Find user's startup.m file
   fprintf(1, 'Searching for startup.m file...\n');
   startupFile = which('startup.m');

   if isempty(startupFile)
      startupFile = fullfile(userpath, 'startup.m');
      fprintf(1, 'No existing startup.m found. Will create one at: %s\n', startupFile);
   else
      fprintf(1, 'Existing startup.m found at: %s\n', startupFile);
   end

   % Ask for user permission
   if dryrun
      dryrunFile = strrep(startupFile, '.m', '_dryrun.m');
      fprintf(1, 'The modified file will be written to: %s\n', dryrunFile)
      reply = input('Do you want to test run this startup.m file? (y/n): ', 's');
   else
      reply = input('Do you want to modify this startup.m file? (y/n): ', 's');
   end
   if ~strcmpi(reply, 'y')
      fprintf(1, 'Operation cancelled by user.\n');
      return;
   end

   % Read existing content or create empty string if file doesn't exist
   if exist(startupFile, 'file')
      try
         content = fileread(startupFile);
      catch
         error('Unable to read the existing startup.m file.');
      end
   else
      content = '';
   end

   % Determine string to append
   if ~isempty(templateFile) && exist(templateFile, 'file')
      try
         appendString = fileread(templateFile);
      catch
         warning('Unable to read the template file. Using default string.');
         appendString = defaultString;
      end
   else
      appendString = defaultString;
   end

   % Append the string
   newContent = [content, appendString];

   % Write the modified content back to the file
   try
      if dryrun
         fid = fopen(dryrunFile, 'w');
      else
         fid = fopen(startupFile, 'w');
      end

      if fid == -1
         error('Unable to open startup.m for writing.');
      end
      fprintf(fid, '%s', newContent);
      fclose(fid);
      fprintf(1, 'Successfully modified startup.m\n');
   catch
      error('Failed to write to startup.m');
   end
end
