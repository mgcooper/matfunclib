function cms = cmd2cms(cmd)
   %CMD2CMS Convert cubic meters / day to cubic meters / second
   %
   %  cms = cmd2cms(cmd) divides the flow values in cmd by 86400 to
   %  convert cubic meters per day to cubic meters per second.
   %
   % inputs:
   %   cmd = array of flow values in cubic meters/day
   %
   % outputs:
   %   cms = array of flow values in cubic meters/second
   %
   % See also: cms2cmd

   cms = cmd./86400;
end
