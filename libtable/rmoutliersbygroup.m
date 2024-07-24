function tbl = rmoutliersbygroup(tbl,groupvars,datavars,method)
   %rmoutliersbygroup set all values of table group members nan
   %
   %    tbl = rmoutliersbygroup(tbl, groupvars, datavars)
   %    tbl = rmoutliersbygroup(tbl, groupvars, datavars, method)
   %
   % Description
   %    tbl = rmoutliersbygroup(tbl, groupvars, datavars) finds occurrences of
   %    outliers in DATAVARS, checks the value of each of GROUPVARS at that
   %    occurence, and sets all other indices with the same groupvars nan.
   %
   % Note: unlike rmnanbygroup, rmoutliersbygroups does not remove all values
   % that match groupvars, instead it only removes outliers within groups.
   % Better function names might rmnanacrossgroups and rmoutlierswithingroups.
   %
   % See also: rmnanbygroup

   if ~iscell(datavars)
      if ischar(datavars)
         datavars = cellstr(datavars);
      else
         % tbl = []; return; % need to exit?
      end
   end

   if ~iscell(groupvars)
      if ischar(groupvars)
         datavars = cellstr(datavars);
      else
      end
   end

   fun = @(x) isoutlier(x, method);
   tbl = sortrows(tbl, groupvars);

   Tnan = varfun( fun, tbl, 'InputVariables', datavars, ...
      'GroupingVariables', groupvars );

   Tnan = sortrows(Tnan, groupvars);

   % if there are multiple datavars, need to get all unique nan inds
   i2 = [];
   for i = 1:length(datavars)
      i2 = [i2; find(Tnan.(['Fun_' datavars{i} ]))];
   end
   i2 = unique(i2);
   tbl(i2, :) = [];


   % additioanl notes:
   % compare the first 10 rows of Tnan and T to make sure they are sorted
   %     test1 = T(1:10,{'method','deriv','event','year','station'});
   %     test2 = Tnan(1:10,{'method','deriv','station'});
   % note - because Tnan only has 'groupvars', I can only use the overlapping
   % vars, but I checked outside this function by using the full set of
   % groupvars and this confirms the sorting is identical:
   % test1 = T(:,{'method','deriv','event','year','station'});
   % test2 = Tnan(:,{'method','deriv','event','year','station'});
   % isequal(test1,test2)

   % for reference:
   % TG = T(:,{'method','deriv'});
   % [G,~] = findgroups(TG);
   % b_outliers = splitapply(@(x){isoutlier(x)},T.b,G);
end

