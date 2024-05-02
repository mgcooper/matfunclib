% preserved this in readDhsvm before converting that to arguments

function [filenames, varnames, objectid] = parseinputs(args)

   % note: this is unused. the benefit to doing it this way is that an empty
   % argument can be passed in and by setting defaults empty, then while loops,
   % we can catch that case more easily

   % set defaults empty
   filenames = {};
   varnames = {};
   objectid = [];

   i=1; % one required input
   while i<nargin
      switch i
         case 1
            filenames = args{i};
         case 2
            varnames = args{i};
         case 3
            objectid = args{i};
      end
      i = i+1;
   end

   % set defaults values for empty inputs
   if isempty(filenames)
      filenames = {
         'Aggregated.Values';
         'Mass.Balance';
         'Streamflow.Only';
         'Streamflow.Only.loc';
         'Streamflow_HUC_outlet.Only'
         };
   end

   if isempty(varnames)
      % do nothing
   end

   if isempty(objectid)
      % do nothing
   end
end
