function [keys,vals] = getuserpaths()
   %GETUSERPATHS Get all paths in user-defined environment variables.
   %
   %  [keys,vals] = getuserpaths()
   %
   % See also: getuserenvs

   [keys,vals] = getenvall('system');     % get all env vars
   keep = contains(keys,'PATH');          % keep ones with PATH
   keys = keys(keep);
   vals = vals(keep);
end
