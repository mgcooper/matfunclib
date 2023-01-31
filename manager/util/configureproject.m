function configureproject(projpath,varargin)
%CONFIGUREPROJECT run config, setup, install, and startup scripts in projpath
%
%  configureproject(projpath) searches projpath (top level only) for Setup.m,
%  Install.m, Startup.m, and Config.m files and executes them. Setup.m and
%  Install.m are synonymous and are assumed to be installation
%  scripts/functions. Config.m and Startup.m are synonymous and are assumed to
%  be configuration scripts/functions run each time a project is activated. To
%  search for a specific installation and/or configuration file, specify a
%  second argument as a character vector or cell string array containing the
%  file name. 
% 
%  configureproject(projpath,configscript) searches projpath (top level only)
%  for a file named configscript and executes it. 
% 
% Example
% 
%  configureproject(projpath,'Config.m')
% 
% See also

% NOTE: for Setup/Install, we don't want to try re-installing stuff if we don't
% have to, but if there isn't much overhead, we can just let it check if
% requirements exist 

if nargin == 1
   tryscripts = {'Config','Setup','Install','Startup'};
else
   tryscripts = cellstr(varargin{1});
end
tryscripts = [tryscripts lower(tryscripts)]; % removed UPPER for now
% tryscripts = [tryscripts lower(tryscripts) upper(tryscripts)];

ok = false;
for n = 1:numel(tryscripts)

   fullfilename = fullfile(projpath,tryscripts{n});

   if numel(fullfilename) > 63
      filename = tryscripts{n};
   else
      filename = fullfilename;
   end

   if isfile([fullfilename '.m'])
      try
         % this should work if filename is a function that accepts at least
         % one argument (most likely it will be varargin) and the fullfile
         % pathname is not more than 63 chars 
         feval(filename,[]);
      catch ME

         % this is a case-insensitive match e.g. 'Config.m' exists and this try
         % is 'config.m' (note: if feval doesn't care about case, then we don't
         % need to loop over both cases)
         if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
            continue
         end

         % this occurs when the setup function accepts no inputs
         if strcmp(ME.identifier,'MATLAB:TooManyInputs')
            try
               feval(filename);
            catch ME
               
            end
         end

         % if feval fails, try run (the case where the setup file is a script)
         if strcmp(ME.identifier,'MATLAB:feval:invalidFunctionName')
            try
               run(filename);
            catch ME
               % rethrow(ME) % no need to throw an error, just send a message
            end
         end
      end
      ok = true; % log it if we are successful
   end
end

if ok == false 
   msg = 'no config/startup/setup/install script or function found';
end