function [data_out] = setval(data_in, val_or_idx_2set, set_val)
   %SETNAN Set logical indices in data array to nan.
   %
   %  [data_out] = setval( data_in,val_or_idx_2set,set_val )
   %
   % See also: setnan

   if numel(data_in) == numel(val_or_idx_2set) && islogical(val_or_idx_2set)
      % assume nanval is a logical denoting where to set data_in to set_val
      idx2set = val_or_idx_2set;
      data_out = data_in;
      if istimetable(data_out)
         nanidx = find(idx2set(:,1));
         for i = 1:height(data_out)
            if ismember(i,nanidx)
               data_out(i,:) = set_val.*table(ones);
            end
         end
      else
         data_out(idx2set) = set_val;
      end
   elseif isscalar(val_or_idx_2set)

      % assume nanval is a scalar value and I want
      val2set = val_or_idx_2set;
      validx = data_in == val2set;
      data_out = data_in;
      data_out(validx) = set_val;
   end
end
