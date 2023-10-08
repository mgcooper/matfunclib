function cms = mgd2cms(mgd)
   %MGD2CMS convert million gallons / day to cubic meters / second
   %
   % syntax:
   %  cms = mgd2cms(mgd)
   %
   % inputs:
   %   mgd = array of values in million gallons / day
   %
   % outputs:
   %   cms = array of values in cubic meters/second

   cms = mgd./86400.*3785.41178;
end
