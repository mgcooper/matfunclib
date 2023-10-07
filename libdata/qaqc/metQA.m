function [Flags, pctBadQA, flagTypes] = metQA(data, dataType, minLim, ...
      maxLim, rocLim, nocIgnore, noData )
   %METQA Performs a series of met data QA checks and returns flagged data.
   %Can be used with getQAlims to determine values for limits. See
   %documentation of getQAlims for description

   %   INPUTS:
   %             DATA = nxm timeseries of data, can be multi-column
   %             TYPE = 1 for incremental, 2 for cumulative values
   %             MIN_LIM = minimum acceptable value limit
   %             MAX_LIM = maximum acceptable value limit
   %             ROC_LIM = maximum acceptable rate of change
   %             NOC_IGNORE = nx1 vector of values to ignore in the
   %                             constant consecutive value flagging. For
   %                             example, the user may want to allow constant
   %                             consecutive zero values (for precipitation,
   %                             for example) or some other commonly ocurring
   %                             value.
   %             NO_DATA = known no-data value to set nan
   %
   %     OUTPUTS:
   %             FLAGS = nx6 if single column data. The data + flags
   %                             nxmx5 if multi-column input data. The data +
   %                             matrices of flags
   %             PCT_BAD = 5x1 vector of percent flagged values for each
   %                             flag type, if single column
   %                             5xm matrix of percent flagged values for each
   %                             flag type and each column of input data
   %
   %     Flag Definitions:
   %             0 = good data
   %             1 = exceeds min limit
   %             2 = exceeds max limit
   %             3 = exceeds rate of change limits
   %             4 = consecutive constant value
   %             5 = cumulative decrease e.g. for cumulative data,
   %                             value on day n+1 exceeds value on day n. Only
   %                             returned if data type = 2
   %             6 = no-data value

   %     LIMITATIONS: currently the constant consecutive value problem is hard
   %     coded to allow 2 consecutive values to pass. A good solution to
   %     locating the indices of consecutive values and determining the number
   %     of consecutive values associate with each indice eludes me. Most
   %     likely a run-length-encoding function would provide this but for now
   %     it's hard code.


   %% transpose the data if it's in row format
   numflags = 6;              % don't include the good data flag, this is used for pct_bad
   [rows,cols] = size(data);

   if cols > rows
      data = data';
      [rows,cols] = size(data);
   end

   %%

   okd_flag = 0; % good data
   min_flag = 1; % mimimum allowable value
   max_flag = 2; % maximum allowable value
   roc_flag = 3; % rate of change
   noc_flag = 4; % no change
   cud_flag = 5; % cumulative decrease
   nod_flag = 6; % no_data value such as -9999

   %% first check for the known no-data value

   nodi = data == noData;
   nod_sums = sum(nodi);
   data(nodi) = nan;
   nodi(nodi == 0) = okd_flag;
   nodi(nodi == 1) = nod_flag;
   %% exceeds minimum/maximum limit

   mini = data < minLim;     % logical is convenient, no need for loops
   min_sums = sum(mini); %
   mini(mini == 0) = okd_flag;           % reset 0's to the okd_flag
   mini(mini == 1) = min_flag;           % reset 1's to the min_flag

   maxi = data > maxLim;
   max_sums = sum(maxi(:,1:end));
   maxi(maxi == 0) = okd_flag;           % reset 0's to the okd_flag
   maxi(maxi == 1) = max_flag;           % reset 1's to the max_flag

   %% exceeds rate of change limit

   roci = NaN(rows,cols);
   roci(1,:) = 0;
   for n = 1:rows-1
      for m = 1:cols
         roc(n+1,m) = data(n+1,m) - data(n,m);    % first get the rate of change
         if roc(n+1,m) > rocLim                     % compare to the max rate of change
            roci(n+1,m) = roc_flag;             % set flag
         else
            roci(n+1,m) = okd_flag;
         end
      end
   end
   temp = roci == 3;
   roc_sums = sum(temp);

   %% no change flags
   % noci = NaN(rows,cols);
   % noci(1,:) = 0;
   % for n = 1:rows-2;
   %     for m = 1:cols;
   %         if data(n+1,m) == data(n,m) & data(n+1,m) ~= noc_ignore(:);  % consecutive value detected, doesn't equal the values the user wishes to ignore
   %             noci(n+1,m) = noc_flag;
   %             noci(n,m) = noc_flag;
   %         elseif data(n+1,m) == data(n,m) & isempty(noc_ignore);
   %             noci(n+1,m) = noc_flag;
   %             noci(n,m) = noc_flag;
   %         else
   %             noci(n+1,m) = okd_flag;                        % no consecutive value detected
   %         end
   %     end
   % end

   %%

   % Different way of no change flags that returns the actual number of
   % consecutive values and the numbers are located in the indices of the
   % original consecutive values,except the first consecutive value is ignored

   % noci = countConsecutiveValues(data,noc_ignore);

   % for now, disable this until a better solution is found
   noci = zeros(size(data));
   noci(noci >= 1) = noc_flag;

   temp = noci >= 1;
   noc_sums = sum(temp);
   %% cumulative decrease flags

   if dataType == 2

      cudi = NaN(rows,cols);
      cudi(1,:) = 0;
      for n = 1:rows-1
         for m = 1:cols
            cud(n+1,m) = data(n+1,m) - data(n,m);    % first get the rate of change
            if cud(n+1,m) < 0                           % compare to the max rate of change
               cudi(n+1,m) = cud_flag;             % set flag
            else
               cudi(n+1,m) = okd_flag;
            end
         end
      end

   else
      cudi = zeros(size(data));
   end

   temp = cudi >= 1;
   cud_sums = sum(cudi);

   %% concatenate the flag columns with the original data

   if cols == 1       % single column data, flag_data is 2d matrix

      Flags = [mini maxi roci noci cudi nodi];

   elseif cols > 1    % multi column data, flag_data is 3d matrix

      Flags = cat(3,mini,maxi,roci,noci,cudi,nodi);
   end

   %% compute the percentage of flagged values

   if cols == 1     % single column data
      for n = 1:numflags
         numbad = sum(Flags(:,n) ~= 0);
         numgood = sum(~isnan(data));
         pctBadQA(n,1) = 100*(numbad/numgood);
      end

   elseif cols > 1
      for m = 1:cols
         for n = 1:numflags
            numbad = sum(Flags(:,m,n) ~= 0);    % the total number of flags
            numgood = sum(~isnan(data(:,m)));
            pctBadQA(n,m) = 100*(numbad/numgood);
         end
      end
   end


   %% remind the user what each flag is

   flagTypes = {'1 = Exceeds Minimum Value','2 = Exceeds Maximum Value', ...
      '3 = Exceeds Maximum Rate of Change', '4 = Constant Consecutive Values', ...
      '5 = Cumulative Decrease','6 = no data value e.g. -9999'};

end
