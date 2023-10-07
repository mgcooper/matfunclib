function projfolder = getprojectfolder(varargin)
   %GETPROJECTFOLDER get the activefolder property of project
   %
   %     projfolder = getprojectfolder() returns the activefolder
   %     attribute for the activeproject in the projectlist directory
   %
   %     projfolder = getprojectfolder(projname) returns the activefolder
   %     attribute for project projname in the projectlist directory
   %
   %     projfolder = getprojectfolder(___,'namespace') returns the namespace
   %     folder for the prior syntax. The namespace folder is the
   %     projlist.folder attribute, i.e. the parent folder containing the root
   %     of the project, which can differ from the activefolder property. The
   %     default behavior returns projlist.activefolder
   %
   % See also setprojectfolder

   %  NOTE: it seems like getprojectfolder(projname) wouldn't work based on the
   %  optionParser section, but it does. This needs to change. It has to do do
   %  with whther or not the options are matched, the confusing this is that
   %  'projname' isn't in the optionParser list, but it works without it.
   %
   %  GREAT EXAMPLE OF WHY INPUTPARSER IS NEEDED! shows how optionParser only
   %  works if we have a fixed number of required args and the opts come after.
   %  For example, it fails if I have varargin and one argument (here projlist)
   %  is not a char. If I did  not allow projlist to come in then it would be
   %  much easier and in fact I should do that

   % NOTE: need to rewrite this, its incredibly dumb. Ran into an error where a
   % string was passed in for project name, so had to add this:
   for n = 1:numel(varargin)
      if isstring(varargin{n})
         varargin{n} = char(varargin{n});
      end
   end

   % set default option to return the activefolder then parse the input
   validopts = {'activefolder','namespace'};
   opts = optionParser(validopts,varargin);

   if nargin < 1
      opts.activefolder = true;
   end

   % check if inputs include 'activefolder' or 'namespace'.
   if sum(ismember(varargin, validopts)) > 1
      error('choose one: activefolder or namespace')
   else
      numargs = nargin - sum(ismember(varargin, validopts));
   end

   projlist = readprjdirectory();

   % this works if one optional argument is provided
   if numargs < 1
      projname = getactiveproject();
   else
      projname = varargin{1};
   end

   projindx = getprjidx(projname, projlist);

   % if the namespace folder is requested, append projname to projectlist.folder
   if opts.namespace == true
      projfolder = fullfile(projlist.folder{projindx}, projname);
   else
      if isoctave
         allfolders = {projlist.activefolder};
         projfolder = allfolders{projindx};
      else
         projfolder = projlist.activefolder{projindx};
      end
   end

   % this works if there are no optional arguments and the input is:
   % function projfolder = getprojectfolder(projname,projlist)
   % if nargin < 2
   %    projlist = readprjdirectory;
   %    if nargin < 1
   %       projname = getactiveproject();
   %    end
   % end
end
