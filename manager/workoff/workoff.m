function workoff(projectname,varargin)
%WORKOFF removes project 'projectname' from path and (optionally) goes to
%the home directory (go home)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   
   % NOTE: I defined tbname as addOptional, so it is flagged by matlab, but
   % this way it is still shown in the function hint. This is a backdoor
   % way to achieve what I haven't been able to figure out, which is
   % showing optional inputs in the function hint without requiring
   % name-value syntax.
   
   p                 = inputParser;
   
   p.FunctionName    = 'workoff';
 % p.UsingDefaults % this may be needed to solve the function hint issue
   
   addRequired(p,'projectname',@(x)ischar(x));
   addOptional(p,'gohome','no',@(x)ischar(x));
   parse(p,projectname,varargin{:});
  
   projectname = p.Results.projectname;
   gohome      = p.Results.gohome;
% input parsing may be overkill here ... I just want to deactivate

%    if nargin == 0
%       projectname = defaultprjdir;
%    end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   dbpath      = getprjdirectorypath;
   projects    = readprjdirectory(dbpath);
   prjidx      = findprjentry(projects,projectname);
   
   prjpath     = projects.folder{prjidx};
   
   % could put next three into a function rmtbpath(tbpath);
   disp(['deactivating ' projectname]);
   warning off; rmpath(genpath(prjpath)); warning on;
   
   if gohome == "gohome"
      cd(getenv('MATLABUSERPATH'));
   end
   % warning off/on suppresses warnings issued when a new folder was
   % created in the active toolbox directory and isn't on the path
   
end

function prjdir = defaultprjdir
   
   % if no path was provided, this assumes the local directory is it
   [~,prjdir] = fileparts(pwd);
   
end