function name = shippednamespace(root)
   %SHIPPEDNAMESPACE The +namespace folder under toolbox/, without the plus.
   %
   %    name = shippednamespace(root)
   %
   %  Discovers the shipped namespace at run time, which keeps the root
   %  build files identical across stamped projects, where the
   %  template's +tbx is renamed to the project's own name. ROOT is the
   %  project root folder (the folder holding buildfile.m).
   %
   % See also: buildfile, releasefile

   arguments
      root (1,1) string {mustBeFolder}
   end

   found = dir(fullfile(root, "toolbox", "+*"));
   found = found([found.isdir]);
   assert(~isempty(found), ...
      "No +namespace folder found under %s.", fullfile(root, "toolbox"))
   name = string(erase(found(1).name, "+"));
end
