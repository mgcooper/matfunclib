function mgd = cms2mgd(cms)
   %CMS2MGD convert cubic meters / second to million gallons / day
   %
   % inputs:
   %   cfs = array of flow values in cubic meters/second
   %
   % outputs:
   %   cms = array of flow values in cubic meters/second

   mgd = cms.*86400./3785.41178;
end