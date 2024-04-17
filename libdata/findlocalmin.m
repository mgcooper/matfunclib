function [mininds, minvals] = findlocalmin(data, k, varargin)
   %FINDLOCALMIN Find the first k local min indices and values in data.
   %
   % optional arguments follow those of 'min' e.g. 'first','last'
   %
   % See also:

   % find all local min indices
   mininds = find(islocalmin(data));

   % if there is no local min, use the global min value
   if isempty(mininds)
      [mininds,minvals] = findmin(data,k,varargin{:});
      warning('no local minima found, using global min, check edges');
      return
   end

   [imin,minvals] = findmin(data(mininds),k,varargin{:});
   mininds = mininds(imin);

   % if no local min is found, issue error
   if isempty(mininds); error('No local min found'); end

   % if the global min is lower than the local min, use it
   globalmin = findmin(data,1);
   if all(data(globalmin)<data(mininds))
      if k==1
         mininds = globalmin;
         minvals = data(globalmin);
      elseif k>1 % add the global min to the list of mininds
         mininds = [mininds;globalmin];
         minvals = [minvals;data(globalmin)];
      end
   end

   % try
   %     mininds = find(islocalmin(indata));
   % catch ME
   %     if strcmp(ME.identifier,'')
   %         % use the global min value
   %         [mininds,minvals]  = findmin(indata,k,varargin{:});
   %         return;
   %     end
   % end

   % figure; plot(1:numel(indata),indata); hold on;
   % scatter(mininds,indata(mininds),'r','filled');
   % scatter(mininds,indata(mininds),'g','filled');
end
