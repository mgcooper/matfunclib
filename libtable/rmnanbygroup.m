function tbl = rmnanbygroup(tbl,groupvars,datavars)
   %rmnanbygroup set all values of table group members nan
   %
   %    tbl = rmnanbygroup(tbl,groupvars,datavars)
   %
   % Description
   %    tbl = rmnanbygroup(tbl,groupvars,datavars) finds occurrences of datavars
   %    that are nan, checks the value of each of groupvars at that occurence,
   %    and sets all other indices with the same groupvars nan. This is
   %    desirable if you have a table of experimental results, and if a trial of
   %    one group is nan, it is important to set the corresponding trial of all
   %    other groups nan.
   %
   % See also: rmoutliersbygroup

   % notes specific to event analysis:
   % for nan removal, we want any event in one series that yields nan for
   % any method to be set nan across all other methods for that event at
   % that station. by grouping by station/year/event, rmnanbygroup finds
   % all nan param values, and then finds all other indices with the same
   % station/year/event, and sets them nan

   if ~iscell(datavars)
      if ischar(datavars)
         datavars = cellstr(datavars);
      else
         % need to exit?
      end
   end

   if ~iscell(groupvars)
      if ischar(groupvars)
         datavars = cellstr(datavars);
      else
      end
   end


   tbl = sortrows(tbl, groupvars);

   Tnan = varfun(@isnan,tbl, 'InputVariables', datavars, ...
      'GroupingVariables', groupvars );

   Tnan = sortrows(Tnan, groupvars);

   % if there are multiple datavars, need to get all unique nan inds
   i1 = tbl(:, groupvars);
   i2 = [];
   for i = 1:length(datavars)
      i2 = [i2; find(Tnan.(['isnan_' datavars{i} ]))];
   end
   i2 = tbl(unique(i2), groupvars);
   i3 = ismember(i1, i2);
   tbl(i3, :) = [];

   % this is how I had it with one datavar
   % i2 = unique(tbl(Tnan.(['isnan_' datavars{1} ]),groupvars));

   % if one knew the number of unique sets , they could substitue it for 8
   % icheck = sum(i3)-height(i2)*8;
   % 8 = nmethods*nderiv;
end
